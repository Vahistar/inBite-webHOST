<?php
$serverPort = getenv('SERVER_PORT') ?: (string)($_SERVER['SERVER_PORT'] ?? '80');
$tunnelTarget = 'http://127.0.0.1:' . htmlspecialchars($serverPort, ENT_QUOTES, 'UTF-8');

$httpsOn = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
    || (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https')
    || ((string)($_SERVER['SERVER_PORT'] ?? '') === '443');
$scheme = $httpsOn ? 'https' : 'http';
$host = $_SERVER['HTTP_HOST'] ?? 'localhost';
$basePath = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '/')), '/');
$siteUrl = $scheme . '://' . $host . ($basePath === '' ? '' : $basePath);
$pageUrl = $scheme . '://' . $host . ($_SERVER['REQUEST_URI'] ?? (($basePath === '' ? '' : $basePath) . '/'));

$pageTitle = 'Welcome to BiteHost™';
$pageDescription = 'Your BiteHost WebHost server is ready. Claim a subdomain, connect Cloudflare Tunnel, and start building with PHP, WordPress, or NamelessMC.';
$pageKeywords = 'BiteHost, WebHost, Pterodactyl, web hosting, PHP hosting, Cloudflare Tunnel, WordPress, NamelessMC, subdomain, inBite';
$pageAuthor = 'Bartosz "Vahistar" Rogowski';
$ogImage = $siteUrl . '/socials.png';

$e = static function (string $value): string {
    return htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
};
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $e($pageTitle); ?></title>
    <meta name="description" content="<?php echo $e($pageDescription); ?>">
    <meta name="keywords" content="<?php echo $e($pageKeywords); ?>">
    <meta name="author" content="<?php echo $e($pageAuthor); ?>">
    <meta name="robots" content="index, follow">
    <meta name="theme-color" content="#3b6fd9">
    <link rel="canonical" href="<?php echo $e($pageUrl); ?>">

    <meta property="og:type" content="website">
    <meta property="og:site_name" content="BiteHost">
    <meta property="og:title" content="<?php echo $e($pageTitle); ?>">
    <meta property="og:description" content="<?php echo $e($pageDescription); ?>">
    <meta property="og:url" content="<?php echo $e($pageUrl); ?>">
    <meta property="og:image" content="<?php echo $e($ogImage); ?>">
    <meta property="og:image:type" content="image/png">
    <meta property="og:image:width" content="1280">
    <meta property="og:image:height" content="720">
    <meta property="og:image:alt" content="BiteHost WebHost welcome screen">
    <meta property="og:locale" content="en_US">

    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="<?php echo $e($pageTitle); ?>">
    <meta name="twitter:description" content="<?php echo $e($pageDescription); ?>">
    <meta name="twitter:image" content="<?php echo $e($ogImage); ?>">
    <meta name="twitter:image:alt" content="BiteHost WebHost welcome screen">

    <link rel="icon" href="bitehost-favicon.png" type="image/png">
    <link rel="shortcut icon" href="bitehost-favicon.png" type="image/png">
    <link rel="apple-touch-icon" href="bitehost-logo.png">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        *, *::before, *::after {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --bg: #fafafa;
            --bg-alt: #ffffff;
            --text: #18181b;
            --text-secondary: #71717a;
            --border: #e4e4e7;
            --border-hover: #d4d4d8;
            --primary: #18181b;
            --primary-hover: #27272a;
            --accent: #3b6fd9;
            --accent-soft: #eef3fb;
            --success: #16a34a;
            --success-soft: #f0fdf4;
            --warning: #d97706;
            --warning-soft: #fffbeb;
            --muted: #f4f4f5;
            --ascii: #5b6472;
            --surface-soft: #f5f8fc;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--bg);
            color: var(--text);
            line-height: 1.6;
            -webkit-font-smoothing: antialiased;
        }

        .container {
            max-width: 1120px;
            margin: 0 auto;
            padding: 0 1.5rem;
            min-width: 0;
            width: 100%;
            box-sizing: border-box;
        }

        .header {
            padding: 1.5rem 0;
            border-bottom: 1px solid var(--border);
            background: var(--bg-alt);
        }

        .header-inner {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-weight: 700;
            font-size: 1.125rem;
            line-height: 1;
            color: var(--text);
            text-decoration: none;
        }

        .logo-mark {
            width: 1.15em;
            height: 1.15em;
            border-radius: 3px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            flex-shrink: 0;
            background: transparent;
        }

        .logo-mark img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            display: block;
        }

        .header-link {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--text-secondary);
            text-decoration: none;
            transition: color 0.15s ease;
        }

        .header-link:hover {
            color: var(--accent);
        }

        .header-link i {
            font-size: 0.8rem;
        }

        .hero {
            position: relative;
            isolation: isolate;
            overflow: hidden;
            padding: 5.5rem 0 7rem;
            text-align: center;
            border-bottom: 1px solid var(--border);
            background-color: var(--surface-soft);
            background-image:
                radial-gradient(ellipse 80% 60% at 50% -10%, rgba(255, 255, 255, 0.22), transparent 55%),
                radial-gradient(ellipse 50% 40% at 90% 80%, rgba(59, 111, 217, 0.05), transparent 50%),
                linear-gradient(180deg, rgba(250, 250, 250, 0.28) 0%, rgba(248, 250, 252, 0.38) 50%, rgba(250, 250, 250, 0.55) 100%),
                url("hero-background.webp");
            background-size: auto, auto, auto, cover;
            background-position: center, center top, center, center;
            background-repeat: no-repeat;
        }

        .hero::before {
            content: "";
            position: absolute;
            inset: 0;
            z-index: -1;
            background-image:
                linear-gradient(rgba(24, 24, 27, 0.045) 1px, transparent 1px),
                linear-gradient(90deg, rgba(24, 24, 27, 0.045) 1px, transparent 1px);
            background-size: 48px 48px;
            mask-image: radial-gradient(ellipse 70% 65% at 50% 35%, #000 20%, transparent 75%);
            -webkit-mask-image: radial-gradient(ellipse 70% 65% at 50% 35%, #000 20%, transparent 75%);
            pointer-events: none;
        }

        .hero::after {
            content: "";
            position: absolute;
            inset: auto -20% -40% -20%;
            height: 55%;
            z-index: -1;
            background: radial-gradient(ellipse at center, rgba(59, 111, 217, 0.05), transparent 70%);
            pointer-events: none;
        }

        .hero > .container {
            position: relative;
            z-index: 1;
        }

        .hero h1 {
            font-size: clamp(2rem, 5vw, 3.25rem);
            font-weight: 700;
            letter-spacing: -0.025em;
            line-height: 1.15;
            margin-bottom: 1rem;
        }

        .hero p {
            font-size: 1.125rem;
            color: var(--text-secondary);
            max-width: 560px;
            margin: 0 auto 2rem;
        }

        .hero-actions {
            display: flex;
            gap: 0.75rem;
            justify-content: center;
            flex-wrap: wrap;
            animation: hero-fade-up 0.7s ease 0.1s both;
        }

        .hero-intro {
            animation: hero-fade-up 0.7s ease both;
        }

        @keyframes hero-fade-up {
            from {
                opacity: 0;
                transform: translateY(12px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.625rem 1.25rem;
            border-radius: 8px;
            font-size: 0.875rem;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.15s ease;
            cursor: pointer;
            border: 1px solid transparent;
        }

        .btn-primary {
            background: var(--primary);
            color: white;
            border-color: var(--primary);
        }

        .btn-primary:hover {
            background: var(--primary-hover);
        }

        .btn-secondary {
            background: var(--bg-alt);
            color: var(--text);
            border-color: var(--border);
        }

        .btn-secondary:hover {
            background: var(--muted);
        }

        .ascii-block {
            display: inline-block;
            max-width: 100%;
            margin: 0 auto 1.35rem;
            text-align: left;
            vertical-align: top;
            transform: translateX(-12px);
        }

        .ascii-art {
            display: block;
            width: max-content;
            max-width: 100%;
            margin: 0;
            overflow-x: auto;
            font-family: 'JetBrains Mono', monospace;
            font-size: clamp(0.38rem, 1.05vw, 0.68rem);
            line-height: 1.25;
            white-space: pre;
            color: var(--ascii);
            text-align: left;
        }

        .hero-intro .ascii-credit {
            display: block;
            width: fit-content;
            max-width: none;
            margin: 0.35rem 0 0 0;
            padding: 0;
            font-size: 0.6875rem;
            font-weight: 500;
            line-height: 1.3;
            letter-spacing: 0.01em;
            color: var(--text-secondary);
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            text-align: left;
            margin-left: 2.6em;
        }

        .section {
            padding: 4rem 0;
        }

        .section-header {
            margin-bottom: 2.5rem;
        }

        .section-label {
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--accent);
            margin-bottom: 0.5rem;
        }

        .section-title {
            font-size: 1.75rem;
            font-weight: 700;
            letter-spacing: -0.02em;
        }

        .section-desc {
            color: var(--text-secondary);
            margin-top: 0.5rem;
        }

        .grid-2 {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1.5rem;
            min-width: 0;
        }

        @media (max-width: 768px) {
            .grid-2 {
                grid-template-columns: 1fr;
            }

            .info-row {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.5rem;
            }

            .info-value {
                max-width: 100%;
                width: auto;
                white-space: normal;
                box-sizing: border-box;
            }
        }

        .card {
            display: flex;
            flex-direction: column;
            height: 100%;
            min-width: 0;
            max-width: 100%;
            overflow: hidden;
            background: var(--bg-alt);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 1.5rem;
            transition: border-color 0.15s ease;
        }

        .card:hover {
            border-color: var(--border-hover);
        }

        .card > .btn {
            margin-top: auto;
        }

        .card-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
            margin-bottom: 1rem;
        }

        .card-icon.dark {
            background: var(--primary);
            color: white;
        }

        .card-icon.blue {
            background: var(--accent-soft);
            color: var(--accent);
        }

        .card-icon.green {
            background: var(--success-soft);
            color: var(--success);
        }

        .card-icon.amber {
            background: var(--warning-soft);
            color: var(--warning);
        }

        .card h3 {
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .card p {
            font-size: 0.875rem;
            color: var(--text-secondary);
            line-height: 1.6;
        }

        .info-list {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            min-width: 0;
            max-width: 100%;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 0.75rem;
            padding: 0.875rem 1rem;
            background: var(--bg);
            border-radius: 8px;
            border: 1px solid var(--border);
            min-width: 0;
            max-width: 100%;
        }

        .info-label {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            font-size: 0.875rem;
            color: var(--text-secondary);
            flex-shrink: 0;
        }

        .info-label i {
            width: 16px;
            text-align: center;
            color: var(--text);
        }

        .info-value {
            flex: 0 1 auto;
            width: fit-content;
            max-width: min(100%, 24rem);
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.8125rem;
            font-weight: 500;
            color: var(--text);
            background: var(--bg-alt);
            padding: 0.25rem 0.625rem;
            border-radius: 6px;
            border: 1px solid var(--border);
            min-width: 0;
            overflow-wrap: anywhere;
            word-break: break-word;
            text-align: left;
        }

        .steps {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            grid-auto-rows: 1fr;
            gap: 1.5rem;
            align-items: stretch;
        }

        @media (max-width: 900px) {
            .steps {
                grid-template-columns: 1fr;
            }
        }

        .step {
            position: relative;
            display: flex;
            flex-direction: column;
            height: 100%;
            min-width: 0;
            padding: 1.5rem;
            background: var(--bg-alt);
            border: 1px solid var(--border);
            border-radius: 12px;
        }

        .step-num {
            width: 28px;
            height: 28px;
            background: var(--primary);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
            font-weight: 600;
            margin-bottom: 1rem;
            flex-shrink: 0;
        }

        .step h3 {
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .step > p {
            font-size: 0.875rem;
            color: var(--text-secondary);
            margin-bottom: 1rem;
            min-height: 2.8em;
        }

        .step-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 0.65rem;
            margin-top: auto;
        }

        .step-list li {
            display: flex;
            align-items: flex-start;
            gap: 0.55rem;
            font-size: 0.8125rem;
            line-height: 1.45;
            color: var(--text-secondary);
        }

        .step-list li::before {
            content: "";
            flex-shrink: 0;
            width: 0.35rem;
            height: 0.35rem;
            margin-top: calc((1.45em - 0.35rem) / 2);
            border-radius: 50%;
            background: var(--success);
        }

        .step-list li span {
            flex: 1;
            min-width: 0;
            overflow-wrap: anywhere;
        }

        .step-list li strong {
            color: var(--text);
            font-weight: 600;
        }

        .step.is-wip {
            opacity: 0.55;
            filter: grayscale(0.85);
            background: color-mix(in srgb, var(--bg-alt) 70%, #9ca3af 30%);
            border-color: color-mix(in srgb, var(--border) 60%, #9ca3af 40%);
            pointer-events: none;
            user-select: none;
        }

        .step.is-wip .step-num {
            background: #9ca3af;
        }

        .step.is-wip .step-list li::before {
            background: #9ca3af;
        }

        .step-list li.is-wip {
            opacity: 0.45;
            filter: grayscale(1);
        }

        .step-list li.is-wip::before {
            background: #9ca3af;
        }

        .step-list li.is-wip strong {
            color: #6b7280;
            font-weight: 500;
        }

        .step-list code {
            display: inline;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.72rem;
            font-weight: 500;
            color: var(--text);
            background: var(--bg);
            border: 1px solid var(--border);
            border-radius: 4px;
            padding: 0.05rem 0.3rem;
            overflow-wrap: anywhere;
            word-break: break-word;
        }

        .info-box {
            background: var(--bg);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 1.5rem;
            margin-top: 2rem;
        }

        .info-box-inner {
            display: flex;
            gap: 1rem;
        }

        .info-box-icon {
            width: 40px;
            height: 40px;
            background: var(--accent-soft);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--accent);
            flex-shrink: 0;
        }

        .info-box h4 {
            font-size: 0.875rem;
            font-weight: 600;
            margin-bottom: 0.25rem;
        }

        .info-box p {
            font-size: 0.8125rem;
            color: var(--text-secondary);
            line-height: 1.6;
        }

        .cta-section {
            --discord: #5865F2;
            --discord-dark: #4752C4;
            --discord-ink: #1E1F22;
            --discord-muted: #B5BAC1;
            position: relative;
            overflow: hidden;
            display: grid;
            grid-template-columns: 1.2fr 0.8fr;
            align-items: center;
            gap: 1.5rem;
            background:
                radial-gradient(ellipse 70% 80% at 85% 50%, rgba(255, 255, 255, 0.14), transparent 55%),
                linear-gradient(135deg, #5865F2 0%, #4752C4 55%, #3C45A5 100%);
            color: white;
            border-radius: 16px;
            padding: 2.25rem 2.5rem;
            margin: 2rem 0 4rem;
            text-align: left;
            box-shadow: 0 18px 40px -18px rgba(88, 101, 242, 0.55);
        }

        .cta-section::before {
            content: "";
            position: absolute;
            inset: 0;
            background-image: radial-gradient(rgba(255, 255, 255, 0.12) 1px, transparent 1px);
            background-size: 18px 18px;
            opacity: 0.35;
            pointer-events: none;
        }

        .cta-copy {
            position: relative;
            z-index: 1;
        }

        .cta-section h2 {
            font-size: clamp(1.6rem, 3vw, 2rem);
            font-weight: 800;
            letter-spacing: -0.02em;
            margin-bottom: 0.55rem;
        }

        .cta-section p {
            color: rgba(255, 255, 255, 0.88);
            margin-bottom: 1.35rem;
            max-width: 34rem;
            line-height: 1.55;
        }

        .btn-discord {
            background: #fff;
            color: var(--discord);
            border-color: #fff;
            font-weight: 700;
            padding: 0.75rem 1.35rem;
            border-radius: 10px;
            box-shadow: 0 8px 20px rgba(30, 31, 34, 0.18);
        }

        .btn-discord:hover {
            background: #f2f3f5;
            color: var(--discord-dark);
        }

        .btn-discord i {
            font-size: 1.15rem;
        }

        .cta-mascot {
            position: relative;
            z-index: 1;
            display: flex;
            justify-content: center;
            align-items: flex-end;
            align-self: stretch;
            min-height: 100%;
            margin: -2.25rem -0.5rem -2.25rem 0;
            padding-top: 1rem;
        }

        .cta-plush {
            position: relative;
            z-index: 1;
            width: min(280px, 100%);
            height: auto;
            max-height: 280px;
            display: block;
            object-fit: contain;
            object-position: bottom center;
            align-self: flex-end;
            filter: drop-shadow(0 12px 20px rgba(30, 31, 34, 0.22));
        }

        .cta-bubble {
            position: absolute;
            top: 28%;
            left: 2%;
            z-index: 3;
            background: #fff;
            color: var(--discord-ink);
            font-size: 0.75rem;
            font-weight: 700;
            padding: 0.45rem 0.7rem;
            border-radius: 12px 12px 4px 12px;
            box-shadow: 0 8px 18px rgba(30, 31, 34, 0.18);
            white-space: nowrap;
            pointer-events: none;
        }

        @media (max-width: 768px) {
            .cta-section {
                grid-template-columns: 1fr;
                text-align: center;
                padding: 1.75rem 1.35rem 1.75rem;
                gap: 1rem;
            }

            .cta-section p {
                margin-left: auto;
                margin-right: auto;
            }

            .cta-copy {
                order: 1;
            }

            .cta-copy .btn-discord {
                margin-bottom: 0.25rem;
            }

            .cta-mascot {
                order: 2;
                margin: 0.25rem auto -1.75rem;
                min-height: 0;
                max-width: 210px;
                padding-top: 0.5rem;
            }

            .cta-plush {
                max-height: 190px;
                width: min(210px, 100%);
            }

            .cta-bubble {
                display: none;
            }
        }

        .footer {
            padding: 2rem 0;
            border-top: 1px solid var(--border);
            background: var(--bg-alt);
        }

        .footer-inner {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .footer-copy {
            font-size: 0.8125rem;
            color: var(--text-secondary);
        }

        .footer-links {
            display: flex;
            gap: 1rem;
        }

        .footer-links a {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            border: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-secondary);
            text-decoration: none;
            transition: all 0.15s ease;
        }

        .footer-links a:hover {
            background: var(--primary);
            border-color: var(--primary);
            color: white;
        }

        .text-mono {
            font-family: 'JetBrains Mono', monospace;
        }

        .text-sm {
            font-size: 0.8125rem;
        }

        .text-muted {
            color: var(--text-secondary);
        }
    </style>
</head>
<body>

    <header class="header">
        <div class="container">
            <div class="header-inner">
                <a href="https://bitehost.me" class="logo">
                    <div class="logo-mark">
                        <img src="bitehost-logo.png" alt="BiteHost">
                    </div>
                    BiteHost™
                </a>
                <a href="https://bitehost.me" target="_blank" rel="noopener noreferrer" class="header-link">
                    bitehost.me
                    <i class="fas fa-arrow-up-right-from-square"></i>
                </a>
            </div>
        </div>
    </header>

    <section class="hero">
        <div class="container">
            <div class="hero-intro">
                <div class="ascii-block">
                    <pre class="ascii-art">    _______   __    __                __    __                        __     
   |       \ |  \  |  \              |  \  |  \                      |  \    
   | $$$$$$$\ \$$ _| $$_     ______  | $$  | $$  ______    _______  _| $$_   
   | $$__/ $$|  \|   $$ \   /      \ | $$__| $$ /      \  /       \|   $$ \  
   | $$    $$| $$ \$$$$$$  |  $$$$$$\| $$    $$|  $$$$$$\|  $$$$$$$ \$$$$$$  
   | $$$$$$$\| $$  | $$ __ | $$    $$| $$$$$$$$| $$  | $$ \$$    \   | $$ __ 
   | $$__/ $$| $$  | $$|  \| $$$$$$$$| $$  | $$| $$__/ $$ _\$$$$$$\  | $$|  \
   | $$    $$| $$   \$$  $$ \$$     \| $$  | $$ \$$    $$|       $$   \$$  $$
    \$$$$$$$  \$$    \$$$$   \$$$$$$$ \$$   \$$  \$$$$$$  \$$$$$$$     \$$$$</pre>
                    <p class="ascii-credit">Made with ❤ by inBite Group</p>
                </div>
                <h1>Your server is ready</h1>
                <p>Everything has been set up successfully. Start building your project or configure your hosting environment.</p>
            </div>
            <div class="hero-actions">
                <a href="https://discord.bitehost.me" target="_blank" rel="noopener noreferrer" class="btn btn-primary">
                    <i class="fab fa-discord"></i>
                    Join Discord
                </a>
                <a href="#" class="btn btn-secondary">
                    <i class="fas fa-book"></i>
                    Documentation
                </a>
            </div>

        </div>
    </section>

    <section class="section">
        <div class="container">
            <div class="grid-2">
                <div class="card">
                    <div class="card-icon dark">
                        <i class="fab fa-discord"></i>
                    </div>
                    <h3>Welcome to BiteHost</h3>
                    <p>We're happy to have you here! Whether you're launching your first website, running a growing project, or building something entirely your own, we're here to keep things running smoothly.</p>
                    <p style="margin-top: 0.75rem;">Need a helping paw? Join our Discord community for support, updates, and a chance to meet fellow creators.</p>
                    <a href="https://discord.bitehost.me" target="_blank" rel="noopener noreferrer" class="btn btn-secondary" style="width: 100%; justify-content: center;">
                        <i class="fab fa-discord"></i>
                        Join our Discord
                    </a>
                </div>

                <div class="card">
                    <div class="card-icon blue">
                        <i class="fas fa-server"></i>
                    </div>
                    <h3>Server Information</h3>
                    <div class="info-list" style="margin-top: 1rem;">
                        <div class="info-row">
                            <div class="info-label">
                                <i class="fab fa-php"></i>
                                PHP Version
                            </div>
                            <span class="info-value"><?php echo htmlspecialchars(phpversion()); ?></span>
                        </div>
                        <div class="info-row">
                            <div class="info-label">
                                <i class="fas fa-cog"></i>
                                Server Software
                            </div>
                            <span class="info-value"><?php echo htmlspecialchars($_SERVER['SERVER_SOFTWARE'] ?? 'N/A'); ?></span>
                        </div>
                        <div class="info-row">
                            <div class="info-label">
                                <i class="fas fa-folder"></i>
                                Document Root
                            </div>
                            <span class="info-value text-sm"><?php echo htmlspecialchars($_SERVER['DOCUMENT_ROOT'] ?? 'N/A'); ?></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="section" style="background: var(--bg-alt); border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);">
        <div class="container">
            <div class="section-header">
                <div class="section-label">Quick Start</div>
                <h2 class="section-title">Getting Started</h2>
                <p class="section-desc">Choose one option. Do not use Tunnel and Certbot together on the same domain.</p>
            </div>

            <div class="steps">
                <div class="step">
                    <div class="step-num">1</div>
                    <h3>Panel subdomain</h3>
                    <p>You can claim a subdomain now. Proxy and SSL are still work in progress.</p>
                    <ul class="step-list">
                        <li>
                            <span>Go to <strong>Subdomains</strong> and create a subdomain.</span>
                        </li>
                        <li class="is-wip">
                            <span><strong>Proxy</strong> - work in progress.</span>
                        </li>
                        <li class="is-wip">
                            <span><strong>SSL / Let's Encrypt</strong> - work in progress.</span>
                        </li>
                        <li>
                            <span>Until then, open the site with your allocation port (e.g. <code>http://name.domain:PORT</code>).</span>
                        </li>
                    </ul>
                </div>

                <div class="step">
                    <div class="step-num">2</div>
                    <h3>Cloudflare Tunnel</h3>
                    <p>Use your own domain without panel proxy. SSL is on Cloudflare.</p>
                    <ul class="step-list">
                        <li>
                            <span>Create a tunnel in Cloudflare Zero Trust and copy the token.</span>
                        </li>
                        <li>
                            <span>In Startup set <strong>Cloudflare Tunnel</strong> to Enable.</span>
                        </li>
                        <li>
                            <span>Paste the token into <strong>Cloudflare Tunnel Token</strong>.</span>
                        </li>
                        <li>
                            <span>In Cloudflare, route the hostname to <code id="tunnel-target"><?php echo $tunnelTarget; ?></code>.</span>
                        </li>
                    </ul>
                </div>

                <div class="step is-wip" aria-disabled="true">
                    <div class="step-num">3</div>
                    <h3>Certbot</h3>
                    <p>TLS certificates inside this server are not ready yet.</p>
                    <ul class="step-list">
                        <li>
                            <span>Do not enable <strong>Certbot</strong> in Startup for now.</span>
                        </li>
                        <li>
                            <span>Use <strong>Cloudflare Tunnel</strong> if you need HTTPS today.</span>
                        </li>
                        <li>
                            <span>Panel subdomain SSL is also still work in progress.</span>
                        </li>
                        <li>
                            <span>This option will return once certificates are fully wired.</span>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="info-box">
                <div class="info-box-inner">
                    <div class="info-box-icon">
                        <i class="fas fa-lightbulb"></i>
                    </div>
                    <div>
                        <h4>Automatic installers</h4>
                        <p>In Startup you can set <strong>WordPress</strong> or <strong>NamelessMC</strong> to Enable before install/reinstall (only one at a time).</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <div class="section-header">
                <div class="section-label">Next Steps</div>
                <h2 class="section-title">What's Next?</h2>
            </div>

            <div class="grid-2">
                <div class="card">
                    <div class="card-icon green">
                        <i class="fas fa-upload"></i>
                    </div>
                    <h3>Upload Your Website</h3>
                    <p>Use SFTP or the file manager to upload your website files to the <code class="text-mono" style="background: var(--bg); padding: 0.125rem 0.375rem; border-radius: 4px; font-size: 0.8125rem; border: 1px solid var(--border);">www</code> directory.</p>
                </div>

                <div class="card">
                    <div class="card-icon amber">
                        <i class="fas fa-database"></i>
                    </div>
                    <h3>Set Up Database</h3>
                    <p>Create a MySQL database from the <strong>Databases</strong> section if your application requires one.</p>
                </div>
            </div>
        </div>
    </section>

    <section class="container">
        <div class="cta-section">
            <div class="cta-copy">
                <h2>A little help goes a long way.</h2>
                <p>Whether you need a paw with setup or just someone to share ideas with, our community is always happy to welcome another face.</p>
                <a href="https://discord.bitehost.me" target="_blank" rel="noopener noreferrer" class="btn btn-discord">
                    <i class="fab fa-discord"></i>
                    Join our Discord    
                </a>
            </div>
            <div class="cta-mascot" aria-hidden="true">
                <div class="cta-bubble">hey friends :3</div>
                <img class="cta-plush" src="discord-wumpus.png" alt="">
            </div>
        </div>
    </section>

    <footer class="footer">
        <div class="container">
            <div class="footer-inner">
                <div class="footer-copy">
                    &copy; 2026 BiteHost™ by inBite Group
                </div>
                <div class="footer-links">
                    <a href="https://www.youtube.com/@vahistar" target="_blank">
                        <i class="fab fa-youtube"></i>
                    </a>
                    <a href="https://discord.bitehost.me" target="_blank" rel="noopener noreferrer">
                        <i class="fab fa-discord"></i>
                    </a>
                    <a href="https://github.com/Vahistar" target="_blank">
                        <i class="fab fa-github"></i>
                    </a>
                </div>
            </div>
        </div>
    </footer>

</body>
</html>
