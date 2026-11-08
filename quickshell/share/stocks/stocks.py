#!/usr/bin/env python3
import json
import subprocess
import sys
import time

SYMBOLS = ["XEQT.TO"]

USER_AGENT = "Mozilla/5.0"
CHART_URL = (
    "https://{host}/v8/finance/chart/"
    "{symbol}?interval=1d&range=5d"
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
    meta = payload["chart"]["result"][0]["meta"]

    price = meta.get("regularMarketPrice")
    previous = meta.get("chartPreviousClose") or meta.get("previousClose")
    if price is None:
        raise ValueError("no price data")

    change = price - previous if previous is not None else 0.0
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
        "currency": meta.get("currency", "CAD"),
    }


def main():
    quotes = []
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
