`dump-certs` is a replacement for `/usr/bin/security find-certificate`. It uses the
Foundation framework and the OSX Security APIs to read and print the system roots.

This tool does not replace any other functionality from security-tool. It is only intended
as a pure alternative for languages or packages that wish to read the OSX system roots,
such as `x509-system` and `go`.

This code is mostly ported from Go's source.
