/**
 * ingest.js — loads the datasets and builds the runtime indexes.
 *
 * Applies the per-type chunking strategy from docs/02-metadata.md:
 *   FAQ            -> one chunk per Q&A pair, never split
 *   game knowledge -> split on semantic section, glossary kept whole
 *   policy         -> whole record (placeholders today)
 *   help article   -> sliding window with overlap
 *   entity         -> one synthetic alias sentence, to aid semantic recall
 */
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { loadEntities } from './resolver.js';
import { buildIndex } from './retriever.js';
import { describeMode } from './config.js';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const DATA = path.resolve(HERE, '../../../ai-assistant/data');

async function readJson(rel, fallback = []) {
  try {
    return JSON.parse(await fs.readFile(path.join(DATA, rel), 'utf-8'));
  } catch (err) {
    console.warn(`[assistant] could not read ${rel}: ${err.message}`);
    return fallback;
  }
}

/** Sliding window over sentences, with overlap, for long prose. */
function windowSections(sections, targetWords = 120, overlapWords = 20) {
  const text = sections.map((s) => s.text).join(' ');
  const words = text.split(/\s+/).filter(Boolean);
  if (words.length <= targetWords) {
    return [{ text, section: sections.map((s) => s.section).join('+') }];
  }

  const out = [];
  let i = 0;
  while (i < words.length) {
    const slice = words.slice(i, i + targetWords);
    out.push({ text: slice.join(' '), section: `window_${out.length + 1}` });
    if (i + targetWords >= words.length) break;
    i += targetWords - overlapWords;
  }
  return out;
}

export async function ingest() {
  const [entities, aliases, faq, games, policies, help] = await Promise.all([
    readJson('navigation/entities.json'),
    readJson('navigation/aliases.json'),
    readJson('rag/faq.json'),
    readJson('rag/game_knowledge.json'),
    readJson('rag/policies.json'),
    readJson('rag/help_articles.json'),
  ]);

  if (!entities.length) {
    console.warn('[assistant] no entities found — navigation will not work. '
      + 'Run the generators in ai-assistant/tools first.');
  }

  loadEntities(entities, aliases);

  const chunks = [];

  // ---- FAQ: atomic Q&A pairs ----
  for (const f of faq) {
    chunks.push({
      chunk_id: f.id,
      document_id: f.id,
      title: f.question,
      content: f.answer,
      category: f.category,
      document_type: 'FAQ',
      keywords: f.keywords || [],
      related_pages: f.related_pages || [],
      priority: f.priority,
      requires_verified_source: Boolean(f.requires_verified_source),
    });
  }

  // ---- game knowledge: one chunk per semantic section ----
  for (const g of games) {
    const base = {
      document_id: `doc_${g.game_id}`,
      category: 'GAMES',
      document_type: 'GAME_KNOWLEDGE',
      game_id: g.game_id,
      related_pages: [],
      priority: 'high',
      requires_verified_source: false,
    };

    if (g.description) {
      chunks.push({ ...base, chunk_id: `doc_${g.game_id}__overview`,
        title: `${g.name} — Overview`, content: g.description });
    }
    if (g.how_to_play) {
      chunks.push({ ...base, chunk_id: `doc_${g.game_id}__howto`,
        title: `${g.name} — How to play`, content: g.how_to_play });
    }
    if (g.basic_rules) {
      chunks.push({ ...base, chunk_id: `doc_${g.game_id}__rules`,
        title: `${g.name} — Rules`, content: g.basic_rules });
    }
    if (g.terminology?.length) {
      chunks.push({ ...base, chunk_id: `doc_${g.game_id}__terms`,
        title: `${g.name} — Terminology`,
        content: g.terminology.map((t) => `${t.term}: ${t.definition}`).join(' ') });
    }
    for (const [i, qa] of (g.common_questions || []).entries()) {
      chunks.push({ ...base, chunk_id: `doc_${g.game_id}__q${i + 1}`,
        title: `${g.name} — ${qa.q}`, content: qa.a });
    }
    if (g.responsible_gaming_note) {
      chunks.push({ ...base, chunk_id: `doc_${g.game_id}__rg`,
        title: `${g.name} — Responsible gaming`, content: g.responsible_gaming_note,
        related_pages: ['page_responsible_gaming'] });
    }
  }

  // ---- policies: whole record, flagged ----
  for (const p of policies) {
    chunks.push({
      chunk_id: p.id,
      document_id: p.id,
      title: p.title,
      content: p.content === '[REPLACE WITH ACTUAL COMPANY POLICY]'
        ? `${p.title}: the published policy covers ${p.summary_of_what_belongs_here || 'this topic'}. `
          + 'The specific terms are on the official policy page.'
        : p.content,
      category: p.category,
      document_type: 'POLICY',
      keywords: [],
      related_pages: ['page_rules', 'page_contact'],
      priority: 'medium',
      requires_verified_source: true,
    });
  }

  // ---- help articles: sliding window ----
  for (const h of help) {
    const wins = windowSections(h.sections || []);
    wins.forEach((wdw, i) => {
      chunks.push({
        chunk_id: `${h.document_id}__c${i + 1}`,
        document_id: h.document_id,
        title: `${h.title}${wins.length > 1 ? ` (${i + 1}/${wins.length})` : ''}`,
        content: wdw.text,
        category: h.category,
        document_type: 'HELP_ARTICLE',
        keywords: [],
        related_pages: [],
        priority: 'medium',
        requires_verified_source: wdw.text.includes('[REQUIRES VERIFIED SOURCE]'),
      });
    });
  }

  // ---- entity alias sentences: recall aid only, truth stays in the registry ----
  for (const e of entities) {
    const alt = (e.aliases || []).slice(0, 8).join(', ');
    chunks.push({
      chunk_id: `doc_entity_${e.id}`,
      document_id: `doc_entity_${e.id}`,
      title: `${e.name} (${e.type})`,
      content: `${e.name} is ${e.description} It is in the ${e.category} section. `
        + (alt ? `It is also called: ${alt}.` : ''),
      category: 'NAVIGATION',
      document_type: 'ENTITY_ALIAS',
      keywords: e.keywords || [],
      related_pages: [e.id],
      priority: 'low',
      requires_verified_source: false,
    });
  }

  const stats = await buildIndex(chunks);

  console.log('[assistant] ready');
  console.log(`[assistant]   mode:     ${describeMode()}`);
  console.log(`[assistant]   entities: ${entities.length}, aliases: ${aliases.length}`);
  console.log(`[assistant]   chunks:   ${stats.chunks} (vector: ${stats.vectorMode})`);

  return { entities: entities.length, aliases: aliases.length, ...stats };
}

export default ingest;
