# Mandatory Submission Checklist

- [ ] Private repository link submitted
- [ ] Required T-Hub and FEG reviewer accounts granted read-level access, ownership not transferred
- [ ] Submitted commit or version is identifiable, hash recorded in the README
- [ ] README.md is complete and reproducible by a technically competent reviewer
- [ ] Working source or prototype is present in `src/`
- [ ] No secrets, credentials or prohibited data are committed
- [ ] docs/impact-case.md completed
- [ ] docs/compliance-note.md completed
- [ ] docs/architecture.md included
- [ ] docs/dependencies.md discloses third-party components and licences
- [ ] AI and code-assistance disclosure completed where materially applicable
- [ ] Demo video, screenshots or deck included where required
- [ ] Team members, Team Lead and ownership information provided
- [ ] Submission form or email completed with the repository link and required declarations

## Recommended final repository check

1. Clone the repository into a clean folder or a fresh environment.
2. Follow the README from start to finish without relying on undocumented local files.
3. Confirm the application starts and the core demo flow works.
4. Check that all required dependencies are declared.
5. Search the repository for accidental secrets or credentials.
6. Verify that no prohibited or confidential data has been committed.
7. Verify that all required documentation files are present.
8. Confirm reviewer access works before the submission deadline.
9. Record the final commit hash and keep an internal copy of the submitted state.

## Secret scan

```bash
git grep -inE "api.?key|password|secret|token|bearer" -- . ":(exclude).env.example"
```
