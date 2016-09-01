dump-certs: main.m
	$(CC) -o $@ $< $(CFLAGS) $(LDFLAGS) -framework Security -framework Foundation
