# src/utils.py
import os

from common import logger


def get_env_var(var_name: str) -> str:
    env_var = os.environ.get(var_name)
    if not env_var:
        logger.error(f"{var_name} is not set in the environment variables.")
        raise EnvironmentError(f"{var_name} is not set in the environment variables.")
    return env_var

