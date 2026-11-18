# BiteHost WebHost

Nginx + PHP-FPM egg for Pterodactyl / Pelican.

## Setup

1. Build and push Docker images (`ghcr.io/vahistar/webhost:8.2|8.3|8.4`) via GitHub Actions or locally.
2. Import `egg-webhost.json` into the panel.
3. Create a server and start it.

## Domains

| Method | Variables |
|--------|-----------|
| Panel reverse proxy | `TRUST_PROXY=1` |
| Cloudflare Tunnel | `CLOUDFLARED_STATUS=1` + `CLOUDFLARED_TOKEN` |
| Certbot | `CERTBOT_STATUS=1` + email/domain (optional DNS token) |

Do not use Certbot HTTP-01 and Cloudflare Tunnel on the same hostname.

## Apps

- `WORDPRESS=1` — WordPress + tuned nginx
- `NAMELESSMC=1` — NamelessMC (not together with WordPress)
- `GIT_ADDRESS` — clone into `www/`
- empty — default landing page

## PHP security

Images require patched PHP (8.2.35+ / 8.3.36+ / 8.4.27+) for CVE-2026-109618 / CVE-2026-109619.  
`session.upload_progress.enabled=0` is enforced in the image and in `php/conf.d/99-php2shell.ini`.

```bash
php -v
php -i | grep session.upload_progress.enabled
```

## License

MIT
