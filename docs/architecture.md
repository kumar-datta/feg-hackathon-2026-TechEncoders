# Architecture and Technical Overview

**Team:** <Team Name> · **Solution:** PSK Session Intelligence

## 1. High-level diagram

```mermaid
flowchart LR
  App[Flutter mobile app] --> API[Node and Express API]
  Web[React website] --> API
  API --> DB[(MongoDB)]
  API --> Assist[Assistant and retrieval service]
  Assist --> LLM[LLM provider]
  Logs[Event logs and trend files] --> Analysis[Python analysis scripts]
  Analysis --> Models[Intent and conversion models]
  Models --> Assist
```

## 2. Major components

| Component | Responsibility | Location |
|---|---|---|
| Mobile app | Player-facing UI and on-device assistant | `src/app/` |
| Website | Player-facing web UI | `src/web/` |
| API | Business logic and data access | `src/api/` |
| Analysis | Data cleaning, pattern mining, model training | `src/analysis/` |

## 3. Data flows

1. <Event, ingestion, feature, decision, UI>
2. <Assistant query, retrieval, response>

## 4. External dependencies

- LLM provider: <name and endpoint>
- Database: MongoDB <version>
- <Other SDKs or services>

## 5. Deployment assumptions

- Runs on a reviewer machine by following the README steps.
- <Container or cloud target for production>
- Secrets are supplied through environment variables only.

## 6. Security considerations

- No credentials in the repository. `.env` is git-ignored.
- <Authentication, input validation, rate limiting>
