#!/bin/bash
# Entry point for Docker container

# Environment setup if needed
#export PATH="/usr/local/bin:$PATH"
export BEETSDIR=/app/config

# Launch Beets with user-provided arguments
exec "$@"