import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parents[1]))
from build import build_extensions


def pytest_sessionstart(session):
    build_extensions()
