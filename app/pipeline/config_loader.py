"""
Pipeline configuration loader.

Loads optional JSON config from disk so thresholds can be changed
without editing Python code.
"""

from __future__ import annotations

import json
import logging
import os
from pathlib import Path
from typing import Any, Dict

logger = logging.getLogger(__name__)


DEFAULT_PIPELINE_CONFIG_PATH = "config/pipeline_config.json"


def load_pipeline_config() -> Dict[str, Any]:
    """
    Load optional pipeline config from JSON file.

    Resolution order:
    1. PIPELINE_CONFIG_FILE env var
    2. config/pipeline_config.json

    Returns:
        Dict config compatible with PipelineOrchestrator.create_full_pipeline.
    """
    config_file = os.getenv("PIPELINE_CONFIG_FILE", DEFAULT_PIPELINE_CONFIG_PATH)
    config_path = Path(config_file)

    if not config_path.exists():
        logger.info(
            "No pipeline config file found at %s. Using env vars/defaults.",
            config_path,
        )
        return {}

    try:
        payload = json.loads(config_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        logger.warning(
            "Invalid JSON in %s (%s). Falling back to env vars/defaults.",
            config_path,
            exc,
        )
        return {}
    except Exception as exc:  # pragma: no cover - defensive
        logger.warning(
            "Could not read %s (%s). Falling back to env vars/defaults.",
            config_path,
            exc,
        )
        return {}

    if not isinstance(payload, dict):
        logger.warning(
            "Pipeline config in %s must be a JSON object. Got %s. Ignoring file.",
            config_path,
            type(payload).__name__,
        )
        return {}

    logger.info("Loaded pipeline config from %s", config_path)
    return payload

