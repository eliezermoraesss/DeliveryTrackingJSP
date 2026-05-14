<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         isELIgnored="false" %>

<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>

<html lang="pt-br">

<head>

    <meta charset="UTF-8">

    <title>Rastreamento de Entregas</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <snk:load />

    <style>

        body{
            background:#f5f6fa;
        }

        .header-page{
            background:white;
            border-radius:12px;
            padding:20px;
            margin-bottom:20px;
            box-shadow:0 2px 10px rgba(0,0,0,0.08);
        }

        .timeline{
            position:relative;
            margin:20px 0;
            padding-left:40px;
        }

        .timeline::before{
            content:'';
            position:absolute;
            left:15px;
            top:0;
            width:4px;
            height:100%;
            background:#dcdde1;
        }

        .timeline-item{
            position:relative;
            margin-bottom:30px;
        }

        .timeline-dot{
            position:absolute;
            left:-32px;
            width:20px;
            height:20px;
            border-radius:50%;
            background:#00a8ff;
            border:4px solid white;
            box-shadow:0 0 0 3px #00a8ff;
        }

        .timeline-card{
            background:white;
            padding:20px;
            border-radius:12px;
            box-shadow:0 2px 8px rgba(0,0,0,0.08);
        }

        .timeline-date{
            color:#718093;
            font-size:13px;
        }

        .status-badge{
            font-size:13px;
            padding:6px 12px;
            border-radius:20px;
        }

    </style>

</head>

<body>

<div class="container mt-4">

    <div class="header-page">

        <h2>Rastreamento de Entregas</h2>

        <form method="get">

            <div class="row">

                <div class="col-md-3">
                    <label>Número Nota</label>

                    <input type="text"
                           class="form-control"
                           name="numeronota"
                           value="${param.numeronota}">
                </div>

                <div class="col-md-3">
                    <label>Data Inicial</label>

                    <input type="date"
                           class="form-control"
                           name="dataini"
                           value="${param.dataini}">
                </div>

                <div class="col-md-3">
                    <label>Data Final</label>

                    <input type="date"
                           class="form-control"
                           name="datafim"
                           value="${param.datafim}">
                </div>

                <div class="col-md-3 d-flex align-items-end">

                    <button class="btn btn-primary w-100">
                        Buscar
                    </button>

                </div>

            </div>

        </form>

    </div>

    <c:if test="${not empty param.numeronota}">

    <snk:query var="ocorrencias">

        SELECT
            NUMERONOTA,
            NOMEOCORRENCIA,
            CODIGOOCORRENCIATRANSPORTADORA,
            TRANSPORTADORA,
            TO_CHAR(DATA, 'DD/MM/YYYY HH24:MI') AS DATA,
            TO_CHAR(DATAPREVISAOENTREGA, 'DD/MM/YYYY') AS DATAPREVISAOENTREGA,
            TO_CHAR(DATAENTREGA, 'DD/MM/YYYY') AS DATAENTREGA,
            CAST(NULL AS VARCHAR2(1000)) AS OBSERVACAO
        FROM AD_OCORRENCIAS
        WHERE 1 = 1

        <c:if test="${not empty param.numeronota}">
            AND NUMERONOTA = '${param.numeronota}'
        </c:if>

        <c:if test="${not empty param.dataini}">
            AND TRUNC(DATA) >= TO_DATE('${param.dataini}','YYYY-MM-DD')
        </c:if>

        <c:if test="${not empty param.datafim}">
            AND TRUNC(DATA) <= TO_DATE('${param.datafim}','YYYY-MM-DD')
        </c:if>

        ORDER BY DATA DESC

    </snk:query>

    <div class="timeline">

        <c:forEach items="${ocorrencias.rows}" var="row">

            <div class="timeline-item">

                <div class="timeline-dot"></div>

                <div class="timeline-card">

                    <div class="d-flex justify-content-between">

                        <h5>
                            ${row.NOMEOCORRENCIA}
                        </h5>

                        <span class="badge bg-primary status-badge">
                            ${row.CODIGOOCORRENCIATRANSPORTADORA}
                        </span>

                    </div>

                    <div class="timeline-date">

                        <strong>Data ocorrência:</strong>

                        ${row.DATA}

                    </div>

                    <div class="mt-2">

                        <strong>Transportadora:</strong>
                        ${row.TRANSPORTADORA}

                    </div>

                    <c:if test="${not empty row.DATAPREVISAOENTREGA}">

                        <div>

                            <strong>Previsão entrega:</strong>

                            ${row.DATAPREVISAOENTREGA}

                        </div>

                    </c:if>

                    <c:if test="${not empty row.DATAENTREGA}">

                        <div class="text-success">

                            <strong>Entregue em:</strong>

                            ${row.DATAENTREGA}

                        </div>

                    </c:if>

                    <c:if test="${not empty row.OBSERVACAO}">

                        <hr>

                        <div>

                            ${row.OBSERVACAO}

                        </div>

                    </c:if>

                </div>

            </div>

        </c:forEach>

    </div>

    </c:if>

    <c:if test="${empty param.numeronota}">
        <div class="alert alert-info">
            Informe o n&uacute;mero da nota e clique em Buscar para visualizar o rastreamento.
        </div>
    </c:if>

</div>

</body>

</html>
