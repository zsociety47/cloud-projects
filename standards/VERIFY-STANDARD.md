# Verify Standard

How every project proves its build with a script, not only a screenshot. This sits in `cloud-projects/standards/` next to `README-TEMPLATE.md` and `DOCUMENTATION-STANDARD.md`. A screenshot shows what a page looked like. A script reads the live cloud and says PASS or FAIL, so it catches the thing you did not look at.

Started from project 6 (AWS to Azure migration), which had one script, `verify-aws.sh`, and nothing for the Azure side, the migration, or teardown.

## 1. What gets a script

Script the major steps, not every step.

- **One script per apply**, for each Terraform root or environment: `scripts/verify-aws.sh`, `scripts/verify-azure.sh`, and so on. It checks that what the root declared now exists with the right size, name, tags, and firewall rules.
- **One script for the end state** when the project has a service milestone that Terraform does not create (a migration, a pipeline run, a backup, a policy that denies). Name it for the result: `scripts/verify-migration.sh`. Read the service's API with `az rest`, `aws`, or `gcloud`, so you poll the state and do not stare at a page.
- **One teardown script**: `scripts/verify-teardown.sh`. It proves nothing billable is left (groups gone, instances terminated, every Terraform state empty, any setting you changed is back).
- Portal-only steps with no API stay manual checks in the README. Say so.

## 2. The run-all script

`scripts/verify-all.sh` runs the per-apply scripts in order, then the end-state script, after everything is up and running. It keeps going when one fails, prints one summary line per script, and exits 1 if any failed. `verify-teardown.sh` is separate, because after teardown the other scripts are supposed to fail.

```bash
./scripts/verify-all.sh      # everything up: apply checks, then the end state
./scripts/verify-teardown.sh # after destroy: nothing billable left
```

## 3. The script contract

Every verify script:

1. Starts with a header comment: what it reads, what it needs (signed-in CLI, region), what it prints, and "Side effects: none".
2. Is read-only. It never creates, changes, or deletes anything.
3. Prints one numbered line per check: `03  Remote Desktop only from one /32: PASS` or `FAIL`. A FAIL line names what it expected and what it found.
4. Exits 0 when every check passes and 1 otherwise.
5. Never prints a public address, account id, subscription id, tenant id, email, key, or password. Compare them inside the script and print only PASS or FAIL.
6. Keeps the names and expected values in variables at the top, with the project's default names, so a reader swaps `zeon` for their short name in one place.
7. Is Bash for simple CLI reads and Python when it has to parse JSON. Both are fine. Keep it under about 150 lines. Split it if it grows.
8. Says what it could not check. A check that cannot run (no permission, service not ready) prints `SKIP` with the reason and does not count as a pass.

Skeleton:

```bash
#!/bin/bash
# Reads the live <cloud> side of <project> and prints PASS or FAIL per check.
# Needs: signed-in CLI. Output: numbered lines. Exit 0 if all pass, 1 otherwise.
# Side effects: none. Does not print addresses, account ids, or passwords.
set -u
set -o pipefail

expected_name="vm-example-zeon"   # change zeon to your short name
failed=0
pass() { printf '%s  %s: PASS\n' "$1" "$2"; }
fail() { printf '%s  %s: FAIL (expected %s, found %s)\n' "$1" "$2" "$3" "$4"; failed=1; }

live="$(az vm show -g rg-example-zeon01 -n "$expected_name" --query name -o tsv 2>/dev/null || true)"
[[ "$live" == "$expected_name" ]] && pass 01 "VM exists" || fail 01 "VM exists" "$expected_name" "${live:-nothing}"

exit "$failed"
```

## 4. Where it appears in the project

- **README**: each Terraform apply step ends with a **Check** line naming its script. The Automated setup section has a **Verify** subsection that runs `verify-all.sh`. The teardown step runs `verify-teardown.sh`.
- **Screenshots**: take the shot after the script passes. When a screenshot is the only proof of a step, say so in the findings.
- **Success criteria**: a criterion "How it is checked" cell names the script and its check number when one covers it.
- **Video script**: the Flow C walkthrough can show the script output as a captured shot. Say that it is saved output, not a live run.
- **What's in this repository**: list each script with one line, like `verify-aws.sh`.

## 5. Lessons log

The project's lessons file gets a "Checks to script next time" table for any project built before this standard. Project 6 is the first.
