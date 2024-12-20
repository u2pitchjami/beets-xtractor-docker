#!/bin/bash

# Nom du conteneur
CONTAINER_NAME="beets-xtractor"

# Commande à exécuter
COMMAND="$@"

if [ -z "$COMMAND" ]; then
  echo "Usage: $0 <beets_command>"
  echo "Exemple: $0 import /app/data/music"
  exit 1
fi

# Lancer la commande dans le conteneur via Docker Compose
docker compose run --rm beets beet "$@"