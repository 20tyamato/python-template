# Python Template

This repository contains templates for a python project. Copy this repository and start your project.

## Python and Pip Installation

- Python 3.11.5
- pip 25.0.1

## Installation

The package can be installed like this:

```shell
git clone git@github.com:mantra-inc/python-template.git
cp -r python-template new-project
pip install -e .
pip install -r requirements.txt
```

## Lint & Format

This repository uses [Ruff](https://github.com/astral-sh/ruff) to run lint & format codes.
You can set up pre-commit git hooks by running following commands, then formatter is run automatically before commit.

```console
pre-commit install
```

or you can also run manually

```console
python -m ruff check
python -m ruff format
```

## Tests

```console
export PYTHONPATH=$(pwd)
pytest -c config/pytest.ini
pip check
```

## Setup Env

```console
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
```

## pip packages installed

```console
pip install python-dotenv
pip install colorlog
pip install pytest
pip install pre-commit
pip install ruff
```
