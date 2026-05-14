<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
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
            --blue-primary: #1a73e8;
            --blue-dark:    #0d47a1;
            --blue-light:   #e8f0fe;
            --green-ok:     #1e8e3e;
            --green-light:  #e6f4ea;
            --yellow:       #f9ab00;
            --yellow-light: #fef9e7;
            --red:          #d93025;
            --gray-100:     #f8f9fa;
            --gray-200:     #e9ecef;
            --gray-300:     #dee2e6;
            --gray-400:     #ced4da;
            --gray-600:     #6c757d;
            --gray-800:     #343a40;
            --white:        #ffffff;
            --radius-md:    12px;
            --radius-lg:    20px;
            --shadow-md:    0 4px 16px rgba(0,0,0,.10);
            --shadow-lg:    0 8px 32px rgba(0,0,0,.16);
            --tr:           all .25s ease;
        }

        body {
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            background: linear-gradient(135deg, #0d47a1 0%, #1565c0 40%, #1976d2 100%);
            min-height: 100vh;
            padding: 24px 16px 48px;
            color: var(--gray-800);
        }

        .wrapper { max-width: 900px; margin: 0 auto; }

        /* ===== HEADER ===== */
        .page-header { text-align: center; margin-bottom: 28px; }
        .page-header .logo { font-size: 3rem; margin-bottom: 8px; }
        .page-header h1 { font-size: 1.75rem; font-weight: 700; color: #fff; letter-spacing: -.4px; }
        .page-header p  { color: rgba(255,255,255,.72); font-size: .92rem; margin-top: 5px; }

        /* ===== SEARCH CARD ===== */
        .search-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            padding: 28px 32px;
            box-shadow: var(--shadow-lg);
            margin-bottom: 28px;
        }
        .search-card h2 {
            font-size: .8rem; font-weight: 700;
            color: var(--gray-600);
            text-transform: uppercase; letter-spacing: .6px;
            margin-bottom: 18px;
        }
        .search-row { display: flex; gap: 10px; align-items: flex-end; flex-wrap: wrap; }
        .search-field { flex: 1; min-width: 180px; }
        .search-field label {
            display: block; font-size: .75rem; font-weight: 700;
            color: var(--gray-600); text-transform: uppercase;
            letter-spacing: .5px; margin-bottom: 6px;
        }
        .search-field input {
            width: 100%; height: 50px;
            border: 2px solid var(--gray-200); border-radius: var(--radius-md);
            padding: 0 16px; font-size: 1.05rem; font-weight: 600;
            color: var(--gray-800); transition: var(--tr); outline: none;
        }
        .search-field input:focus {
            border-color: var(--blue-primary);
            box-shadow: 0 0 0 3px rgba(26,115,232,.14);
        }
        .search-field input.input-error { border-color: var(--red); }

        .btn-search {
            height: 50px; padding: 0 26px;
            background: var(--blue-primary); color: #fff;
            border: none; border-radius: var(--radius-md);
            font-size: .95rem; font-weight: 700; cursor: pointer;
            transition: var(--tr); white-space: nowrap;
        }
        .btn-search:hover { background: var(--blue-dark); transform: translateY(-1px); box-shadow: 0 4px 12px rgba(26,115,232,.35); }
        .btn-search:disabled { background: var(--gray-400); cursor: not-allowed; transform: none; box-shadow: none; }

        .btn-clear {
            height: 50px; padding: 0 18px;
            background: var(--gray-100); color: var(--gray-600);
            border: 2px solid var(--gray-200); border-radius: var(--radius-md);
            font-size: .88rem; font-weight: 600; cursor: pointer; transition: var(--tr);
        }
        .btn-clear:hover { background: var(--gray-200); color: var(--gray-800); }

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

        /* ===== WELCOME ===== */
        .welcome-state {
            background: rgba(255,255,255,.12);
            border: 1px solid rgba(255,255,255,.2);
            border-radius: var(--radius-lg);
            padding: 42px 28px; text-align: center;
        }
        .welcome-state .icon { font-size: 4rem; margin-bottom: 14px; }
        .welcome-state h3 { font-size: 1.15rem; font-weight: 700; color: #fff; margin-bottom: 8px; }
        .welcome-state p  { color: rgba(255,255,255,.7); font-size: .9rem; line-height: 1.65; max-width: 360px; margin: 0 auto; }

        /* ===== ERROR ===== */
        .error-state {
            display: none;
            background: var(--white);
            border-radius: var(--radius-lg);
            padding: 48px 28px; text-align: center;
            box-shadow: var(--shadow-lg);
        }
        .error-state .icon { font-size: 3.5rem; margin-bottom: 12px; }
        .error-state h3 { font-size: 1.1rem; font-weight: 700; color: var(--gray-800); margin-bottom: 6px; }
        .error-state p  { color: var(--gray-600); font-size: .88rem; }

        /* ===== RESULT COUNT ===== */
        .result-count {
            font-size: .88rem; color: rgba(255,255,255,.85);
            margin-bottom: 14px; padding: 0 4px;
            display: none;
        }
        .result-count strong { color: #fff; }

        /* ===== NOTA CARD ===== */
        .nota-card {
            display: none;
            background: var(--white);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
            overflow: hidden; margin-bottom: 24px;
        }

        /* Header nota */
        .nota-header {
            background: linear-gradient(135deg, #0d47a1, #1976d2);
            padding: 20px 28px;
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
            width: 44px; height: 44px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.2rem; border: 3px solid var(--gray-300);
            background: var(--white); transition: var(--tr);
        }
        .step-icon.done    { background: var(--green-ok);    border-color: var(--green-ok);    color: #fff; }
        .step-icon.active  { background: var(--blue-primary);border-color: var(--blue-primary);color: #fff; box-shadow: 0 0 0 6px rgba(26,115,232,.18); }
        .step-icon.pending { background: var(--white);        border-color: var(--gray-300);    color: var(--gray-400); }

        .step-label {
            margin-top: 7px; font-size: .68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: .4px;
            text-align: center; color: var(--gray-400); line-height: 1.3;
        }
        .step-label.done   { color: var(--green-ok); }
        .step-label.active { color: var(--blue-primary); }

        .step-line {
            flex: 1; height: 3px;
            background: var(--gray-200);
            position: relative; top: -21px; z-index: 0;
            transition: var(--tr);
        }
        .step-line.done { background: var(--green-ok); }
        .step-line.half { background: linear-gradient(90deg, var(--green-ok) 50%, var(--gray-200) 50%); }

        /* ===== TIMELINE ===== */
        .timeline-section { padding: 22px 28px 30px; }
        .timeline-section h4 {
            font-size: .76rem; font-weight: 700; color: var(--gray-600);
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
            position: absolute; left: -29px; top: 15px;
            width: 22px; height: 22px; border-radius: 50%;
            border: 3px solid var(--white);
            display: flex; align-items: center; justify-content: center;
            font-size: .58rem; font-weight: 700; color: #fff;
        }
        .dot-entregue { background: var(--green-ok);    box-shadow: 0 0 0 2px var(--green-ok); }
        .dot-cidade   { background: #7c3aed;            box-shadow: 0 0 0 2px #7c3aed; }
        .dot-transito { background: var(--blue-primary);box-shadow: 0 0 0 2px var(--blue-primary); }
        .dot-coleta   { background: var(--gray-600);    box-shadow: 0 0 0 2px var(--gray-600); }
        .dot-alerta   { background: var(--yellow);      box-shadow: 0 0 0 2px var(--yellow); color: #333; }
        .dot-default  { background: var(--gray-400);    box-shadow: 0 0 0 2px var(--gray-400); }

        .tl-card {
            background: var(--gray-100); border: 1px solid var(--gray-200);
            border-radius: var(--radius-md); padding: 13px 17px;
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
        }
    </style>
</head>
<body>
<div class="wrapper">

    <!-- HEADER -->
    <div class="page-header">
        <div class="logo">🚚</div>
        <h1>Rastreamento de Entregas</h1>
        <p>Consulta de ocorrências por nota fiscal · AD_OCORRENCIAS</p>
    </div>

    <!-- SEARCH -->
    <div class="search-card">
        <h2>🔍 Pesquisar Nota Fiscal</h2>
        <div class="search-row">
            <div class="search-field">
                <label for="inputNota">Número da Nota</label>
                <input type="text" id="inputNota" placeholder="Ex: 157405"
                       autocomplete="off" maxlength="50" autofocus/>
            </div>
            <button class="btn-search" id="btnRastrear" onclick="rastrear()">🔍 Rastrear</button>
            <button class="btn-clear" id="btnLimpar" style="display:none" onclick="limpar()">✕ Limpar</button>
        </div>
    </div>

    <!-- LOADING -->
    <div class="loading-area" id="loading">
        <div class="spinner"></div>
        <p>Buscando ocorrências...</p>
    </div>

    <!-- WELCOME (estado inicial) -->
    <div class="welcome-state" id="welcome">
        <div class="icon">📦</div>
        <h3>Acompanhe sua entrega</h3>
        <p>Digite o número da nota fiscal e clique em <strong>Rastrear</strong> para visualizar o histórico completo de ocorrências.</p>
    </div>

    <!-- ERROR -->
    <div class="error-state" id="errorState">
        <div class="icon">🔍</div>
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
            <h4>📍 Histórico Completo de Ocorrências</h4>
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
              "TO_CHAR(DATA,               'DD/MM/YYYY HH24:MI') AS DATA_FMT, " +
              "TO_CHAR(PRAZO,              'DD/MM/YYYY')          AS PRAZO_FMT, " +
              "TO_CHAR(DATAPREVISAOENTREGA,'DD/MM/YYYY')          AS PREVISAO_FMT, " +
              "TO_CHAR(DATAENTREGA,        'DD/MM/YYYY')          AS ENTREGA_FMT, " +
              "DBMS_LOB.SUBSTR(OBSERVACAO, 4000, 1)               AS OBSERVACAO_TXT " +
              "FROM SANKHYA.AD_OCORRENCIAS " +
              "WHERE NUMERONOTA = '" + numeroNota.replace(/'/g,"''") + "' " +
              "ORDER BY DATA ASC NULLS FIRST";

    var payload = {
        serviceName: "DbExplorerSP.executeQuery",
        requestBody: { sql: sql }
    };

    var resp = await fetch('/mge/service.sbr?serviceName=DbExplorerSP.executeQuery&outputType=json', {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    });

    if (!resp.ok) throw new Error('HTTP ' + resp.status);
    var data = await resp.json();

    // Estrutura de resposta do Sankhya: data.responseBody.rows / columns
    if (data.status === '1' || (data.responseBody && data.responseBody.rows)) {
        var rb = data.responseBody;
        var columns = rb.columns || [];
        var rows    = rb.rows    || [];
        // Normalizar: transformar array de arrays em array de objetos
        return rows.map(function(row) {
            var obj = {};
            columns.forEach(function(col, i) { obj[col.name || col] = row[i]; });
            return obj;
        });
    }
    throw new Error(data.statusMessage || 'Erro ao consultar o serviço');
}

// ============================================================
// HELPERS DE STATUS
// ============================================================
function getStatus(cod) {
    var c = (cod || '').toString().trim();
    if (c === '01' || c === '1')  return { cls: 'st-entregue', label: 'ENTREGUE',       icon: '✅', step: 4 };
    if (c === '98')               return { cls: 'st-cidade',   label: 'NA CIDADE',      icon: '🏙️', step: 3 };
    if (c === '00' || c === '0')  return { cls: 'st-coleta',   label: 'COLETA INICIADA',icon: '📋', step: 1 };
    return                               { cls: 'st-transito', label: 'EM TRÂNSITO',    icon: '🚛', step: 2 };
}

function getDotClass(cod) {
    var c = (cod || '').toString().trim();
    if (c === '01' || c === '1')  return { dot: 'dot-entregue', card: 'card-entregue', txt: '✓'  };
    if (c === '98')               return { dot: 'dot-cidade',   card: '',              txt: '📍' };
    if (c === '52')               return { dot: 'dot-transito', card: '',              txt: '🚛' };
    if (c === '00' || c === '0')  return { dot: 'dot-coleta',   card: '',              txt: '📋' };
    return                               { dot: 'dot-default',  card: '',              txt: '●'  };
}

function esc(s) {
    if (!s) return '';
    return String(s)
        .replace(/&/g,'&amp;').replace(/</g,'&lt;')
        .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function orDash(v, prefix) {
    if (!v || v.toString().trim() === '') return '<span class="empty">—</span>';
    return '<span>' + esc(prefix || '') + esc(v) + '</span>';
}

// ============================================================
// RENDER PROGRESS BAR
// ============================================================
function renderProgress(currentStep) {
    // currentStep: 1=coleta, 2=transito, 3=cidade, 4=entregue
    var steps = [
        { label: 'Coleta<br/>Iniciada', icon: '📋' },
        { label: 'Em<br/>Trânsito',     icon: '🚛' },
        { label: 'Na<br/>Cidade',       icon: '🏙️' },
        { label: 'Entregue',            icon: '✅' }
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
    var numeronota  = rows[0].NUMERONOTA  || rows[0].numeronota  || '';
    var serienota   = rows[0].SERIENOTA   || rows[0].serienota   || '';
    var cnpj        = rows[0].CNPJEMISSORCTE || rows[0].cnpjemissorcte || '';
    var transp      = rows[0].TRANSPORTADORA || rows[0].transportadora || '';
    var rastreio    = '';
    var previsao    = '';
    var dataEntrega = '';
    var primeiraOc  = rows[0].DATA_FMT  || rows[0].data_fmt  || '';
    var ultimaOc    = rows[rows.length-1].DATA_FMT || rows[rows.length-1].data_fmt || '';
    var ultimoCod   = '';

    rows.forEach(function(r) {
        var cod = r.CODIGOOCORRENCIATRANSPORTADORA || r.codigoocorrenciatransportadora || '';
        if (cod) ultimoCod = cod;
        var prev = r.PREVISAO_FMT || r.previsao_fmt || '';
        if (prev) previsao = prev;
        var ent = r.ENTREGA_FMT || r.entrega_fmt || '';
        if (ent) dataEntrega = ent;
        var rast = r.CODIGORASTREIO || r.codigorastreio || '';
        if (rast) rastreio = rast;
        if (!transp) transp = r.TRANSPORTADORA || r.transportadora || '';
    });

    var st = getStatus(ultimoCod);

    // --- Header da nota ---
    document.getElementById('notaTitulo').textContent = '📄 NF ' + numeronota;
    var metaHtml = '';
    if (serienota) metaHtml += '<span>📋 Série: ' + esc(serienota) + '</span>';
    if (cnpj)      metaHtml += '<span>🏢 ' + esc(cnpj) + '</span>';
    metaHtml += '<span>🔢 ' + rows.length + ' ocorrência(s)</span>';
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
            (previsao   ? '<span class="hl">📅 '  + esc(previsao)   + '</span>' : '<span class="empty">—</span>') +
        '</div>' +
        '<div class="detail-item"><label>Data de Entrega</label>' +
            (dataEntrega ? '<span class="hl-green">✅ ' + esc(dataEntrega) + '</span>' : '<span class="empty">—</span>') +
        '</div>' +
        '<div class="detail-item"><label>Transportadora</label>' +
            (transp  ? '<span>🚚 ' + esc(transp)  + '</span>' : '<span class="empty">—</span>') +
        '</div>' +
        (rastreio ? '<div class="detail-item"><label>Cód. Rastreio</label><span>🔖 ' + esc(rastreio) + '</span></div>' : '');

    // --- Progress bar ---
    renderProgress(st.step);

    // --- Timeline ---
    var tlHtml = '';
    rows.forEach(function(r) {
        var cod      = (r.CODIGOOCORRENCIATRANSPORTADORA || r.codigoocorrenciatransportadora || '').toString().trim();
        var nome     = r.NOMEOCORRENCIA  || r.nomeocorrencia  || 'Ocorrência';
        var dataFmt  = r.DATA_FMT        || r.data_fmt        || '';
        var prevFmt  = r.PREVISAO_FMT    || r.previsao_fmt    || '';
        var entFmt   = r.ENTREGA_FMT     || r.entrega_fmt     || '';
        var obs      = r.OBSERVACAO_TXT  || r.observacao_txt  || '';
        var tCnpj    = r.CNPJEMISSORCTE  || r.cnpjemissorcte  || '';
        var tTransp  = r.TRANSPORTADORA  || r.transportadora  || '';
        var tUnid    = r.UNIDADE         || r.unidade         || '';
        var tCte     = r.NUMEROCTE       || r.numerocte       || '';
        var tRast    = r.CODIGORASTREIO  || r.codigorastreio  || '';
        var tAgend   = r.AGENDAMENTOENTREGA || r.agendamentoentrega || '';
        var tPrenota = r.NUMEROPRENOTA   || r.numeroprenota   || '';

        var dc = getDotClass(cod);

        tlHtml += '<div class="tl-item">';
        tlHtml +=   '<div class="tl-dot ' + dc.dot + '">' + dc.txt + '</div>';
        tlHtml +=   '<div class="tl-card ' + dc.card + '">';
        tlHtml +=     '<div class="tl-top">';
        tlHtml +=       '<div><span class="tl-event">' + esc(nome) + '</span>';
        if (cod) tlHtml += '<span class="cod-badge">Cód. ' + esc(cod) + '</span>';
        tlHtml +=       '</div>';
        tlHtml +=       '<span class="tl-datetime">📅 ' + esc(dataFmt) + '</span>';
        tlHtml +=     '</div>';

        // Meta
        var metaItems = [];
        if (tCnpj)   metaItems.push('🏢 <strong>' + esc(tCnpj)   + '</strong>');
        if (tTransp) metaItems.push('🚚 <strong>' + esc(tTransp) + '</strong>');
        if (tUnid)   metaItems.push('📦 ' + esc(tUnid));
        if (tCte)    metaItems.push('📑 CT-e: <strong>' + esc(tCte) + '</strong>');
        if (tRast)   metaItems.push('🔖 ' + esc(tRast));
        if (tAgend)  metaItems.push('📆 Agend.: ' + esc(tAgend));
        if (tPrenota)metaItems.push('📝 Pré-nota: <strong>' + esc(tPrenota) + '</strong>');

        if (metaItems.length) {
            tlHtml += '<div class="tl-meta">';
            metaItems.forEach(function(m) { tlHtml += '<span class="tl-meta-item">' + m + '</span>'; });
            tlHtml += '</div>';
        }

        if (prevFmt)   tlHtml += '<div class="tl-pill pill-yellow">⏱️ Previsão de entrega: <strong>' + esc(prevFmt) + '</strong></div>';
        if (entFmt)    tlHtml += '<div class="tl-pill pill-green">✅ Entregue em: <strong>' + esc(entFmt) + '</strong></div>';

        if (obs && obs.trim()) {
            tlHtml += '<div class="tl-obs"><div class="tl-obs-label">💬 Observação</div>' + esc(obs.trim()) + '</div>';
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

function limpar() {
    document.getElementById('inputNota').value = '';
    document.getElementById('btnLimpar').style.display = 'none';
    hideAll();
    showWelcome(true);
    document.getElementById('inputNota').focus();
}

async function rastrear() {
    var nota = document.getElementById('inputNota').value.trim();
    var input = document.getElementById('inputNota');

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
    inp && inp.addEventListener('keydown', function(e){ if(e.key === 'Enter') rastrear(); });
});
</script>

</body>
</html>
