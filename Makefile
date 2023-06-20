requirements:
	@pip freeze > requirements.txt

test:
	@python -m unittest tests/test_*.py

test-rtl:
	$(MAKE) -C rtl_tests