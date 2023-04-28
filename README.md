# base-pipeline

## Additional scripts

### trivy-ignore.py

Generates a `.trivyignore` file from a json vulnerability report and writes it to `STDOUT`.

#### Container image

```sh
trivy image --scanners vuln -s CRITICAL <IMAGE> --format json | scripts/trivy-ignore.py
# Accept the risk
CVE-2037-0001
```

#### File system

```sh
trivy fs --scanners vuln -s CRITICAL <DIR> --format json | scripts/trivy-ignore.py
# Accept the risk
CVE-2037-0001
```