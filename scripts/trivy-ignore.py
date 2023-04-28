#!/usr/bin/env python3

from itertools import chain
from json import load
from sys import stdin

data = load(stdin)

results = data.get("Results", [])
vulns = list(chain(*[ [ vuln.get("VulnerabilityID") for vuln in result.get("Vulnerabilities", []) ] for result in results ]))

if vulns:
    print("# Accept the risk")
    print("\n".join(vulns))
