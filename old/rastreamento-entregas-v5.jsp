<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
%>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Rastreamento de Entregas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <snk:load/>

    <style>
        /* ===== RESET & BASE ===== */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --brand:        #0f172a;
            --brand-soft:   #1e293b;
            --page-bg:      #f1f5f9;
            --surface:      #ffffff;
            --line:         #e5e7eb;
            --muted-line:   #d1d5db;
            --text:         #111827;
            --text-muted:   #6b7280;
            --blue-primary: #3b82f6;
            --blue-dark:    #2563eb;
            --blue-light:   #dbeafe;
            --green-ok:     #22c55e;
            --green-dark:   #16a34a;
            --green-light:  #dcfce7;
            --yellow:       #f59e0b;
            --yellow-light: #fef3c7;
            --red:          #ef4444;
            --red-light:    #fee2e2;
            --gray-100:     #f8fafc;
            --gray-200:     #e5e7eb;
            --gray-300:     #d1d5db;
            --gray-400:     #9ca3af;
            --gray-600:     #6b7280;
            --gray-800:     #1f2937;
            --white:        #ffffff;
            --radius-sm:    8px;
            --radius-md:    12px;
            --radius-lg:    18px;
            --shadow-md:    0 10px 25px rgba(15, 23, 42, .08);
            --shadow-lg:    0 20px 45px rgba(15, 23, 42, .14);
            --tr:           all .22s ease;
        }

        body {
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            background:
                radial-gradient(circle at top left, rgba(59, 130, 246, .14), transparent 34rem),
                linear-gradient(180deg, #f8fafc 0%, var(--page-bg) 100%);
            min-height: 100vh;
            padding: 30px 16px 54px;
            color: var(--text);
            cursor: default;
            caret-color: transparent;
        }

        input,
        textarea,
        select,
        [contenteditable="true"] {
            caret-color: auto;
            cursor: text;
            user-select: text;
        }

        button,
        a,
        [role="button"] {
            caret-color: transparent;
        }

        .icon-svg {
            width: 1em;
            height: 1em;
            display: inline-block;
            vertical-align: -0.125em;
            fill: none;
            stroke: currentColor;
            stroke-width: 2;
            stroke-linecap: round;
            stroke-linejoin: round;
        }
        .icon-gap { margin-right: 6px; }
        .page-header .logo .icon-svg,
        .error-state .icon .icon-svg {
            width: 1em;
            height: 1em;
        }
        .step-icon .icon-svg {
            width: 22px;
            height: 22px;
        }
        .tl-dot .icon-svg {
            width: 12px;
            height: 12px;
        }
        .status-badge .icon-svg,
        .detail-item .icon-svg,
        .tl-meta-item .icon-svg,
        .tl-pill .icon-svg,
        .tl-datetime .icon-svg,
        .cod-badge .icon-svg {
            margin-right: 4px;
        }

        .wrapper { max-width: 1040px; margin: 0 auto; }

        /* ===== HEADER ===== */
        .page-header {
            background: linear-gradient(135deg, var(--brand) 0%, var(--brand-soft) 100%);
            border: 1px solid rgba(255,255,255,.08);
            border-radius: 22px;
            box-shadow: var(--shadow-lg);
            padding: 40px 30px;
            margin-bottom: 30px;
            text-align: center;
        }
        .brand-lockup {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 24px;
            min-width: 0;
        }
        .brand-logo {
            width: 200px;
            height: 200px;
            object-fit: contain;
            flex: 0 0 auto;
            border-radius: 20px;
            background: #fff;
            padding: 16px;
            box-shadow: 0 16px 32px rgba(0,0,0,.3);
        }
        .page-header h1 {
            margin: 0;
            color: #fff;
            font-size: clamp(1.8rem, 3vw, 2.8rem);
            font-weight: 800;
            letter-spacing: 0;
            line-height: 1.1;
        }
        .page-header p {
            margin: 10px 0 0;
            color: rgba(255,255,255,.76);
            font-size: 1.1rem;
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        /* ===== SEARCH CARD ===== */
        .search-card {
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: var(--radius-lg);
            padding: 22px;
            box-shadow: var(--shadow-md);
            margin-bottom: 22px;
        }
        .search-card h2 {
            font-size: .8rem; font-weight: 700;
            color: var(--gray-600);
            text-transform: uppercase; letter-spacing: .6px;
            margin-bottom: 18px;
        }
        .search-row { display: flex; gap: 12px; align-items: flex-end; flex-wrap: wrap; }
        .search-field { flex: 1; min-width: 260px; }
        .search-field label {
            display: block; font-size: .75rem; font-weight: 700;
            color: var(--text-muted); text-transform: uppercase;
            letter-spacing: .5px; margin-bottom: 6px;
        }
        .search-field input {
            width: 100%; height: 52px;
            border: 1px solid var(--muted-line); border-radius: var(--radius-md);
            padding: 0 16px; font-size: 1.08rem; font-weight: 650;
            color: var(--text); transition: var(--tr); outline: none;
            background: #fff;
        }
        .search-field input:focus {
            border-color: var(--blue-primary);
            box-shadow: 0 0 0 4px rgba(59,130,246,.14);
        }
        .search-field input.input-error { border-color: var(--red); }

        .btn-search {
            height: 52px; padding: 0 26px;
            background: var(--blue-primary); color: #fff;
            border: none; border-radius: var(--radius-md);
            font-size: .95rem; font-weight: 700; cursor: pointer;
            transition: var(--tr); white-space: nowrap;
            display: inline-flex; align-items: center; justify-content: center;
        }
        .btn-search:hover { background: var(--blue-dark); transform: translateY(-1px); box-shadow: 0 9px 18px rgba(59,130,246,.28); }
        .btn-search:disabled { background: var(--gray-400); cursor: not-allowed; transform: none; box-shadow: none; }

        .btn-clear {
            height: 52px; padding: 0 18px;
            background: var(--gray-100); color: var(--text-muted);
            border: 1px solid var(--muted-line); border-radius: var(--radius-md);
            font-size: .88rem; font-weight: 600; cursor: pointer; transition: var(--tr);
            display: inline-flex; align-items: center; justify-content: center;
        }
        .btn-clear:hover { background: var(--gray-200); color: var(--text); }

        /* ===== SPINNER ===== */
        .loading-area {
            display: none;
            text-align: center; padding: 48px 0;
        }
        .spinner {
            width: 44px; height: 44px;
            border: 4px solid rgba(255,255,255,.25);
            border-top-color: #fff;
            border-radius: 50%;
            animation: spin .8s linear infinite;
            margin: 0 auto 14px;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
        .loading-area p { color: rgba(255,255,255,.8); font-size: .9rem; }

        /* ===== ERROR ===== */
        .error-state {
            display: none;
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: var(--radius-lg);
            padding: 48px 28px; text-align: center;
            box-shadow: var(--shadow-lg);
        }
        .error-state .icon { font-size: 3.5rem; margin-bottom: 12px; }
        .error-state h3 { font-size: 1.1rem; font-weight: 700; color: var(--gray-800); margin-bottom: 6px; }
        .error-state p  { color: var(--gray-600); font-size: .88rem; }

        /* ===== RESULT COUNT ===== */
        .result-count {
            font-size: .9rem; color: var(--text-muted);
            margin-bottom: 14px; padding: 0 4px;
            display: none;
        }
        .result-count strong { color: var(--brand); }

        /* ===== NOTA CARD ===== */
        .nota-card {
            display: none;
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
            overflow: hidden; margin-bottom: 24px;
        }

        /* Header nota */
        .nota-header {
            background: linear-gradient(135deg, var(--brand), var(--brand-soft));
            padding: 24px 28px;
            display: flex; justify-content: space-between;
            align-items: flex-start; flex-wrap: wrap; gap: 12px;
        }
        .nota-header h3  { color: #fff; font-size: 1.3rem; font-weight: 700; }
        .nota-header-meta {
            color: rgba(255,255,255,.72); font-size: .82rem;
            margin-top: 5px; display: flex; gap: 14px; flex-wrap: wrap;
        }

        /* Badge status */
        .status-badge {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 6px 16px; border-radius: 999px;
            font-size: .76rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: .5px;
            border: 2px solid rgba(255,255,255,.35); white-space: nowrap;
        }
        .st-entregue { background: rgba(30,142,62,.9);  color: #fff; }
        .st-transito  { background: rgba(249,171,0,.9); color: #222; }
        .st-cidade    { background: rgba(26,115,232,.9);color: #fff; }
        .st-coleta    { background: rgba(80,90,100,.8); color: #fff; }
        .st-default   { background: rgba(100,100,100,.7); color: #fff; }

        /* Detalhes grid */
        .nota-details {
            padding: 18px 28px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 16px;
            border-bottom: 1px solid var(--gray-200);
            background: var(--gray-100);
        }
        .detail-item label {
            display: block; font-size: .68rem; font-weight: 700;
            color: var(--gray-600); text-transform: uppercase;
            letter-spacing: .5px; margin-bottom: 4px;
        }
        .detail-item span          { font-size: .88rem; font-weight: 600; color: var(--gray-800); }
        .detail-item span.hl       { color: var(--blue-primary); }
        .detail-item span.hl-green { color: var(--green-ok); }
        .detail-item span.empty    { color: var(--gray-400); font-style: italic; font-weight: 400; }

        /* ===== PROGRESS BAR ===== */
        .progress-section { padding: 22px 28px; border-bottom: 1px solid var(--gray-200); }
        .progress-steps   { display: flex; align-items: center; }

        .step-item {
            flex: 1; display: flex; flex-direction: column;
            align-items: center; position: relative; z-index: 1;
        }
        .step-icon {
            width: 58px; height: 58px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            border: 3px solid var(--gray-300);
            background: var(--white); transition: var(--tr);
        }
        .step-icon .icon-svg { width: 27px; height: 27px; }
        .step-icon.done    { background: var(--green-ok);    border-color: var(--green-ok);    color: #fff; box-shadow: 0 8px 18px rgba(34,197,94,.22); }
        .step-icon.active  { background: var(--blue-primary);border-color: var(--blue-primary);color: #fff; box-shadow: 0 0 0 7px rgba(59,130,246,.18); }
        .step-icon.pending { background: var(--white);        border-color: var(--gray-300);    color: var(--gray-400); }

        .step-label {
            margin-top: 9px; font-size: .72rem; font-weight: 800;
            text-transform: uppercase; letter-spacing: .4px;
            text-align: center; color: var(--gray-400); line-height: 1.3;
        }
        .step-label.done   { color: var(--green-ok); }
        .step-label.active { color: var(--blue-primary); }

        .step-line {
            flex: 1; height: 4px;
            background: var(--gray-200);
            position: relative; top: -27px; z-index: 0;
            transition: var(--tr);
        }
        .step-line.done { background: var(--green-ok); }
        .step-line.half { background: linear-gradient(90deg, var(--green-ok) 50%, var(--gray-200) 50%); }

        /* ===== TIMELINE ===== */
        .timeline-section { padding: 22px 28px 30px; }
        .timeline-section h4 {
            font-size: .8rem; font-weight: 800; color: var(--text-muted);
            text-transform: uppercase; letter-spacing: .5px; margin-bottom: 20px;
        }

        .timeline { position: relative; padding-left: 34px; }
        .timeline::before {
            content: '';
            position: absolute; left: 11px; top: 10px; bottom: 10px;
            width: 2px; background: var(--gray-200);
        }

        .tl-item { position: relative; margin-bottom: 16px; }
        .tl-item:last-child { margin-bottom: 0; }

        .tl-dot {
            position: absolute; left: -32px; top: 13px;
            width: 28px; height: 28px; border-radius: 50%;
            border: 3px solid var(--white);
            display: flex; align-items: center; justify-content: center;
            font-size: .58rem; font-weight: 700; color: #fff;
        }
        .tl-dot .icon-svg { width: 15px; height: 15px; }
        .dot-entregue { background: var(--green-ok);    box-shadow: 0 0 0 2px var(--green-ok); }
        .dot-cidade   { background: #7c3aed;            box-shadow: 0 0 0 2px #7c3aed; }
        .dot-transito { background: var(--blue-primary);box-shadow: 0 0 0 2px var(--blue-primary); }
        .dot-coleta   { background: var(--gray-600);    box-shadow: 0 0 0 2px var(--gray-600); }
        .dot-alerta   { background: var(--yellow);      box-shadow: 0 0 0 2px var(--yellow); color: #333; }
        .dot-default  { background: var(--gray-400);    box-shadow: 0 0 0 2px var(--gray-400); }

        .tl-card {
            background: var(--gray-100); border: 1px solid var(--gray-200);
            border-radius: var(--radius-md); padding: 16px 18px;
            transition: var(--tr);
        }
        .tl-card:hover { box-shadow: var(--shadow-md); border-color: var(--blue-primary); background: #f0f4ff; }
        .tl-card.card-entregue { background: var(--green-light); border-color: #a8d5b5; }
        .tl-card.card-entregue:hover { background: #d4edda; }

        .tl-top {
            display: flex; justify-content: space-between;
            align-items: flex-start; gap: 10px; flex-wrap: wrap;
        }
        .tl-event    { font-size: .93rem; font-weight: 700; color: var(--gray-800); }
        .tl-datetime { font-size: .78rem; color: var(--gray-600); white-space: nowrap; }

        .cod-badge {
            display: inline-block;
            background: var(--blue-light); color: var(--blue-primary);
            font-size: .66rem; font-weight: 700;
            padding: 2px 8px; border-radius: 999px; margin-left: 6px;
            vertical-align: middle;
        }

        .tl-meta { margin-top: 8px; display: flex; gap: 12px; flex-wrap: wrap; }
        .tl-meta-item {
            font-size: .76rem; color: var(--gray-600);
            display: flex; align-items: center; gap: 3px;
        }
        .tl-meta-item strong { color: var(--gray-800); }

        .tl-pill {
            margin-top: 8px;
            display: inline-flex; align-items: center; gap: 5px;
            border-radius: 6px; padding: 4px 12px;
            font-size: .76rem; font-weight: 600;
        }
        .pill-yellow { background: var(--yellow-light); color: #7a5c00; border: 1px solid #f0d060; }
        .pill-green  { background: var(--green-light);  color: #155724; border: 1px solid #a8d5b5; }

        .tl-obs {
            margin-top: 10px;
            background: var(--white);
            border-left: 3px solid var(--blue-primary);
            border-radius: 0 6px 6px 0;
            padding: 9px 13px;
            font-size: .8rem; color: var(--gray-800);
            line-height: 1.6; white-space: pre-wrap; word-break: break-word;
        }
        .tl-obs-label {
            font-size: .66rem; font-weight: 700; color: var(--blue-primary);
            text-transform: uppercase; letter-spacing: .4px; margin-bottom: 4px;
        }

        /* ===== RESPONSIVE ===== */
        @media (max-width: 600px) {
            .search-card { padding: 20px 18px; }
            .nota-header, .nota-details, .progress-section, .timeline-section { padding-left: 18px; padding-right: 18px; }
            .nota-header { flex-direction: column; }
            .brand-lockup { flex-direction: column; text-align: center; }
            .brand-logo { width: 160px; height: 160px; }
            .search-row { align-items: stretch; }
            .btn-search, .btn-clear { width: 100%; }
            .step-icon { width: 50px; height: 50px; }
            .step-line { top: -24px; }
        }
    </style>
</head>
<body>
<svg aria-hidden="true" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" style="position:absolute;width:0;height:0;overflow:hidden">
    <symbol id="i-search" viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"></circle><path d="M20 20l-3.5-3.5"></path></symbol>
    <symbol id="i-x" viewBox="0 0 24 24"><path d="M18 6L6 18"></path><path d="M6 6l12 12"></path></symbol>
    <symbol id="i-truck" viewBox="0 0 24 24"><path d="M3 7h11v10H3z"></path><path d="M14 11h4l3 3v3h-7z"></path><circle cx="7" cy="18" r="2"></circle><circle cx="18" cy="18" r="2"></circle></symbol>
    <symbol id="i-box" viewBox="0 0 24 24"><path d="M21 8l-9-5-9 5 9 5 9-5z"></path><path d="M3 8v8l9 5 9-5V8"></path><path d="M12 13v8"></path></symbol>
    <symbol id="i-file" viewBox="0 0 24 24"><path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path><path d="M14 3v6h6"></path><path d="M8 13h8"></path><path d="M8 17h5"></path></symbol>
    <symbol id="i-list" viewBox="0 0 24 24"><path d="M8 6h13"></path><path d="M8 12h13"></path><path d="M8 18h13"></path><path d="M3 6h.01"></path><path d="M3 12h.01"></path><path d="M3 18h.01"></path></symbol>
    <symbol id="i-calendar" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="17" rx="2"></rect><path d="M8 2v4"></path><path d="M16 2v4"></path><path d="M3 10h18"></path></symbol>
    <symbol id="i-building" viewBox="0 0 24 24"><path d="M4 21V5a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v16"></path><path d="M9 21v-4h3v4"></path><path d="M8 7h1"></path><path d="M12 7h1"></path><path d="M8 11h1"></path><path d="M12 11h1"></path><path d="M18 9h1a1 1 0 0 1 1 1v11"></path><path d="M3 21h18"></path></symbol>
    <symbol id="i-check" viewBox="0 0 24 24"><path d="M20 6L9 17l-5-5"></path></symbol>
    <symbol id="i-city" viewBox="0 0 24 24"><path d="M3 21h18"></path><path d="M5 21V8l6-4v17"></path><path d="M13 21V6h6v15"></path><path d="M8 10h.01"></path><path d="M8 14h.01"></path><path d="M16 10h.01"></path><path d="M16 14h.01"></path></symbol>
    <symbol id="i-clipboard" viewBox="0 0 24 24"><path d="M9 4h6"></path><path d="M10 2h4a2 2 0 0 1 2 2v1H8V4a2 2 0 0 1 2-2z"></path><path d="M8 4H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2h-2"></path><path d="M8 12h8"></path><path d="M8 16h5"></path></symbol>
    <symbol id="i-map" viewBox="0 0 24 24"><path d="M12 21s7-4.5 7-11a7 7 0 0 0-14 0c0 6.5 7 11 7 11z"></path><circle cx="12" cy="10" r="2"></circle></symbol>
    <symbol id="i-bookmark" viewBox="0 0 24 24"><path d="M6 4a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v18l-6-4-6 4z"></path></symbol>
    <symbol id="i-invoice" viewBox="0 0 24 24"><path d="M6 2h12v20l-3-2-3 2-3-2-3 2z"></path><path d="M9 8h6"></path><path d="M9 12h6"></path><path d="M9 16h4"></path></symbol>
    <symbol id="i-clock" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"></circle><path d="M12 7v5l3 2"></path></symbol>
    <symbol id="i-comment" viewBox="0 0 24 24"><path d="M21 11.5a8.5 8.5 0 0 1-9 8.5 8.7 8.7 0 0 1-4-.9L3 21l1.8-4.5A8.5 8.5 0 1 1 21 11.5z"></path></symbol>
    <symbol id="i-circle" viewBox="0 0 24 24"><circle cx="12" cy="12" r="4"></circle></symbol>
</svg>
<div class="wrapper">

    <!-- HEADER -->
    <div class="page-header">
        <div class="brand-lockup">
            <img class="brand-logo"
                 src="https://cloud.multfer.com.br/ti/img/logo-multfer-rastreamentov2_1.jpg"
                 alt="Multfer">
            <div>
                <h1>🚧 EM CONSTRUÇÃO | Rastreamento de Entregas</h1>
                <p>MULTFER</p>
            </div>
        </div>
    </div>

    <!-- SEARCH -->
    <div class="search-card">
        <div class="search-row">
            <div class="search-field">
                <label for="inputNota">Digite o Número da Nota</label>
                <input type="text"
                       id="inputNota"
                       placeholder="Ex: 1100011"
                       autocomplete="off"
                       inputmode="numeric"
                       pattern="[0-9]*"
                       maxlength="50"
                       autofocus/>
            </div>
            <button class="btn-search" id="btnRastrear" onclick="rastrear()"><svg class="icon-svg icon-gap"><use href="#i-search" xlink:href="#i-search"></use></svg>Consultar</button>
            <button class="btn-clear" id="btnLimpar" style="display:none" onclick="limpar()"><svg class="icon-svg icon-gap"><use href="#i-x" xlink:href="#i-x"></use></svg>Limpar</button>
        </div>
    </div>

    <!-- LOADING -->
    <div class="loading-area" id="loading">
        <div class="spinner"></div>
        <p>Buscando ocorrências...</p>
    </div>

    <!-- ERROR -->
    <div class="error-state" id="errorState">
        <div class="icon"><svg class="icon-svg"><use href="#i-search" xlink:href="#i-search"></use></svg></div>
        <h3 id="errorTitle">Nenhuma ocorrência encontrada</h3>
        <p id="errorMsg"></p>
    </div>

    <!-- RESULT COUNT -->
    <p class="result-count" id="resultCount"></p>

    <!-- NOTA CARD (preenchido via JS) -->
    <div class="nota-card" id="notaCard">

        <div class="nota-header" id="notaHeader">
            <div>
                <h3 id="notaTitulo"></h3>
                <div class="nota-header-meta" id="notaMeta"></div>
            </div>
            <span class="status-badge" id="statusBadge"></span>
        </div>

        <div class="nota-details" id="notaDetails"></div>

        <div class="progress-section">
            <div class="progress-steps" id="progressSteps"></div>
        </div>

        <div class="timeline-section">
            <h4><svg class="icon-svg icon-gap"><use href="#i-map" xlink:href="#i-map"></use></svg>Histórico Completo de Ocorrências</h4>
            <div class="timeline" id="timeline"></div>
        </div>

    </div>

</div><%-- /wrapper --%>

<script>
// ============================================================
// SANKHYA SERVICE CALL — usa o endpoint nativo do ERP
// que já mantém a sessão do usuário logado
// ============================================================
var BASE_URL = '/mge/service.sbr?serviceName=DbExplorerSP.executeQuery&outputType=json';
var QUERY_COLUMNS = [
    'ID', 'NUMERONOTA', 'SERIENOTA', 'CNPJEMISSORCTE', 'EMITENTENOTA',
    'CHAVECTE', 'CHAVENOTA', 'CODIGOOCORRENCIATRANSPORTADORA',
    'NOMEOCORRENCIA', 'CODIGOOCORRENCIA', 'CODIGORASTREIO',
    'TRANSPORTADORA', 'UNIDADE', 'NUMEROCTE', 'AGENDAMENTOENTREGA',
    'NUMEROPRENOTA', 'DATA_FMT', 'PRAZO_FMT', 'PREVISAO_FMT',
    'ENTREGA_FMT', 'OBSERVACAO_TXT'
];

function getSankhyaToken() {
    // O token de sessão fica em cookie ou pode ser lido via API de contexto;
    // para gadgets JSP o Sankhya já injeta a sessão automaticamente nas
    // requisições ao mesmo domínio — basta usar credentials: 'include'
    return null;
}

async function fetchOcorrencias(numeroNota) {
    var sql = "SELECT ID, NUMERONOTA, SERIENOTA, CNPJEMISSORCTE, EMITENTENOTA, CHAVECTE, CHAVENOTA, " +
              "CODIGOOCORRENCIATRANSPORTADORA, NOMEOCORRENCIA, CODIGOOCORRENCIA, CODIGORASTREIO, " +
              "TRANSPORTADORA, UNIDADE, NUMEROCTE, AGENDAMENTOENTREGA, NUMEROPRENOTA, " +
              "TO_CHAR(DATA, 'DD/MM/YYYY HH24:MI') AS DATA_FMT, " +
              "TO_CHAR(PRAZO, 'DD/MM/YYYY') AS PRAZO_FMT, " +
              "TO_CHAR(DATAPREVISAOENTREGA, 'DD/MM/YYYY') AS PREVISAO_FMT, " +
              "TO_CHAR(DATAENTREGA, 'DD/MM/YYYY') AS ENTREGA_FMT, " +
              "CAST(NULL AS VARCHAR2(1000)) AS OBSERVACAO_TXT " +
              "FROM AD_OCORRENCIAS " +
              "WHERE TRIM(NUMERONOTA) = '" + numeroNota.replace(/'/g,"''") + "' " +
              "ORDER BY DATA ASC, ID ASC";

    var payload = {
        serviceName: "DbExplorerSP.executeQuery",
        requestBody: { sql: sql }
    };

    var resp = await fetch('/mge/service.sbr?serviceName=DbExplorerSP.executeQuery&outputType=json', {
        method: 'POST',
        credentials: 'include',
        headers: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Accept': 'application/json;charset=UTF-8'
        },
        body: JSON.stringify(payload)
    });

    if (!resp.ok) throw new Error('HTTP ' + resp.status);
    var data = await resp.json();

    if (data.status === '1' || data.status === 1 || data.responseBody) {
        return normalizeQueryResponse(data);
    }
    throw new Error(data.statusMessage || data.message || 'Erro ao consultar o serviço');
}

function normalizeQueryResponse(data) {
    var rb = data.responseBody || data.response || data;
    var rawRows = rb.rows || rb.row || rb.result || rb.resultSet || rb.data || rb.records || [];

    if (rawRows && rawRows.rows) rawRows = rawRows.rows;
    if (rawRows && rawRows.row) rawRows = rawRows.row;
    if (rawRows && !Array.isArray(rawRows) && typeof rawRows === 'object') rawRows = [rawRows];
    if (!Array.isArray(rawRows)) rawRows = [];

    var columns = getColumns(rb);
    if (!columns.length) columns = QUERY_COLUMNS;

    return rawRows.map(function(row) {
        var obj = {};

        if (Array.isArray(row)) {
            columns.forEach(function(col, i) {
                obj[col] = cellValue(row[i]);
            });
            return obj;
        }

        if (row && typeof row === 'object') {
            if (Array.isArray(row.values) || Array.isArray(row.cells) || Array.isArray(row.cell)) {
                var rowValues = row.values || row.cells || row.cell;
                columns.forEach(function(col, i) {
                    obj[col] = cellValue(rowValues[i]);
                });
                return obj;
            }

            var keys = Object.keys(row);
            var numericKeys = keys.length && keys.every(function(key) { return /^\d+$/.test(key); });
            if (numericKeys) {
                columns.forEach(function(col, i) {
                    obj[col] = cellValue(row[String(i)]);
                });
                return obj;
            }

            Object.keys(row).forEach(function(key) {
                obj[normalizeColumnName(key)] = cellValue(row[key]);
            });
            return obj;
        }

        return obj;
    });
}

function getColumns(rb) {
    var meta = rb.fieldsMetadata || rb.fieldsMetaData || rb.columns || rb.metadata || rb.metaData || [];
    var cols = [];

    if (!Array.isArray(meta) && meta && typeof meta === 'object') {
        meta = meta.fields || meta.columns || Object.keys(meta).map(function(k) {
            var item = meta[k];
            if (item && typeof item === 'object' && !item.name && !item.NAME && !item.fieldName && !item.FIELDNAME) {
                item.name = k;
            }
            return item || k;
        });
    }

    if (Array.isArray(meta)) {
        meta.forEach(function(col, idx) {
            var name = '';
            if (typeof col === 'string') {
                name = col;
            } else if (col && typeof col === 'object') {
                name = col.name || col.NAME || col.fieldName || col.FIELDNAME ||
                       col.field || col.FIELD || col.columnName || col.COLUMNNAME ||
                       col.alias || col.ALIAS || '';
            }
            cols.push(normalizeColumnName(name || QUERY_COLUMNS[idx] || ('COL' + idx)));
        });
    }

    return cols;
}

function normalizeColumnName(name) {
    return String(name || '').replace(/[^0-9A-Za-z_]/g, '').toUpperCase();
}

function cellValue(value) {
    if (value === null || typeof value === 'undefined') return '';
    if (typeof value !== 'object') return value;
    if (typeof value.value !== 'undefined') return value.value;
    if (typeof value.VALUE !== 'undefined') return value.VALUE;
    if (typeof value.$ !== 'undefined') return value.$;
    if (typeof value.text !== 'undefined') return value.text;
    if (typeof value.content !== 'undefined') return value.content;
    return '';
}

function icon(name, extraClass) {
    return '<svg class="icon-svg ' + (extraClass || '') + '" aria-hidden="true"><use href="#i-' + name + '" xlink:href="#i-' + name + '"></use></svg>';
}

function field(row, name) {
    if (!row) return '';
    var upper = normalizeColumnName(name);
    var lower = upper.toLowerCase();
    if (typeof row[upper] !== 'undefined') return row[upper];
    if (typeof row[lower] !== 'undefined') return row[lower];
    if (typeof row[name] !== 'undefined') return row[name];
    return '';
}

// ============================================================
// HELPERS DE STATUS
// ============================================================
function getStatus(cod) {
    var c = (cod || '').toString().trim();
    if (c === '01' || c === '1')  return { cls: 'st-entregue', label: 'ENTREGUE',        icon: icon('check'),     step: 4 };
    if (c === '98')               return { cls: 'st-cidade',   label: 'NA CIDADE',       icon: icon('city'),      step: 3 };
    if (c === '00' || c === '0')  return { cls: 'st-coleta',   label: 'COLETA INICIADA', icon: icon('clipboard'), step: 1 };
    return                               { cls: 'st-transito', label: 'EM TRÂNSITO',     icon: icon('truck'),     step: 2 };
}

function getDotClass(cod) {
    var c = (cod || '').toString().trim();
    if (c === '01' || c === '1')  return { dot: 'dot-entregue', card: 'card-entregue', txt: icon('check') };
    if (c === '98')               return { dot: 'dot-cidade',   card: '',              txt: icon('map') };
    if (c === '52')               return { dot: 'dot-transito', card: '',              txt: icon('truck') };
    if (c === '00' || c === '0')  return { dot: 'dot-coleta',   card: '',              txt: icon('clipboard') };
    return                               { dot: 'dot-default',  card: '',              txt: icon('circle') };
}

function esc(s) {
    if (!s) return '';
    return String(s)
        .replace(/&/g,'&amp;').replace(/</g,'&lt;')
        .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function orDash(v, prefix) {
    if (!v || v.toString().trim() === '') return '<span class="empty">-</span>';
    return '<span>' + esc(prefix || '') + esc(v) + '</span>';
}

// ============================================================
// RENDER PROGRESS BAR
// ============================================================
function renderProgress(currentStep) {
    // currentStep: 1=coleta, 2=transito, 3=cidade, 4=entregue
    var steps = [
        { label: 'Coleta<br/>Iniciada', icon: icon('clipboard') },
        { label: 'Em<br/>Trânsito',     icon: icon('truck') },
        { label: 'Na<br/>Cidade',       icon: icon('city') },
        { label: 'Entregue',            icon: icon('check') }
    ];
    var html = '';
    steps.forEach(function(s, i) {
        var stepNum = i + 1;
        var iconCls = stepNum < currentStep ? 'done' : (stepNum === currentStep ? 'active' : 'pending');
        var lblCls  = iconCls;
        html += '<div class="step-item">' +
                  '<div class="step-icon ' + iconCls + '">' + s.icon + '</div>' +
                  '<div class="step-label ' + lblCls + '">' + s.label + '</div>' +
                '</div>';
        if (i < steps.length - 1) {
            var lineCls = stepNum < currentStep ? 'done' : (stepNum === currentStep ? 'half' : '');
            html += '<div class="step-line ' + lineCls + '"></div>';
        }
    });
    document.getElementById('progressSteps').innerHTML = html;
}

// ============================================================
// RENDER RESULTADO
// ============================================================
function renderResultado(rows) {
    if (!rows || rows.length === 0) {
        showError('Nenhuma ocorrência encontrada',
            'Não foram localizadas ocorrências para a nota informada. Verifique o número e tente novamente.');
        return;
    }

    // --- Resumo (calcular a partir das rows) ---
    var numeronota  = field(rows[0], 'NUMERONOTA');
    var serienota   = field(rows[0], 'SERIENOTA');
    var cnpj        = field(rows[0], 'CNPJEMISSORCTE');
    var transp      = field(rows[0], 'TRANSPORTADORA');
    var rastreio    = '';
    var previsao    = '';
    var dataEntrega = '';
    var primeiraOc  = field(rows[0], 'DATA_FMT');
    var ultimaOc    = field(rows[rows.length-1], 'DATA_FMT');
    var ultimoCod   = '';

    rows.forEach(function(r) {
        var cod = field(r, 'CODIGOOCORRENCIATRANSPORTADORA');
        if (cod) ultimoCod = cod;
        var prev = field(r, 'PREVISAO_FMT');
        if (prev) previsao = prev;
        var ent = field(r, 'ENTREGA_FMT');
        if (ent) dataEntrega = ent;
        var rast = field(r, 'CODIGORASTREIO');
        if (rast) rastreio = rast;
        if (!transp) transp = field(r, 'TRANSPORTADORA');
    });

    var st = getStatus(ultimoCod);

    // --- Header da nota ---
    document.getElementById('notaTitulo').innerHTML = icon('file', 'icon-gap') + 'NF ' + esc(numeronota);
    var metaHtml = '';
    if (serienota) metaHtml += '<span>' + icon('clipboard') + ' Série: ' + esc(serienota) + '</span>';
    if (cnpj)      metaHtml += '<span>' + icon('building') + ' ' + esc(cnpj) + '</span>';
    metaHtml += '<span>' + icon('list') + ' ' + rows.length + ' ocorrência(s)</span>';
    document.getElementById('notaMeta').innerHTML = metaHtml;

    var badge = document.getElementById('statusBadge');
    badge.className = 'status-badge ' + st.cls;
    badge.innerHTML = st.icon + ' ' + st.label;

    // --- Detalhes grid ---
    var det = document.getElementById('notaDetails');
    det.innerHTML =
        '<div class="detail-item"><label>Primeira Ocorrência</label>' + orDash(primeiraOc) + '</div>' +
        '<div class="detail-item"><label>Última Ocorrência</label>'   + orDash(ultimaOc)   + '</div>' +
        '<div class="detail-item"><label>Previsão de Entrega</label>' +
            (previsao   ? '<span class="hl">' + icon('calendar') + ' '  + esc(previsao)   + '</span>' : '<span class="empty">-</span>') +
        '</div>' +
        '<div class="detail-item"><label>Data de Entrega</label>' +
            (dataEntrega ? '<span class="hl-green">' + icon('check') + ' ' + esc(dataEntrega) + '</span>' : '<span class="empty">-</span>') +
        '</div>' +
        '<div class="detail-item"><label>Transportadora</label>' +
            (transp  ? '<span>' + icon('truck') + ' ' + esc(transp)  + '</span>' : '<span class="empty">-</span>') +
        '</div>';

    // --- Progress bar ---
    renderProgress(st.step);

    // --- Timeline ---
    var tlHtml = '';
    rows.forEach(function(r) {
        var cod      = String(field(r, 'CODIGOOCORRENCIATRANSPORTADORA') || '').trim();
        var nome     = field(r, 'NOMEOCORRENCIA') || 'Ocorrência';
        var dataFmt  = field(r, 'DATA_FMT');
        var prevFmt  = field(r, 'PREVISAO_FMT');
        var entFmt   = field(r, 'ENTREGA_FMT');
        var obs      = field(r, 'OBSERVACAO_TXT');
        var tCnpj    = field(r, 'CNPJEMISSORCTE');
        var tTransp  = field(r, 'TRANSPORTADORA');
        var tUnid    = field(r, 'UNIDADE');
        var tCte     = field(r, 'NUMEROCTE');

        var dc = getDotClass(cod);

        tlHtml += '<div class="tl-item">';
        tlHtml +=   '<div class="tl-dot ' + dc.dot + '">' + dc.txt + '</div>';
        tlHtml +=   '<div class="tl-card ' + dc.card + '">';
        tlHtml +=     '<div class="tl-top">';
        tlHtml +=       '<div><span class="tl-event">' + esc(nome) + '</span>';
        if (cod) tlHtml += '<span class="cod-badge">Cód. ' + esc(cod) + '</span>';
        tlHtml +=       '</div>';
        tlHtml +=       '<span class="tl-datetime">' + icon('calendar') + ' ' + esc(dataFmt) + '</span>';
        tlHtml +=     '</div>';

        // Meta
        var metaItems = [];
        if (tCnpj)   metaItems.push(icon('building') + ' <strong>' + esc(tCnpj)   + '</strong>');
        if (tTransp) metaItems.push(icon('truck') + ' <strong>' + esc(tTransp) + '</strong>');
        if (tUnid)   metaItems.push(icon('box') + ' ' + esc(tUnid));
        if (tCte)    metaItems.push(icon('invoice') + ' CT-e: <strong>' + esc(tCte) + '</strong>');

        if (metaItems.length) {
            tlHtml += '<div class="tl-meta">';
            metaItems.forEach(function(m) { tlHtml += '<span class="tl-meta-item">' + m + '</span>'; });
            tlHtml += '</div>';
        }

        if (prevFmt)   tlHtml += '<div class="tl-pill pill-yellow">' + icon('clock') + ' Previsão de entrega: <strong>' + esc(prevFmt) + '</strong></div>';
        if (entFmt)    tlHtml += '<div class="tl-pill pill-green">' + icon('check') + ' Entregue em: <strong>' + esc(entFmt) + '</strong></div>';

        if (obs && obs.trim()) {
            tlHtml += '<div class="tl-obs"><div class="tl-obs-label">' + icon('comment') + ' Observação</div>' + esc(obs.trim()) + '</div>';
        }

        tlHtml += '</div></div>';
    });
    document.getElementById('timeline').innerHTML = tlHtml;

    // --- Exibir resultado count + card ---
    document.getElementById('resultCount').innerHTML =
        '<strong>' + rows.length + '</strong> ocorrência(s) encontrada(s) para <strong>NF ' + esc(numeronota) + '</strong>';
    document.getElementById('resultCount').style.display = 'block';
    document.getElementById('notaCard').style.display    = 'block';
}

// ============================================================
// CONTROLE DE UI
// ============================================================
function showLoading(on) {
    document.getElementById('loading').style.display = on ? 'block' : 'none';
}
function showWelcome(on) {
    document.getElementById('welcome').style.display = on ? 'block' : 'none';
}
function showError(title, msg) {
    document.getElementById('errorTitle').textContent = title || 'Erro';
    document.getElementById('errorMsg').textContent   = msg   || '';
    document.getElementById('errorState').style.display = 'block';
}
function hideAll() {
    ['loading','welcome','errorState','notaCard','resultCount'].forEach(function(id) {
        var el = document.getElementById(id);
        if (el) el.style.display = 'none';
    });
}

function somenteNumeros(valor) {
    return String(valor || '').replace(/\D/g, '');
}

function ehEditavel(el) {
    if (!el) return false;
    var tag = (el.tagName || '').toLowerCase();
    return tag === 'input' || tag === 'textarea' || tag === 'select' || el.isContentEditable;
}

function limpar() {
    document.getElementById('inputNota').value = '';
    document.getElementById('btnLimpar').style.display = 'none';
    hideAll();
    showWelcome(true);
    document.getElementById('inputNota').focus();
}

async function rastrear() {
    var input = document.getElementById('inputNota');
    var nota = somenteNumeros(input.value);
    input.value = nota;

    if (!nota) {
        input.classList.add('input-error');
        setTimeout(function(){ input.classList.remove('input-error'); }, 2000);
        input.focus();
        return;
    }

    hideAll();
    showLoading(true);
    document.getElementById('btnRastrear').disabled = true;
    document.getElementById('btnLimpar').style.display = 'none';

    try {
        var rows = await fetchOcorrencias(nota);
        hideAll();
        renderResultado(rows);
        document.getElementById('btnLimpar').style.display = '';
    } catch(e) {
        hideAll();
        showError('Erro ao consultar', 'Não foi possível buscar as ocorrências. Detalhe: ' + e.message);
    } finally {
        document.getElementById('btnRastrear').disabled = false;
    }
}

// ===== INIT =====
document.addEventListener('DOMContentLoaded', function() {
    showWelcome(true);
    var inp = document.getElementById('inputNota');
    if (inp) {
        inp.addEventListener('input', function() {
            var limpo = somenteNumeros(inp.value);
            if (inp.value !== limpo) inp.value = limpo;
        });
        inp.addEventListener('paste', function() {
            setTimeout(function() { inp.value = somenteNumeros(inp.value); }, 0);
        });
        inp.addEventListener('keydown', function(e) {
            var controle = e.ctrlKey || e.metaKey || e.altKey ||
                ['Backspace','Delete','Tab','Enter','ArrowLeft','ArrowRight','Home','End'].indexOf(e.key) >= 0;
            if (e.key === 'Enter') {
                e.preventDefault();
                rastrear();
                return;
            }
            if (!controle && !/^\d$/.test(e.key)) {
                e.preventDefault();
            }
        });
    }

    document.addEventListener('mousedown', function(e) {
        if (!ehEditavel(e.target) && ehEditavel(document.activeElement)) {
            document.activeElement.blur();
        }
    });
});
</script>

</body>
</html>
