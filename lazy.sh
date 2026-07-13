#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────
# Lazy VPN - One-script VPN server setup for Ubuntu
# https://github.com/samsesh/lazy-vpn
# ─────────────────────────────────────────────────────

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════╗"
    echo "║           Lazy VPN Installer             ║"
    echo "║      One-script VPN setup for Ubuntu     ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
print_section() { echo -e "\n${BOLD}${BLUE}── $1 ──${NC}"; }

check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        print_error "This script must be run as root. Use: sudo bash lazy.sh"
        exit 1
    fi
}

check_os() {
    if ! grep -qi 'ubuntu' /etc/os-release 2>/dev/null; then
        print_warn "This script is designed for Ubuntu. Proceed with caution."
        read -p "Continue anyway? (y/N): " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
    fi
}

check_dependencies() {
    local deps=("curl" "wget")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            print_info "Installing $dep..."
            apt-get install -y "$dep" &>/dev/null
        fi
    done
}

# ─────────────────────────────────────────────────────
# VPN Detection
# ─────────────────────────────────────────────────────
scan_vpn_services() {
    local found=0

    # Systemd services
    local services=("wg-quick@wg0" "wireguard" "openvpn" "ocserv" "x-ui" "3x-ui"
                     "pritunl" "softether" "hysteria" "naiveproxy")

    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            print_warn "Running service: $svc"
            found=1
        fi
    done

    # Docker containers
    if command -v docker &>/dev/null; then
        local containers
        containers=$(docker ps --format '{{.Names}} {{.Image}}' 2>/dev/null || true)
        if [[ -n "$containers" ]]; then
            while IFS= read -r line; do
                local name image
                name=$(echo "$line" | awk '{print $1}')
                image=$(echo "$line" | awk '{print $2}')
                case "$image" in
                    *x-ui*|*3x-ui*|*alireza*|*mhsanaei*)
                        print_warn "Running Docker container: $name ($image)"
                        found=1 ;;
                    *wireguard*|*wg*)
                        print_warn "Running Docker container: $name ($image)"
                        found=1 ;;
                    *openvpn*)
                        print_warn "Running Docker container: $name ($image)"
                        found=1 ;;
                    *ocserv*|*openconnect*)
                        print_warn "Running Docker container: $name ($image)"
                        found=1 ;;
                    *marzban*)
                        print_warn "Running Docker container: $name ($image)"
                        found=1 ;;
                    *3proxy*)
                        print_warn "Running Docker container: $name ($image)"
                        found=1 ;;
                    *hysteria*)
                        print_warn "Running Docker container: $name ($image)"
                        found=1 ;;
                esac
            done <<< "$containers"
        fi
    fi

    # Listening ports (common VPN ports)
    local ports
    ports=$(ss -tlnp 2>/dev/null | awk 'NR>1 {print $4}' | grep -oP ':\K[0-9]+' | sort -un || true)
    local vpn_ports=("51820" "1194" "443" "8443" "54321" "2053" "8080" "3128" "1080")
    local used_ports=()
    for vp in "${vpn_ports[@]}"; do
        if echo "$ports" | grep -qx "$vp"; then
            used_ports+=("$vp")
        fi
    done

    if [[ ${#used_ports[@]} -gt 0 ]]; then
        echo ""
        print_section "Ports in use (possible VPN services)"
        echo "  ${used_ports[*]}"
    fi

    if [[ $found -eq 0 ]] && [[ ${#used_ports[@]} -eq 0 ]]; then
        print_info "No existing VPN services detected."
    fi

    return $found
}

confirm_install() {
    local service="$1"
    echo ""
    print_warn "Existing VPN services detected above."
    read -p "Continue installing $service? (y/N): " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || return 1
    return 0
}

# ─────────────────────────────────────────────────────
# Docker Management
# ─────────────────────────────────────────────────────
docker_check() {
    if command -v docker &>/dev/null; then
        print_info "Docker is already installed (v$(docker --version | awk '{print $3}' | tr -d ','))"
        return 0
    fi

    print_info "Installing Docker..."
    curl -sSL https://get.docker.com | sh
    systemctl enable docker &>/dev/null
    systemctl start docker
    sleep 3
    print_info "Docker installed successfully!"
}

# ─────────────────────────────────────────────────────
# System Info
# ─────────────────────────────────────────────────────
show_ip_info() {
    print_section "IP Information"
    local local_ip public_ipv4 public_ipv6 ipv6
    local_ip=$(hostname -I | awk '{print $1}')
    public_ipv4=$(curl -s --max-time 5 https://api.ipify.org || echo "N/A")
    public_ipv6=$(curl -6s --max-time 5 https://api6.ipify.org || echo "N/A")
    ipv6=$(ip -6 addr show dev eth0 2>/dev/null | awk '/inet6/ {print $2}' | head -1)
    ipv6="${ipv6:-Not assigned}"

    echo "  Local IP:        $local_ip"
    echo "  Public IPv4:     $public_ipv4"
    echo "  Public IPv6:     $public_ipv6"
    echo "  IPv6 Subnet:     $ipv6"
}

show_system_info() {
    print_section "System Information"
    echo "  OS:              $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
    echo "  Kernel:          $(uname -r)"
    echo "  Architecture:    $(uname -m)"
    echo "  Hostname:        $(hostname)"
    echo ""
    print_section "Memory"
    free -h | awk 'NR==1{print "  "$0} NR==2{print "  "$0}'
    echo ""
    print_section "Disk"
    df -h / | awk 'NR==1{print "  "$0} NR==2{print "  "$0}'
}

# ─────────────────────────────────────────────────────
# VPN Server Menu
# ─────────────────────────────────────────────────────
menu_xray() {
    while true; do
        clear
        print_header
        scan_vpn_services || true
        echo ""
        echo -e "${BOLD}Xray & Proxy Solutions${NC}"
        echo ""
        echo "  1)  Back"
        echo "  2)  X-UI (alireza0)"
        echo "  3)  X-UI (alireza0) [Docker]"
        echo "  4)  3X-UI (Sanaei)"
        echo "  5)  3X-UI (Sanaei) [Docker]"
        echo "  6)  X-UI (Kafka) [English]"
        echo "  7)  X-UI (Chinese)"
        echo "  8)  X-UI (Chinese) [Docker]"
        echo "  9)  Hiddify"
        echo " 10)  ShadowSocksR"
        echo " 11)  Hi Hysteria"
        echo " 12)  NaiveProxy"
        echo " 13)  Xray Reality"
        echo " 14)  Marzban [Docker]"
        echo ""
        read -p "Select option: " choice
        case $choice in
            1) return ;;
            2)
                if confirm_install "X-UI (alireza0)"; then
                    print_info "Installing X-UI (alireza0)..."
                    bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)
                fi
                ;;
            3)
                if confirm_install "X-UI (Docker)"; then
                    docker_check
                    mkdir -p /docker/x-ui
                    docker run -itd \
                        -p 54321:54321 -p 443:443 -p 80:80 \
                        -e XRAY_VMESS_AEAD_FORCED=false \
                        -v /docker/x-ui/db/:/etc/x-ui/ \
                        -v /docker/x-ui/cert/:/root/cert/ \
                        --name x-ui --restart=unless-stopped \
                        alireza7/x-ui:latest
                    print_info "X-UI (Docker) installed. Panel: http://<your-ip>:54321"
                fi
                ;;
            4)
                if confirm_install "3X-UI (Sanaei)"; then
                    print_info "Installing 3X-UI (Sanaei)..."
                    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
                fi
                ;;
            5)
                if confirm_install "3X-UI (Docker)"; then
                    docker_check
                    mkdir -p /docker/x-ui
                    docker run -itd \
                        -e XRAY_VMESS_AEAD_FORCED=false \
                        -v /docker/x-ui/db/:/etc/x-ui/ \
                        -v /docker/x-ui/cert/:/root/cert/ \
                        --network=host \
                        --restart=unless-stopped \
                        --name 3x-ui \
                        ghcr.io/mhsanaei/3x-ui:latest
                    print_info "3X-UI (Docker) installed."
                fi
                ;;
            6)
                if confirm_install "X-UI (Kafka)"; then
                    print_info "Installing X-UI (Kafka)..."
                    bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install_en.sh)
                fi
                ;;
            7)
                if confirm_install "X-UI (Chinese)"; then
                    print_info "Installing X-UI (Chinese)..."
                    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
                fi
                ;;
            8)
                if confirm_install "X-UI Chinese (Docker)"; then
                    docker_check
                    mkdir -p /docker/x-ui
                    docker run -itd --network=host \
                        -v /docker/x-ui/db/:/etc/x-ui/ \
                        -v /docker/x-ui/cert/:/root/cert/ \
                        --name x-ui --restart=unless-stopped \
                        enwaiax/x-ui:latest
                    print_info "X-UI Chinese (Docker) installed."
                fi
                ;;
            9)
                if confirm_install "Hiddify"; then
                    print_info "Installing Hiddify..."
                    bash -c "$(curl -Lfo- https://raw.githubusercontent.com/hiddify/hiddify-config/main/common/download_install.sh)"
                fi
                ;;
            10)
                if confirm_install "ShadowSocksR"; then
                    print_info "Installing ShadowSocksR..."
                    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
                    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
                    sysctl -p &>/dev/null
                    bash <(curl -Ls https://raw.githubusercontent.com/ShadowsocksR-Live/shadowsocksr-native/master/install/ssrn-install.sh)
                fi
                ;;
            11)
                if confirm_install "Hi Hysteria"; then
                    print_info "Installing Hi Hysteria..."
                    bash <(curl -fsSL https://git.io/hysteria.sh)
                fi
                ;;
            12)
                if confirm_install "NaiveProxy"; then
                    print_info "Installing NaiveProxy..."
                    bash <(curl -fsSL https://gitlab.com/rwkgyg/naiveproxy-yg/raw/main/naiveproxy.sh)
                fi
                ;;
            13)
                if confirm_install "Xray Reality"; then
                    print_info "Installing Xray Reality..."
                    bash -c "$(curl -L https://raw.githubusercontent.com/sajjaddg/xray-reality/master/install.sh)"
                fi
                ;;
            14)
                if confirm_install "Marzban"; then
                    menu_marzban
                fi
                ;;
            *) print_error "Invalid option" ;;
        esac
        echo ""
        read -p "Press Enter to continue..."
    done
}

menu_marzban() {
    print_info "Installing Marzban..."
    docker_check
    mkdir -p /docker/marzban && cd /docker/marzban
    wget -qO- https://github.com/Gozargah/Marzban-examples/releases/latest/download/multi-port.tar.gz | tar xz --xform 's/multi-port/marzban/'
    cd marzban && docker compose pull
    apt-get install -y socat cron &>/dev/null

    read -p "Domain name: " domain
    read -p "Email address: " email
    read -p "Use TLS? (Y/n): " use_tls

    if [[ "$use_tls" =~ ^[Yy]$ ]] || [[ -z "$use_tls" ]]; then
        curl -sSL https://get.acme.sh | sh -s email="$email"
        mkdir -p /var/lib/marzban/certs/
        ~/.acme.sh/acme.sh --issue --standalone -d "$domain" \
            --key-file /var/lib/marzban/certs/key.pem \
            --fullchain-file /var/lib/marzban/certs/fullchain.pem
        sed -i "s#VICORN_SSL_CERTFILE=.*#VICORN_SSL_CERTFILE=\"/var/lib/marzban/certs/fullchain.pem\"#" /docker/marzban/.env
        sed -i "s#UVICORN_SSL_KEYFILE=.*#UVICORN_SSL_KEYFILE=\"/var/lib/marzban/certs/key.pem\"#" /docker/marzban/.env
    fi

    docker compose up -d
    print_info "Marzban installed! Config: /docker/marzban"
}

# ─────────────────────────────────────────────────────
# VPN Servers
# ─────────────────────────────────────────────────────
menu_wireguard() {
    while true; do
        clear
        print_header
        scan_vpn_services || true
        echo ""
        echo -e "${BOLD}WireGuard${NC}"
        echo ""
        echo "  1)  Back"
        echo "  2)  Install WireGuard"
        echo "  3)  Install WireGuard [Docker]"
        echo ""
        read -p "Select option: " choice
        case $choice in
            1) return ;;
            2)
                if confirm_install "WireGuard"; then
                    print_info "Installing WireGuard..."
                    bash <(curl -fsSL https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh)
                fi
                ;;
            3)
                if confirm_install "WireGuard (Docker)"; then
                    docker_check
                    print_info "Installing WireGuard (Docker)..."
                    git clone https://github.com/samsesh/wireguard-docker.git /tmp/lazy-wg
                    read -p "Install path [/docker/wireguard]: " wg_path
                    wg_path="${wg_path:-/docker/wireguard}"
                    read -p "Number of peers [10]: " wg_peers
                    wg_peers="${wg_peers:-10}"
                    read -p "Container name [wireguard]: " wg_name
                    wg_name="${wg_name:-wireguard}"

                    sed -i "s/^FILELOCATION=.*/FILELOCATION=$wg_path/g" /tmp/lazy-wg/.env
                    sed -i "s/^USERPEERS=.*/USERPEERS=$wg_peers/g" /tmp/lazy-wg/.env
                    sed -i "s/^CONTAINERNAME=.*/CONTAINERNAME=$wg_name/g" /tmp/lazy-wg/.env

                    (cd /tmp/lazy-wg && bash install-on-ubuntu.sh)
                    print_info "WireGuard installed! Show QR: docker exec -it $wg_name /app/show-peer 1"
                fi
                ;;
            *) print_error "Invalid option" ;;
        esac
        echo ""
        read -p "Press Enter to continue..."
    done
}

menu_openvpn() {
    while true; do
        clear
        print_header
        scan_vpn_services || true
        echo ""
        echo -e "${BOLD}OpenVPN${NC}"
        echo ""
        echo "  1)  Back"
        echo "  2)  Install OpenVPN"
        echo "  3)  Install OpenVPN [Docker]"
        echo "  4)  Install OpenVPN (Pritunl)"
        echo ""
        read -p "Select option: " choice
        case $choice in
            1) return ;;
            2)
                if confirm_install "OpenVPN"; then
                    print_info "Installing OpenVPN..."
                    bash <(curl -sSL https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh)
                fi
                ;;
            3)
                if confirm_install "OpenVPN (Docker)"; then
                    docker_check
                    print_info "Installing OpenVPN (Docker)..."
                    read -p "Install path [/docker/openvpn]: " ovpn_path
                    ovpn_path="${ovpn_path:-/docker/openvpn}"
                    read -p "Container name [openvpn]: " ovpn_name
                    ovpn_name="${ovpn_name:-openvpn}"

                    mkdir -p "$ovpn_path"
                    git clone https://github.com/samsesh/openvpn-dockercompose.git "$ovpn_path"
                    sed -i "s/^container_name:.*/container_name:$ovpn_name/g" "$ovpn_path/docker-compose.yml"

                    (cd "$ovpn_path" && bash fisrtconf.sh && \
                        docker compose run --rm "$ovpn_name" ovpn_initpki && \
                        docker compose up -d "$ovpn_name")

                    print_info "OpenVPN installed! Add user: docker-compose run --rm $ovpn_name easyrsa build-client-full <username> nopass"
                fi
                ;;
            4)
                if confirm_install "Pritunl"; then
                    print_info "Installing Pritunl..."
                    bash <(curl -sSL https://github.com/samsesh/pritunl-install/raw/Localhost/installfromgithub.sh)
                fi
                ;;
            *) print_error "Invalid option" ;;
        esac
        echo ""
        read -p "Press Enter to continue..."
    done
}

menu_openconnect() {
    while true; do
        clear
        print_header
        scan_vpn_services || true
        echo ""
        echo -e "${BOLD}OpenConnect${NC}"
        echo ""
        echo "  1)  Back"
        echo "  2)  Install OpenConnect"
        echo "  3)  Install OpenConnect [Docker]"
        echo ""
        read -p "Select option: " choice
        case $choice in
            1) return ;;
            2)
                if confirm_install "OpenConnect"; then
                    print_info "Installing OpenConnect..."
                    mkdir -p /tmp/lazy && cd /tmp/lazy
                    wget -N --no-check-certificate https://raw.githubusercontent.com/sfc9982/AnyConnect-Server/main/ocserv-en.sh
                    chmod +x ocserv-en.sh && bash ocserv-en.sh
                fi
                ;;
            3)
                if confirm_install "OpenConnect (Docker)"; then
                    docker_check
                    print_info "Installing OpenConnect (Docker)..."
                    docker build -t ocserv https://github.com/samsesh/ocserv-docker.git
                    read -p "Port [443]: " oc_port
                    oc_port="${oc_port:-443}"
                    docker run --name ocserv --privileged \
                        -p "$oc_port":443 -p "$oc_port":443/udp \
                        -d --restart unless-stopped ocserv
                    print_info "OpenConnect installed! Add user: docker exec -ti ocserv ocpasswd -c /etc/ocserv/ocpasswd <username>"
                fi
                ;;
            *) print_error "Invalid option" ;;
        esac
        echo ""
        read -p "Press Enter to continue..."
    done
}

# ─────────────────────────────────────────────────────
# Censorship Resistance
# ─────────────────────────────────────────────────────
menu_censorship_resistance() {
    while true; do
        clear
        print_header
        echo -e "${BOLD}Censorship Resistance Tools${NC}"
        echo ""
        echo "  1)  Back"
        echo "  2)  PasarGuard Panel (GUI)"
        echo "  3)  PasarGuard Node"
        echo "  4)  AmneziaWG 2.0 (Self-hosted)"
        echo "  5)  AmneziaVPN Client Info"
        echo ""
        echo -e "  ${CYAN}PasarGuard: https://github.com/PasarGuard${NC}"
        echo -e "  ${CYAN}AmneziaWG:   https://amnezia.org/blog/amneziawg-2-0-available-for-self-hosted${NC}"
        echo ""
        read -p "Select option: " choice
        case $choice in
            1) return ;;
            2)
                print_info "PasarGuard Panel — Unified GUI Censorship Resistant Solution"
                echo ""
                echo "  GitHub:    https://github.com/PasarGuard/panel"
                echo "  Docs:      https://docs.pasargard.org"
                echo ""
                echo "  Install via Docker:"
                echo "    git clone https://github.com/PasarGuard/panel.git"
                echo "    cd panel && docker compose up -d"
                echo ""
                ;;
            3)
                print_info "PasarGuard Node — Decentralized Censorship-Resistant Access Layer"
                echo ""
                echo "  GitHub:    https://github.com/PasarGuard/node"
                echo ""
                echo "  Build from source:"
                echo "    git clone https://github.com/PasarGuard/node.git"
                echo "    cd node && go build"
                echo ""
                ;;
            4)
                print_info "AmneziaWG 2.0 — Advanced Anti-DPI WireGuard Fork"
                echo ""
                echo "  Blog:      https://amnezia.org/blog/amneziawg-2-0-available-for-self-hosted"
                echo "  Docs:      https://docs.amnezia.org/documentation/amnezia-wg/"
                echo ""
                echo "  Features:"
                echo "    - Custom Protocol Signatures (CPS) for traffic mimicry"
                echo "    - Per-packet padding to defeat statistical analysis"
                echo "    - Dynamic header ranges to prevent pattern recognition"
                echo "    - Mimics DNS, QUIC, and SIP traffic"
                echo ""
                echo "  To install on your server:"
                echo "    1. Install AmneziaVPN app >= v4.8.12.9"
                echo "    2. Connect to your server"
                echo "    3. Click gear icon → install AmneziaWG"
                echo "    4. Generate fresh client configs for AWG 2.0"
                echo ""
                ;;
            5)
                print_info "AmneziaVPN Client"
                echo ""
                echo "  Download:  https://amnezia.org/downloads"
                echo "  GitHub:    https://github.com/amnezia-vpn/amnezia-client"
                echo "  Android:   https://play.google.com/store/apps/details?id=org.amnezia.vpn"
                echo "  iOS:       https://apps.apple.com/us/app/amneziavpn/id1600529900"
                echo ""
                ;;
            *) print_error "Invalid option" ;;
        esac
        echo ""
        read -p "Press Enter to continue..."
    done
}

# ─────────────────────────────────────────────────────
# Server Options
# ─────────────────────────────────────────────────────
menu_server_tools() {
    while true; do
        clear
        print_header
        show_system_info
        show_ip_info
        echo ""
        echo -e "${BOLD}Server Tools${NC}"
        echo ""
        echo "  1)  Back"
        echo "  2)  Ubuntu Optimizer"
        echo "  3)  Install Docker"
        echo "  4)  Install GOST"
        echo "  5)  Install CFWarp"
        echo "  6)  Install WARP Proxy (port 4000)"
        echo ""
        read -p "Select option: " choice
        case $choice in
            1) return ;;
            2)
                print_info "Running Ubuntu Optimizer..."
                bash <(curl -s https://raw.githubusercontent.com/samsesh/Ubuntu-Optimizer/main/ubuntu-optimizer.sh)
                ;;
            3)
                docker_check
                ;;
            4)
                if command -v gost &>/dev/null; then
                    print_info "GOST is already installed"
                else
                    print_info "Installing GOST..."
                    bash <(curl -fsSL https://github.com/samsesh/gost/raw/master/install.sh) --install
                fi
                ;;
            5)
                print_info "Installing CFWarp..."
                wget -N https://gitlab.com/rwkgyg/CFwarp/raw/main/CFwarp.sh && bash CFwarp.sh <<< $'1\n1\n3'
                ;;
            6)
                print_info "Installing WARP Proxy..."
                bash <(curl -sSL https://gist.githubusercontent.com/hamid-gh98/dc5dd9b0cc5b0412af927b1ccdb294c7/raw/install_warp_proxy.sh)
                ;;
            *) print_error "Invalid option" ;;
        esac
        echo ""
        read -p "Press Enter to continue..."
    done
}

# ─────────────────────────────────────────────────────
# VPN Server Menu
# ─────────────────────────────────────────────────────
menu_vpn_servers() {
    while true; do
        clear
        print_header
        scan_vpn_services || true
        echo ""
        echo -e "${BOLD}VPN Servers${NC}"
        echo ""
        echo "  1)  Back"
        echo "  2)  WireGuard"
        echo "  3)  OpenVPN"
        echo "  4)  OpenConnect"
        echo "  5)  SoftEther"
        echo "  6)  Xray & Proxies"
        echo "  7)  Juicity"
        echo "  8)  X-Panel SSH"
        echo "  9)  Censorship Resistance"
        echo ""
        read -p "Select option: " choice
        case $choice in
            1) return ;;
            2) menu_wireguard ;;
            3) menu_openvpn ;;
            4) menu_openconnect ;;
            5)
                if confirm_install "SoftEther"; then
                    print_info "Installing SoftEther..."
                    git clone https://github.com/samsesh/softether-install.git /tmp/lazy-se
                    (cd /tmp/lazy-se && bash install.sh)
                fi
                ;;
            6) menu_xray ;;
            7)
                if confirm_install "Juicity"; then
                    print_info "Installing Juicity..."
                    bash <(curl -fsSL https://raw.githubusercontent.com/samsesh/Juicity-Installer/main/juicity-installer.sh)
                fi
                ;;
            8)
                if confirm_install "X-Panel SSH"; then
                    print_info "Installing X-Panel SSH..."
                    bash <(curl -Ls https://raw.githubusercontent.com/Alirezad07/X-Panel-SSH-User-Management/main/install.sh --ipv4)
                    bash <(curl -Ls https://raw.githubusercontent.com/Alirezad07/X-Panel-SSH-User-Management/main/block_iran.sh --ipv4)
                    bash <(curl -Ls https://raw.githubusercontent.com/Alirezad07/X-Panel-SSH-User-Management/master/fix-call.sh --ipv4)
                fi
                ;;
            9) menu_censorship_resistance ;;
            *) print_error "Invalid option" ;;
        esac
        echo ""
        read -p "Press Enter to continue..."
    done
}

# ─────────────────────────────────────────────────────
# Main Menu
# ─────────────────────────────────────────────────────
main_menu() {
    while true; do
        print_header
        echo -e "${BOLD}Main Menu${NC}"
        echo ""
        echo "  1)  Server Info & Tools"
        echo "  2)  Install VPN Server"
        echo "  3)  Censorship Resistance"
        echo "  4)  Quit"
        echo ""
        echo -e "  ${CYAN}GitHub:${NC} https://github.com/samsesh/lazy-vpn"
        echo -e "  ${CYAN}PasarGuard:${NC} https://github.com/PasarGuard"
        echo -e "  ${CYAN}AmneziaWG 2.0:${NC} https://amnezia.org/blog/amneziawg-2-0-available-for-self-hosted"
        echo ""
        read -p "Select option: " choice
        case $choice in
            1) menu_server_tools ;;
            2) menu_vpn_servers ;;
            3) menu_censorship_resistance ;;
            4) clear; exit 0 ;;
            *) print_error "Invalid option" ;;
        esac
    done
}

# ─────────────────────────────────────────────────────
# Entry Point
# ─────────────────────────────────────────────────────
check_root
check_os
check_dependencies
main_menu
