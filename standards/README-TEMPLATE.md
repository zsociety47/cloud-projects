# Project README Template

Copy everything below the line into a new project's `README.md`, then replace each `<placeholder>`. The order follows the mentorship format: video first, then the step-by-step guide with a screenshot after each step, then the technical detail for engineers.

**Repository setup:** lowercase name with hyphens (e.g. `active-directory-vm-lab`), a one-sentence description, visibility **Public**.

**Screenshots:** save them in the project's `docs/images/` folder as `step-01-<what>.png`, `step-02-<what>.png`, and so on, and link them with a relative path. Crop out email addresses and anything secret before saving.

**Before publishing:** check the page in GitHub's preview. The video link opens, every image shows, and every acronym is spelled out the first time it appears.

---

```markdown
# <Project Title>

<!-- Optional: workflow status badge -->

## 🎬 Watch Me Build This Lab!

[![Watch the video](docs/images/loom-thumbnail.png)](<loom-link>)

**Live demo:** <link, if there is one> · **Author:** Zeon Stewart, [LinkedIn](<linkedin-link>)

## At a glance

- **What it is:** <one plain sentence a recruiter can follow>
- **What's automated:** <what happens without manual steps>
- **Why it's secure:** <the main security idea, in plain words>
- **Result:** <what was proven>

Part of [Cloud Projects](https://github.com/zsociety47/cloud-projects).

---

## Project Steps

<One or two sentences: what these steps build, and what to have ready.>

### Step 1: <Action in a few words>

*Automated by `<command>` in `scripts/<script>`.*

1. <First thing to do>
2. <Next thing to do>

![<What the screenshot shows>](docs/images/step-01-<what>.png)

### Step 2: <Action in a few words>

1. <First thing to do>
2. <Next thing to do>

![<What the screenshot shows>](docs/images/step-02-<what>.png)

### Step <N>: Clean up when you're done

1. <What to delete, in order>

---

## Automated setup

### Run this as yourself

The names committed in this repository are this proof of concept. Leave them. Put your owner word in the copy you run. The sequence is the same as the [naming standard](https://github.com/zsociety47/cloud-projects/blob/main/standards/NAMING-STANDARD.md): type, project or role, environment, then **your** owner word and number on top-level names only (`rg-tf-poc-zeon01` becomes `rg-tf-poc-<yourword>01`).

| Open this | Do this |
|---|---|
| [`terraform.tfvars.example`](terraform.tfvars.example) | Copy to `terraform.tfvars` (gitignored). Replace `yourname` / `yourname01` with your owner word. Change `tags.owner`. Leave inside-the-group names (`snet-backend`, `nsg-web`). |
| [`variables.tf`](variables.tf) | Read only. These defaults are this proof. Do not edit them to match yours. |

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then the rest of Automated setup, using the names you just set. Do not copy numeric GitHub ids from this repository; ask GitHub for yours.

<Prerequisites, then one heading per action: sign in, init, plan, apply, each direct check, verify, teardown. Under each heading, say what the reader is doing and what they should see before the next command. Do not stack those commands in one block.>

---

## Architecture

<Mermaid diagram following DIAGRAM-STANDARD.md, then the "How to read this diagram" key.>

---

## Hypothesis

<One sentence: what this project sets out to prove.>

## Success criteria

| # | Criterion | How it is checked | Result |
|---|-----------|-------------------|--------|
| 1 | <criterion> | <how> | ✅ |

## What's in this repository

<File tree with one-line descriptions.>

## Security choices

- **<Choice>.** <Why.>

## Cost

<What it costs to run and the cheaper or sturdier alternatives.>

## Going further

- <Next improvement>

---

## Technical findings

*For engineers: what actually happened while building this, including the errors.*

- **<Finding>.** <The error, the cause, and the fix.>
```
