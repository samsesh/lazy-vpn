#!/bin/bash
echo "$(tput setaf 2)welcome to lazy vpn script$(tput sgr0)"

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
    #!/bin/bash

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

vpnserver() {

    PS3="Please select vpn server for installing: "

    options=("install 3x-ui" "install x-ui" "install openconnect server" "Quit")

    select opt in "${options[@]}"; do
        case $opt in
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
        echo  "https://github.com/samsesh/pritunl-install"
            bash <(curl -sSL https://github.com/samsesh/pritunl-install/raw/Localhost/pritunlinstall.sh)

            ;;
        "install openconnect server")
            echo "You chose Option 3"

            ;;
        "back to main menu")
            fisrtmenu
            ;;
        *) echo "Invalid option $REPLY" ;;
        esac
    done

}

fisrtmenu() {
    PS3="Please select an option: "
    options=("server options" "install vpn server" "uninstall vpn server" "Quit")

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
        "uninstall vpn server")
            echo "soon"

            ;;
        "Quit")
            exit
            ;;
        *) echo "Invalid option $REPLY" ;;
        esac
    done

}
fisrtmenu
