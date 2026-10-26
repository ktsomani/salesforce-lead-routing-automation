"""Integration check for an external REST endpoint.

Usage:
    python integration_check.py --base-url https://jsonplaceholder.typicode.com

Runs a set of checks (status code, required fields, types) and prints
PASS/FAIL per check. Exits non-zero if any check fails.
"""
import argparse
import sys

import requests

REQUIRED_USER_FIELDS = {"id": int, "name": str, "email": str}


def check_status(resp, expected=200):
    ok = resp.status_code == expected
    return ok, f"status {resp.status_code} (expected {expected})"


def check_fields(payload, required):
    problems = []
    for field, ftype in required.items():
        if field not in payload:
            problems.append(f"missing '{field}'")
        elif not isinstance(payload[field], ftype):
            problems.append(f"'{field}' is {type(payload[field]).__name__}")
    return (not problems), ("ok" if not problems else "; ".join(problems))


def run(base_url):
    results = []

    resp = requests.get(f"{base_url}/users/1", timeout=10)
    ok, msg = check_status(resp, 200)
    results.append(("GET /users/1 status", ok, msg))

    if resp.status_code == 200:
        ok, msg = check_fields(resp.json(), REQUIRED_USER_FIELDS)
        results.append(("GET /users/1 required fields", ok, msg))

    resp = requests.get(f"{base_url}/users/999999", timeout=10)
    ok, msg = check_status(resp, 404)
    results.append(("GET unknown user returns 404", ok, msg))

    return results


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", required=True)
    args = parser.parse_args()

    results = run(args.base_url.rstrip("/"))
    failed = 0
    for name, ok, msg in results:
        print(f"[{'PASS' if ok else 'FAIL'}] {name}: {msg}")
        if not ok:
            failed += 1
    print(f"\n{len(results) - failed}/{len(results)} checks passed")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
