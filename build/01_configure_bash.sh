#!/usr/bin/env bash

# Configura bash con un conjunto de alias y variables requeridas.

start=$(date +%s.%N)

banner="--------------------------------------------------------------------------"

# Definir rutas de archivos y directorios
PROJECT_DIR="$HOME/git/cardano-stake-pool-aws"  # Asegúrate de que esta ruta sea dinámica o configurable.
BASHRC_SOURCE="${PROJECT_DIR}/config/.bashrc"
BASHRC_TARGET="$HOME/.bashrc"
NODE_CONFIG_FILE="$HOME/.node-config"  # Hace que esta ruta sea fácilmente modificable o documentada.

# Copiar el archivo .bashrc personalizado
if [ -f "${BASHRC_SOURCE}" ]; then
    cp -f "${BASHRC_SOURCE}" "${BASHRC_TARGET}"
else
    echo "Archivo ${BASHRC_SOURCE} no encontrado."
    exit 1
fi

# Evaluar los alias y variables del .bashrc
if ! source "${BASHRC_TARGET}"; then
    echo "Error al cargar ${BASHRC_TARGET}"
    exit 1
fi

# Configurar NETWORK_ARGUMENT basado en NODE_CONFIG
configure_network_argument() {
    local network_arg=""
    case "$NODE_CONFIG" in
        "mainnet")
            network_arg="--mainnet"
            ;;
        "testnet")
            network_arg="--testnet-magic 1097911063"
            ;;
        "guild")
            network_arg="--guild"
            ;;
        "staging")
            network_arg="--staging"
            ;;
        *)
            echo "NODE_CONFIG no reconocido: $NODE_CONFIG"
            exit 1
    esac

    if ! sed -i -e "s|NETWORK_ARGUMENT=|NETWORK_ARGUMENT=${network_arg}|g" "${NODE_CONFIG_FILE}"; then
        echo "Error al configurar NETWORK_ARGUMENT en ${NODE_CONFIG_FILE}"
        exit 1
    fi
}

# Llamar a la función configure_network_argument
configure_network_argument

# Tiempo de ejecución del script
end=$(date +%s.%N)
runtime=$(echo "$end - $start" | bc -l)

# Mostrar información del script
echo "$banner"
echo "Script runtime: $runtime seconds"
echo "HELPERS: $HELPERS"
echo "NETWORK_ARGUMENT: $(grep 'NETWORK_ARGUMENT=' ${NODE_CONFIG_FILE})"
echo "$banner"
