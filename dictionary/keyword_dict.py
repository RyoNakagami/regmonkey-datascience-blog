import pathlib
from datetime import date
from typing import Dict, Type, TypeVar

import yaml
from pydantic import BaseModel

T = TypeVar("T", bound=BaseModel)


def load_config(path: pathlib.Path, model: Type[T]) -> T:
    with open(path, encoding="utf-8") as f:
        return model.model_validate(yaml.safe_load(f))


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


class GitCommitTagField(BaseModel):
    category: str
    tag: str
    description: str
    example: str


class GitCommitTagConfig(BaseModel):
    commit_tags: list[GitCommitTagField]


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


class NumberField(BaseModel):
    number: str
    genre: str
    description: str


class NumberConfig(BaseModel):
    numbers: list[NumberField]


class UbuntuDirectoryField(BaseModel):
    directory: str
    description: str


class UbuntuDirectoryConfig(BaseModel):
    UbuntuDirectory: list[UbuntuDirectoryField]


class UnicodeField(BaseModel):
    character: str
    codepoint: str
    name: str
    category: str
    description: str


class UnicodeConfig(BaseModel):
    unicode_list: list[UnicodeField]


class UnitofMeasurementField(BaseModel):
    SI_unit: str
    symbol: str
    scale: str
    binary_scale: str
    description: str | None = None


class UnitOfMeasurementConfig(BaseModel):
    unit_of_measurement: list[UnitofMeasurementField]


class RegexField(BaseModel):
    metachar: str
    meaning: str
    pattern_example: str
    match_example: str


class RegexConfig(BaseModel):
    regex_list: list[RegexField]


_HERE = pathlib.Path(__file__).parent

CONFIG = load_config(_HERE / "dictionary.yml", Config)
COMMAND_CONFIG = load_config(_HERE / "command_dictionary.yml", CommandConfig)
GITCOMMITTAG_CONFIG = load_config(_HERE / "git_commit_tag.yml", GitCommitTagConfig)
GNOME_TOOL_CONFIG = load_config(_HERE / "toollist.yml", GnomeToolConfig)
GREEK_LETTER_CONFIG = load_config(_HERE / "greekletter.yml", GreekLetterConfig)
Number_CONFIG = load_config(_HERE / "magic_numbers.yml", NumberConfig)
UBUNTU_DIRECTORY_CONFIG = load_config(
    _HERE / "ubuntu_directory.yml", UbuntuDirectoryConfig
)
UNICODE_CONFIG = load_config(_HERE / "unicode_dictionary.yml", UnicodeConfig)
UNIT_OF_MEASUREMENT_CONFIG = load_config(
    _HERE / "unit_of_measurement.yml", UnitOfMeasurementConfig
)
REGEX_CONFIG = load_config(_HERE / "regex.yml", RegexConfig)
