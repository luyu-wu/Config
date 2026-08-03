#!/usr/bin/env python3
import json
import subprocess
import sys
import time

# Edit this list to change the tickers shown in the widget.
SYMBOLS = ["XEQT.TO", "BMO.TO", "XIU.TO"]

USER_AGENT = "Mozilla/5.0"
CHART_URL = (
    "https://{host}/v8/finance/chart/"
    "{symbol}?interval=1d&range=1mo"
)
HOSTS = ["query1.finance.yahoo.com", "query2.finance.yahoo.com"]


def fetch_quote(symbol):
    last_error = None
    for host in HOSTS:
        for attempt in range(3):
            proc = subprocess.run(
                [
                    "curl", "-sS", "--fail", "--max-time", "15",
                    "-A", USER_AGENT,
                    CHART_URL.format(host=host, symbol=symbol),
                ],
                capture_output=True,
                text=True,
                timeout=20,
            )
            if proc.returncode == 0:
                break
            last_error = proc.stderr.strip() or f"curl exited {proc.returncode}"
            if "429" in last_error:
                # rate limited: try the other host next, with a short pause
                time.sleep(0.6 + attempt)
        else:
            continue
        break
    else:
        raise ValueError(last_error)

    payload = json.loads(proc.stdout)
    result = payload["chart"]["result"][0]
    meta = result["meta"]
    closes = [
        c for c in (result["indicators"]["quote"][0].get("close") or []) if c is not None
    ]
    if len(closes) < 2:
        raise ValueError("not enough price data")

    price, previous = closes[-1], closes[-2]
    change = price - previous
    change_percent = change / previous * 100.0 if previous else 0.0

    raw_symbol = meta.get("symbol") or symbol
    # Yahoo appends an exchange suffix (e.g. ".TO" for Toronto); strip it
    # for display only, the request symbol keeps it.
    display = raw_symbol.split(".")[0] if "." in raw_symbol else raw_symbol

    return {
        "symbol": display,
        "name": meta.get("longName") or meta.get("shortName") or symbol,
        "price": round(price, 4),
        "change": round(change, 4),
        "changePercent": round(change_percent, 4),
        "currency": meta.get("currency", "USD"),
        "sparkline": [round(c, 4) for c in closes[-20:]],
    }


def main():
    quotes = []
    # Fetch sequentially with a small stagger to stay under Yahoo's rate limits.
    for symbol in SYMBOLS:
        try:
            quotes.append(fetch_quote(symbol))
        except Exception as exc:  # noqa: BLE001
            print(f"warning: {symbol}: {exc}", file=sys.stderr)
        time.sleep(0.3)

    json.dump(quotes, sys.stdout, ensure_ascii=False)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
