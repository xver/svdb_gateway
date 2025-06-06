.PHONY: lint test

lint:
	flake8 --ignore=E501,E302,E305 ../py

test:
	pytest ../py