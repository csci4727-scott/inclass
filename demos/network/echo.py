import socket
import sys

if len(sys.argv) < 3:
    raise SystemExit("usage: echo.py server PORT | echo.py client HOST PORT")
mode = sys.argv[1]
if mode == "server":
    with socket.socket() as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind(("127.0.0.1", int(sys.argv[2])))
        s.listen(1)
        print("server: listening", flush=True)
        with s.accept()[0] as conn:
            data = conn.recv(4096)
            print(f"server: received {data!r}", flush=True)
            conn.sendall(data)
elif mode == "client":
    with socket.create_connection((sys.argv[2], int(sys.argv[3]))) as conn:
        data = sys.stdin.buffer.read()
        conn.sendall(data)
        print(f"client: echoed {conn.recv(4096)!r}")
else:
    raise SystemExit("unknown mode")
