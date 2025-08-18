#!/bin/bash
# LLM Server Management Script

OLLAMA_USER="{{ bootstrap_llm_server__ollama_user }}"

case "$1" in
    list-models)
        sudo -u $OLLAMA_USER /usr/local/bin/ollama list
        ;;
    pull-model)
        if [ -z "$2" ]; then
            echo "Usage: $0 pull-model <model-name>"
            exit 1
        fi
        sudo -u $OLLAMA_USER /usr/local/bin/ollama pull "$2"
        ;;
    remove-model)
        if [ -z "$2" ]; then
            echo "Usage: $0 remove-model <model-name>"
            exit 1
        fi
        sudo -u $OLLAMA_USER /usr/local/bin/ollama rm "$2"
        ;;
    status)
        systemctl status ollama
        {% if bootstrap_llm_server__install_open_webui %}
        systemctl status open-webui
        {% endif %}
        {% if bootstrap_llm_server__install_ollama_webui %}
        systemctl status ollama-webui
        {% endif %}
        {% if bootstrap_llm_server__configure_nginx %}
        systemctl status nginx
        {% endif %}
        ;;
    restart)
        systemctl restart ollama
        {% if bootstrap_llm_server__install_open_webui %}
        systemctl restart open-webui
        {% endif %}
        {% if bootstrap_llm_server__install_ollama_webui %}
        systemctl restart ollama-webui
        {% endif %}
        {% if bootstrap_llm_server__configure_nginx %}
        systemctl restart nginx
        {% endif %}
        ;;
    logs)
        journalctl -u ollama -f
        ;;
    *)
        echo "Usage: $0 {list-models|pull-model|remove-model|status|restart|logs}"
        exit 1
        ;;
esac
