<h1 align="center"> Warden Protocol Buenavista v0.4.2 Node Ubuntu Installation with Cosmovisor </h1>

* [Warden Website](https://wardenprotocol.org/)<br>
* [Warden Discord](https://discord.gg/7rzkxXRK)<br>
* [Warden Twitter](https://twitter.com/wardenprotocol)<br>

### Install the requirements.
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
```

### Install Go 1.22.4, the latest version.
```
wget https://dl.google.com/go/go1.22.4.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.22.4.linux-amd64.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
source ~/.profile
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc
```

###  Download the file, move it to the necessary locations, configure it, and install the Cosmovisor application.

```
cd $HOME
mkdir -p $HOME/.warden/cosmovisor/genesis/bin
wget https://github.com/warden-protocol/wardenprotocol/releases/download/v0.4.2/wardend_Linux_x86_64.zip
unzip -o wardend_Linux_x86_64.zip
rm -rf wardend_Linux_x86_64.zip
chmod +x wardend
```
```
mv wardend $HOME/.warden/cosmovisor/genesis/bin/
```
```
sudo ln -s $HOME/.warden/cosmovisor/genesis $HOME/.warden/cosmovisor/current -f
sudo ln -s $HOME/.warden/cosmovisor/current/bin/wardend /usr/local/bin/wardend -f
```
```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.6.0
```

### Create the service file
```
sudo tee /etc/systemd/system/wardend.service > /dev/null << EOF
[Unit]
Description=warden node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.warden"
Environment="DAEMON_NAME=wardend"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.warden/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable wardend
```

### Create the configuration files for our node, replace "monikername" with your desired name and enter the command.
```
wardend init "monikername" --chain-id buenavista-1
```

### Download the network's genesis file and move it.
```
curl -Ls https://snapshots.kjnodes.com/warden-testnet/genesis.json > $HOME/.warden/config/genesis.json
```

### Download the updated addrbook.
```
wget -O $HOME/.warden/config/addrbook.json "https://raw.githubusercontent.com/hazennetworksolutions/warden/main/addrbook.json"
```

### Set up the gas price.
```
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025uward\"/;" ~/.warden/config/app.toml
```

### Set up the seed and peer settings.
```
SEEDS="8288657cb2ba075f600911685670517d18f54f3b@warden-testnet-seed.itrocket.net:18656"
PEERS="b14f35c07c1b2e58c4a1c1727c89a5933739eeea@warden-testnet-rpc.itrocket.net:18656,88806b3c6e081b26a5ab6fd0eda11c51e5f31bdf@37.120.189.81:11256,e850365a8232650623f30356c77583939b896327@116.202.217.20:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.warden/config/config.toml
```

### Set up pruning.
```
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.warden/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.warden/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.warden/config/app.toml
```

### If you want to change the port to 112XX ports, you can use the following code, it's optional.
```
CUSTOM_PORT=112

sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}58\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}56\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}66\"%" $HOME/.warden/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"localhost:9090\"%address = \"localhost:${CUSTOM_PORT}90\"%; s%^address = \"localhost:9091\"%address = \"localhost:${CUSTOM_PORT}91\"%" $HOME/.warden/config/app.toml
```

### Start the node. It takes some time to connect to peers, so please wait
```
sudo systemctl restart wardend
journalctl -fu wardend -o cat
```

### Create a wallet, replace walletname with your desired wallet name
```
wardend keys add walletname
```

### If you want to import a wallet, replace walletname with your desired wallet name
```
wardend keys add walletname --recover
```

### We get the faucet from the Warden Discord #faucet channel. $request wardenwalletadress

### Creating a Validator
Note: Use the code below to get the pubkey
```
wardend comet show-validator
```

Note: Write the pubkey you obtained into the file below using nano.
```
nano /root/validator.json
```
```
{
        "pubkey": pubkey,
        "amount": "1000000uward",
        "moniker": "monikername",
        "identity": "optional",
        "website": "optional",
        "security": "optional",
        "details": "optional",
        "commission-rate": "0.1",
        "commission-max-rate": "0.2",
        "commission-max-change-rate": "0.01",
        "min-self-delegation": "1"
}
```
To save the file you modified, press ctrl+x simultaneously, then press +y, and finally press enter.
### Create the validator
```
wardend tx staking create-validator /root/validator.json \
    --from=walletname \
    --chain-id=buenavista-1 \
    --fees=500uward \
    --node=http://localhost:11257
```

### Let's stake
```
wardend tx staking delegate valoperadress amount000000uward \
--chain-id buenavista-1 \
--from "walletname" \
--fees 500uward \
--node=http://localhost:11257
```

### To completely remove the Warden node
```
sudo systemctl stop wardend
sudo systemctl disable wardend
sudo rm -rf /etc/systemd/system/wardend.service
sudo rm $(which wardend)
sudo rm -rf $HOME/.warden
sed -i "/WARDEN_/d" $HOME/.bash_profile
```
