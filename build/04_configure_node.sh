#!/usr/bin/env bash

# Configura los nodos core y relay de Cardano.

start=$(date +%s.%N)
banner="--------------------------------------------------------------------------"

# Asegura la carga de variables de entorno
source /home/ubuntu/.bashrc || exit 1

# Copia y ejecuta el script para desplegar como servicio systemd
cd $HELPERS/scripts || exit 1
sudo cp ./deploy-as-systemd.sh $CNODE_HOME/scripts/deploy-as-systemd.sh
$CNODE_HOME/scripts/deploy-as-systemd.sh || exit 1
sudo systemctl daemon-reload
sudo systemctl restart cnode.service || exit 1

# Configuración de topología
if [ "$IS_RELAY_NODE" = true ]; then
    cat > $CNODE_HOME/${NODE_CONFIG}-topology.json << EOF
{
  "Producers": [
    {
      "addr": "${BLOCK_PRODUCER_NODE_IP}",
      "port": 6000,
      "valency": 1
    },
    {
      "addr": "relays-new.cardano-mainnet.iohk.io",
      "port": 3001,
      "valency": 2
    }
  ]
}
EOF
else
    cat > $CNODE_HOME/${NODE_CONFIG}-topology.json << EOF
{
  "Producers": [
    {
      "addr": "${RELAY_NODE_1_IP}",
      "port": 6000,
      "valency": 1
    },
    {
      "addr": "${RELAY_NODE_2_IP}",
      "port": 6000,
      "valency": 1
    }
  ]
}
EOF
fi

end=$(date +%s.%N)
runtime=$(echo "$end - $start" | bc -l)

echo "$banner"
echo "Script runtime: $runtime seconds"
echo "Status of Cardano Node: $(sudo systemctl status cnode.service --no-pager | grep Active)"
echo "$banner"
