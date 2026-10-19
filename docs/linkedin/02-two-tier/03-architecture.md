# Post 3: Architecture diagram

**Publish:** Wednesday, October 21, 2026, 9:00 AM Eastern  
**Visual:** export of the README architecture diagram, following the [diagram standard](https://github.com/zsociety47/cloud-projects/blob/main/standards/DIAGRAM-STANDARD.md). Highlight the `TCP 5432 denied` arrow from `vm-test-01` to `vm-db-01`. Save as `03-architecture.jpg`.

## Post

```text
Solid line: the browser reaches nginx.
Solid line: the web subnet reaches PostgreSQL.
The other solid line is the one that should fail.

A test VM in the same VNet hits the deny at priority 200.

The database VM has no public IP. Outbound packages go through NAT.

Which line would you draw first: the allow, or the deny?

https://github.com/zsociety47/azure-two-tier-network-poc

#Azure #VirtualNetwork #NSG #CloudComputing #DevOps
```
