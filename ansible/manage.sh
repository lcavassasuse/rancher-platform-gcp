#!/usr/bin/env bash
set -euo pipefail

# --- CONFIGURAZIONE VARIABILI DI INGRESSO (Passate da n8n / env0) ---
TARGET_HOST="${TARGET_HOST:-}"
SSH_USER="${SSH_USER:-suse-admin}"
SSH_KEY_PATH="${SSH_KEY_PATH:-~/.ssh/id_rsa}"
PROSPECT_SLUG="${PROSPECT_SLUG:-acme-corp}"
INDUSTRY_VERTICAL="${INDUSTRY_VERTICAL:-bfsi}"

if [ -z "$TARGET_HOST" ]; then
    echo "❌ Errore: TARGET_HOST non definito. Fornire l'IP pubblico dell'istanza GCP."
    exit 1
fi

echo "🚀 Avvio Data Seeding e Setup Rancher per Prospect: ${PROSPECT_SLUG} [Vertical: ${INDUSTRY_VERTICAL}]"

# --- GENERAZIONE INVENTORY DINAMICO TEMPORANEO ---
ANSIBLE_INVENTORY="/tmp/inventory_${PROSPECT_SLUG}.ini"
cat <<EOF > "$ANSIBLE_INVENTORY"
[rancher_nodes]
${TARGET_HOST} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_KEY_PATH} ansible_python_interpreter=/usr/bin/python3
EOF

# --- ESECUZIONE PLAYBOOK ANSIBLE ---
export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook -i "$ANSIBLE_INVENTORY" site.yml \
  --extra-vars "prospect_name=${PROSPECT_SLUG}" \
  --extra-vars "industry_vertical=${INDUSTRY_VERTICAL}" \
  --extra-vars "target_host=${TARGET_HOST}"

echo "✅ Deployment Ansible completato con successo su GCP!"
