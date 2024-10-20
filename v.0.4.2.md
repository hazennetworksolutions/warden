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
rm -rf wardenprotocol
git clone --depth 1 --branch v0.3.1 https://github.com/warden-protocol/wardenprotocol/
cd wardenprotocol
make install
```


### Create the service file
```
sudo tee /etc/systemd/system/wardend.service > /dev/null <<EOF
[Unit]
Description=Warden node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.warden
ExecStart=$(which wardend) start --home $HOME/.warden
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
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
PEERS="b14f35c07c1b2e58c4a1c1727c89a5933739eeea@warden-testnet-peer.itrocket.net:18656,41a3a66993696c5e5d44945de2036227a4578fb3@195.201.241.107:56296,194b68f0df274d1d169b08681f3b7b13e1f25b06@95.165.89.222:26686,4ee71e3dfbd6669428e20e281d42051aeedc2b28@5.9.116.21:27356,8a51e39c91c1667667daeb47a1a9e80b705d9a88@188.165.213.192:26656,b38a2dbbd5223a10c10f1bc4f66cfe3f0d781a65@144.76.202.120:21656,ac1a5d4489c09589a0b57e05310643b0cec31447@37.120.169.122:26656,d4af4ec2657c9756c87aa5b49d2d724b45f96d8b@188.165.228.73:26656,2baf881692c8f98e757b055fbc87cbca7197fbb9@152.53.33.174:26656,db6947c73751a64b81360e2487c85c54ec0c81a5@81.17.97.89:656,8e50a2f74459baf9265b5488ecc4bbbff2d6f69d@94.130.164.82:27356"
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
