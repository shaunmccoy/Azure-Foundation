# Test VMs

Deploys one Ubuntu and one Windows Server VM into a chosen subnet for testing routing, DNS,
proxy and firewall behaviour, plus an optional Azure AI services account behind a private
endpoint as a private-link test target. Destroy the deployment when testing is finished.

The Linux VM installs `net-tools`, `curl`, `traceroute`, `iperf3` and `dnsutils` at first boot;
output is in `/var/log/cloud-init-output.log`.

To run iperf3 as a server on a port:

```bash
iperf3 -s -p 5201
```

## Credentials

Nothing is passed in or printed. Terraform generates the Linux SSH key pair and the Windows
administrator password and stores them in the hub INFRA Key Vault; the secret names are in the
`credential_secret_names` output.

## Files

| File | Purpose |
| --- | --- |
| `main.tf` | Resource group, NSG and the two test VMs |
| `cognitive.tf` | Optional private-link test target |
| `templates/debian_init.sh.tftpl` | First-boot script for the Linux VM |
| `variables.tf` | Config-specific inputs |
| `outputs.tf` | Addresses and secret names |
