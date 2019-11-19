.PHONY: test clean docker-build

# test
test:
	python -m pytest -vs

docker-build:
	docker build -t devopsexchange/python-default:latest .

# remove pyc & __pycache__ files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

