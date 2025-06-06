CC = gcc
BASE_CFLAGS = -fPIC -shared -I../c/include -I../dpi/include -I/usr/include
CFLAGS ?= $(BASE_CFLAGS)
LDFLAGS = -lsqlite3
BIN_DIR = ../../bin
TARGET = $(BIN_DIR)/libdbdpi.so
SQLITE_PRIMITIVE_SRC = ../c/src/sqlite_primitive.c
SQLITE_DPI_SRC = ../dpi/src/sqlite_dpi.c

.PHONY: all clean

all: $(BIN_DIR) $(TARGET)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(TARGET): $(SQLITE_PRIMITIVE_SRC) $(SQLITE_DPI_SRC)
	@echo "CFLAGS: $(CFLAGS)"
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

clean:
	rm -f $(TARGET)