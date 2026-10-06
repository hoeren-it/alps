# Docker / Komodo deployment

This fork is configured for the hoeren-it VPS:

- Web URL: <https://webmail.hoeren-it.de>
- TLS termination and routing: the existing Traefik instance on `traefik_net`
- Mail services: `mail.hoeren-it.de` over IMAPS (993) and SMTPS (465)

The domain's wildcard DNS already points at the VPS, so no new DNS record is
needed. The container does not publish a host port; only Traefik can reach it
over the shared Docker network.

## Run locally

```sh
cp .env.example .env
docker compose up --build -d
```

For local use, either attach the service to an existing `traefik_net` with the
matching Traefik configuration, or adjust the external network and router labels
for your environment.

## Deploy with Komodo

Create a Compose stack from `hoeren-it/alps`, branch `main`, file `compose.yaml`,
and target the `netcup` server. Enable **Run build**; the Compose build uses the
Dockerfile in this repository. The stack's environment file may remain empty.

After deployment, Traefik should issue a certificate and route the hostname.
Users sign in with their existing mail address and mailbox password. The IMAP
server must support IMAP METADATA (RFC 5464), which ALPS uses to store user
settings and authentication keys.
