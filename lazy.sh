#!/bin/bash
dockercheck() {
    #install docker

    # Check if Docker is already installed
    if ! command -v docker &>/dev/null; then
        echo $(tput setaf 2)Docker is not installed on this system. Installing Docker...$(tput sgr0)

        # Install Docker using the official Docker installation script
        curl -sSL https://get.docker.com | sh

        # Start the Docker service
        service docker start

        sleep 5
        clear
        echo $(tput setaf 2)Docker has been installed successfully!$(tput sgr0)
    else
        echo $(tput setaf 2)Docker is already installed on this system.$(tput sgr0)
    fi

    sleep 5
    clear
}

ipcheck() {
    # Get the local IP address
    local_ip=$(hostname -I | awk '{print $1}')

    # Get the public IP addresses
    public_ipv4=$(curl -s https://api.ipify.org)
    public_ipv6=$(curl -6s https://api6.ipify.org)

    # Get the IPv6 address
    ipv6=$(ip -6 addr show dev eth0 | awk '/inet6/ {print $2}')

    # Check if the IPv6 address is assigned
    if [ -z "$ipv6" ]; then
        ipv6="$(tput setaf 2)Not assigned$(tput sgr0)" # Set the text to red if not assigned
    fi

    # Display the IP addresses
    echo "IP Information:"
    echo "------------------------------------"
    echo "Local IP Address: $local_ip"
    echo "Public IPv4 Address: $public_ipv4"
    echo "Public IPv6 Address: $public_ipv6"
    echo "IPv6 Address: $ipv6"
    echo ""
}

sysinfo() {
    echo "System Information:"
    echo "------------------------------------"

    echo "Kernel Name: $(uname -s)"
    echo "Kernel Release: $(uname -r)"
    echo "Kernel Version: $(uname -v)"
    echo "Machine Architecture: $(uname -m)"
    echo ""

    echo "Operating System Information:"
    echo "------------------------------------"

    if [ -f /etc/os-release ]; then
        cat /etc/os-release
        echo ""
    fi

    echo "Memory Information:"
    echo "------------------------------------"

    free -m
    echo ""
}

sercvermenu() {
    clear
    sysinfo
    ipcheck

    PS3="Please select an option: "

    options=("run Ubuntu-Optimizer" "install docker" "install gost" "install cfwarp" "install warp on port 4000" "back main menu")

    select opt in "${options[@]}"; do
        case $opt in
        "run Ubuntu-Optimizer")
            echo "run Ubuntu-Optimizer"
            bash <(curl -s https://raw.githubusercontent.com/samsesh/Ubuntu-Optimizer/main/ubuntu-optimizer.sh)
            ;;
        "install docker")
            echo "install docker"
            dockercheck
            ;;
        "install gost")
            echo "install gost"
            if ! command -v gost &>/dev/null; then
                echo $(tput setaf 2)gost is not installed on this system. Installing Gost...$(tput sgr0)
                bash <(curl -fsSL https://github.com/samsesh/gost/raw/master/install.sh) --install

                echo $(tput setaf 2)gost has been installed successfully!$(tput sgr0)
            else
                echo $(tput setaf 2)gost is already installed on this system.$(tput sgr0)
            fi
            ;;
        "install cfwarp")
            # Download and run CFwarp.sh script
            wget -N https://gitlab.com/rwkgyg/CFwarp/raw/main/CFwarp.sh && bash CFwarp.sh <<EOF
1
1
3
EOF
            clear
            ;;
        "install warp on port 4000")
            echo "install warp"
            bash <(curl -sSL https://gist.githubusercontent.com/hamid-gh98/dc5dd9b0cc5b0412af927b1ccdb294c7/raw/install_warp_proxy.sh)
            ;;
        "back main menu")
            fisrtmenu
            ;;
        *) echo "Invalid option $REPLY" ;;
        esac
    done

}

check_if_running_as_root() {
    # If you want to run as another user, please modify $EUID to be owned by this user
    if [[ "$EUID" -ne '0' ]]; then
        echo "$(tput setaf 1)Error: You must run this script as root!$(tput sgr0)"
        exit 1
    fi
}

vpnserver() {
    clear
    check_if_running_as_root
    PS3="Please select vpn server for installing: "

    options=("back" "x-Panel (SSH)" "xray (11)" "openvpn (3)" "openconnect (2)" "wireguard (2)" "install softether server" "install socks and http proxy server(docker base)")

    select opt in "${options[@]}"; do
        case $opt in
        "back")
            fisrtmenu
            ;;
        "x-Panel (SSH)")
            echo "https://github.com/Alirezad07/X-Panel-SSH-User-Management"
            sleep 5
            bash <(curl -Ls https://raw.githubusercontent.com/Alirezad07/X-Panel-SSH-User-Management/main/install.sh --ipv4)
            bash <(curl -Ls https://raw.githubusercontent.com/Alirezad07/X-Panel-SSH-User-Management/main/block_iran.sh --ipv4)
            bash <(curl -Ls https://raw.githubusercontent.com/Alirezad07/X-Panel-SSH-User-Management/master/fix-call.sh --ipv4)
            ;;
        "xray (11)")
            xrayi
            ;;
        "openvpn (3)")
            openvpni
            ;;
        "openconnect (2)")
            openconnecti
            ;;
        "wireguard (2)")
            wireguardi
            ;;
        "Telegram proxy (docker base)")
            echo ""
            sleep 5
            dockercheck

            echo "Please enter the new value for FILELOCATION (press Enter to use default value of /docker/docker-compose-mtproxy):"
            read file_location

            if [ -z "$file_location" ]; then
                file_location="/docker/docker-compose-mtproxy"
            fi

            git clone https://github.com/iShift/docker-compose-mtproxy.git $file_location

            echo "Enter a port number for (Press Enter for default value '443'): "
            read host_port

            if ! [[ $port =~ $regex ]]; then
                echo "Error: Port number must be a number" >&2
                exit 1
            elif [ -z "$host_port" ]; then
                host_port="443"
            fi
            regex='^[0-9]+$'

            # Prompt the user for the tag
            read -p "Enter the tag (leave empty for random): " tag

            # Generate a random tag if the user didn't provide one
            if [ -z "$tag" ]; then
                tag=$(openssl rand -hex 16)
            fi

            # Prompt the user for the secret
            read -p "Enter the secret (leave empty for random): " secret

            # Generate a random secret if the user didn't provide one
            if [ -z "$secret" ]; then
                secret=$(openssl rand -hex 32)
            fi

            # Set the path to the config.env file
            config_file="$file_location/config.env"
            compose_file="$file_location/docker-compose.yml"

            # Update the values in the config.env file
            echo "TAG=$tag" >"$config_file"
            echo "SECRET=$secret" >>"$config_file"

            sed -i "s/443:443/$host_port:443/g" "$compose_file"

            pw=$(pwd)
            cd $file_location
            docker compose up -d
            cd $pw
            clear
            echo "done"
            echo "your tag $tag"
            echo "your secret $secret"
            ;;
        "install socks and http proxy server(docker base)")
            echo "https://github.com/samsesh/3proxy-docker-compose"
            sleep 5
            regex='^[0-9]+$'

            echo "Enter a port number for socks (Press Enter for default value '3128'): "
            read ports

            if ! [[ $port =~ $regex ]]; then
                echo "Error: Port number must be a number" >&2
                exit 1
            elif [ -z "$ports" ]; then
                ports="3128"
            fi
            regex='^[0-9]+$'

            echo "Enter a port number for http (Press Enter for default value '1080'): "
            read porth

            if ! [[ $port =~ $regex ]]; then
                echo "Error: Port number must be a number" >&2
                exit 1
            elif [ -z "$porth" ]; then
                port="443"
            fi
            echo "Enter user for proxy (Press Enter for default value 'evli'): "
            read username

            if [ -z "$username" ]; then
                username="evli"
            fi
            echo "Enter user for proxy (Press Enter for default value 'live'): "
            read password

            if [ -z "$password" ]; then
                password="live"
            fi
            docker run --rm -d \
                -p $ports:3128/tcp \
                -p $porth:1080/tcp \
                -e PROXY_LOGIN=$username \
                -e PROXY_PASSWORD=$password \
                -e PRIMARY_RESOLVER=2001:4860:4860::8888 \
                tarampampam/3proxy:latest

            ;;

        "install softether server")
            echo "https://github.com/samsesh/softether-install"
            sleep 5
            git clone https://github.com/samsesh/softether-install.git && cd softether-install && bash install.sh
            ;;

        *) echo "Invalid option $REPLY" ;;
        esac
    done

}

xrayi() {
    clear

    PS3="Please select an option: "

    options=("back to vpn server menu" "x-ui (7 script)" "install hiddify" "ShadowSocks ssr" "install Hi_Hysteria (chinese)" "install NaiveProxy (chinese)" "install xray-reality" "marzban (docker base)")

    select opt in "${options[@]}"; do
        case $opt in
        "back to vpn server menu")
            vpnserver
            ;;
        "x-ui (7 script)")
            xui
            ;;
        "install hiddify")
            echo "https://github.com/hiddify/hiddify-config/"
            sleep 5
            bash -c "$(curl -Lfo- https://raw.githubusercontent.com/hiddify/hiddify-config/main/common/download_install.sh)"
            ;;
        "ShadowSocks ssr")
            echo "https://github.com/ShadowsocksR-Live/shadowsocksr-native"
            sleep 5
            echo "net.core.default_qdisc=fq" >>/etc/sysctl.conf
            echo "net.ipv4.tcp_congestion_control=bbr" >>/etc/sysctl.conf
            bash <(curl -Ls https://raw.githubusercontent.com/ShadowsocksR-Live/shadowsocksr-native/master/install/ssrn-install.sh)
            ;;
        "install Hi_Hysteria (chinese)")
            echo "https://github.com/emptysuns/Hi_Hysteria"
            sleep 5
            bash <(curl -fsSL https://git.io/hysteria.sh)
            ;;
        "install NaiveProxy")
            echo "https://github.com/yonggekkk/NaiveProxy-yg"
            sleep 5
            bash <(curl -fsSL https://gitlab.com/rwkgyg/naiveproxy-yg/raw/main/naiveproxy.sh)
            ;;
        "install xray-reality")
            echo "https://github.com/sajjaddg/xray-reality"
            sleep 5
            bash -c "$(curl -L https://raw.githubusercontent.com/sajjaddg/xray-reality/master/install.sh)"
            ;;
        "marzban (docker base)")
            echo "https://github.com/Gozargah/Marzban"
            sleep 5
            dockercheck
            mkdir /docker
            cd /docker
            wget -qO- https://github.com/Gozargah/Marzban-examples/releases/latest/download/multi-port.tar.gz | tar xz --xform 's/multi-port/marzban/' && cd marzban
            docker compose pull
            apt install -y socat cron
            read -p "Enter your domain name: " domain
            read -p "Enter your email address: " email
            read -p "Do you want to use TLS? (Y/n): " use_tls

            if [[ $use_tls =~ ^[Yy]$ ]] || [[ -z $use_tls ]]; then
                # Obtain SSL certificate
                curl https://get.acme.sh | sh -s email=$email
                mkdir -p /var/lib/marzban/certs/
                ~/.acme.sh/acme.sh --issue --standalone -d $domain \
                    --key-file /var/lib/marzban/certs/key.pem \
                    --fullchain-file /var/lib/marzban/certs/fullchain.pem
                # Change environment file
                sed -i "s#VICORN_SSL_CERTFILE=.*#VICORN_SSL_CERTFILE=\"/var/lib/marzban/certs/fullchain.pem\"#" /docker/marzban/.env
                sed -i "s#UVICORN_SSL_KEYFILE=.*#UVICORN_SSL_KEYFILE=\"/var/lib/marzban/certs/key.pem\"#" /docker/marzban/.env
            else
                echo "Skipping TLS certificate generation."
            fi
            docker compose up -d
            clear
            echo "done"
            echo "marzban folder path :"
            echo "/docker/marzban"
            sleep 10
            vpnserver
            ;;

        *) echo "Invalid option $REPLY" ;;
        esac
    done

}

xuicheck() {
    if ! dpkg -s x-ui >/dev/null 2>&1; then
        echo ""
        if ! docker ps --filter "name=xui" | grep xui >/dev/null 2>&1; then
            if ! docker ps --filter "name=x-ui" | grep xui >/dev/null 2>&1; then
                echo ""
            else
                echo "x-ui Docker container is running with name x-ui"
            fi
        else
            echo "x-ui Docker container is running with name xui"
        fi
    else
        echo "you have x-ui installed, it is better to change its default port and avoid reinstalling it on the server and use docker to have more x-ui services"
    fi
}

xui() {
    clear
    xuicheck
    PS3="Please select an option: "

    options=("back to vpn server menu" "install x-ui (alireza0)" "install x-ui (alireza0)(docker base)" "install 3x-ui (Sanaei)" "install x-ui (Sanaei)(docker base)" "install x-ui (Kafka)(en)" "install x-ui (chinese)" "install x-ui (chinese)(docker base)")
    select opt in "${options[@]}"; do
        case $opt in
        "back to vpn server menu")
            vpnserver
            ;;
        "install x-ui (alireza0)")
            echo "https://github.com/alireza0/x-ui"
            sleep 5
            bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)
            ;;
        "install x-ui (alireza0)(docker base)")
            echo "https://github.com/alireza0/x-ui"
            sleep 5
            dockercheck
            mkdir /docker
            cd /docker
            mkdir x-ui && cd x-ui
            docker run -itd \
                -p 54321:54321 -p 443:443 -p 80:80 \
                -e XRAY_VMESS_AEAD_FORCED=false \
                -v /docker/x-ui/db/:/etc/x-ui/ \
                -v /docker/x-ui/cert/:/root/cert/ \
                --name x-ui --restart=unless-stopped \
                alireza7/x-ui:latest
            ;;
        "install x-ui (Sanaei)(docker base)")
            echo "https://github.com/alireza0/x-ui"
            sleep 5
            dockercheck
            mkdir /docker
            cd /docker
            mkdir x-ui && cd x-ui
            docker run -itd \
                -e XRAY_VMESS_AEAD_FORCED=false \
                -v $PWD/db/:/etc/x-ui/ \
                -v $PWD/cert/:/root/cert/ \
                --network=host \
                --restart=unless-stopped \
                --name 3x-ui \
                ghcr.io/mhsanaei/3x-ui:latest
            ;;
        "install 3x-ui (Sanaei)")
            echo "https://github.com/MHSanaei/3x-ui"
            sleep 5
            bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
            ;;
        "install x-ui (Kafka)(en)")
            echo "https://github.com/FranzKafkaYu/x-ui/"
            sleep 5
            bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install_en.sh)
            ;;
        "install x-ui (chinese)")
            echo "https://github.com/vaxilu/x-ui/"
            sleep 5
            bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
            ;;
        "install x-ui (chinese)(docker base)")
            echo "https://github.com/vaxilu/x-ui/"
            sleep 5
            dockercheck
            mkdir /docker
            cd /docker
            mkdir x-ui && cd x-ui
            docker run -itd --network=host \
                -v /docker/x-ui/db/:/etc/x-ui/ \
                -v /docker/x-ui/cert/:/root/cert/ \
                --name x-ui --restart=unless-stopped \
                enwaiax/x-ui:latest
            ;;
        *) echo "Invalid option $REPLY" ;;
        esac
    done

}
openconnecti() {
    clear

    PS3="Please select an option: "

    options=("back to vpn server menu" "install openconnect server (docker base)" "install openconnect server")

    select opt in "${options[@]}"; do
        case $opt in
        "back to vpn server menu")
            vpnserver
            ;;
        "install openconnect server (docker base)")
            echo "https://github.com/samsesh/ocserv-docker"
            sleep 5
            dockercheck
            docker build -t ocserv https://github.com/samsesh/ocserv-docker.git
            regex='^[0-9]+$'

            echo "Enter a port number (Press Enter for default value '443'): "
            read port

            if ! [[ $port =~ $regex ]]; then
                echo "Error: Port number must be a number" >&2
                exit 1
            elif [ -z "$port" ]; then
                port="443"
            fi
            docker run --name ocserv --privileged -p $port:443 -p $port:443/udp -d --restart unless-stopped ocserv
            echo "you use this command for add user"
            echo "docker exec -ti ocserv ocpasswd -c /etc/ocserv/ocpasswd testUserName"
            echo "more info https://github.com/samsesh/ocserv-docker#docker-installation"
            echo "Press any key to exit..."
            read -n 1 -s
            vpnserver
            ;;
        "install openconnect server")
            echo "https://github.com/samsesh/ocserv-docker"
            sleep 5
            mkdir -p /tmp/lazy/
            cd /tmp/lazy/
            wget -N --no-check-certificate https://raw.githubusercontent.com/sfc9982/AnyConnect-Server/main/ocserv-en.sh
            chmod +x ocserv-en.sh
            bash ocserv-en.sh
            vpnserver
            ;;

        *) echo "Invalid option $REPLY" ;;
        esac
    done

}
wireguardi() {
    clear

    PS3="Please select an option: "

    options=("back to vpn server menu" "install wireguard" "install wireguard (docker base)")

    select opt in "${options[@]}"; do
        case $opt in
        "back to vpn server menu")
            vpnserver
            ;;
        "install wireguard (docker base)")
            echo "https://github.com/samsesh/wireguard-docker"
            sleep 5
            dockercheck
            mkdir -p /tmp/lazy/
            git clone https://github.com/samsesh/wireguard-docker.git /tmp/lazy/wg

            echo "Please enter the new value for FILELOCATION (press Enter to use default value of /docker/wireguard):"
            read file_location

            if [ -z "$file_location" ]; then
                file_location="/docker/wireguard"
            fi

            echo "Please enter the new value for USERPEERS (press Enter to use default value of 10):"
            read user_peers

            if [ -z "$user_peers" ]; then
                user_peers="10"
            fi

            echo "Please enter the new value for CONTAINERNAME (press Enter to use default value of wireguard):"
            read container_name

            if [ -z "$container_name" ]; then
                container_name="wireguard"
            fi

            sed -i "s/^FILELOCATION=.*/FILELOCATION=$file_location/g" /tmp/lazy/wg/.env
            sed -i "s/^USERPEERS=.*/USERPEERS=$user_peers/g" /tmp/lazy/wg/.env
            sed -i "s/^CONTAINERNAME=.*/CONTAINERNAME=$container_name/g" /tmp/lazy/wg/.env

            pw=$(pwd)
            cd /tmp/lazy/wg
            bash install-on-ubuntu.sh
            cd $pw
            clear
            ehco "for show connection qr code use this command"
            echo "docker exec -it $container_name /app/show-peer 1"
            echo "more info on https://github.com/samsesh/wireguard-docker"
            ;;
        "install wireguard")
            echo "https://github.com/angristan/wireguard-install"
            sleep 5
            bash <(curl -fsSL https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh)
            vpnserver
            ;;

        *) echo "Invalid option $REPLY" ;;
        esac
    done

}
openvpni() {
    clear

    PS3="Please select an option: "

    options=("back to vpn server menu" "install openvpn server (docker base)" "install openvpn server (pritunl)" "install openvpn server")

    select opt in "${options[@]}"; do
        case $opt in
        "back to vpn server menu")
            vpnserver
            ;;
        "install openvpn server (docker base)")
            echo "https://github.com/samsesh/openvpn-dockercompose"
            sleep 5
            clear
            echo "Please enter the new value for FILELOCATION (press Enter to use default value of /docker/openvpn-dockercompose):"
            read file_location_open

            if [ -z "$file_location_open" ]; then
                file_location_open="/docker/openvpn-dockercompose"
            fi
            echo "Please enter the new value for CONTAINERNAME (press Enter to use default value of openvpn):"
            read container_name_open

            if [ -z "$container_name_open" ]; then
                container_name_open="openvpn"
            fi

            mkdir /docker
            git clone https://github.com/samsesh/openvpn-dockercompose.git $file_location_open
            sed -i "s/^container_name:.*/container_name:$container_name_open/g" $file_location_open/docker-compose.yml
            pw=$(pwd)
            cd $file_location_open
            bash fisrtconf.sh
            docker compose run --rm $container_name_open ovpn_initpki
            docker compose up -d $container_name_open
            cd $pw
            echo "you use this command for add user"
            echo "docker-compose run --rm $container_name_open easyrsa build-client-full testUserName nopass"
            echo "more info https://github.com/samsesh/openvpn-dockercompose"
            echo "Press any key to exit..."
            read -n 1 -s
            vpnserver
            ;;
        "install openvpn server (pritunl)")
            echo "https://github.com/samsesh/pritunl-install"
            sleep 5
            bash <(curl -sSL https://github.com/samsesh/pritunl-install/raw/Localhost/installfromgithub.sh)
            ;;
        "install openvpn server")
            echo "https://github.com/angristan/openvpn-install"
            sleep 5
            bash <(curl -sSL https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh)
            ;;

        *) echo "Invalid option $REPLY" ;;
        esac
    done

}

fisrtmenu() {
    clear
    echo "$(tput setaf 2)welcome to lazy vpn script$(tput sgr0)"
    PS3="Please select an option: "
    options=("server options" "install vpn server" "Quit")

    select opt in "${options[@]}"; do
        case $opt in
        "server options")
            echo "You chose Option 1"
            sercvermenu
            ;;
        "install vpn server")
            echo "VPN Servers "
            vpnserver
            ;;
        "Quit")
            clear
            exit 1
            ;;
        *) echo "Invalid option $REPLY" ;;
        esac
    done

}
fisrtmenu
