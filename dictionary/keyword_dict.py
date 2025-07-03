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


class CommandField(BaseModel):
    command: str
    language: str
    description: str
    examples: str


class CommandConfig(BaseModel):
    command_list: list[CommandField]


class GnomeToolField(BaseModel):
    tool: str
    genre: str
    description: str
    reference: str


class GnomeToolConfig(BaseModel):
    tool_list: list[GnomeToolField]


class GreekLetterField(BaseModel):
    capital: str
    small: str
    name: str
    capital_input: str
    small_input: str
    capital_unicode: str | None = None
    small_unicode: str | None = None


class GreekLetterConfig(BaseModel):
    GreekLetter: list[GreekLetterField]


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


def new_commandconfig(paths_to_config: List[pathlib.Path]) -> CommandConfig:
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
    config: CommandConfig = CommandConfig.model_validate(merged_config)

    return config


def new_gnome_tool_config(paths_to_config: List[pathlib.Path]) -> GnomeToolConfig:
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
    config: GnomeToolConfig = GnomeToolConfig.model_validate(merged_config)

    return config


def new_greek_letter_config(paths_to_config: List[pathlib.Path]) -> GreekLetterConfig:
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
    config: GreekLetterConfig = GreekLetterConfig.model_validate(merged_config)

    return config


# Define multiple config paths
CONFIG_FILES = [pathlib.Path(__file__).parent / "dictionary.yml"]
COMMAND_CONFIG_FILES = [pathlib.Path(__file__).parent / "command_dictionary.yml"]
GNOME_TOOL_CONFIG_FILES = [pathlib.Path(__file__).parent / "toollist.yml"]
GREEK_LETTER_CONFIG_FILES = [pathlib.Path(__file__).parent / "greekletter.yml"]

# Create Config and CommandConfig instances
CONFIG: Config = new_config(paths_to_config=CONFIG_FILES)
COMMAND_CONFIG: CommandConfig = new_commandconfig(paths_to_config=COMMAND_CONFIG_FILES)
GNOME_TOOL_CONFIG: GnomeToolConfig = new_gnome_tool_config(
    paths_to_config=GNOME_TOOL_CONFIG_FILES
)
GREEK_LETTER_CONFIG: GreekLetterConfig = new_greek_letter_config(
    paths_to_config=GREEK_LETTER_CONFIG_FILES
)
