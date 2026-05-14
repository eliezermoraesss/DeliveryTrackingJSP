<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>

<%
    String pNumeroNota = request.getParameter("NUMERONOTA");
    if (pNumeroNota == null) {
        pNumeroNota = "";
    }
    pNumeroNota = pNumeroNota.trim().replaceAll("[^0-9A-Za-z._/-]", "");
    pageContext.setAttribute("p_numeronota", pNumeroNota);
%>

<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Rastreamento &middot; NF <c:out value="${p_numeronota}"/></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <snk:load/>

    <%-- ============================================================
         QUERIES — executadas server-side com param.NUMERONOTA já
         resolvido pela requisição GET vinda do arquivo de busca.
    ============================================================ --%>

    <c:if test="${not empty p_numeronota}">

    <%-- Resumo da nota: status geral, datas, transportadora --%>
    <snk:query var="resumo_nota">
        SELECT
            MAX(NUMERONOTA)                                 AS NUMERONOTA,
            MAX(SERIENOTA)                                  AS SERIENOTA,
            MAX(CNPJEMISSORCTE)                             AS CNPJEMISSORCTE,
            MAX(EMITENTENOTA)                               AS EMITENTENOTA,
            MAX(TRANSPORTADORA)                             AS TRANSPORTADORA,
            COUNT(1)                                        AS TOTAL_OCORRENCIAS,
            TO_CHAR(MIN(DATA), 'DD/MM/YYYY HH24:MI')        AS PRIMEIRA_OC,
            TO_CHAR(MAX(DATA), 'DD/MM/YYYY HH24:MI')        AS ULTIMA_OC,
            TO_CHAR(MAX(DATAPREVISAOENTREGA), 'DD/MM/YYYY') AS PREVISAO,
            TO_CHAR(MAX(DATAENTREGA), 'DD/MM/YYYY')         AS DATA_ENTREGA,
            MAX(CODIGORASTREIO)                             AS RASTREIO,
            MAX(CODIGOOCORRENCIATRANSPORTADORA)             AS ULTIMO_COD_OC,
            MAX(NOMEOCORRENCIA)                             AS ULTIMA_OCORRENCIA
        FROM AD_OCORRENCIAS
        WHERE TRIM(NUMERONOTA) = '${p_numeronota}'
    </snk:query>

    <%-- Todas as ocorrências em ordem cronológica --%>
    <snk:query var="ocorrencias">
        SELECT
            ID,
            NUMERONOTA,
            SERIENOTA,
            CNPJEMISSORCTE,
            EMITENTENOTA,
            CHAVECTE,
            CHAVENOTA,
            CODIGOOCORRENCIATRANSPORTADORA,
            NOMEOCORRENCIA,
            CODIGOOCORRENCIA,
            CODIGORASTREIO,
            TRANSPORTADORA,
            UNIDADE,
            EMITENTEPRENOTA,
            SERIEPRENOTA,
            NUMEROPRENOTA,
            NUMEROCTE,
            AGENDAMENTOENTREGA,
            TO_CHAR(DATA,               'DD/MM/YYYY HH24:MI') AS DATA_FMT,
            TO_CHAR(PRAZO,              'DD/MM/YYYY')          AS PRAZO_FMT,
            TO_CHAR(DATAPREVISAOENTREGA,'DD/MM/YYYY')          AS PREVISAO_FMT,
            TO_CHAR(DATAENTREGA,        'DD/MM/YYYY')          AS ENTREGA_FMT,
            CAST(NULL AS VARCHAR2(1000))                    AS OBSERVACAO_TXT
        FROM AD_OCORRENCIAS
        WHERE TRIM(NUMERONOTA) = '${p_numeronota}'
        ORDER BY DATA ASC, ID ASC
    </snk:query>

    </c:if>

    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --blue-primary: #1a73e8;
            --blue-dark:    #0d47a1;
            --blue-light:   #e8f0fe;
            --green-ok:     #1e8e3e;
            --green-light:  #e6f4ea;
            --yellow:       #f9ab00;
            --yellow-light: #fef9e7;
            --gray-100:     #f8f9fa;
            --gray-200:     #e9ecef;
            --gray-400:     #ced4da;
            --gray-600:     #6c757d;
            --gray-800:     #343a40;
            --white:        #ffffff;
            --radius-md:    12px;
            --radius-lg:    20px;
            --shadow-md:    0 4px 16px rgba(0,0,0,.10);
            --shadow-lg:    0 8px 32px rgba(0,0,0,.16);
            --transition:   all .25s ease;
        }

        body {
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            background: linear-gradient(135deg, #0d47a1 0%, #1565c0 40%, #1976d2 100%);
            min-height: 100vh;
            padding: 24px 16px 48px;
            color: var(--gray-800);
        }

        .tracking-wrapper { max-width: 900px; margin: 0 auto; }

        /* ===== TOPBAR ===== */
        .topbar {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }
        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(255,255,255,.15);
            color: #fff;
            border: 1px solid rgba(255,255,255,.3);
            border-radius: 999px;
            padding: 7px 18px;
            font-size: .85rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            transition: var(--transition);
        }
        .btn-back:hover { background: rgba(255,255,255,.25); color: #fff; }

        .topbar-title { color: #fff; font-size: 1.1rem; font-weight: 700; }
        .topbar-sub   { color: rgba(255,255,255,.7); font-size: .85rem; }

        /* ===== RESULT COUNT ===== */
        .result-count {
            font-size: .88rem;
            color: rgba(255,255,255,.85);
            margin-bottom: 14px;
            padding: 0 4px;
        }
        .result-count strong { color: #fff; }

        /* ===== NOTA CARD ===== */
        .nota-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
            overflow: hidden;
            margin-bottom: 24px;
        }

        /* --- Header do card --- */
        .nota-header {
            background: linear-gradient(135deg, #0d47a1, #1976d2);
            padding: 22px 28px;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 14px;
        }
        .nota-header h3   { color: #fff; font-size: 1.35rem; font-weight: 700; }
        .nota-header-meta {
            color: rgba(255,255,255,.75);
            font-size: .83rem;
            margin-top: 5px;
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
        }

        /* Badge status */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 18px;
            border-radius: 999px;
            font-size: .78rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .5px;
            border: 2px solid rgba(255,255,255,.35);
            white-space: nowrap;
        }
        .st-entregue { background: rgba(30,142,62,.9);  color: #fff; }
        .st-transito  { background: rgba(249,171,0,.9); color: #222; }
        .st-cidade    { background: rgba(26,115,232,.9);color: #fff; }
        .st-coleta    { background: rgba(80,90,100,.8); color: #fff; }

        /* --- Detalhes resumo --- */
        .nota-details {
            padding: 20px 28px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(155px, 1fr));
            gap: 18px;
            border-bottom: 1px solid var(--gray-200);
            background: var(--gray-100);
        }
        .detail-item label {
            display: block;
            font-size: .7rem;
            font-weight: 700;
            color: var(--gray-600);
            text-transform: uppercase;
            letter-spacing: .5px;
            margin-bottom: 5px;
        }
        .detail-item span         { font-size: .9rem; font-weight: 600; color: var(--gray-800); }
        .detail-item span.hl      { color: var(--blue-primary); }
        .detail-item span.hl-green{ color: var(--green-ok); }
        .detail-item span.empty   { color: var(--gray-400); font-style: italic; font-weight: 400; }

        /* --- Progress bar --- */
        .progress-section {
            padding: 24px 28px;
            border-bottom: 1px solid var(--gray-200);
        }
        .progress-steps { display: flex; align-items: center; }

        .step-item {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            position: relative;
            z-index: 1;
        }
        .step-icon {
            width: 46px; height: 46px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.25rem;
            border: 3px solid var(--gray-200);
            background: var(--white);
            transition: var(--transition);
        }
        .step-icon.done    { background: var(--green-ok);    border-color: var(--green-ok);    color: #fff; }
        .step-icon.active  { background: var(--blue-primary);border-color: var(--blue-primary);color: #fff; box-shadow: 0 0 0 6px rgba(26,115,232,.18); }
        .step-icon.pending { background: var(--white);        border-color: var(--gray-300);    color: var(--gray-400); }

        .step-label {
            margin-top: 8px;
            font-size: .7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .4px;
            text-align: center;
            color: var(--gray-400);
            line-height: 1.3;
        }
        .step-label.done   { color: var(--green-ok); }
        .step-label.active { color: var(--blue-primary); }

        .step-line {
            flex: 1;
            height: 3px;
            background: var(--gray-200);
            position: relative;
            top: -22px;
            z-index: 0;
        }
        .step-line.done   { background: var(--green-ok); }
        .step-line.half   { background: linear-gradient(90deg, var(--green-ok) 50%, var(--gray-200) 50%); }

        /* --- Timeline --- */
        .timeline-section { padding: 24px 28px 32px; }
        .timeline-section h4 {
            font-size: .78rem;
            font-weight: 700;
            color: var(--gray-600);
            text-transform: uppercase;
            letter-spacing: .5px;
            margin-bottom: 22px;
        }

        .timeline { position: relative; padding-left: 34px; }
        .timeline::before {
            content: '';
            position: absolute;
            left: 11px; top: 10px; bottom: 10px;
            width: 2px;
            background: var(--gray-200);
        }

        .tl-item { position: relative; margin-bottom: 18px; }
        .tl-item:last-child { margin-bottom: 0; }

        .tl-dot {
            position: absolute;
            left: -29px; top: 15px;
            width: 22px; height: 22px;
            border-radius: 50%;
            border: 3px solid var(--white);
            display: flex; align-items: center; justify-content: center;
            font-size: .6rem;
            font-weight: 700;
            color: #fff;
        }
        .dot-entregue { background: var(--green-ok);    box-shadow: 0 0 0 2px var(--green-ok); }
        .dot-cidade   { background: #7c3aed;            box-shadow: 0 0 0 2px #7c3aed; }
        .dot-transito { background: var(--blue-primary);box-shadow: 0 0 0 2px var(--blue-primary); }
        .dot-coleta   { background: var(--gray-600);    box-shadow: 0 0 0 2px var(--gray-600); }
        .dot-alerta   { background: var(--yellow);      box-shadow: 0 0 0 2px var(--yellow); color: #333; }
        .dot-default  { background: var(--gray-400);    box-shadow: 0 0 0 2px var(--gray-400); }

        .tl-card {
            background: var(--gray-100);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-md);
            padding: 14px 18px;
            transition: var(--transition);
        }
        .tl-card:hover { box-shadow: var(--shadow-md); border-color: var(--blue-primary); background: #f0f4ff; }
        .tl-card.card-entregue { background: var(--green-light); border-color: #a8d5b5; }
        .tl-card.card-entregue:hover { background: #d4edda; }

        .tl-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 12px;
            flex-wrap: wrap;
        }
        .tl-event    { font-size: .95rem; font-weight: 700; color: var(--gray-800); }
        .tl-datetime { font-size: .8rem; color: var(--gray-600); white-space: nowrap; }

        .cod-badge {
            display: inline-block;
            background: var(--blue-light);
            color: var(--blue-primary);
            font-size: .68rem;
            font-weight: 700;
            padding: 2px 9px;
            border-radius: 999px;
            margin-left: 7px;
            vertical-align: middle;
        }

        .tl-meta {
            margin-top: 9px;
            display: flex;
            gap: 14px;
            flex-wrap: wrap;
        }
        .tl-meta-item {
            font-size: .78rem;
            color: var(--gray-600);
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .tl-meta-item strong { color: var(--gray-800); }

        .tl-previsao {
            margin-top: 9px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: var(--yellow-light);
            color: #7a5c00;
            border: 1px solid #f0d060;
            border-radius: 6px;
            padding: 5px 13px;
            font-size: .78rem;
            font-weight: 600;
        }
        .tl-entrega-ok {
            margin-top: 9px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: var(--green-light);
            color: #155724;
            border: 1px solid #a8d5b5;
            border-radius: 6px;
            padding: 5px 13px;
            font-size: .78rem;
            font-weight: 600;
        }

        .tl-obs {
            margin-top: 12px;
            background: var(--white);
            border-left: 3px solid var(--blue-primary);
            border-radius: 0 6px 6px 0;
            padding: 10px 14px;
            font-size: .82rem;
            color: var(--gray-800);
            line-height: 1.6;
            white-space: pre-wrap;
            word-break: break-word;
        }
        .tl-obs-label {
            font-size: .68rem;
            font-weight: 700;
            color: var(--blue-primary);
            text-transform: uppercase;
            letter-spacing: .4px;
            margin-bottom: 5px;
        }

        /* ===== NOT FOUND ===== */
        .not-found {
            background: var(--white);
            border-radius: var(--radius-lg);
            padding: 60px 32px;
            text-align: center;
            box-shadow: var(--shadow-lg);
        }
        .not-found .icon { font-size: 4rem; margin-bottom: 16px; }
        .not-found h3 { font-size: 1.2rem; font-weight: 700; color: var(--gray-800); margin-bottom: 8px; }
        .not-found p  { color: var(--gray-600); max-width: 320px; margin: 0 auto 24px; font-size: .9rem; line-height: 1.6; }
        .btn-voltar-nf {
            display: inline-block;
            background: var(--blue-primary);
            color: #fff;
            border-radius: 999px;
            padding: 10px 28px;
            font-weight: 700;
            font-size: .9rem;
            text-decoration: none;
            transition: var(--transition);
        }
        .btn-voltar-nf:hover { background: var(--blue-dark); color: #fff; }

        @media (max-width: 600px) {
            .nota-header, .nota-details, .progress-section, .timeline-section { padding-left: 18px; padding-right: 18px; }
            .nota-header { flex-direction: column; }
        }
    </style>
</head>
<body>
<div class="tracking-wrapper">

    <!-- ===== TOPBAR ===== -->
    <div class="topbar">
        <a href="rastreamento-entregas.jsp" class="btn-back">← Nova Busca</a>
        <div>
            <div class="topbar-title">🚚 Rastreamento de Entregas</div>
            <div class="topbar-sub">AD_OCORRENCIAS &middot; NF <c:out value="${p_numeronota}"/></div>
        </div>
    </div>

    <%-- ===== SEM RESULTADO ===== --%>
    <c:choose>
        <c:when test="${empty ocorrencias.rows}">
            <div class="not-found">
                <div class="icon">🔍</div>
                <h3>Nenhuma ocorrência encontrada</h3>
                <p>N&atilde;o foram localizadas ocorr&ecirc;ncias para a nota <strong><c:out value="${p_numeronota}"/></strong>. Verifique o n&uacute;mero e tente novamente.</p>
                <a href="rastreamento-entregas.jsp" class="btn-voltar-nf">← Voltar e pesquisar</a>
            </div>
        </c:when>

        <%-- ===== COM RESULTADO ===== --%>
        <c:otherwise>
            <c:forEach items="${resumo_nota.rows}" var="res">

                <p class="result-count">
                    <strong><c:out value="${res.TOTAL_OCORRENCIAS}"/></strong> ocorrência(s) encontrada(s) para
                    <strong>NF <c:out value="${res.NUMERONOTA}"/></strong>
                </p>

                <%-- Determinar status / progress --%>
                <c:set var="uc" value="${res.ULTIMO_COD_OC}"/>

                <c:set var="isEntregue" value="${uc eq '01' or uc eq '1'}"/>
                <c:set var="isCidade"   value="${uc eq '98' or isEntregue}"/>
                <c:set var="isTransito" value="${not (uc eq '00' or uc eq '0')}"/>

                <c:choose>
                    <c:when test="${isEntregue}">
                        <c:set var="stClass" value="st-entregue"/>
                        <c:set var="stLabel" value="ENTREGUE"/>
                        <c:set var="stIcon"  value="✅"/>
                    </c:when>
                    <c:when test="${uc eq '98'}">
                        <c:set var="stClass" value="st-cidade"/>
                        <c:set var="stLabel" value="NA CIDADE"/>
                        <c:set var="stIcon"  value="🏙️"/>
                    </c:when>
                    <c:when test="${uc eq '00' or uc eq '0'}">
                        <c:set var="stClass" value="st-coleta"/>
                        <c:set var="stLabel" value="COLETA INICIADA"/>
                        <c:set var="stIcon"  value="📋"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="stClass" value="st-transito"/>
                        <c:set var="stLabel" value="EM TRÂNSITO"/>
                        <c:set var="stIcon"  value="🚛"/>
                    </c:otherwise>
                </c:choose>

                <div class="nota-card">

                    <!-- Cabeçalho -->
                    <div class="nota-header">
                        <div>
                            <h3>📄 NF <c:out value="${res.NUMERONOTA}"/></h3>
                            <div class="nota-header-meta">
                                <span>📋 Série: <c:out value="${res.SERIENOTA}"/></span>
                                <c:if test="${not empty res.CNPJEMISSORCTE}">
                                    <span>🏢 <c:out value="${res.CNPJEMISSORCTE}"/></span>
                                </c:if>
                                <span>🔢 <c:out value="${res.TOTAL_OCORRENCIAS}"/> ocorrência(s)</span>
                            </div>
                        </div>
                        <span class="status-badge <c:out value='${stClass}'/>">
                            <c:out value="${stIcon}"/> <c:out value="${stLabel}"/>
                        </span>
                    </div>

                    <!-- Detalhes -->
                    <div class="nota-details">
                        <div class="detail-item">
                            <label>Primeira Ocorrência</label>
                            <span><c:out value="${res.PRIMEIRA_OC}"/></span>
                        </div>
                        <div class="detail-item">
                            <label>Última Ocorrência</label>
                            <span><c:out value="${res.ULTIMA_OC}"/></span>
                        </div>
                        <div class="detail-item">
                            <label>Previsão de Entrega</label>
                            <c:choose>
                                <c:when test="${not empty res.PREVISAO}">
                                    <span class="hl">📅 <c:out value="${res.PREVISAO}"/></span>
                                </c:when>
                                <c:otherwise><span class="empty">—</span></c:otherwise>
                            </c:choose>
                        </div>
                        <div class="detail-item">
                            <label>Data de Entrega</label>
                            <c:choose>
                                <c:when test="${not empty res.DATA_ENTREGA}">
                                    <span class="hl-green">✅ <c:out value="${res.DATA_ENTREGA}"/></span>
                                </c:when>
                                <c:otherwise><span class="empty">—</span></c:otherwise>
                            </c:choose>
                        </div>
                        <div class="detail-item">
                            <label>Transportadora</label>
                            <c:choose>
                                <c:when test="${not empty res.TRANSPORTADORA}">
                                    <span>🚚 <c:out value="${res.TRANSPORTADORA}"/></span>
                                </c:when>
                                <c:otherwise><span class="empty">—</span></c:otherwise>
                            </c:choose>
                        </div>
                        <c:if test="${not empty res.RASTREIO}">
                            <div class="detail-item">
                                <label>Código de Rastreio</label>
                                <span>🔖 <c:out value="${res.RASTREIO}"/></span>
                            </div>
                        </c:if>
                    </div>

                    <!-- ===== PROGRESS BAR ===== -->
                    <div class="progress-section">
                        <div class="progress-steps">

                            <%-- COLETA --%>
                            <div class="step-item">
                                <div class="step-icon done">📋</div>
                                <div class="step-label done">Coleta<br/>Iniciada</div>
                            </div>

                            <c:choose>
                                <c:when test="${isEntregue or isCidade}">
                                    <div class="step-line done"></div>
                                </c:when>
                                <c:when test="${isTransito}">
                                    <div class="step-line half"></div>
                                </c:when>
                                <c:otherwise>
                                    <div class="step-line"></div>
                                </c:otherwise>
                            </c:choose>

                            <%-- EM TRÂNSITO --%>
                            <div class="step-item">
                                <c:choose>
                                    <c:when test="${isEntregue or isCidade}">
                                        <div class="step-icon done">🚛</div>
                                        <div class="step-label done">Em<br/>Trânsito</div>
                                    </c:when>
                                    <c:when test="${isTransito}">
                                        <div class="step-icon active">🚛</div>
                                        <div class="step-label active">Em<br/>Trânsito</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="step-icon pending">🚛</div>
                                        <div class="step-label">Em<br/>Trânsito</div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <c:choose>
                                <c:when test="${isEntregue}"><div class="step-line done"></div></c:when>
                                <c:when test="${isCidade}">  <div class="step-line half"></div></c:when>
                                <c:otherwise>               <div class="step-line"></div></c:otherwise>
                            </c:choose>

                            <%-- NA CIDADE --%>
                            <div class="step-item">
                                <c:choose>
                                    <c:when test="${isEntregue}">
                                        <div class="step-icon done">🏙️</div>
                                        <div class="step-label done">Na<br/>Cidade</div>
                                    </c:when>
                                    <c:when test="${isCidade}">
                                        <div class="step-icon active">🏙️</div>
                                        <div class="step-label active">Na<br/>Cidade</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="step-icon pending">🏙️</div>
                                        <div class="step-label">Na<br/>Cidade</div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <c:choose>
                                <c:when test="${isEntregue}"><div class="step-line done"></div></c:when>
                                <c:otherwise>              <div class="step-line"></div></c:otherwise>
                            </c:choose>

                            <%-- ENTREGUE --%>
                            <div class="step-item">
                                <c:choose>
                                    <c:when test="${isEntregue}">
                                        <div class="step-icon done">✅</div>
                                        <div class="step-label done">Entregue</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="step-icon pending">✅</div>
                                        <div class="step-label">Entregue</div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                        </div>
                    </div>

                    <!-- ===== TIMELINE ===== -->
                    <div class="timeline-section">
                        <h4>📍 Histórico Completo de Ocorrências</h4>
                        <div class="timeline">

                            <c:forEach items="${ocorrencias.rows}" var="oc">

                                <c:set var="cod" value="${oc.CODIGOOCORRENCIATRANSPORTADORA}"/>

                                <c:choose>
                                    <c:when test="${cod eq '01' or cod eq '1'}">
                                        <c:set var="dotCls"  value="dot-entregue"/>
                                        <c:set var="cardCls" value="card-entregue"/>
                                        <c:set var="dotTxt"  value="✓"/>
                                    </c:when>
                                    <c:when test="${cod eq '98'}">
                                        <c:set var="dotCls"  value="dot-cidade"/>
                                        <c:set var="cardCls" value=""/>
                                        <c:set var="dotTxt"  value="📍"/>
                                    </c:when>
                                    <c:when test="${cod eq '52'}">
                                        <c:set var="dotCls"  value="dot-transito"/>
                                        <c:set var="cardCls" value=""/>
                                        <c:set var="dotTxt"  value="🚛"/>
                                    </c:when>
                                    <c:when test="${cod eq '00' or cod eq '0'}">
                                        <c:set var="dotCls"  value="dot-coleta"/>
                                        <c:set var="cardCls" value=""/>
                                        <c:set var="dotTxt"  value="📋"/>
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="dotCls"  value="dot-default"/>
                                        <c:set var="cardCls" value=""/>
                                        <c:set var="dotTxt"  value="●"/>
                                    </c:otherwise>
                                </c:choose>

                                <div class="tl-item">
                                    <div class="tl-dot <c:out value='${dotCls}'/>">
                                        <c:out value="${dotTxt}"/>
                                    </div>

                                    <div class="tl-card <c:out value='${cardCls}'/>">

                                        <!-- Linha principal -->
                                        <div class="tl-top">
                                            <div>
                                                <span class="tl-event">
                                                    <c:choose>
                                                        <c:when test="${not empty oc.NOMEOCORRENCIA}">
                                                            <c:out value="${oc.NOMEOCORRENCIA}"/>
                                                        </c:when>
                                                        <c:otherwise>Ocorrência</c:otherwise>
                                                    </c:choose>
                                                </span>
                                                <c:if test="${not empty oc.CODIGOOCORRENCIATRANSPORTADORA}">
                                                    <span class="cod-badge">Cód. <c:out value="${oc.CODIGOOCORRENCIATRANSPORTADORA}"/></span>
                                                </c:if>
                                            </div>
                                            <span class="tl-datetime">📅 <c:out value="${oc.DATA_FMT}"/></span>
                                        </div>

                                        <!-- Meta -->
                                        <div class="tl-meta">
                                            <c:if test="${not empty oc.CNPJEMISSORCTE}">
                                                <span class="tl-meta-item">🏢 <strong><c:out value="${oc.CNPJEMISSORCTE}"/></strong></span>
                                            </c:if>
                                            <c:if test="${not empty oc.TRANSPORTADORA}">
                                                <span class="tl-meta-item">🚚 <strong><c:out value="${oc.TRANSPORTADORA}"/></strong></span>
                                            </c:if>
                                            <c:if test="${not empty oc.UNIDADE}">
                                                <span class="tl-meta-item">📦 <c:out value="${oc.UNIDADE}"/></span>
                                            </c:if>
                                            <c:if test="${not empty oc.NUMEROCTE}">
                                                <span class="tl-meta-item">📑 CT-e: <strong><c:out value="${oc.NUMEROCTE}"/></strong></span>
                                            </c:if>
                                            <c:if test="${not empty oc.CODIGORASTREIO}">
                                                <span class="tl-meta-item">🔖 <c:out value="${oc.CODIGORASTREIO}"/></span>
                                            </c:if>
                                            <c:if test="${not empty oc.AGENDAMENTOENTREGA}">
                                                <span class="tl-meta-item">📆 Agend.: <c:out value="${oc.AGENDAMENTOENTREGA}"/></span>
                                            </c:if>
                                            <c:if test="${not empty oc.NUMEROPRENOTA}">
                                                <span class="tl-meta-item">📝 Pré-nota: <strong><c:out value="${oc.NUMEROPRENOTA}"/></strong></span>
                                            </c:if>
                                        </div>

                                        <!-- Previsão -->
                                        <c:if test="${not empty oc.PREVISAO_FMT}">
                                            <div class="tl-previsao">
                                                ⏱️ Previsão de entrega: <strong><c:out value="${oc.PREVISAO_FMT}"/></strong>
                                            </div>
                                        </c:if>

                                        <!-- Data entrega confirmada -->
                                        <c:if test="${not empty oc.ENTREGA_FMT}">
                                            <div class="tl-entrega-ok">
                                                ✅ Entregue em: <strong><c:out value="${oc.ENTREGA_FMT}"/></strong>
                                            </div>
                                        </c:if>

                                        <!-- OBSERVACAO (CLOB) -->
                                        <c:if test="${not empty oc.OBSERVACAO_TXT}">
                                            <div class="tl-obs">
                                                <div class="tl-obs-label">💬 Observação</div>
                                                <c:out value="${oc.OBSERVACAO_TXT}"/>
                                            </div>
                                        </c:if>

                                    </div>
                                </div>
                            </c:forEach>

                        </div>
                    </div>

                </div><%-- /nota-card --%>
            </c:forEach>

        </c:otherwise>
    </c:choose>

</div><%-- /tracking-wrapper --%>
</body>
</html>
