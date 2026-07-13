# Lazy VPN

> One-script VPN server setup — deploy, manage, and optimize your server with ease.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-brightgreen.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Ubuntu%20%7C%20Debian%20%7C%20Arch-lightgrey.svg)]()

## What is Lazy VPN?

Lazy VPN is an interactive Bash script that lets you install and configure popular VPN protocols and proxy tools on your server — all from a single menu. No manual steps, no copy-pasting commands. Just run the script and pick what you need.

### Key Features

- **30+ VPN & proxy tools** in one menu
- **Auto-detection** of existing VPN services before install
- **Multi-distro** support (Ubuntu, Debian, Arch, Fedora, and more)
- **Uninstaller** — remove any service cleanly
- **Docker & non-Docker** options for most services
- **Censorship resistance** tools (AmneziaWG 2.0, PasarGuard)
- **System info** dashboard with IP, memory, and disk stats
- **Color-coded** output with clean UI

## Quick Start

```bash
bash <(curl -sSL https://github.com/samsesh/lazy-vpn/raw/Localhost/lazy.sh)
```

### Recommended: Run with tmux

tmux keeps the session alive even if your SSH connection drops.

```bash
tmux new -s lazy "bash <(curl -sSL https://github.com/samsesh/lazy-vpn/raw/Localhost/lazy.sh)"
```

If the connection is interrupted, reconnect with:

```bash
tmux a -d -t lazy
```

## Menu Structure

```
Main Menu
├── 1) Server Info & Tools
│   ├── System info (OS, kernel, memory, disk)
│   ├── IP diagnostics (IPv4, IPv6)
│   ├── Ubuntu Optimizer
│   ├── Docker
│   ├── XanMod Kernel (with Secure Boot check)
│   ├── BBR3 TCP Congestion Control
│   ├── GOST / CFWarp / WARP
│   ├── Proxy & Tools (MTProxy, SOCKS5/HTTP)
│   └── Uninstaller
├── 2) Install VPN Server
│   ├── WireGuard (standard / Docker)
│   ├── OpenVPN (standard / Docker / Pritunl)
│   ├── OpenConnect (standard / Docker)
│   ├── SoftEther
│   ├── Xray & Proxies (X-UI, 3X-UI, Hiddify, Reality, Marzban, etc.)
│   ├── Juicity
│   ├── X-Panel SSH
│   └── Censorship Resistance
│       ├── PasarGuard Panel (one-click Docker install)
│       ├── PasarGuard Node (one-click install)
│       ├── AmneziaWG 2.0 (kernel module + setup guide)
│       └── AmneziaVPN Client info
└── 3) Quit
```

## Supported Protocols & Tools

### VPN Servers

| Protocol | Options | Docker |
|----------|---------|--------|
| [WireGuard](https://www.wireguard.com/) | Standard, Docker | Yes |
| [AmneziaWG 2.0](https://amnezia.org/blog/amneziawg-2-0-available-for-self-hosted) | Kernel module, app-based setup | Via [AmneziaVPN](https://amnezia.org/downloads) |
| [OpenVPN](https://openvpn.net/) | Standard, Pritunl, Docker | Yes |
| [OpenConnect](https://ocserv.dwww.org/) | Standard, Docker | Yes |
| [SoftEther](https://www.softether.org/) | Standard | No |

### Xray & Proxy Solutions

| Protocol | Variants | Docker |
|----------|----------|--------|
| [X-UI](https://github.com/alireza0/x-ui) | alireza0, Sanaei, Kafka, Chinese | Yes |
| [3X-UI](https://github.com/MHSanaei/3x-ui) | Sanaei | Yes |
| [Hiddify](https://github.com/hiddify/hiddify-config/) | Full stack | No |
| [Xray Reality](https://github.com/sajjaddg/xray-reality) | TLS + Reality | No |
| [Marzban](https://github.com/Gozargah/Marzban) | Multi-protocol panel | Yes |
| [Juicity](https://github.com/samsesh/Juicity-Installer) | QUIC-based | No |
| [ShadowSocksR](https://github.com/ShadowsocksR-Live/shadowsocksr-native) | SSR Native | No |
| [NaiveProxy](https://github.com/yonggekkk/NaiveProxy-yg) | Chromium-based | No |
| [Hi Hysteria](https://github.com/emptysuns/Hi_Hysteria) | UDP-based | No |

### Server Utilities & Proxies

| Tool | Description | Docker |
|------|-------------|--------|
| [Ubuntu Optimizer](https://github.com/samsesh/Ubuntu-Optimizer) | Kernel & system tuning | No |
| [XanMod Kernel](https://xanmod.org/) | High-performance kernel for servers | No |
| [BBR3](https://onidel.com/blog/enable-bbr3-linux-vps) | TCP congestion control (BBR v3) | No |
| [Docker](https://docs.docker.com/engine/install/) | Container runtime | — |
| [GOST](https://github.com/samsesh/gost) | Go Simple Tunnel | No |
| [CFWarp](https://gitlab.com/rwkgyg/CFwarp/) | Cloudflare WARP | No |
| WARP Proxy | Cloudflare WARP on port 4000 | No |
| [X-Panel SSH](https://github.com/Alirezad07/X-Panel-SSH-User-Management) | SSH user management | No |
| Telegram MTProxy | Telegram proxy | Yes |
| SOCKS5/HTTP Proxy | 3proxy-based proxy server | Yes |

## Censorship Resistance

For environments with heavy DPI (Deep Packet Inspection) filtering:

### [AmneziaWG 2.0](https://amnezia.org/blog/amneziawg-2-0-available-for-self-hosted)

Advanced WireGuard fork that mimics legitimate UDP traffic (DNS, QUIC, SIP).

- **Custom Protocol Signatures (CPS)** — dress up VPN traffic to look like real protocols
- **Per-packet padding** — defeats statistical analysis of packet sizes
- **Dynamic headers** — random header values prevent pattern recognition
- **One-click install** via the AmneziaVPN desktop app (>= v4.8.12.9)

### [PasarGuard](https://github.com/PasarGuard)

Unified GUI censorship-resistant solution with decentralized architecture.

- **[Panel](https://github.com/PasarGuard/panel)** — TypeScript-based GUI management panel (one-click Docker install)
- **[Node](https://github.com/PasarGuard/node)** — Go-based decentralized access node (one-click install script)
- **[Subscription Template](https://github.com/PasarGuard/subscription-template)** — Responsive multi-language subscription page

### Other Anti-Censorship Tools

- **[Hiddify](https://github.com/hiddify/hiddify-config/)** — Multi-protocol proxy with anti-censorship features
- **[Xray Reality](https://github.com/sajjaddg/xray-reality)** — TLS-based transport that mimics real websites

## Uninstaller

Remove any installed VPN service cleanly:

- WireGuard, OpenVPN, OpenConnect
- X-UI / 3X-UI
- Marzban, SoftEther, Hiddify
- Docker (full purge)
- **Remove ALL** option for complete cleanup

## System Requirements

- **OS:** Ubuntu, Debian, Arch, Fedora, CentOS, openSUSE, Alpine (and derivatives)
- **Privileges:** Root access required (`sudo`)
- **Network:** Active internet connection
- **Optional:** tmux recommended for stable SSH sessions

## ToDo

- [ ] Test on clean server
- [ ] Add VPN config backup/export
- [ ] Add server health check dashboard

## Contributing

Pull requests are welcome. For major changes, please open an issue first.

## License

[GPL-3.0](LICENSE)

## Related Projects

- [Ubuntu Optimizer](https://github.com/samsesh/Ubuntu-Optimizer)
- [Best VPN list](https://github.com/stars/samsesh/lists/vpn)
- [PasarGuard](https://github.com/PasarGuard) — Panel | Node | Docs
- [AmneziaWG](https://docs.amnezia.org/documentation/amnezia-wg/) — Documentation
- [AmneziaVPN](https://amnezia.org/downloads) — Client downloads
