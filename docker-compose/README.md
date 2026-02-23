<!--
Copyright 2026 Element Creations Ltd

SPDX-License-Identifier: AGPL-3.0-only
-->

# ESS Community on a single Docker host (Docker Compose)

This folder provides a **Docker Compose translation** of the ESS Community stack for a single Ubuntu host.

> ⚠️ This is a standalone Compose deployment path for environments without Kubernetes.

## Included components

- Synapse
- Matrix Authentication Service (MAS)
- Element Web
- Element Admin
- Hookshot (optional profile)
- Matrix RTC backend (LiveKit, optional profile)
- PostgreSQL
- Redis
- NGINX reverse proxy + `.well-known`

## Quick start

1. Copy and edit environment values:

```sh
cp .env.example .env
```

2. Replace all `change-me-*` values in:
- `.env`
- `synapse/homeserver.yaml`
- `mas/config.yaml`
- `postgres-init/01-create-dbs.sql`
- optional files for Hookshot/LiveKit

3. Replace hostnames in config templates:
- `synapse/homeserver.yaml`
- `mas/config.yaml`
- `element-web/config.json`
- `well-known/matrix/*`

4. Start core stack:

```sh
docker compose up -d
```

5. Start optional integrations:

```sh
docker compose --profile hookshot --profile matrix-rtc up -d
```

6. Register first user (MAS flow):

```sh
docker compose exec mas mas-cli manage register-user
```

## Notes

- NGINX currently exposes port 80 in cleartext in this baseline setup. For production, add TLS certs and HTTPS server blocks, or place it behind an external TLS reverse proxy.
- This Compose setup is intentionally explicit so it can be audited and customized easily on a single host.
