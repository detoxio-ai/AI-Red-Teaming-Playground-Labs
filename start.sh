#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Load .env so APP_PORT/AUTH_KEY are available to docker compose and for printing
set -a
[ -f .env ] && . ./.env
set +a

# Allow override at invocation: PORT=16000 ./start.sh
export APP_PORT="${PORT:-${APP_PORT:-15000}}"

# Resolve public IP (fallback to localhost if curl fails)
PUBLIC_IP="$(curl -fsS ifconfig.io || true)"
if [[ -z "$PUBLIC_IP" ]]; then
  PUBLIC_IP="localhost"
fi

# Bring up the stack (compose reads .env automatically)
docker compose -f docker-compose-openai.yaml up -d

# Print login URL
AUTH_KEY="$(grep -E '^AUTH_KEY=' .env | cut -d= -f2- | tr -d '\r' || true)"
echo ""
echo "✅ Playground up. Login:"
echo "   http://${PUBLIC_IP}:${APP_PORT}/login?auth=${AUTH_KEY}"
echo "   (Challenges spawn on ports like 4001–4012)"
echo ""

