#!/usr/bin/env bash

DOCKER_LIST_CMD="docker exec -it ollama ollama list"
echo "${DOCKER_LIST_CMD}"
eval "${DOCKER_LIST_CMD}"

## to remove model
#docker exec -it ollama ollama rm qwen2.5-coder:32b

echo "1. List All Downloaded Models (/api/tags)"
CURL_LIST_CMD="curl http://localhost:11434/api/tags | jq"
echo "${CURL_LIST_CMD}"
eval "${CURL_LIST_CMD}"

echo "2. List Currently Loaded / Running Models (/api/ps)"
CURL_LIST_CMD="curl http://localhost:11434/api/ps | jq"
echo "${CURL_LIST_CMD}"
eval "${CURL_LIST_CMD}"

echo "3. List all OpenAI-Compatible Endpoint models (/v1/models)"
CURL_LIST_CMD="curl http://localhost:11434/v1/models | jq"
echo "${CURL_LIST_CMD}"
eval "${CURL_LIST_CMD}"
