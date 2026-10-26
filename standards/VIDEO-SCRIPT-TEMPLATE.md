# Video script: <Project name>

**FLOW A: live build on camera (under 15 minutes)**  or  **FLOW B: walkthrough (build off camera first).** Keep exactly one of these two lines, right under the title, so the flow is the first thing you see.

Private file in `loom-notes/`. One per project. Follows the "Lab Video Recording Flows" guide.

## Setup
- Flow: [ ] A (build live on camera, under 15 min)  [ ] B (build off-camera first, then walk through the finished build)
- Target length: __ minutes
- Face on camera for the intro, the build or walkthrough, and the outro (screen share with voiceover alone is not enough)
- Before recording: environment built and tested, terminal font large, notifications off, secrets and subscription or tenant IDs hidden from the screen, resource group name ready for teardown
- Upload the raw video file to LinkedIn (not a Loom link); capture a still frame for the thumbnail (1920x1080 PNG, short overlay text)

## Part 1: Intro (about 60 to 75 seconds; name, goal, and problem inside the first 30)
Follow [COMMUNICATION-STANDARD.md](COMMUNICATION-STANDARD.md). The viewer should be able to answer: who, what, why it matters, how it will be proved.
Say, in your own words:
1. Your name and who you are: "Hi, I'm Zeon, a cloud and full-stack engineer."
2. What you're building in this project.
3. The business problem it solves and why that problem matters.

Draft: ...

## Part 2: The middle
**Flow A (live build):** for each step, show it, then say how it works and why you're doing it that way.
**Flow B (walkthrough):** open the finished architecture. Walk each piece, then say how it works and why it's built that way.

**File, then the portal.** For each important file, the middle has a pair of rows. The first row is the file: the setting and the name. The second row is the portal page where that same name is visible. Say the connection out loud: this line is that object.

A verify script can run, and it is not the proof the viewer sees. If the check prints a pass and nothing else, open the portal page that shows the same fact. An empty list, a refused create, and a real create are all portal shots. When a rule allows a resource, create that resource in the portal, show it, and delete it before the session ends. When a rule blocks a resource, show the portal refusing it. Show a test user by display name. Keep the sign-in name off screen when it contains the tenant domain.

Project 5 was recorded without these pairs. Leave that script as it is.

| # | Step or component | What to show | What to say (how and why) | Screenshot to grab |
|---|-------------------|--------------|---------------------------|--------------------|
| 1 | | | | |
| 2 | | | | |

Include the moment of proof: run the verification and show it passing, plus one thing that was blocked on purpose.

## Part 3: Outro (about 60 to 75 seconds)
Follow [COMMUNICATION-STANDARD.md](COMMUNICATION-STANDARD.md): recap, value, honest limit, how to repeat it, what is next.
Say:
1. The business use case this solves and why it matters.
2. What you would change or improve if you did it again.
3. Where to find the code and the written guide (the GitHub repo).

Draft: ...

## Screenshots to capture
List each filename from the README's commented-out image lines, and tick them off:
- [ ] step-01-...

## After recording
- [ ] Check the intro: name, goal and business problem within the first 30 seconds
- [ ] Watch once for exposed secrets, IDs or personal data; trim or re-record if any
- [ ] Still frame and thumbnail made
- [ ] README video link and thumbnail GIF updated; hub README row updated
- [ ] LinkedIn post drafts written from this script
