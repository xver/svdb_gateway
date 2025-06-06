.PHONY: all clean c dpi py help

all: c

c:
	$(MAKE) -f c.mk

py:
	$(MAKE) -f py.mk

clean:
	$(MAKE) -f c.mk clean

help:
	@echo "Makefile Help:"
	@echo "  all     - Build all components (C, DPI, Python)"
	@echo "  c       - Build C utilities"
	@echo "  py      - Run Python utilities"
	@echo "  clean   - Clean all build artifacts"