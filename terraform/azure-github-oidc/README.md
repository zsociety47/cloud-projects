# azure-github-oidc

One GitHub repository's identity in Azure: Entra app, two federated credentials, Reader on the shared state group, Storage Blob Data Contributor on the state account, Contributor on **that project's** resource group.

The resource group must already exist. This module does not create groups.

Numeric GitHub ids:

```bash
./scripts/oidc-ids.sh owner/name
```

The OpenID Connect subject is `repo:owner@owner-id/name@repo-id:...`, not `owner/name`.
