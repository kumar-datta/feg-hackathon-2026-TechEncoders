# FEG Hackathon 2026 — <Team Name>

**Team:** <Team Name>
**Challenge:** Challenge 1 — Session Conversion (turn more PSK visits into completed actions, without pushing anyone)
**Solution title:** PSK Session Intelligence

---

## 1. Team, challenge and solution title

| Item | Value |
|---|---|
| Team name | <TechEncoders|
| Team Lead | <P.Srivatsav Reddy,poreddy.reddy@research.iiit.ac.in> |
| Team members | Kumar datta ,Chakri|
| Challenge entered | Challenge 1 — Session Conversion |
| Solution title | PSK Session Intelligence |
| Submitted commit | `<commit hash — record at freeze>` |

## 2. Problem statement

PSK customers open the app four to six times a day, but only about one visit in three ends with a bet placed or a game opened. Users are already engaged; they are simply not finishing. The brief names two causes: people cannot find what suits them, and people one tap from betting still walk away.

## 3. Solution overview and key innovation

<One or two paragraphs. What the prototype does, what is new about it, and why it answers the challenge without pressuring the player.>

Key innovation:
- <Innovation 1>
- <Innovation 2>

## 4. Key features / user journey

1. <Step the user takes>
2. <What the system does>
3. <Outcome / completed action>

## 5. Technology stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter / Dart |
| Web | React, Node.js, Express, MongoDB |
| Analysis | Python 3.11, pandas, numpy, scikit-learn, openpyxl |
| Assistant / ML | <models, on-device retrieval, etc.> |

## 6. System requirements and prerequisites

- OS: Windows 10/11, macOS 13+, or Ubuntu 22.04+
- <Flutter 3.x SDK> / <Node.js 20 LTS> / <Python 3.11>
- <Any other tooling: Android Studio, Xcode, Docker>

## 7. Installation / setup steps

```bash
git clone <private-repo-url>
```

```bash
npm install
```

## 8. Environment variables and configuration

Copy `.env.example` to `.env` and fill in the values. Never commit `.env`.

| Variable | Purpose | Required |
|---|---|---|
| `PORT` | Server port | No, defaults to 5959 |
| `MONGODB_URI` | Database connection string | Yes |
| `LLM_API_KEY` | Assistant provider key | Yes |

Non-secret configuration templates live in `config/`.

## 9. How to run the prototype

```bash
npm run dev
```

Then open http://localhost:5959.

## 10. How to test / validate the prototype

```bash
npm test
```

Validation scripts live in `tests/`. <Describe what each one verifies.>

## 11. Demo instructions / demo flow

1. <Open the app, land on Home>
2. <Trigger the feature>
3. <Show the completed action>

Demo video link: see [demo/demo-video-link.md](demo/demo-video-link.md). Screenshots are in `demo/screenshots/`, the deck in `demo/presentation/`.

## 12. Known limitations, assumptions and future improvements

**Limitations**
- <For example, trained on August 2026 event logs from 113 top users, not representative of all customers>

**Assumptions**
- <For example, Android rejected or system-closed bet events are a client defect rather than hesitation>

**Future improvements**
- <For example, use odds-movement data to detect hesitation caused by price changes>

## 13. Links to required documents

- [Architecture](docs/architecture.md)
- [Impact case, D3](docs/impact-case.md)
- [Compliance note, D4](docs/compliance-note.md)
- [Dependency disclosure](docs/dependencies.md)

## AI and code-assistance disclosure

<State which generative AI or code-assistant tools were used, for what, and confirm the team reviewed and takes responsibility for all output. Remove this section if not applicable.>

## Licence

See [LICENSE](LICENSE).
