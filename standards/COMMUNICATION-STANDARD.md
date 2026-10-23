# Communication standard: videos and LinkedIn posts

Applies to every project, in every cloud, from now on. The goal: a viewer finishes the intro or the post and has almost no questions left about what was built, why it matters, and how to do it themselves.

Voice: plain, a little playful, like explaining it to a friend over coffee. Short sentences. Spell out every acronym the first time it appears ("role-based access control (RBAC)"), then use the short form. Explain each tool in one sentence a non-specialist could repeat. Prefer a concrete picture (a mail room, a smoke detector) over a definition. No hype words.

## Test before publishing

After the intro or the post, can a stranger answer these without watching further?

1. Who made this, and what is it?
2. What problem does it solve, and who has that problem?
3. What goes wrong without it?
4. How does it work, in one sentence?
5. What will I see, or what was the proof?
6. What are its limits?
7. How do I repeat it, and what do I need first?

If any answer is missing, add a sentence. Do not cut the answer to hit a time target.

## Video intro (about 60 to 75 seconds)

1. Hook with the problem as a scene (0:00 to 0:15).
2. Name, role, and the goal, still inside the first 30 seconds.
3. What the build contains, in two to four named parts, each with a one-sentence explanation.
4. How it is built (the tool, in one sentence) and why that matters.
5. What the viewer will see, including one thing blocked on purpose.
6. Then show the architecture picture before any command.

## Video outro (about 60 to 75 seconds)

1. Recap the build in one sentence.
2. Value: who benefits, and which failure it prevents.
3. An honest limit: what it does not do.
4. How to repeat it: prerequisites, the order, the check, the teardown.
5. What you would change, and what comes next in the series.
6. Where the code and the written guide are.

## LinkedIn post (video post about 110 words; every other post about 75 words or fewer)

1. Hook: one or two lines that stand alone.
2. What it is, in plain words, with any tool explained.
3. How it works, with a picture or a comparison.
4. The proof, or the specific number from the build.
5. Why it matters, and an honest limit if there is one.
6. How to repeat it: what you need.
7. One real question, then the repository link, then five hashtags.

Length: the video post is the longest and stays near 110 words (about 700 characters). GitHub, architecture, and tool posts stay near 75 words or fewer (about 450 characters), closer to the first two projects' posts. The picture and the video carry the detail; the post gives the hook, one plain explanation, one proof, one question, the link. If a draft runs over, cut the "how to repeat it" paragraph first, then the second explanation, and keep the proof.

Rules: every number comes from the build. No claim the project did not prove. No Loom link. The link stays in the post. Check each acronym is spelled out once.

## Images

One image per post, 1200 by 627, made to show one fact from that post. Never stock photos, vendor diagrams, or other people's screenshots.

- Same system for the whole series: a small badge with the project number and name, one accent color per project, and a footer line.
- Rotate the style by post type so the feed does not go flat: video is a bold statement or a still of you on camera, GitHub is a terminal or real output, architecture is a light diagram, tool is a dark card with one number or one comparison.
- Alternate light and dark across a week. Do not post two dark cards back to back.
- Every image carries something the viewer can check: a count, a status line, a denied size, a role name.
- Big type, few words. It must read on a phone.
- No subscription IDs, sign-in names, or alert addresses in any frame.
- Cards are generated from `loom-notes/tools/make-cards.py`, so a redesign is one edit.

## Private versus public

Scripts and drafts live in `loom-notes`. Nothing public mentions where the project idea came from.
