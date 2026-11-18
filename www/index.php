<?php
declare(strict_types=1);
$ip = getenv('SERVER_IP') ?: ($_SERVER['SERVER_ADDR'] ?? '0.0.0.0');
$port = getenv('SERVER_PORT') ?: (string)($_SERVER['SERVER_PORT'] ?? '80');
$host = htmlspecialchars($_SERVER['HTTP_HOST'] ?? "{$ip}:{$port}", ENT_QUOTES, 'UTF-8');
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>BiteHost WebHost</title>
  <style>
    :root {
      --bg: #0b1220;
      --fg: #e8eef8;
      --muted: #9db0c9;
      --accent: #3dd6c6;
      --card: #121a2b;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0; min-height: 100vh; font-family: "Segoe UI", system-ui, sans-serif;
      color: var(--fg);
      background:
        radial-gradient(1200px 600px at 10% -10%, #1b3a4a 0%, transparent 55%),
        radial-gradient(900px 500px at 100% 0%, #243056 0%, transparent 50%),
        var(--bg);
      display: grid; place-items: center; padding: 2rem;
    }
    main {
      width: min(640px, 100%);
      background: color-mix(in srgb, var(--card) 92%, transparent);
      border: 1px solid #243049;
      border-radius: 16px; padding: 2rem 2.25rem;
      box-shadow: 0 24px 60px rgba(0,0,0,.35);
    }
    h1 { margin: 0 0 .35rem; font-size: 1.85rem; letter-spacing: -.02em; }
    .brand { color: var(--accent); font-weight: 700; }
    p { color: var(--muted); line-height: 1.55; }
    code {
      background: #0a101c; padding: .15rem .4rem; border-radius: 6px;
      color: #c9e7ff; font-size: .92em;
    }
    ul { color: var(--muted); padding-left: 1.2rem; }
    li { margin: .35rem 0; }
    footer { margin-top: 1.5rem; font-size: .85rem; color: #7f93ad; }
  </style>
</head>
<body>
  <main>
    <h1><span class="brand">BiteHost</span> WebHost</h1>
    <p>Your Nginx + PHP container is online at <code><?= $host ?></code>.</p>
    <p>Next steps:</p>
    <ul>
      <li>Panel subdomain / proxy (SSL on the host)</li>
      <li>Or Cloudflare Tunnel — set <code>CLOUDFLARED_STATUS=1</code> + token</li>
      <li>Or Certbot — set <code>CERTBOT_STATUS=1</code> + domain/email</li>
      <li>One-click WordPress / NamelessMC via egg variables on reinstall</li>
    </ul>
    <footer>BiteHost WebHost Egg v2 · PHP <?= PHP_VERSION ?></footer>
  </main>
</body>
</html>
