#!/bin/bash
echo "welcome to lazy vpn script"

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

    echo "Filesystem Information:"
    echo "------------------------------------"

    df -h
    echo ""

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
        "back")
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
            # Add your code here for Option 2
            ;;
        "uninstall vpn server")
            echo "soon"
            # Add your code here for Option 3
            ;;
        "Quit")
            exit
            ;;
        *) echo "Invalid option $REPLY" ;;
        esac
    done

}
fisrtmenu
