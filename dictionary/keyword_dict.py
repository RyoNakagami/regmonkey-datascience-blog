import pathlib
from typing import Dict, List
from datetime import date
import yaml
from pydantic import BaseModel


class KeywordField(BaseModel):
    genre: str
    comment: str
    updated_date: date


class Config(BaseModel):
    keywords: Dict[str | int, KeywordField]


def new_config(paths_to_config: List[pathlib.Path]) -> Config:
    """Generates a Config object from a yaml file.

    Args:
        path_to_config (str): Path to the configuration file.

    Returns:
        Config: A Config object.

    """

    merged_config = {}

    for path in paths_to_config:
        with open(path, encoding="utf-8") as f:
            yaml_config = yaml.safe_load(f)
            merged_config.update(yaml_config)
    config: Config = Config.model_validate(merged_config)

    return config


# Define multiple config paths
CONFIG_FILES = [
    pathlib.Path(__file__).parent / "dictionary.yml",
]
CONFIG: Config = new_config(paths_to_config=CONFIG_FILES)
