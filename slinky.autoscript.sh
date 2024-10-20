#!/bin/bash

#!/bin/bash
LOG_FILE="/var/log/warden_node_install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

printGreen() {
    echo -e "\033[32m$1\033[0m"
}

printLine() {
    echo "------------------------------"
}

# Function to print the node logo
function printNodeLogo {
    echo -e "\033[32m"
    echo "          
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
---------------------------------------------    ---------------------------------------------------
-------------------------------------      -       -     -------------------------------------------
--------------------------------          -  ----  -           -------------------------------------
-----------------------------      ---------       ---------      ----------------------------------
--------------------------     ------- -  ----   ----  - -------     -------------------------------
------------------------    ---- ----  ---  -------  ---  --------     -----------------------------
----------------------    ------ ----  -----  ---  ----- ------------    ---------------------------
--------------------    --         --  ------     ------  -------------    -------------------------
--------------------------------  -----------    ---------------------------------------------------
----------------------------------------------------------------------------------------------------
----------               -------           --------                ------                  ---------
-------                  ----                ------                  ----                  ---------
------     ---------     ---     --------     -----    ----------     ---    -----------------------
------   ------------------    ------------    ----    -----------    ---    -----------------------
-----    ------------------    ------------    ----                  ----               ------------
-----    ------------------    ------------    ----                ------               ------------
------    -----------    ---    ----------    -----    ---------     ----    -----------------------
-------     ------      -----     ------     ------    ----------    ----    ------------- ---------
---------             ---------            --------    ----------    ----                  ---------
-------------    -------------------  ------      --------------------------------------------------
--------------------------------------------  ---  -------------------------------------------------
--------------------------------------------      --------------------------------------------------
-----      ----------    -------           ---- ---              --------                  ---------
-----       ---------    -----               ------                 -----                  ---------
-----         -------    ----    --------     -----    ---------     ----    -----------------------
-----    --     -----    ---    -----------    ----    -----------    ---    -----------------------
-----    ---     ----    ---   ------------    ----    -----------    ---               ------------
-----    -----     --    ---   ------------    ----    -----------    ---              -------------
-----    -------    -    ---    ----------    -----   -----------    ----    -----------------------
-----    ---------      -----      -----     ------                 -----                  ---------
-----    ----------     -------             -------               -------                  ---------
-----------------------------------     ------------------------------------------------------------
----------------------------------------------   ---------------------------------------------------
-------------------    --------- ----  ------     ------  --          --    ------------------------
---------------------   -------- ----  ------  -  ------  ---  --------   --------------------------
----------------------    ------ ----  ----  ----  -----  ---  ------    ---------------------------
------------------------     --------  ---  -------  --- ---------     -----------------------------
---------------------------     --------  ----   ----  --------     --------------------------------
-----------------------------       --------       --------       ----------------------------------
---------------------------------         -  ----  -          --------------------------------------
---------------------------------------   --  ---  -    --------------------------------------------
----------------------------------------------   ---------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
CoreNode 2024 All rights reserved."
    echo -e "\033[0m"
}

# Show the node logo
printNodeLogo

# User confirmation to proceed
echo -n "Type 'yes' to start the installation Slinky Service and press Enter: "
read user_input

if [[ "$user_input" != "yes" ]]; then
  echo "Installation cancelled."
  exit 1
fi

# Function to print in green
printGreen() {
  echo -e "\033[32m$1\033[0m"
}

printGreen "Starting installation..."
sleep 1

printGreen "If there are any, clean up the previous installation files"

sudo systemctl stop wardend
sudo systemctl disable wardend

# Color definitions (for colored terminal output)
GREEN="\e[1m\e[1;32m"
NC="\e[0m"

printGreen() {
    echo -e "\033[32m$1\033[0m"
}

printLine() {
    echo "------------------------------"
}

# Instruction message
print_instructions() {
    echo -e "${GREEN}Please make sure that the following settings are in your 'app.toml' file:${NC}"
    echo "###############################################################################"
    echo "###                                  Oracle                                 ###"
    echo "###############################################################################"
    echo "[oracle]"
    echo "# Enabled indicates whether the oracle is enabled."
    echo 'enabled = "true"'
    echo ""
    echo "# Oracle Address is the URL of the out-of-process oracle sidecar. This is used to"
    echo "# connect to the oracle sidecar when the application boots up. Note that the address"
    echo "# can be modified at any point, but will only take effect after the application is"
    echo "# restarted. This can be the address of an oracle container running on the same"
    echo "# machine or a remote machine."
    echo 'oracle_address = "127.0.0.1:8080"'
    echo ""
    echo "# Client Timeout is the time that the client is willing to wait for responses from"
    echo "# the oracle before timing out."
    echo 'client_timeout = "2s"'
    echo ""
    echo "# MetricsEnabled determines whether oracle metrics are enabled. Specifically"
    echo "# this enables instrumentation of the oracle client and the interaction between"
    echo "# the oracle and the app."
    echo 'metrics_enabled = "true"'
    echo ""
    echo -e "${GREEN}Then, restart the Warden and Slinky services:${NC}"
    echo "1. Restart the services:"
    echo "   sudo systemctl daemon-reload && sudo systemctl restart wardend && sudo systemctl restart slinkyd"
    echo ""
    echo "To view the service logs:"
    echo "   journalctl -fu slinkyd --no-hostname"
}

# Get PORT information from the user
read -p "Enter your PORT (2-digit): " PORT
echo 'export PORT='$PORT

# Add the PORT information to the .bash_profile
echo "export WARDEN_PORT="$PORT"" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Go kurulumunu gerçekleştirme
echo -e "${GREEN}Installing Go...${NC}"
cd $HOME
VER="1.23.0"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin

# Versiyon kontrolü
echo $(go version) && sleep 1

# Start the installation of Slinky
echo -e "${GREEN}Starting Slinky installation...${NC}" && sleep 1
cd $HOME
rm -rf slinky
git clone https://github.com/skip-mev/slinky.git
cd slinky
git checkout v1.0.5
make build
sudo mv build/slinky /usr/local/bin/

# Create the Slinky service file
echo -e "${GREEN}Creating the Slinky service file...${NC}"
sudo tee /etc/systemd/system/slinkyd.service > /dev/null <<EOF
[Unit]
Description=Warden Slinky Oracle
After=network-online.target

[Service]
User=$USER
ExecStart=$(which slinky) --market-map-endpoint 127.0.0.1:${WARDEN_PORT}090
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the services
echo -e "${GREEN}Starting the Slinky service...${NC}" && sleep 1
sudo systemctl daemon-reload
sudo systemctl enable slinkyd
sudo systemctl start slinkyd

# Display instructions to the user
print_instructions
    
echo -e "${GREEN} You're Ready! ${NC}"
