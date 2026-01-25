CC = clang
CFLAGS = -std=c99 -Wall -Werror -D_POSIX_C_SOURCE=200809L
LDFLAGS = -lcurl
TARGET = build/situation-room
ANALYZER = build/analyzer
SRCDIR = src

# Main monitor sources
MON_SRCS = $(SRCDIR)/main.c $(SRCDIR)/http_check.c $(SRCDIR)/config.c $(SRCDIR)/logger.c
MON_OBJS = $(MON_SRCS:.c=.o)

all: $(TARGET) $(ANALYZER)

$(TARGET): $(MON_OBJS)
	$(CC) $(CFLAGS) $(MON_OBJS) -o $(TARGET) $(LDFLAGS)

$(ANALYZER): $(SRCDIR)/analyzer.c 
	$(CC) $(CFLAGS) $(SRCDIR)/analyzer.c -o $(ANALYZER)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(ANAZLYER) $(SRCDIR)/*.o situation-room.log

.PHONY: all clean
