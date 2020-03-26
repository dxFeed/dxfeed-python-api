from build import build_extensions


def pytest_sessionstart(session):
    build_extensions()
