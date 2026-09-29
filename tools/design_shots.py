"""Screenshots of a design mockup (*.dc.html) with tabs: clicks every tab and
saves the whole page. Used to lay screens out 1:1 from `design/`.

Usage: py -3.14 tools/design_shots.py "<mockup file name>" <out_dir> [scale]
  Serves design/Защити огород дизайн/ on 127.0.0.1:8065 itself.
  Tabs are the pill buttons at the top (their text starts with the tab id "01 …").
"""
import base64, json, os, socket, struct, subprocess, sys, threading, time, urllib.parse, urllib.request
import functools, http.server
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DESIGN = ROOT / "design" / "Защити огород дизайн"
name, out_dir = sys.argv[1], Path(sys.argv[2])
scale = float(sys.argv[3]) if len(sys.argv) > 3 else 0.5
out_dir.mkdir(parents=True, exist_ok=True)

handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=str(DESIGN))
handler.log_message = lambda *a: None
srv = http.server.ThreadingHTTPServer(("127.0.0.1", 8065), handler)
threading.Thread(target=srv.serve_forever, daemon=True).start()

chrome = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
prof = os.path.join(os.environ.get("TEMP", "."), "chrome_cdp_design")
p = subprocess.Popen([chrome, "--headless=new", "--remote-debugging-port=9334", f"--user-data-dir={prof}",
                      "--no-proxy-server", "--window-size=1600,1200", "about:blank"],
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
ws_url = None
for _ in range(150):
    try:
        tabs = json.load(urllib.request.urlopen("http://127.0.0.1:9334/json"))
        ws_url = next(t["webSocketDebuggerUrl"] for t in tabs if t["type"] == "page")
        break
    except Exception:
        time.sleep(0.2)
host, path = ws_url[len("ws://"):].split("/", 1)
hn, port = host.split(":")
s = socket.create_connection((hn, int(port)))
s.send((f"GET /{path} HTTP/1.1\r\nHost: {host}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n"
        "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\nSec-WebSocket-Version: 13\r\n\r\n").encode())
buf = b""
while b"\r\n\r\n" not in buf:
    buf += s.recv(4096)
buf = buf.split(b"\r\n\r\n", 1)[1]


def send(obj):
    data = json.dumps(obj).encode()
    hdr = bytes([0x81])
    n = len(data)
    if n < 126:
        hdr += bytes([0x80 | n])
    elif n < 65536:
        hdr += bytes([0x80 | 126]) + struct.pack(">H", n)
    else:
        hdr += bytes([0x80 | 127]) + struct.pack(">Q", n)
    mask = b"\x01\x02\x03\x04"
    s.send(hdr + mask + bytes(b ^ mask[i % 4] for i, b in enumerate(data)))


def need(n):
    global buf
    while len(buf) < n:
        chunk = s.recv(1 << 20)
        if not chunk:
            raise EOFError
        buf += chunk


def recv():
    global buf
    need(2)
    n = buf[1] & 0x7F
    off = 2
    if n == 126:
        need(4); n = struct.unpack(">H", buf[2:4])[0]; off = 4
    elif n == 127:
        need(10); n = struct.unpack(">Q", buf[2:10])[0]; off = 10
    need(off + n)
    msg = buf[off:off + n]
    buf = buf[off + n:]
    return json.loads(msg)


mid = 0


def call(method, params=None):
    """Sends a command and waits for its answer."""
    global mid
    mid += 1
    send({"id": mid, "method": method, "params": params or {}})
    while True:
        m = recv()
        if m.get("id") == mid:
            return m.get("result", {})


def js(expr):
    return call("Runtime.evaluate", {"expression": expr, "returnByValue": True}).get("result", {}).get("value")


call("Page.enable")
call("Page.navigate", {"url": "http://127.0.0.1:8065/" + urllib.parse.quote(name)})
time.sleep(6)
labels = js("""[...document.querySelectorAll('div')].filter(d => d.style.cursor === 'pointer'
    && /^\\d\\d /.test(d.textContent.trim())).map(d => d.textContent.trim())""") or [""]
print(len(labels), "tabs")


def shot(file):
    size = call("Page.getLayoutMetrics")["cssContentSize"]
    r = call("Page.captureScreenshot", {"format": "png", "captureBeyondViewport": True,
                                        "clip": {"x": 0, "y": 0, "width": size["width"], "height": size["height"], "scale": scale}})
    file.write_bytes(base64.b64decode(r["data"]))
    print("saved", file)


for label in labels:
    if label:
        js(f"""[...document.querySelectorAll('div')].find(d => d.style.cursor === 'pointer'
            && d.textContent.trim() === {json.dumps(label)}).click()""")
        time.sleep(1.5)
    shot(out_dir / ((label.split(" ")[0] if label else "page") + ".png"))
p.kill()
srv.shutdown()
