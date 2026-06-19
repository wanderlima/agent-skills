# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security issue in this repository, please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, open a private security advisory on GitHub:

https://github.com/wanderlima/agent-skills/security/advisories/new

Include:

- A description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if you have one)

You can expect an initial response within 7 days.

## Scope

This policy covers:

- Skill instructions that could lead to unsafe agent behavior
- Bundled scripts under `skills/*/scripts/`
- Repository automation and CI configuration

It does not cover vulnerabilities in third-party tools referenced by skills
(e.g. `mmdc`, `md-to-pdf`, Puppeteer). Report those to the respective upstream projects.
