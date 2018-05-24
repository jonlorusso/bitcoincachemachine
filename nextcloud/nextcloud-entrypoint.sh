#!/bin/bash
#file nextcloud-entrypoint


wait-for-it -t 0 514 manager1

echo "Calling up.sh for nextcloud."
bash -c /app/up.sh

