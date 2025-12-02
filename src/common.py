# src/common.py
import logging
import os

from dotenv import load_dotenv

from src.config import init_logging_config

load_dotenv()
init_logging_config()

logger = logging.getLogger(__name__)


def get_env_var(var_name: str) -> str:
    env_var = os.environ.get(var_name)
    if not env_var:
        err_msg = f"{var_name} is not set in the environment variables."
        logger.error(err_msg)
        raise EnvironmentError(err_msg)
    return env_var
