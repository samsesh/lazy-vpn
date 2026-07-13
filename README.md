# Lazy VPN

> One-script VPN server setup for Ubuntu — deploy, manage, and optimize your server with ease.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-brightgreen.svg)](https://www.gnu.org/software/bash/)

## What is Lazy VPN?

Lazy VPN is an interactive Bash script that lets you install and configure popular VPN protocols and proxy tools on your Ubuntu server — all from a single menu. No manual steps, no copy-pasting commands. Just run the script and pick what you need.

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

## Supported Protocols & Tools

### VPN Servers

| Protocol | Options | Docker Support |
|----------|---------|----------------|
| [WireGuard](https://www.wireguard.com/) | Standard, Docker | Yes |
| [AmneziaWG 2.0](https://amnezia.org/blog/amneziawg-2-0-available-for-self-hosted) | Self-hosted | Via [AmneziaVPN](https://amnezia.org/downloads) |
| [OpenVPN](https://openvpn.net/) | Standard, Pritunl, Docker | Yes |
| [OpenConnect](https://ocserv.dwww.org/) | Standard, Docker | Yes |
| [SoftEther](https://www.softether.org/) | Standard | No |

### Xray & Proxy Solutions

| Protocol | Variants | Docker Support |
|----------|----------|----------------|
| [X-UI](https://github.com/alireza0/x-ui) | alireza0, Sanaei, Kafka, Chinese | Yes |
| [3X-UI](https://github.com/MHSanaei/3x-ui) | Sanaei | Yes |
| [Hiddify](https://github.com/hiddify/hiddify-config/) | Full stack | No |
| [Xray Reality](https://github.com/sajjaddg/xray-reality) | TLS + Reality | No |
| [Marzban](https://github.com/Gozargah/Marzban) | Multi-protocol panel | Yes |
| [Juicity](https://github.com/samsesh/Juicity-Installer) | QUIC-based | No |
| [ShadowSocksR](https://github.com/ShadowsocksR-Live/shadowsocksr-native) | SSR Native | No |
| [NaiveProxy](https://github.com/yonggekkk/NaiveProxy-yg) | Chromium-based | No |
| [Hi Hysteria](https://github.com/emptysuns/Hi_Hysteria) | UDP-based | No |

### Server Utilities

| Tool | Description |
|------|-------------|
| [Ubuntu Optimizer](https://github.com/samsesh/Ubuntu-Optimizer) | Kernel & system tuning |
| [Docker](https://docs.docker.com/engine/install/) | Container runtime |
| [GOST](https://github.com/samsesh/gost) | Go Simple Tunnel |
| [CFWarp](https://gitlab.com/rwkgyg/CFwarp/) | Cloudflare WARP |
| WARP Proxy | Cloudflare WARP on port 4000 |
| [X-Panel SSH](https://github.com/Alirezad07/X-Panel-SSH-User-Management) | SSH user management |
| Telegram MTProxy | Docker-based Telegram proxy |
| SOCKS/HTTP Proxy | Docker-based 3proxy |

## Censorship Resistance

For environments with heavy DPI (Deep Packet Inspection) filtering, these tools help maintain access:

- **[AmneziaWG 2.0](https://amnezia.org/blog/amneziawg-2-0-available-for-self-hosted)** — Advanced WireGuard fork that mimics legitimate UDP traffic (DNS, QUIC, SIP). Features Custom Protocol Signatures (CPS), per-packet padding, and dynamic headers to evade DPI detection.
- **[PasarGuard](https://github.com/PasarGuard)** — Unified GUI censorship-resistant solution. Includes a [panel](https://github.com/PasarGuard/panel) (TypeScript), [node](https://github.com/PasarGuard/node) (Go), and [subscription templates](https://github.com/PasarGuard/subscription-template) for decentralized access.
- **[Hiddify](https://github.com/hiddify/hiddify-config/)** — Multi-protocol proxy with anti-censorship features.
- **[Xray Reality](https://github.com/sajjaddg/xray-reality)** — TLS-based transport that mimics real websites.

## System Requirements

- **OS:** Ubuntu (tested on 20.04, 22.04, 24.04)
- **Privileges:** Root access required
- **Network:** Active internet connection
- **Optional:** tmux recommended for stable sessions

## Features

- Interactive menu-driven interface
- System info & IP diagnostics
- Docker auto-installation
- Server optimization tools
- One-click VPN deployment
- Docker & non-Docker options for most services
- Color-coded output for readability

## ToDo

- [ ] Add uninstaller
- [ ] Check for existing VPN servers before installing
- [ ] Add AmneziaWG server installer
- [ ] Add PasarGuard node installer
- [ ] Support for Debian/Arch

## Contributing

Pull requests are welcome. For major changes, please open an issue first.

## License

[GPL-3.0](LICENSE)

## Related Projects

- [Ubuntu Optimizer](https://github.com/samsesh/Ubuntu-Optimizer)
- [Best VPN list](https://github.com/stars/samsesh/lists/vpn)
- [PasarGuard Panel](https://github.com/PasarGuard/panel)
- [PasarGuard Node](https://github.com/PasarGuard/node)
- [AmneziaWG Documentation](https://docs.amnezia.org/documentation/amnezia-wg/)
