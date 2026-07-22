#!/usr/bin/env bash
set -euo pipefail

# --- CONFIGURAZIONE VARIABILI D'AMBIENTE DALLA PIATTAFORMA ---
TARGET_HOST="${TARGET_HOST:-}"
SSH_USER="${SSH_USER:-suse-admin}"
SSH_KEY_PATH="${SSH_KEY_PATH:-~/.ssh/id_rsa}"
PROSPECT_SLUG="${PROSPECT_SLUG:-demo-prospect}"
INDUSTRY_VERTICAL="${INDUSTRY_VERTICAL:-bfsi}"

# Credenziali GCP iniettate come variabile di ambiente dalla piattaforma (n8n/env0/Instruqt)
GCP_SA_KEY_JSON=$GCP_CREDENTIALS_JSON

if [ -z "$TARGET_HOST" ]; then
    echo "❌ [ERROR] TARGET_HOST non definito. Impossibile procedere."
    exit 1
fi

# --- GESTIONE CREDENZIALI GCP EFFIMERE PER ANSIBLE ---
TEMP_GCP_KEY_FILE=""

if [ -n "$GCP_SA_KEY_JSON" ]; then
    TEMP_GCP_KEY_FILE="/tmp/gcp_key_${PROSPECT_SLUG}_$$.json"
    echo "$GCP_SA_KEY_JSON" > "$TEMP_GCP_KEY_FILE"
    chmod 600 "$TEMP_GCP_KEY_FILE"
    
    # TRAP SECURITY GUARANTEE: Elimina il file della chiave alla chiusura dello script
    trap 'rm -f "$TEMP_GCP_KEY_FILE"' EXIT INT TERM
    
    export GCP_SERVICE_ACCOUNT_FILE="$TEMP_GCP_KEY_FILE"
    export GOOGLE_APPLICATION_CREDENTIALS="$TEMP_GCP_KEY_FILE"
    echo "🔑 [SECURITY] Credenziale JSON esportata in ambiente temporaneo sicuro: $TEMP_GCP_KEY_FILE"
elif [ -n "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]; then
    echo "🔑 [SECURITY] Utilizzo file credenziali esistente: $GOOGLE_APPLICATION_CREDENTIALS"
else
    echo "⚠️ [WARN] Nessuna credenziale JSON GCP rilevata in ambiente. Assicurarsi che il runner sia autenticato."
fi

# --- GENERAZIONE INVENTORY DINAMICO TEMPORANEO ---
ANSIBLE_INVENTORY="/tmp/inventory_${PROSPECT_SLUG}_$$.ini"
trap 'rm -f "$TEMP_GCP_KEY_FILE" "$ANSIBLE_INVENTORY"' EXIT INT TERM

cat <<EOF > "$ANSIBLE_INVENTORY"
[rancher_nodes]
${TARGET_HOST} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_KEY_PATH} ansible_python_interpreter=/usr/bin/python3
EOF

# --- ESECUZIONE ANSIBLE PLAYBOOK ---
export ANSIBLE_HOST_KEY_CHECKING=False

echo "🚀 [DX-ENGINE] Avvio Data Seeding Ansible per Prospect: ${PROSPECT_SLUG}..."

ansible-playbook -i "$ANSIBLE_INVENTORY" site.yml \
  --extra-vars "prospect_name=${PROSPECT_SLUG}" \
  --extra-vars "industry_vertical=${INDUSTRY_VERTICAL}" \
  --extra-vars "target_host=${TARGET_HOST}"

echo "✅ [DX-ENGINE] Data Seeding completato con successo per ${PROSPECT_SLUG}!"
