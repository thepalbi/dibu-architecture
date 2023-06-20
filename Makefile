requirements:
	@pip freeze > requirements.txt

test:
	@python -m unittest tests/test_*.py

test-rtl:
	@cd rtl_tests && ./run_tests.sh
