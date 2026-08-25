#!/usr/bin/env python3
"""
config.py
Centralized configuration using Pydantic for env vars.
"""

from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List, Optional


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    # Logging
    LOG_LEVEL: str = "INFO"

    # Vikunja
    VIKUNJA_API_URL: str
    VIKUNJA_BEARER_TOKEN: str
    VIKUNJA_TASK_POLLING_INTERVAL: int = 20
    VIKUNJA_PROJECT_NAMES: str = "crewai,crewai-test"

    # LLM
    LOCAL_LLM_BASE_URL: str = "http://localhost:8000/v1"
    LOCAL_LLM_MODEL: str = "nemoclaw"
    LOCAL_LLM_PROVIDER: str = "openai"
    LOCAL_LLM_MAX_TOKENS: int = 4096
    LOCAL_LLM_API_KEY: str = "mock-key-if-required"

    # Gitea
    GITEA_USER: str = "automation-bot"
    GITEA_TOKEN: str
    GITEA_BASE_URL: str = "https://gitea.admin.dettonville.int"
    GIT_USER_NAME: str = "Automation Bot"
    GIT_USER_EMAIL: str = "automation@dettonville.int"

    # LangGraph
    LANGGRAPH_ROUTER_URL: str = "http://langgraph-router:8000/v1/orchestrate"
    LANGGRAPH_API_KEY: str

    # CocoIndex
    COCOINDEX_DB_URL: str = "postgres://cocoindex:cocoindex@postgres-cocoindex:5432/cocoindex"
    # COCO_EMBED_MODEL: str = "sentence-transformers/all-MiniLM-L6-v2"
    COCO_EMBED_MODEL: str = "nomic-embed-text"

    EMBEDDING_API_BASE: str = "http://localhost:11434"
    EMBEDDING_API_KEY: Optional[str] = "ollama"

    # Other
    MAX_IO_WORKERS: int = 4
    TARGET_PROJECT_NAMES: str = "crewai,crewai-test"  # alias

    @property
    def VIKUNJA_HEADERS(self):
        return {
            "Authorization": f"Bearer {self.VIKUNJA_BEARER_TOKEN}",
            "Content-Type": "application/json",
        }

    @property
    def vikunja_project_list(self) -> List[str]:
        return [name.strip().lower() for name in self.VIKUNJA_PROJECT_NAMES.split(",") if name.strip()]


# Singleton instance
settings = Settings()
