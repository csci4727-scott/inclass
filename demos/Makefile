CC := gcc
CFLAGS := -Wall -Wextra -O2 -g
LDFLAGS := -lm
BIN := sqrts-demo
SRC := sqrts.c
PAGES ?= 64

.PHONY: all run clean

all: $(BIN)

$(BIN): $(SRC)
	$(CC) $(CFLAGS) $(SRC) $(LDFLAGS) -o $(BIN)

run: $(BIN)
	./$(BIN) $(PAGES)

clean:
	rm -f $(BIN)
