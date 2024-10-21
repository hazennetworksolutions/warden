#!/bin/bash

# Logo and Color Definitions
LOGO="
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
CoreNode 2024 All rights reserved.
"
GREEN="\e[1m\e[1;32m"
NC="\e[0m"

# Functions for printing messages
printGreen() {
    echo -e "${GREEN}$1${NC}"
}

printLine() {
    echo "-----------------------------------------"
}

printLogo() {
    echo -e "${GREEN}${LOGO}${NC}"
    printLine
}

# Display Logo and Welcome Message
clear
printLogo
printGreen "Welcome to the Warden & Slinky Setup Menu"

# Menu options
PS3="Please select the script you want to run: "

options=("Install Warden" "Install Slinky" "Exit")

select opt in "${options[@]}"; do
    case $opt in
        "Install Warden")
            printGreen "Starting Warden installation..."
            bash <(curl -s https://raw.githubusercontent.com/hazennetworksolutions/warden/refs/heads/main/0.4.2-autoscript.sh)
            break
            ;;
        "Install Slinky")
            printGreen "Starting Slinky installation..."
            bash <(curl -s https://raw.githubusercontent.com/hazennetworksolutions/warden/refs/heads/main/slinky.autoscript.sh)
            break
            ;;
        "Exit")
            printGreen "Exiting the setup..."
            exit 0
            ;;
        *) 
            echo -e "${GREEN}Invalid option. Please try again.${NC}" 
            ;;
    esac
done
