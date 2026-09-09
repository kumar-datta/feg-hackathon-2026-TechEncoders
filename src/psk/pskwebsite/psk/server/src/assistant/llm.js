/**
 * llm.js — thin multi-provider adapter.
 *
 * Every call degrades gracefully: if the provider is unreachable, rate-limited
 * or unconfigured, the caller receives null and falls back to the deterministic
 * path rather than failing the request.
 */
import config from './config.js';

const TIMEOUT_MS = 20000;

async function post(url, headers, body) {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), TIMEOUT_MS);
  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...headers },
      body: JSON.stringify(body),
      signal: ctrl.signal,
    });
    if (!res.ok) {
      const text = await res.text().catch(() => '');
      console.warn(`[assistant] ${config.providerName} ${res.status}: ${text.slice(0, 200)}`);
      return null;
    }
    return await res.json();
  } catch (err) {
    console.warn(`[assistant] ${config.providerName} request failed: ${err.message}`);
    return null;
  } finally {
    clearTimeout(timer);
  }
}

/**
 * Generate a chat completion.
 * @returns {Promise<string|null>} the text, or null if unavailable
 */
export async function chat({ system, messages, temperature = 0.2, maxTokens }) {
  if (!config.enabled) return null;
  const p = config.provider;
  const model = config.chatModel;
  const limit = maxTokens || config.maxTokens;

  if (p.style === 'openai') {
    const data = await post(
      config.baseUrl + p.chatPath,
      p.authHeader(config.apiKey),
      {
        model,
        messages: [{ role: 'system', content: system }, ...messages],
        temperature,
        max_tokens: limit,
      }
    );
    return data?.choices?.[0]?.message?.content?.trim() || null;
  }

  if (p.style === 'anthropic') {
    const data = await post(
      config.baseUrl + p.chatPath,
      p.authHeader(config.apiKey),
      { model, system, messages, temperature, max_tokens: limit }
    );
    const block = data?.content?.find((c) => c.type === 'text');
    return block?.text?.trim() || null;
  }

  if (p.style === 'google') {
    const path = p.chatPath.replace('{model}', model);
    const url = `${config.baseUrl}${path}?key=${encodeURIComponent(config.apiKey)}`;
    const contents = messages.map((m) => ({
      role: m.role === 'assistant' ? 'model' : 'user',
      parts: [{ text: m.content }],
    }));
    const data = await post(url, {}, {
      contents,
      systemInstruction: { parts: [{ text: system }] },
      generationConfig: { temperature, maxOutputTokens: limit },
    });
    return data?.candidates?.[0]?.content?.parts?.[0]?.text?.trim() || null;
  }

  return null;
}

/**
 * Embed a batch of strings.
 * @returns {Promise<number[][]|null>} vectors, or null if unavailable
 */
export async function embed(texts) {
  if (!config.embeddingsEnabled || !texts.length) return null;
  const p = config.provider;
  const model = config.embedModel;

  if (p.style === 'openai') {
    const data = await post(
      config.baseUrl + p.embedPath,
      p.authHeader(config.apiKey),
      { model, input: texts }
    );
    if (!data?.data) return null;
    return data.data
      .sort((a, b) => a.index - b.index)
      .map((d) => d.embedding);
  }

  if (p.style === 'google') {
    // one request per text; the batch endpoint differs across API versions
    const out = [];
    for (const text of texts) {
      const path = p.embedPath.replace('{model}', model);
      const url = `${config.baseUrl}${path}?key=${encodeURIComponent(config.apiKey)}`;
      const data = await post(url, {}, {
        model: `models/${model}`,
        content: { parts: [{ text }] },
      });
      const vec = data?.embedding?.values;
      if (!vec) return null;
      out.push(vec);
    }
    return out;
  }

  return null;
}

export default { chat, embed };
