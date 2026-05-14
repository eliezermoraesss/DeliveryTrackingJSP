<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rastreamento v2 | Sankhya Tracking</title>
    
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --primary: #3483FA;
            --success: #00A650;
            --warning: #FFAD1F;
            --bg-light: #F5F5F5;
            --surface: #FFFFFF;
            --text-main: #333333;
            --text-muted: #666666;
            --ml-yellow: #FFF159;
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            --radius: 12px;
            --shadow: 0 4px 12px rgba(0,0,0,0.05);
        }

        [data-theme="dark"] {
            --bg-light: #121212;
            --surface: #1E1E1E;
            --text-main: #E1E1E1;
            --text-muted: #A0A0A0;
            --ml-yellow: #d4c84a;
            --shadow: 0 4px 12px rgba(0,0,0,0.3);
        }

        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: var(--bg-light);
            color: var(--text-main);
            margin: 0;
            transition: var(--transition);
            overflow-x: hidden;
        }

        /* Navbar & Filters */
        .navbar-v2 {
            background-color: var(--ml-yellow);
            padding: 25px 0;
            box-shadow: var(--shadow);
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        .filter-panel {
            background: var(--surface);
            padding: 20px 30px;
            border-radius: var(--radius);
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            margin-top: -15px;
            border: 1px solid rgba(0,0,0,0.05);
        }

        .input-ml-v2 {
            background: var(--bg-light);
            border: 2px solid transparent;
            border-radius: 8px;
            padding: 12px 16px;
            font-size: 14px;
            font-weight: 500;
            width: 100%;
            color: var(--text-main);
            transition: var(--transition);
        }

        .input-ml-v2:focus {
            border-color: var(--primary);
            outline: none;
            background: var(--surface);
        }

        .label-v2 {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 6px;
            color: var(--text-muted);
            display: block;
        }

        .btn-track-v2 {
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 8px;
            padding: 0 30px;
            height: 48px;
            font-weight: 600;
            transition: var(--transition);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .btn-track-v2:hover {
            background: #216be5;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(52, 131, 250, 0.3);
        }

        /* Summary Dashboard */
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .summary-card {
            background: var(--surface);
            padding: 20px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            border-bottom: 4px solid transparent;
            transition: var(--transition);
        }

        .summary-card:hover {
            transform: translateY(-5px);
        }

        .summary-card.active { border-color: var(--primary); }
        .summary-card.success { border-color: var(--success); }

        .summary-label { font-size: 12px; color: var(--text-muted); margin-bottom: 5px; }
        .summary-value { font-size: 18px; font-weight: 700; }

        /* Timeline v2 */
        .tracking-container {
            max-width: 1100px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .main-card-v2 {
            background: var(--surface);
            border-radius: 20px;
            box-shadow: var(--shadow);
            overflow: hidden;
            border: 1px solid rgba(0,0,0,0.05);
        }

        .timeline-v2 {
            padding: 60px 40px;
            background: radial-gradient(circle at top right, rgba(52, 131, 250, 0.05), transparent);
        }

        .progress-track-v2 {
            height: 8px;
            background: var(--bg-light);
            border-radius: 10px;
            position: relative;
            margin: 40px 0;
        }

        .progress-fill-v2 {
            height: 100%;
            background: linear-gradient(90deg, var(--primary), var(--success));
            border-radius: 10px;
            width: 0%;
            transition: width 1.5s cubic-bezier(0.65, 0, 0.35, 1);
            position: relative;
        }

        .progress-fill-v2::after {
            content: '';
            position: absolute;
            right: -5px;
            top: -4px;
            width: 16px;
            height: 16px;
            background: white;
            border: 4px solid var(--success);
            border-radius: 50%;
            box-shadow: 0 0 10px rgba(0, 166, 80, 0.5);
        }

        .steps-container-v2 {
            display: flex;
            justify-content: space-between;
            margin-top: -62px;
        }

        .step-v2 {
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 140px;
            z-index: 2;
        }

        .circle-v2 {
            width: 44px;
            height: 44px;
            background: var(--surface);
            border: 3px solid var(--bg-light);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            color: var(--text-muted);
            margin-bottom: 12px;
            transition: var(--transition);
        }

        .step-v2.completed .circle-v2 {
            border-color: var(--success);
            color: var(--success);
            background: var(--surface);
        }

        .step-v2.current .circle-v2 {
            border-color: var(--primary);
            color: var(--primary);
            background: var(--surface);
            transform: scale(1.15);
            box-shadow: 0 0 20px rgba(52, 131, 250, 0.2);
        }

        .step-info-v2 {
            text-align: center;
        }

        .step-name-v2 {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-muted);
            margin-bottom: 4px;
        }

        .step-v2.current .step-name-v2, 
        .step-v2.completed .step-name-v2 { color: var(--text-main); }

        .step-date-v2 { font-size: 11px; color: var(--text-muted); }

        /* Occurrences v2 */
        .occ-section-v2 {
            padding: 40px;
            background: var(--bg-light);
            border-top: 1px solid rgba(0,0,0,0.05);
        }

        .occ-item-v2 {
            display: flex;
            gap: 20px;
            margin-bottom: 25px;
            position: relative;
        }

        .occ-item-v2:not(:last-child)::after {
            content: '';
            position: absolute;
            left: 17px;
            top: 40px;
            bottom: -15px;
            width: 2px;
            background: rgba(0,0,0,0.05);
        }

        .occ-icon-v2 {
            width: 36px;
            height: 36px;
            background: var(--surface);
            border: 2px solid var(--primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary);
            flex-shrink: 0;
            z-index: 1;
        }

        .occ-card-v2 {
            background: var(--surface);
            padding: 16px 20px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.02);
            flex-grow: 1;
            transition: var(--transition);
        }

        .occ-card-v2:hover {
            transform: translateX(5px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }

        /* Dark Mode Toggle */
        .theme-toggle {
            position: fixed;
            bottom: 30px;
            right: 30px;
            width: 50px;
            height: 50px;
            background: var(--primary);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            box-shadow: 0 4px 15px rgba(52, 131, 250, 0.4);
            z-index: 2000;
            transition: var(--transition);
        }

        .theme-toggle:hover { transform: scale(1.1) rotate(15deg); }

        /* Animation */
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .animate-up { animation: slideUp 0.6s forwards; }

        .badge-status {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }
    </style>
    <snk:load />
</head>
<body data-theme="light">

    <div class="theme-toggle" onclick="toggleTheme()">
        <i class="fas fa-moon"></i>
    </div>

    <nav class="navbar-v2">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <div class="filter-panel">
                        <form action="" method="GET">
                            <div class="row g-3 align-items-end">
                                <div class="col-md-5">
                                    <label class="label-v2">Localizar Nota Fiscal</label>
                                    <div class="position-relative">
                                        <i class="fas fa-barcode position-absolute" style="left: 15px; top: 15px; color: var(--text-muted)"></i>
                                        <input type="text" name="NUMERONOTA" class="input-ml-v2" style="padding-left: 45px" placeholder="Digite o número da nota..." value="${param.NUMERONOTA}">
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <label class="label-v2">De</label>
                                    <input type="date" name="DT_INICIO" class="input-ml-v2" value="${param.DT_INICIO}">
                                </div>
                                <div class="col-md-3">
                                    <label class="label-v2">Até</label>
                                    <input type="date" name="DT_FIM" class="input-ml-v2" value="${param.DT_FIM}">
                                </div>
                                <div class="col-md-1">
                                    <button type="submit" class="btn-track-v2 w-100">
                                        <i class="fas fa-location-arrow"></i>
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </nav>

    <div class="tracking-container">
        
        <c:set var="hasSearch" value="${not empty param.NUMERONOTA}" />

        <c:if test="${hasSearch}">
            <snk:query var="ocorrencias">
                SELECT
                    OC.ID,
                    OC.NUMERONOTA,
                    OC.NUMEROCTE,
                    OC.UNIDADE,
                    OC.TRANSPORTADORA,
                    OC.CODIGORASTREIO,
                    OC.CODIGOOCORRENCIA,
                    OC.CODIGOOCORRENCIATRANSPORTADORA,
                    NVL(OC.NOMEOCORRENCIA, 'Ocorrencia sem descricao') AS NOMEOCORRENCIA,
                    OC.DATA,
                    OC.PRAZO,
                    OC.DATAPREVISAOENTREGA,
                    OC.DATAENTREGA,
                    CAST(NULL AS VARCHAR2(1000)) AS OBSERVACAO,
                    CASE
                        WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) IN ('01', '001', '1')
                             OR TRIM(OC.CODIGOOCORRENCIA) IN ('01', '001', '1')
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%ENTREG%' THEN 4
                        WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) = '98'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%DESTINO%'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%FILIAL%' THEN 3
                        WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) = '52'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%REDESPACH%'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%TRANSITO%' THEN 2
                        WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) = '00'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%COLETA%'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%INICIADO%' THEN 1
                        ELSE 0
                    END AS ETAPA_ORDEM
                FROM AD_OCORRENCIAS OC
                WHERE TRIM(OC.NUMERONOTA) = '${param.NUMERONOTA}'
                <c:if test="${not empty param.DT_INICIO}">
                    AND OC.DATA >= TO_DATE('${param.DT_INICIO}', 'YYYY-MM-DD')
                </c:if>
                <c:if test="${not empty param.DT_FIM}">
                    AND OC.DATA < TO_DATE('${param.DT_FIM}', 'YYYY-MM-DD') + 1
                </c:if>
                ORDER BY OC.DATA ASC, OC.ID ASC
            </snk:query>

            <c:choose>
                <c:when test="${ocorrencias.rowCount > 0}">
                    <c:set var="res" value="${ocorrencias.rows[0]}" />
                    
                    <%-- Logic for v2 Status --%>
                    <c:set var="step" value="0" />
                    <c:set var="dtColeta" value="${null}" />
                    <c:set var="dtTrans" value="${null}" />
                    <c:set var="dtRota" value="${null}" />
                    <c:set var="dtEnt" value="${null}" />
                    
                    <c:forEach items="${ocorrencias.rows}" var="row">
                        <c:if test="${row.ETAPA_ORDEM gt step}">
                            <c:set var="step" value="${row.ETAPA_ORDEM}" />
                        </c:if>
                        <c:if test="${row.ETAPA_ORDEM eq 1 and empty dtColeta}"><c:set var="dtColeta" value="${row.DATA}" /></c:if>
                        <c:if test="${row.ETAPA_ORDEM eq 2 and empty dtTrans}"><c:set var="dtTrans" value="${row.DATA}" /></c:if>
                        <c:if test="${row.ETAPA_ORDEM eq 3 and empty dtRota}"><c:set var="dtRota" value="${row.DATA}" /></c:if>
                        <c:if test="${row.ETAPA_ORDEM eq 4 and empty dtEnt}"><c:set var="dtEnt" value="${row.DATA}" /></c:if>
                    </c:forEach>

                    <c:set var="progressWidth" value="5" />
                    <c:set var="step1Class" value="" />
                    <c:set var="step2Class" value="" />
                    <c:set var="step3Class" value="" />
                    <c:set var="step4Class" value="" />
                    <c:if test="${step eq 1}"><c:set var="progressWidth" value="25" /><c:set var="step1Class" value="completed current" /></c:if>
                    <c:if test="${step eq 2}"><c:set var="progressWidth" value="50" /><c:set var="step1Class" value="completed" /><c:set var="step2Class" value="completed current" /></c:if>
                    <c:if test="${step eq 3}"><c:set var="progressWidth" value="75" /><c:set var="step1Class" value="completed" /><c:set var="step2Class" value="completed" /><c:set var="step3Class" value="completed current" /></c:if>
                    <c:if test="${step eq 4}"><c:set var="progressWidth" value="100" /><c:set var="step1Class" value="completed" /><c:set var="step2Class" value="completed" /><c:set var="step3Class" value="completed" /><c:set var="step4Class" value="completed current" /></c:if>

                    <div class="summary-grid animate-up">
                        <div class="summary-card success">
                            <div class="summary-label">Status Atual</div>
                            <div class="summary-value" style="color: var(--success)">
                                <c:choose>
                                    <c:when test="${step eq 4}">Entregue</c:when>
                                    <c:when test="${step eq 3}">Em Rota</c:when>
                                    <c:when test="${step eq 2}">Em Trânsito</c:when>
                                    <c:otherwise>Processando</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="summary-card active">
                            <div class="summary-label">Nota Fiscal</div>
                            <div class="summary-value">${res.NUMERONOTA}</div>
                        </div>
                        <div class="summary-card">
                            <div class="summary-label">Previsão</div>
                            <div class="summary-value">
                                <c:choose>
                                    <c:when test="${not empty res.DATAPREVISAOENTREGA}">
                                        <snk:formatDate value="${res.DATAPREVISAOENTREGA}" pattern="dd/MM/yyyy"/>
                                    </c:when>
                                    <c:otherwise>---</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="summary-card">
                            <div class="summary-label">Transportadora</div>
                            <div class="summary-value">
                                <c:choose>
                                    <c:when test="${not empty res.TRANSPORTADORA}">${res.TRANSPORTADORA}</c:when>
                                    <c:otherwise>Sankhya Log</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <div class="main-card-v2 animate-up">
                        <div class="timeline-v2">
                            <div class="d-flex justify-content-between align-items-center mb-5">
                                <h4 class="m-0 font-weight-bold">Fluxo de Entrega</h4>
                                <div class="badge-status bg-light text-dark">
                                    ID Rastreio:
                                    <c:choose>
                                        <c:when test="${not empty res.CODIGORASTREIO}">${res.CODIGORASTREIO}</c:when>
                                        <c:otherwise>---</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="progress-track-v2">
                                <div class="progress-fill-v2" id="progressFill" style="width: ${progressWidth}%"></div>
                            </div>

                            <div class="steps-container-v2">
                                <div class="step-v2 ${step1Class}">
                                    <div class="circle-v2"><i class="fas fa-warehouse"></i></div>
                                    <div class="step-info-v2">
                                        <div class="step-name-v2">Coletado</div>
                                        <div class="step-date-v2">
                                            <c:if test="${not empty dtColeta}">
                                                <snk:formatDate value="${dtColeta}" pattern="dd/MM"/>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                                <div class="step-v2 ${step2Class}">
                                    <div class="circle-v2"><i class="fas fa-truck-loading"></i></div>
                                    <div class="step-info-v2">
                                        <div class="step-name-v2">Em Trânsito</div>
                                        <div class="step-date-v2">
                                            <c:if test="${not empty dtTrans}">
                                                <snk:formatDate value="${dtTrans}" pattern="dd/MM"/>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                                <div class="step-v2 ${step3Class}">
                                    <div class="circle-v2"><i class="fas fa-shipping-fast"></i></div>
                                    <div class="step-info-v2">
                                        <div class="step-name-v2">Em Rota</div>
                                        <div class="step-date-v2">
                                            <c:if test="${not empty dtRota}">
                                                <snk:formatDate value="${dtRota}" pattern="dd/MM"/>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                                <div class="step-v2 ${step4Class}">
                                    <div class="circle-v2"><i class="fas fa-check-circle"></i></div>
                                    <div class="step-info-v2">
                                        <div class="step-name-v2">Entregue</div>
                                        <div class="step-date-v2">
                                            <c:if test="${not empty dtEnt}">
                                                <snk:formatDate value="${dtEnt}" pattern="dd/MM"/>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="occ-section-v2">
                            <h5 class="mb-4 d-flex align-items-center">
                                <i class="fas fa-history me-3 text-primary"></i> 
                                Linha do Tempo Detalhada
                            </h5>
                            
                            <div class="occ-list-v2">
                                <c:forEach items="${ocorrencias.rows}" var="oc" varStatus="loop">
                                    <div class="occ-item-v2">
                                        <div class="occ-icon-v2">
                                            <i class="fas fa-dot-circle"></i>
                                        </div>
                                        <div class="occ-card-v2">
                                            <div class="d-flex justify-content-between align-items-start mb-2">
                                                <span class="font-weight-bold" style="font-size: 15px;">${oc.NOMEOCORRENCIA}</span>
                                                <small class="text-muted">
                                                    <snk:formatDate value="${oc.DATA}" pattern="dd MMM, HH:mm"/>
                                                </small>
                                            </div>
                                            <div class="text-muted" style="font-size: 13px;">
                                                <c:if test="${not empty oc.UNIDADE}">
                                                    <i class="fas fa-map-marker-alt me-2"></i> ${oc.UNIDADE}
                                                </c:if>
                                            </div>
                                            <c:if test="${not empty oc.OBSERVACAO}">
                                                <div class="mt-3 p-2 rounded bg-light border-left" style="font-size: 12px; font-style: italic; border-left: 3px solid var(--primary)">
                                                    "${oc.OBSERVACAO}"
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="main-card-v2 p-5 text-center">
                        <img src="https://cdn-icons-png.flaticon.com/512/2748/2748558.png" width="120" class="mb-4 opacity-50" style="filter: grayscale(1)">
                        <h4>Ops! Nenhum registro encontrado</h4>
                        <p class="text-muted">Verifique o número da nota ou o período selecionado.</p>
                        <button class="btn btn-outline-primary mt-3" onclick="window.location.href='?'">Limpar Filtros</button>
                    </div>
                </c:otherwise>
            </c:choose>
        </c:if>

        <c:if test="${not hasSearch}">
            <div class="main-card-v2 p-5 text-center">
                <div class="row align-items-center">
                    <div class="col-md-6 text-start">
                        <h2 class="font-weight-bold mb-3">Rastreie sua encomenda em tempo real.</h2>
                        <p class="text-muted mb-4">Utilize o número da nota fiscal emitido pela Multfer para acompanhar cada passo da sua entrega.</p>
                        <div class="d-flex gap-3">
                            <div class="p-3 bg-light rounded text-center" style="width: 100px;">
                                <i class="fas fa-shield-alt text-success mb-2"></i>
                                <div style="font-size: 10px; font-weight: 700">Seguro</div>
                            </div>
                            <div class="p-3 bg-light rounded text-center" style="width: 100px;">
                                <i class="fas fa-bolt text-warning mb-2"></i>
                                <div style="font-size: 10px; font-weight: 700">Rápido</div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <img src="https://img.freepik.com/free-vector/delivery-service-with-mask-concept_23-2148505116.jpg" class="img-fluid rounded-circle" style="max-width: 300px; mix-blend-mode: multiply">
                    </div>
                </div>
            </div>
        </c:if>

    </div>

    <script>
        function toggleTheme() {
            const body = document.body;
            const current = body.getAttribute('data-theme');
            const next = current === 'light' ? 'dark' : 'light';
            body.setAttribute('data-theme', next);
            
            const icon = document.querySelector('.theme-toggle i');
            icon.className = next === 'light' ? 'fas fa-moon' : 'fas fa-sun';
        }

        // Auto-scroll logic for v2
        document.addEventListener('DOMContentLoaded', () => {
            const fill = document.getElementById('progressFill');
            if(fill) {
                const targetWidth = fill.style.width;
                fill.style.width = '0%';
                setTimeout(() => {
                    fill.style.width = targetWidth;
                }, 100);
            }
        });
    </script>
</body>
</html>

</html>
