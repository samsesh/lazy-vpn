#!/bin/bash
dockercheck() {
    #install docker

    # Check if Docker is already installed
    if ! command -v docker &>/dev/null; then
        echo $(tput setaf 2)Docker is not installed on this system. Installing Docker...$(tput sgr0)

        # Install Docker using the official Docker installation script
        curl -sSL https://get.docker.com | sh

        # Add the current user to the docker group so you can run Docker commands without sudo
        usermod -aG docker $USER

        # Start the Docker service
        service docker start

        sleep 5
        clear
        echo $(tput setaf 2)Docker has been installed successfully!$(tput sgr0)

        sercvermenu
    else
        echo $(tput setaf 2)Docker is already installed on this system.$(tput sgr0)
        sercvermenu
    fi

    sleep 5
    clear
}

sercvermenu() {
    clear
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

    PS3="Please select an option: "

    options=("run Ubuntu-Optimizer" "install docker" "install cfwarp" "back")

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
        "install cfwarp")
            # Download and run CFwarp.sh script
            wget -N https://gitlab.com/rwkgyg/CFwarp/raw/main/CFwarp.sh && bash CFwarp.sh <<EOF
1
1
3
EOF
            clear
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

    options=("install hiddify" "install 3x-ui" "install x-ui" "install xray-reality" "install openconnect server (docker base)" "install openvpn server (pritunl)" "install softether server" "install socks and http proxy server(docker base)" "back to main menu")

    select opt in "${options[@]}"; do
        case $opt in

        "install hiddify")
            echo "https://github.com/hiddify/hiddify-config/"
            sleep 5
            bash -c "$(curl -Lfo- https://raw.githubusercontent.com/hiddify/hiddify-config/main/common/download_install.sh)"
            ;;

        "install 3x-ui")
            echo "https://github.com/MHSanaei/3x-ui"
            sleep 5
            bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
            ;;
        "install x-ui")
            echo "https://github.com/FranzKafkaYu/x-ui/"
            sleep 5
            bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install_en.sh)
            ;;
        "install xray-reality")
            echo "https://github.com/sajjaddg/xray-reality"
            sleep 5
            bash -c "$(curl -L https://raw.githubusercontent.com/sajjaddg/xray-reality/master/install.sh)"
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
            ;;
        "install openvpn server (pritunl)")
            echo "https://github.com/samsesh/pritunl-install"
            bash <(curl -sSL https://github.com/samsesh/pritunl-install/raw/Localhost/pritunlinstall.sh)

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
            $ docker run --rm -d \
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

        "back to main menu")
            fisrtmenu
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
