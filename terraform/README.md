# Shared Terraform, grouped by cloud

Terraform is the tool that builds cloud from text files. This folder is grouped by cloud so Azure, Google Cloud, and Amazon Web Services do not share a module tree.

```text
terraform/
├── azure/     live. Modules, laptop root, and copy-ready callers
├── gcp/       empty on purpose. Google Cloud modules land here later
└── aws/       empty on purpose. Amazon Web Services modules land here later
```

| Folder | Status | Open this |
|---|---|---|
| [`azure/`](azure/) | In use | [`azure/modules/`](azure/modules/) |
| [`gcp/`](gcp/) | Not started | the README in that folder |
| [`aws/`](aws/) | Not started | the README in that folder |

Do not put an Azure file under `gcp/` or `aws/`. Do not put a Google Cloud or AWS file under `azure/`.

Azure GitHub Actions jobs are named `azure-*` in [`.github/workflows/`](../.github/workflows/), because GitHub only loads workflow files in that directory, not in subfolders.
