#!/usr/bin/env bash

# Give directories execute + read + write permissions
find /home/container-user/docker/ollama/data -type d -exec chmod 755 {} +

# Keep normal files readable and writable by container-user
find /home/container-user/docker/ollama/data -type f -exec chmod 644 {} +
