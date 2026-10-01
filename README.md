# 🦅 Shaheen ReconX
**Advanced Reconnaissance Turned Simple (ARTS)**

Shaheen ReconX is a lightweight Bash automation script that simplifies the first phase of bug bounty / attack-surface reconnaissance: **subdomain enumeration and live-host discovery**. One command, one organized workspace, and a clean list of responsive hosts ready for deeper enumeration.

Created by **Syed Bukhari (@0xTheFalcon)** — Version 1.2.1

---

## ✨ Features

- 🕵️ **Passive subdomain enumeration** via [Subfinder](https://github.com/projectdiscovery/subfinder) (`-all` mode)
- ☁️ **Cloud-provider subdomain harvesting** via [Kaeferjaeger.gay](https://kaeferjaeger.gay) (using cloudrecon)
- 🔗 **Automatic merge & deduplication** of all sources into a single master list
- ❤️ **Live host probing** with [httprobe](https://github.com/tomnomnom/httprobe) (HTTPS preferred, extra ports: `8008, 8080, 8081, 8089, 8443, 8843, 5000, 9001`)
- 📊 **Summary stats** — unique finds per source, total hosts, alive hosts
- 🧠 **Interactive workflow** — pauses before probing so you can review your subdomain list first, and can skip re-enumeration if a list already exists
- 🗂️ **Organized workspaces** — results are stored under `~/Targets/<folder>/<filename>/`
- ⏱️ **Runtime tracking** with a formatted elapsed-time summary
- 🌈 Fancy `figlet` + `lolcat` banner, because recon should look good too

---

## 📦 Prerequisites

| Tool | Purpose |
|------|---------|
| [Go](https://go.dev/) | Required to install the tools below |
| [subfinder](https://github.com/projectdiscovery/subfinder) | Passive subdomain enumeration |
| [httprobe](https://github.com/tomnomnom/httprobe) | Live host probing |
| [cloudrecon](https://github.com/G0ldenGunSec/CloudRecon) | Installed at `/opt/cloudrecon/` (provides `cloud_data_search.sh`) |
| `figlet` | ASCII banner (Doom font) |
| `lolcat` | Rainbow-colored output |

Install the Go tools:

```bash
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/tomnomnom/httprobe@latest
```

Note: **The effectiveness and coverage by this tool depends upon the sources configured**. Configure your subfinder API keys (~/.config/subfinder/provider-config.yaml) for best results, and make sure /opt/cloudrecon/cloud_data_search.sh exists with execute permissions.

🚀 Usage

bash
chmod +x shaheen-reconx.sh
./shaheen-reconx.sh <domain> <target_foldername> <filename>
Example:


```bash
./shaheen-reconx.sh nust.edu.pk NUST nust
```

This creates and populates the workspace:

```text
~/Targets/bugbounty/example/
├── nust.lst      # Master subdomain list (all sources merged & deduped)
├── alive.lst        # Responsive hosts after httprobe
├── kaeferjaeger.lst  # For reference only
└── subfinder.lst    # (temporary, removed after run)
```
