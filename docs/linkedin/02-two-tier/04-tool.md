# Post 4: Tool (Network Security Groups)

**Publish:** Thursday, October 22, 2026, 9:00 AM Eastern  
**Visual:** the database subnet NSG with `Deny-Other-Vnet` at priority 200 sitting above `AllowVnetInBound`. Use `docs/images/step-05-nsg-db.png` from [azure-two-tier-network-poc](https://github.com/zsociety47/azure-two-tier-network-poc) and save the JPEG as `04-tool.jpg`.

## Post

```text
Azure already allows every address in the VNet.

An allow rule for the web subnet does not cancel that.

I added Deny-Other-Vnet at priority 200. Then a test VM timed out on 5432.

Timeout is a pass. A fast refuse would mean the packet arrived.

If you lock a subnet, do you write the deny, or trust the default?

https://github.com/zsociety47/azure-two-tier-network-poc

#Azure #NSG #NetworkSecurity #CloudComputing #DevOps
```
