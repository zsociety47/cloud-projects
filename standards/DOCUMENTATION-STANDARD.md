# Documentation Standard

How every project in this portfolio is documented. This sits in `cloud-projects/standards/` next to `README-TEMPLATE.md` and `DIAGRAM-STANDARD.md`. Those two files stay the source of truth for the README layout and the diagram style. This file adds the rules around them: what gets written, when, and what "done" means.

## 1. Principles
1. **Reproducible.** A stranger can rebuild the project from the README alone, without asking me anything.
2. **Recruiter on top, engineer on the bottom.** The first screen answers "what is this and why does it matter" in 30 seconds. Technical depth lives lower down.
3. **Proof over claims.** Every success criterion is backed by a screenshot, a command output, or a `verify` result. No criterion is marked ✅ until it has actually been checked.
4. **Honest.** Failures, gotchas and what I'd change are documented. They are the most credible part.
5. **Public-safe.** No secrets, and no identifying values in text or screenshots (see section 6).

## 2. Naming and framing (public-facing text)
- Each project is my own proof of concept (PoC). Never mention a mentorship or program, and never use "Lab 01" style naming or the word "lab" in public text.
- Use the project's real name, e.g. "Secure Two-Tier Web Application on Azure". Repo names follow `azure-<topic>-poc`.
- Spell out every acronym the first time it appears in a document (for example "Network Security Group (NSG)"), including in READMEs and comments.

## 3. Files per project
Public repo:
- `README.md` (section 4)
- `docs/images/` (screenshots and the thumbnail GIF, named per section 5)
- `scripts/` or `src/` (the automation, with docstrings or header comments explaining each file)
- `.gitignore` covering keys, `.env`, virtual environments and state files
- Python projects: `requirements.txt` with pinned versions, and setup steps in the README

Private repo `loom-notes/`:
- `NN-<project>.md`: video script (from `VIDEO-SCRIPT-TEMPLATE.md`), a "Screenshots to capture" shot list, and the LinkedIn post drafts
- `NN-<project>-findings.md`: the running log from section 7

LinkedIn drafts stay in `loom-notes` (private), never in the public repo.

Hub repo `cloud-projects`: the README index row for the project (title, one-line summary, link to repo, video link, status).

## 4. README structure
Follow `standards/README-TEMPLATE.md` for the exact layout. The order is:
1. Title and build/deploy status badge
2. Video section (animated thumbnail GIF linking to the video)
3. **At a glance**: what it is, the business problem, the result, tools used (recruiter-friendly)
4. **Project steps**: the manual walkthrough, numbered. Every step has an "Automated by ..." line pointing to the script or function that does it, and a screenshot slot
5. **Automated setup**: prerequisites, setup, deploy, verify, teardown commands, copy-pasteable
6. **Architecture**: Mermaid diagram plus a "How to read this diagram" key
7. **Hypothesis**
8. **Success criteria**: a checklist, each ✅ tied to evidence
9. **Repository contents**: a short tree with one line per file
10. **Security**: what is exposed, what is not, and why
11. **Cost**: what it costs to run and how long it takes to tear down
12. **Going further**: what I'd improve or build next
13. **Technical findings**: every gotcha, with the error text, the cause and the fix

If the video was recorded before a README restructure, add a one-line note under the video saying the layout has changed.

## 5. Screenshots
- Save to `docs/images/` as `step-NN-short-description.jpg` (or `.png`).
- Until a screenshot exists, leave its image line commented out (`<!-- ... -->`) and list the filename in the `loom-notes` shot list. Never ship a broken image link.
- Every screenshot has alt text describing what it proves.
- Crop to the relevant part. Redact first (section 6).

## 6. Public-safety checklist (run before every commit)
- No passwords, keys, tokens, connection strings or `.pem`/`.key` files, in the repo or in screenshots.
- No subscription IDs, tenant IDs, personal email addresses or public IP addresses I don't intend to share. Client IDs and resource names are fine only if the app registration is deleted or the value is not a secret.
- Placeholders in docs use `<your-value>` style. Example values are clearly examples.
- Scan the diff for secrets before asking me to approve a commit.

## 7. Document as you go
- After each build phase, append to the findings log: what I did, what failed (exact error text), the cause, the fix.
- Do not reconstruct the findings from memory at the end. Gotchas found during the build are the content that makes the project credible.
- At the end of each phase, update the README step for that phase and mark which screenshots are still needed.

## 7b. Video script
- Every project gets a video script written from `standards/VIDEO-SCRIPT-TEMPLATE.md` before recording, stored in `loom-notes/`.
- The script follows the recording guide: face on camera throughout; intro (name, what I'm building, business problem, within 30 seconds); middle by flow (A: build live under 15 minutes; B: build off-camera, then walk through the finished architecture); outro (business use case, what I'd change).
- The script includes the proof moment (verification passing, plus something blocked on purpose) and the screenshot shot list.
- After recording, check the video against the script and the public-safety checklist before it goes anywhere.

## 8. Code documentation
- Every script or module starts with a docstring or header comment: what it does, inputs, outputs, side effects (what it creates or deletes in Azure).
- Functions that call Azure explain why, not just what.
- Teardown always lists what it will delete and requires typing the resource group name.
- Error messages say what happened and what to do next, in plain language.

## 9. Diagrams
Follow `standards/DIAGRAM-STANDARD.md`. Mermaid in the README. Diagrams show the real build, including trust boundaries (what is public, what is private) and the direction of allowed traffic. The same diagram is exported as an image for the LinkedIn architecture post.

## 10. Definition of done
A project is not done until all of these are true:
- [ ] README follows the structure in section 4, with no placeholder text except the deliberate `LINKEDIN_LINK_HERE`
- [ ] Every success criterion has evidence and is checked ✅ only after verification
- [ ] A clean-slate test: the README's commands were followed from scratch (or by a fresh copy of the repo) and worked
- [ ] Technical findings section is filled in from the running log
- [ ] Screenshots are captured, redacted and linked (or consciously deferred and listed)
- [ ] Public-safety checklist passed
- [ ] Hub README row added or updated
- [ ] Video script (from the template) and shot list exist in `loom-notes`, and the recorded video was checked against them
- [ ] Teardown tested and the resource group is gone
