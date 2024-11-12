.PHONY: help unittest format lint typecheck test audit

SRC = src data tests

# Default target
help:
	@echo "Available targets:"
	@echo "  make run       - Run all ETL steps"
	@echo "  make unittest  - Run unittests with pytest"
	@echo "  make format    - Reformat using rye"
	@echo "  make lint      - Lint using rye"
	@echo "  make typecheck - Typecheck with pyright"
	@echo "  make test      - Run lint, typecheck, and unittest sequentially"

# Check if .venv exists and is up to date
.venv: pyproject.toml uv.lock
	@echo "==> Installing packages"
	@uv sync
	@touch $@

# Run unittests with pytest
unittest: .venv
	@echo "==> Running unit tests"
	@.venv/bin/pytest $(SRC) --sw

# Reformat using rye
format: .venv
	@echo "==> Formatting all files"
	@.venv/bin/black $(SRC)
	@.venv/bin/ruff check --fix $(SRC)

# Lint using rye
lint: .venv
	@echo "==> Linting all files"
	@.venv/bin/ruff check $(SRC)

# Typecheck with pyright
typecheck: .venv
	@echo "==> Typechecking"
	@.venv/bin/pyright $(SRC)

# Run lint, typecheck, and unittest sequentially
test: lint typecheck unittest audit

audit: .venv
	@echo "==> Auditing"
	@.venv/bin/shelf audit

run: .venv
	@echo "==> Running the ETL"
	@.venv/bin/shelf run

db: run
	@echo "==> Entering DuckDB shell"
	@.venv/bin/shelf db

clean:
	rm -rf data/* metadata/*
