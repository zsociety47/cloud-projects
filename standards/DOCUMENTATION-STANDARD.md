# Documentation Standard

How every project in this portfolio is documented. This sits in `cloud-projects/standards/` next to `README-TEMPLATE.md` and `DIAGRAM-STANDARD.md`. Those two files stay the source of truth for the README layout and the diagram style. This file adds the rules around them: what gets written, when, and what "done" means.

## 1. Principles
1. **Reproducible.** A stranger can rebuild the project from the README alone, without asking me anything. Automated setup starts with **Run this as yourself** (section 4a): a table of linked files that says which name slot to replace. Defaults in code stay this proof of concept. Videos are not reshot for that paragraph.
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

Private repo `loom-notes/`, grouped by project:

- `scripts/NN-<project>/script.md`: video script from `VIDEO-SCRIPT-TEMPLATE.md`, including the shot list
- `notes/NN-<project>/findings.md`: the running log from section 7
- `linkedin/NN-<project>/`: the LinkedIn post drafts (`01-video.md`, `02-github.md`, `03-architecture.md`, `04-tool.md`)

LinkedIn drafts stay in `loom-notes` (private), never in the public repo.

Hub repo `cloud-projects`: the README index row for the project (title, one-line summary, link to repo, video link, status).

## 4. README structure
Follow `standards/README-TEMPLATE.md` for the exact layout. The order is:
1. Title and build/deploy status badge
2. Video section (animated thumbnail GIF linking to the video)
3. **At a glance**: what it is, the business problem, the result, tools used (recruiter-friendly)
4. **Project steps**: the manual walkthrough, numbered. Every step has an "Automated by ..." line pointing to the script or function that does it, and a screenshot slot
5. **Automated setup**: **Run this as yourself** first (section 4a), then prerequisites, setup, deploy, verify, teardown commands, copy-pasteable
6. **Architecture**: Mermaid diagram plus a "How to read this diagram" key
7. **Hypothesis**
8. **Success criteria**: a checklist, each ✅ tied to evidence
9. **Repository contents**: a short tree with one line per file
10. **Security**: what is exposed, what is not, and why
11. **Cost**: what it costs to run and how long it takes to tear down
12. **Going further**: what I'd improve or build next
13. **Technical findings**: every gotcha, with the error text, the cause and the fix

If the video was recorded before a README restructure, add a one-line note under the video saying the layout has changed.

## 4a. Run this as yourself

This heading is required in Automated setup on every project, including Azure 8 and 9 and every later cloud. It is how another person produces the same build under their own names. Do not skip it, and do not put the deploy commands above it.

Required shape, in this order:

1. One short paragraph that says the names in this repository are the author's own proof of concept, to leave them alone, and to swap only the short name and number in the copy they run (`zeon01` → `ada01`). Link [NAMING-STANDARD.md](NAMING-STANDARD.md).
2. A table. The first column is a relative markdown link to the file they open. The second column is the action: copy this to that, change these keys. Every file they must touch has a row.
3. A copy-paste command when the override is a file (`cp terraform.tfvars.example terraform.tfvars`).
4. Then the rest of Automated setup, using the names they just set.

How the override is supplied, by project type:

| Project type | What they open | What they run |
|---|---|---|
| Terraform | `terraform.tfvars.example` | Copy to `terraform.tfvars` (gitignored). Defaults in `variables.tf` stay this proof. |
| Python | `src/lib/config.py` | Change the listed constants in their copy. Keep any guest script that repeats a globally unique name in step. |
| Shell | the deploy script, or `.env.example` | Pass a suffix, or copy `.env.example` to `.env`. |

Do not rewrite committed defaults to `yourname`. The video, the screenshots, and this proof keep `zeon01`. A later operator changes the copy they run, not the published evidence.

Azure projects 1 through 6 already have this table. Copy that shape; do not invent a new one.

## 5. Screenshots
- Save to `docs/images/` as `step-NN-short-description.jpg` (or `.png`).
- Until a screenshot exists, leave its image line commented out (`<!-- ... -->`) and list the filename in the `loom-notes` shot list. Never ship a broken image link.
- Every screenshot has alt text describing what it proves.
- Crop to the relevant part. Redact first (section 6).

### First running pass
The first time a project is applied, capture the shot list for that pass before teardown. A screen that only exists while the resources are on (a running machine, a firewall rule, a portal page, a quota page) is photographed then. Do not destroy that pass and rebuild later only to take the pictures.

The private shot list is the checklist for the pass. Before teardown, every row that this pass can prove is either captured or marked with the reason it could not be taken. A row left as "Missing" after the resources are gone means the pass failed this rule.

When a later change makes a shot show the wrong fact, replace that file and update the shot-list status. Shots the change did not affect stay. The README keeps the commented line until the replacement file exists. Replacing a shot is expected. Rebuilding a whole project because the first pass was never photographed is the waste this rule prevents.

## 6. Public-safety checklist (run before every commit)
- No passwords, keys, tokens, connection strings or `.pem`/`.key` files, in the repo or in screenshots.
- No subscription IDs, tenant IDs, personal email addresses or public IP addresses I don't intend to share. Client IDs and resource names are fine only if the app registration is deleted or the value is not a secret.
- Placeholders in docs use `<your-value>` style. Example values are clearly examples.
- Scan the diff for secrets before asking me to approve a commit.

## 7. Document as you go
- After each build phase, append to the findings log: what I did, what failed (exact error text), the cause, the fix.
- Do not reconstruct the findings from memory at the end. Gotchas found during the build are the content that makes the project credible.
- At the end of each phase, update the README step for that phase. Capture the screenshots that phase made possible before anything from that phase is destroyed. Mark any shot that is still impossible, and why.

## 7c. Compared with the previous project

After the design lock of each new project, write a private comparison in `loom-notes/notes/compared-across-projects.md` and a short pointer in that project's `findings.md`. Cover:

1. **The idea.** What the previous project still forced you to run or trust, and what this one hands to the platform.
2. **Architecture.** Compute, data store, how access is granted, where secrets live, regions, number of machines.
3. **Automation.** What reused the previous skeleton (`config`, clients, helpers, deploy / verify / teardown), which new clients or guest files appeared, and any change to deploy order.
4. **Verify.** How the pass table changed, especially the blocked-on-purpose row.
5. **Teardown.** Anything beyond deleting the resource group.

The public README stays self-contained. It does not say "previous project" or use the word lab.

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
- [ ] **Run this as yourself** lists every file a later operator must change, each as a relative link, and says which slot of the name to replace (`zeon01` → their short name and number)
- [ ] Every success criterion has evidence and is checked ✅ only after verification
- [ ] A clean-slate test: the README's commands were followed from scratch (or by a fresh copy of the repo) and worked
- [ ] Technical findings section is filled in from the running log
- [ ] Screenshots from the first running pass are captured, redacted, and linked. A shot is deferred only when that pass could not show it, and the shot list says why. Shots replaced after a later change are the current files.
- [ ] Public-safety checklist passed
- [ ] Hub README row added or updated
- [ ] Video script (from the template) and shot list exist in `loom-notes`, and the recorded video was checked against them
- [ ] Teardown tested and the resource group is gone
