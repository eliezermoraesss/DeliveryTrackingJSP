<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Dashboard de Performance do Sistema</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <snk:load/>
    
    <!-- Query dados da empresa e informações contextuais -->
    <snk:query var="dados_cliente">
      SELECT 
        EMP.RAZAOSOCIAL AS NOMEPARC,
        EMP.CGC,
        CID.DESCRICAOCORREIO || '/' || UFS.UF AS LOCALIZACAO
      FROM TSIEMP EMP, TSICID CID, TSIUFS UFS
      WHERE EMP.CODCID = CID.CODCID AND CID.UF = UFS.CODUF AND
EMP.CODEMP = (SELECT MIN(CODEMP) FROM TSIEMP)
    </snk:query>

    <!-- Query informações de contexto do dashboard -->
    <snk:query var="info_dashboard">
      SELECT 
        TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS DATA_ATUAL,
        TO_CHAR(SYSDATE, 'HH24:MI') AS HORA_ATUAL,
        TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -3), 'MM/YYYY') AS MES_INICIO,
        TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -1), 'MM/YYYY') AS MES_FIM,
        'Últimos 3 Meses Completos' AS PERIODO_DESCRICAO
      FROM DUAL
    </snk:query>

    <!-- Query usuários ativos hoje -->
    <snk:query var="usuarios_ativos">
      SELECT COUNT(DISTINCT CODUSU) AS USUARIOS_ATIVOS_HOJE
      FROM TSIRLG 
      WHERE TRUNC(LOGIN) = TRUNC(SYSDATE)
    </snk:query>

    <!-- Query versão do Oracle -->
    <snk:query var="versao_oracle">
      SELECT 
        TO_NUMBER(REGEXP_SUBSTR(banner_full, 'Release ([0-9]+)', 1, 1, NULL, 1)) AS versao,
        REGEXP_SUBSTR(banner_full, 'Release ([0-9]+(\.[0-9]+)*)', 1, 1, NULL, 1) AS release,
        CASE 
          WHEN TO_NUMBER(REGEXP_SUBSTR(banner_full, 'Release ([0-9]+)', 1, 1, NULL, 1)) >= 12 
            THEN 'OK'
          ELSE 'ALERTA'
        END AS status
      FROM v$version
      WHERE banner_full LIKE 'Oracle%'
    </snk:query>

    <!-- Query para Média de Pedidos de Venda -->
    <snk:query var="media_pedidos">
      WITH DADOS_MENSAIS AS (
        SELECT TO_CHAR(DTNEG, 'YYYY_MM') AS ANO_MES, COUNT(1) AS TOTAL
        FROM TGFCAB
        WHERE DTNEG >= ADD_MONTHS(TRUNC(SYSDATE) - (TO_NUMBER(TO_CHAR(SYSDATE,'DD')) - 1), -3)
          AND DTNEG < TRUNC(SYSDATE) - (TO_NUMBER(TO_CHAR(SYSDATE,'DD')) - 1)
          AND TIPMOV = 'P'
          AND STATUSNOTA = 'L'
        GROUP BY TO_CHAR(DTNEG, 'YYYY_MM')
      )
      SELECT 
        NVL(ROUND(AVG(TOTAL), 0), 0) AS MEDIA,
        CASE 
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 40000 THEN 400
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 6000 THEN 300
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 1300 THEN 200
          ELSE 100
        END AS SCORE
      FROM DADOS_MENSAIS
    </snk:query>

    <!-- Query para Média de NF de Venda -->
    <snk:query var="media_nf">
      WITH DADOS_MENSAIS AS (
        SELECT TO_CHAR(DTNEG, 'YYYY_MM') AS ANO_MES, COUNT(1) AS TOTAL
        FROM TGFCAB
        WHERE DTNEG >= ADD_MONTHS(TRUNC(SYSDATE) - (TO_NUMBER(TO_CHAR(SYSDATE,'DD')) - 1), -3)
          AND DTNEG < TRUNC(SYSDATE) - (TO_NUMBER(TO_CHAR(SYSDATE,'DD')) - 1)
          AND TIPMOV = 'V'
          AND STATUSNOTA = 'L'
        GROUP BY TO_CHAR(DTNEG, 'YYYY_MM')
      )
      SELECT 
        NVL(ROUND(AVG(TOTAL), 0), 0) AS MEDIA,
        CASE 
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) >= 38001 THEN 570
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 5000 THEN 320
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 800 THEN 220
          ELSE 120
        END AS SCORE
      FROM DADOS_MENSAIS
    </snk:query>

    <!-- Query para Média de Itens de NF -->
    <snk:query var="media_itens">
      WITH DADOS_MENSAIS AS (
        SELECT TO_CHAR(TGFCAB.DTNEG, 'YYYY_MM') AS ANO_MES, 
               ROUND(COUNT(TGFITE.SEQUENCIA)/COUNT(DISTINCT TGFITE.NUNOTA),2) AS TOTAL
        FROM TGFCAB, TGFITE
        WHERE TGFCAB.NUNOTA = TGFITE.NUNOTA
          AND TGFCAB.DTNEG >= ADD_MONTHS(TRUNC(SYSDATE) - (TO_NUMBER(TO_CHAR(SYSDATE,'DD')) - 1), -3)
          AND TGFCAB.DTNEG < TRUNC(SYSDATE) - (TO_NUMBER(TO_CHAR(SYSDATE,'DD')) - 1)
          AND TGFCAB.TIPMOV IN ('P','V')
          AND TGFCAB.STATUSNOTA = 'L'
        GROUP BY TO_CHAR(TGFCAB.DTNEG, 'YYYY_MM')
      )
      SELECT 
        NVL(ROUND(AVG(TOTAL), 0), 0) AS MEDIA,
        CASE 
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 60 THEN 581
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 40 THEN 330
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 15 THEN 230
          ELSE 130
        END AS SCORE
      FROM DADOS_MENSAIS
    </snk:query>

    <!-- Query para Média Contábil -->
    <snk:query var="media_contabil">
      WITH DADOS_MENSAIS AS (
        SELECT TO_CHAR(REFERENCIA, 'YYYY_MM') AS ANO_MES, COUNT(1) AS TOTAL
        FROM TCBLAN
        WHERE REFERENCIA >= ADD_MONTHS(TRUNC(SYSDATE) - (TO_NUMBER(TO_CHAR(SYSDATE,'DD')) - 1), -3)
          AND REFERENCIA < TRUNC(SYSDATE) - (TO_NUMBER(TO_CHAR(SYSDATE,'DD')) - 1)
        GROUP BY TO_CHAR(REFERENCIA, 'YYYY_MM')
      )
      SELECT 
        NVL(ROUND(AVG(TOTAL), 0), 0) AS MEDIA,
        CASE 
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) >= 550001 THEN 440
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 20000 THEN 340
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) >= 2001 THEN 240
          ELSE 140
        END AS SCORE
      FROM DADOS_MENSAIS
    </snk:query>

    <!-- Query para Média Financeiro -->
    <snk:query var="media_financeiro">
      WITH DADOS_MENSAIS AS (
        SELECT TO_CHAR(DTNEG, 'YYYY_MM') AS ANO_MES, COUNT(1) AS TOTAL
        FROM TGFFIN
        WHERE DTNEG >= ADD_MONTHS(TRUNC(SYSDATE) - (TO_NUMBER(TO_CHAR(SYSDATE,'DD')) - 1), -3)
          AND DTNEG < TRUNC(SYSDATE) - (TO_NUMBER(TO_CHAR(SYSDATE,'DD')) - 1)
          AND RECDESP <> 0
          AND PROVISAO = 'N'
          AND ORIGEM = 'F'
        GROUP BY TO_CHAR(DTNEG, 'YYYY_MM')
      )
      SELECT 
        NVL(ROUND(AVG(TOTAL), 0), 0) AS MEDIA,
        CASE 
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) >= 15001 THEN 450
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 6000 THEN 350
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 1000 THEN 250
          ELSE 150
        END AS SCORE
      FROM DADOS_MENSAIS
    </snk:query>

    <!-- Query para Média Livros Fiscais -->
    <snk:query var="media_livros">
      WITH DADOS_MENSAIS AS (
        SELECT TO_CHAR(DTDOC, 'YYYY_MM') AS ANO_MES, COUNT(1) AS TOTAL
        FROM TGFLIV
        WHERE DTDOC >= ADD_MONTHS(TRUNC(SYSDATE) - (TO_NUMBER(TO_CHAR(SYSDATE,'DD')) - 1), -3)
          AND DTDOC < TRUNC(SYSDATE) - (TO_NUMBER(TO_CHAR(SYSDATE,'DD')) - 1)
        GROUP BY TO_CHAR(DTDOC, 'YYYY_MM')
      )
      SELECT 
        NVL(ROUND(AVG(TOTAL), 0), 0) AS MEDIA,
        CASE 
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) >= 300001 THEN 460
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 30000 THEN 360
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 2000 THEN 260
          ELSE 160
        END AS SCORE
      FROM DADOS_MENSAIS
    </snk:query>

    <!-- Query para Média de Usuários -->
    <snk:query var="media_usuarios">
      WITH DADOS_MENSAIS AS (
        SELECT TO_CHAR(LOGIN, 'YYYY_MM') AS ANO_MES, COUNT(DISTINCT TSIRLG.CODUSU) AS TOTAL
        FROM TSIRLG
        WHERE LOGIN >= ADD_MONTHS(TRUNC(SYSDATE) - (TO_NUMBER(TO_CHAR(SYSDATE,'DD')) - 1), -3)
          AND LOGIN < TRUNC(SYSDATE) - (TO_NUMBER(TO_CHAR(SYSDATE,'DD')) - 1)
        GROUP BY TO_CHAR(LOGIN, 'YYYY_MM')
      )
      SELECT 
        NVL(ROUND(AVG(TOTAL), 0), 0) AS MEDIA,
        CASE 
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 300 THEN 470
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) > 100 THEN 370
          WHEN NVL(ROUND(AVG(TOTAL), 0), 0) >= 16 THEN 270
          ELSE 170
        END AS SCORE
      FROM DADOS_MENSAIS
    </snk:query>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&display=swap" rel="stylesheet');
        body {
            font-family: 'Roboto', sans-serif;
            font-weight: 700;
        }
        * {
            margin: 0;
            padding: 0;
        }
        i {
            margin-right: 10px;
        }
        .divInfoParceiro {
          padding: 15px 20px !important;
          color: #fff;
          display: flex;
          flex-wrap: wrap;
          align-items: center;
          justify-content: space-between;
          font-size: 16px;
          font-weight: 400;
          min-height: 70px;
          background: linear-gradient(135deg, #66cc66 0%, #5bb85b 100%);
        }

        .info-empresa {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            font-weight: 600;
            gap: 8px;
        }

        .empresa-titulo {
            font-size: 20px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .info-contexto {
            display: flex;
            align-items: center;
            gap: 25px;
            font-size: 15px;
            opacity: 1;
            margin-left: 20px;
            flex-wrap: wrap;
        }

        .info-item {
            display: flex;
            align-items: center;
            gap: 8px;
            white-space: nowrap;
            background: rgba(255, 255, 255, 0.15);
            padding: 8px 15px;
            border-radius: 20px;
            font-weight: 500;
        }

        .info-item-label {
            font-weight: 600;
        }

        .oracle-info {
            display: flex;
            align-items: center;
            gap: 8px;
            background: rgba(255, 255, 255, 0.15);
            padding: 6px 15px;
            border-radius: 20px;
            font-size: 15px;
            font-weight: 500;
        }

        .oracle-version {
            font-weight: 600;
        }

        .oracle-status-badge {
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .oracle-status-ok {
            background-color: #4caf50;
            color: white;
        }

        .oracle-status-alert {
            background-color: #f44336;
            color: white;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
        }

        @media (max-width: 768px) {
            .divInfoParceiro {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
                padding: 15px !important;
            }
            .info-contexto {
                gap: 10px;
                font-size: 13px;
                margin-left: 0px;
            }
            .empresa-titulo {
                font-size: 18px;
            }
        }
        .titulo-info {
            font-weight: 500;
        }

        /*---------- css do grid -------------------*/
        .container {
            max-width: 100%;
            margin: auto;
            background: white;
            border-radius: 8px;
            padding: 2rem;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.05);
        }

        h2 {
            color: #66cc66;
            margin-bottom: 1.5rem;
        }

        .performance-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .performance-card {
            background: linear-gradient(135deg, #66cc66 0%, #4da84d 100%);
            border-radius: 12px;
            padding: 1.5rem;
            color: white;
            box-shadow: 0 4px 15px rgba(102, 204, 102, 0.3);
            transition: transform 0.3s ease;
        }

        .performance-card:hover {
            transform: translateY(-2px);
        }

        .card-title {
            font-size: 0.9rem;
            font-weight: 700;
            margin-bottom: 1rem;
            opacity: 0.9;
        }

        .metric-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.5rem;
        }

        .metric-label {
            font-size: 0.8rem;
            opacity: 0.8;
        }

        .metric-value {
            font-size: 1.2rem;
            font-weight: bold;
        }

        .score-summary {
            background: linear-gradient(135deg, #4da84d 0%, #3d8b3d 100%);
            border-radius: 12px;
            padding: 2rem;
            color: white;
            text-align: center;
            margin-top: 2rem;
        }

        .total-score {
            font-size: 3rem;
            font-weight: bold;
            margin: 1rem 0;
        }

        .classification {
            font-size: 1.5rem;
            font-weight: 500;
            padding: 0.5rem 1rem;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 25px;
            display: inline-block;
        }

        /* Footer documentation styles */
        .footer-documentation {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 12px;
            padding: 2rem;
            margin-top: 2rem;
            border: 1px solid #dee2e6;
        }

        .doc-section h4 {
            color: #495057;
            margin-bottom: 1rem;
            font-weight: 600;
        }

        .doc-section p {
            color: #6c757d;
            margin-bottom: 1.5rem;
            line-height: 1.6;
        }

        .doc-link-container {
            text-align: center;
            margin: 1.5rem 0;
        }

        .doc-button {
            display: inline-flex;
            align-items: center;
            background: linear-gradient(135deg, #66cc66 0%, #4da84d 100%);
            color: white;
            text-decoration: none;
            padding: 1rem 2rem;
            border-radius: 50px;
            font-weight: 500;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(102, 204, 102, 0.3);
        }

        .doc-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 204, 102, 0.4);
            color: white;
            text-decoration: none;
        }

        .doc-icon {
            margin-right: 0.5rem;
            font-size: 1.2rem;
        }

        .doc-text {
            margin: 0 0.5rem;
        }

        .doc-arrow {
            margin-left: 0.5rem;
            transition: transform 0.3s ease;
        }

        .doc-button:hover .doc-arrow {
            transform: translateX(3px);
        }

        .doc-description {
            font-size: 0.9rem;
            opacity: 0.8;
            text-align: center;
        }

        /* Modal Styles */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.7);
            z-index: 9999;
            overflow-y: auto;
            padding: 20px;
        }

        .modal-content {
            background: white;
            max-width: 1200px;
            margin: 20px auto;
            border-radius: 16px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
            position: relative;
            animation: modalSlideIn 0.3s ease-out;
        }

        @keyframes modalSlideIn {
            from {
                opacity: 0;
                transform: translateY(-50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .modal-header {
            background: linear-gradient(135deg, #66cc66 0%, #4da84d 100%);
            color: white;
            padding: 25px 30px;
            border-radius: 16px 16px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-header h3 {
            margin: 0;
            font-size: 24px;
            font-weight: 700;
        }

        .modal-close {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            font-size: 28px;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0;
            line-height: 1;
        }

        .modal-close:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: rotate(90deg);
        }

        .modal-body {
            padding: 30px;
            color: #333;
            max-height: calc(100vh - 200px);
            overflow-y: auto;
        }

        .req-section {
            margin-bottom: 30px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 12px;
            border-left: 4px solid #66cc66;
        }

        .req-section h4 {
            color: #66cc66;
            margin-bottom: 15px;
            font-size: 20px;
            font-weight: 600;
        }

        .req-section h5 {
            color: #4da84d;
            margin: 20px 0 10px;
            font-size: 16px;
            font-weight: 600;
        }

        .req-section ul {
            margin: 10px 0;
            padding-left: 25px;
            line-height: 1.8;
        }

        .req-section ul li {
            margin-bottom: 8px;
        }

        .req-alert {
            padding: 15px;
            border-radius: 8px;
            margin-top: 15px;
            border-left: 4px solid;
        }

        .req-alert-warning {
            background: #fff3cd;
            border-color: #ffc107;
            color: #856404;
        }

        .req-alert-info {
            background: #d1ecf1;
            border-color: #17a2b8;
            color: #0c5460;
        }

        .req-alert-danger {
            background: #f8d7da;
            border-color: #dc3545;
            color: #721c24;
        }

        .req-button {
            background: linear-gradient(135deg, #66cc66 0%, #4da84d 100%);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 25px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(102, 204, 102, 0.3);
        }

        .req-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 204, 102, 0.4);
        }

        .requirements-summary {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-top: 15px;
            text-align: center;
        }

        .requirements-summary p {
            margin-bottom: 15px;
            color: #666;
            font-size: 15px;
        }

        /* Popup de Integrações */
        .integration-popup-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            z-index: 10000;
            justify-content: center;
            align-items: center;
        }

        .integration-popup {
            background: white;
            border-radius: 16px;
            padding: 30px;
            max-width: 400px;
            width: 90%;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
            animation: popupSlideIn 0.3s ease-out;
        }

        @keyframes popupSlideIn {
            from {
                opacity: 0;
                transform: scale(0.9);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }

        .integration-popup h4 {
            color: #66cc66;
            margin-bottom: 20px;
            font-size: 20px;
            text-align: center;
        }

        .integration-popup-content {
            margin-bottom: 25px;
        }

        .integration-popup-content label {
            display: block;
            margin-bottom: 10px;
            color: #333;
            font-weight: 500;
        }

        .integration-popup-content input {
            width: 100%;
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s;
        }

        .integration-popup-content input:focus {
            outline: none;
            border-color: #66cc66;
        }

        .integration-popup-buttons {
            display: flex;
            gap: 10px;
            justify-content: center;
        }

        .integration-popup-btn {
            padding: 12px 30px;
            border: none;
            border-radius: 25px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .integration-popup-btn-save {
            background: linear-gradient(135deg, #66cc66 0%, #4da84d 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(102, 204, 102, 0.3);
        }

        .integration-popup-btn-save:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 204, 102, 0.4);
        }

        .integration-popup-btn-cancel {
            background: #f0f0f0;
            color: #666;
        }

        .integration-popup-btn-cancel:hover {
            background: #e0e0e0;
        }

        .performance-card-clickable {
            cursor: pointer;
            position: relative;
        }

        .performance-card-clickable::after {
            content: '\270F\FE0F Clique para editar';
            position: absolute;
            top: 10px;
            right: 15px;
            font-size: 0.75rem;
            opacity: 0.85;
            font-weight: 600;
            background: rgba(255, 255, 255, 0.25);
            padding: 5px 12px;
            border-radius: 15px;
            white-space: nowrap;
        }

        .performance-card-clickable:hover::after {
            opacity: 1;
            background: rgba(255, 255, 255, 0.35);
            transform: scale(1.05);
            transition: all 0.3s ease;
        }
        
        /*---------- css do grid -------------------*/

        /*----------bootstrap-navbar-css------------*/

        nav {
            display: block !important; 
        }
        .navbar-logo {
            padding: 15px;
            color: #fff;
        }
        .navbar-mainbg {
            background-color: #66cc66;
            padding: 0px;
        }
        #navbarSupportedContent {
            overflow: hidden;
            position: relative;
        }
        #navbarSupportedContent ul {
            padding: 0px;
            margin: 0px;
        }
        #navbarSupportedContent ul li a i {
            margin-right: 10px;
        }
        #navbarSupportedContent li {
            list-style-type: none;
            float: left;
        }
        #navbarSupportedContent ul li a {
            color: white;
            text-decoration: none;
            font-size: 16px;
            display: block;
            padding: 13px 10px;
            transition-duration: 0.6s;
            transition-timing-function: cubic-bezier(0.68, -0.55, 0.265, 1.55);
            position: relative;
        }
        #navbarSupportedContent>ul>li.active>a {
            color: #2e3c50;
            background-color: transparent;
            transition: all 0.7s;
        }
        #navbarSupportedContent a:not(:only-child):after {
            content: "\f105";
            position: absolute;
            right: 12px;
            top: 8px;
            font-size: 12px;
            font-family: "Font Awesome 5 Free";
            display: inline-block;
            padding-right: 3px;
            vertical-align: middle;
            font-weight: 700;
            transition: 0.5s;
        }
        #navbarSupportedContent .active>a:not(:only-child):after {
            transform: rotate(90deg);
        }
        .hori-selector {
            display: inline-block;
            position: absolute;
            height: 100%;
            top: 0px;
            left: 0px;
            transition-duration: 0.6s;
            transition-timing-function: cubic-bezier(0.68, -0.55, 0.265, 1.55);
            background-color: #fff;
            border-top-left-radius: 15px;
            border-top-right-radius: 15px;
            margin-top: 10px;
        }
        .hori-selector .right, .hori-selector .left {
            position: absolute;
            width: 25px;
            height: 25px;
            background-color: #fff;
            bottom: 10px;
        }
        .hori-selector .right {
            right: -25px;
        }
        .hori-selector .left {
            left: -25px;
        }
        .hori-selector .right:before, .hori-selector .left:before {
            content: '';
            position: absolute;
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background-color: #66cc66;
        }
        .hori-selector .right:before {
            bottom: 0;
            right: -25px;
        }
        .hori-selector .left:before {
            bottom: 0;
            left: -25px;
        }

        .navbar-mainbg {
            background-color: #66cc66; /* Default active color */
            padding: 0px;
        }

        .navbar-inactive .navbar-mainbg,
        .navbar-inactive .hori-selector .right:before,
        .navbar-inactive .hori-selector .left:before {
            background-color: #CC6C5C !important; /* Inactive color */
        }

        @media(min-width: 992px) {
            .navbar-expand-custom {
                -ms-flex-flow: row nowrap;
                flex-flow: row nowrap;
                -ms-flex-pack: start;
                justify-content: flex-start;
            }
            .navbar-expand-custom .navbar-nav {
                -ms-flex-direction: row;
                flex-direction: row;
            }
            .navbar-expand-custom .navbar-toggler {
                display: none;
            }
            .navbar-expand-custom .navbar-collapse {
                display: -ms-flexbox !important;
                display: flex !important;
                -ms-flex-preferred-size: auto;
                flex-basis: auto;
            }
        }
        @media (max-width: 991px) {
            #navbarSupportedContent ul li a {
                padding: 12px 30px;
            }
            .hori-selector {
                margin-top: 0px;
                margin-left: 10px;
                border-radius: 0;
                border-top-left-radius: 25px;
                border-bottom-left-radius: 25px;
            }
            .hori-selector .left, .hori-selector .right {
                right: 10px;
            }
            .hori-selector .left {
                top: -25px;
                left: auto;
            }
            .hori-selector .right {
                bottom: -25px;
            }
            .hori-selector .left:before {
                left: -25px;
                top: -25px;
            }
            .hori-selector .right:before {
                bottom: -25px;
                left: -25px;
            }
        }
    </style>
    
    <script>
            function getRequirementsA() {
                return `
                    <div class="req-section">
                        <h4>&#128295; Servidor de Banco de Dados</h4>
                        <ul>
                            <li><strong>Processador:</strong> 4 vCPUs / 3.4 GHz (configuração mínima)</li>
                            <li><strong>Memória:</strong> 8 GB RAM</li>
                            <li><strong>Discos:</strong> 100GB (Disco SATA-2) para banco de dados + 50GB para backup</li>
                            <li><strong>SGBD:</strong> Oracle XE / SQL Server Express</li>
                        </ul>
                        
                        <h5>&#128193; Particionamento Oracle:</h5>
                        <ul>
                            <li>/ = 50 GB (Sistema Operacional)</li>
                            <li>/tmp = 4 GB (mínimo)</li>
                            <li>/u01 = 100 GB (Binários e datafiles do Oracle)</li>
                            <li>/u02 = 50 GB (Destinado a backup)</li>
                        </ul>
                        
                        <h5>&#128193; Particionamento SQL Server:</h5>
                        <ul>
                            <li>C:\\ = 100 GB (Sistema Operacional e binários)</li>
                            <li>D:\\ = 100 GB (Datafiles - formatado em bloco de 64 KB)</li>
                            <li>E:\\ = 50 GB (Backup)</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128640; Servidor de Aplicação</h4>
                        <ul>
                            <li><strong>Processador:</strong> 4 vCPUs / 3.4 GHz (configuração mínima)</li>
                            <li><strong>Memória:</strong> 8 GB RAM</li>
                            <li><strong>Disco:</strong> 100 GB (Disco SATA-2)</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128736; Softwares Homologados</h4>
                        <h5>Banco de Dados:</h5>
                        <ul>
                            <li><strong>Oracle:</strong> XE / Free (18c ou 23c)</li>
                            <li><strong>SQL Server:</strong> 2017 Express até 2019 Express</li>
                        </ul>
                        
                        <h5>Sistemas Operacionais (SankhyaOm):</h5>
                        <ul>
                            <li><strong>Linux:</strong> CentOS, Oracle Linux, Red Hat Enterprise Linux</li>
                            <li><strong>Windows:</strong> Windows Server 2012 ou superior</li>
                        </ul>
                        
                        <div class="req-alert req-alert-warning">
                            <strong>&#9888; Atenção:</strong> Oracle Database 18 XE e 23 FREE não recebem suporte oficial nem correções de bugs ou segurança da Oracle.
                        </div>
                    </div>

                    <div class="req-section">
                        <h4>&#128187; Módulos Delphi (Terminal Service)</h4>
                        <h5>Servidor:</h5>
                        <ul>
                            <li><strong>01 a 10 estações:</strong> 4 vCPUs 3 GHz + 6GB RAM</li>
                            <li><strong>10 a 20 estações:</strong> 6 vCPUs 3 GHz + 8GB RAM</li>
                            <li><strong>20 a 30 estações:</strong> 8 vCPUs 3 GHz + 10GB RAM</li>
                            <li><strong>Acima de 30 estações:</strong> 12 vCPUs 3 GHz + 12GB RAM</li>
                            <li><strong>Disco:</strong> 250GB SSD com 130 mb/s ou superior</li>
                        </ul>
                        
                        <h5>Estações de Trabalho:</h5>
                        <ul>
                            <li><strong>Processador:</strong> I3 3 GHz ou superior</li>
                            <li><strong>Memória:</strong> 8GB RAM</li>
                            <li><strong>Disco:</strong> SSD 120 GB</li>
                            <li><strong>Conexão:</strong> Banda mínima 256Kbps por estação</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128722; Módulo Sankhya Checkout</h4>
                        <ul>
                            <li><strong>Windows:</strong> 10 ou 11</li>
                            <li><strong>Resolução:</strong> 1024x768 pixels</li>
                            <li><strong>USB:</strong> 2.0 ou superior</li>
                            <li><strong>Memória RAM:</strong> 8 GB (Win 10) / 12 GB (Win 11)</li>
                            <li><strong>Disco:</strong> SSD 120 GB</li>
                            <li><strong>Internet:</strong> 100MB</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128101; eSocial</h4>
                        <p>Para a utilização do eSocial, as configurações citadas no servidor de aplicação já atendem os requisitos para o seu funcionamento, pois a sua instalação deverá ser realizada no mesmo servidor onde está configurado o SankhyaOm.</p>
                        <p>Caso o cliente tenha contratado somente o módulo folha, este documento fica válido para a sua configuração.</p>
                    </div>

                    <div class="req-section">
                        <h4>&#128273; Software para conexão do Service Desk Sankhya</h4>
                        <p>A equipe de Service Desk utiliza para conexão aos clientes os softwares <strong>Anydesk/LogMeIn/TeamViewer</strong>.</p>
                        
                        <h5>Informações de Segurança:</h5>
                        <ul>
                            <li>Não há necessidade de abrir portas extras em firewall corporativo</li>
                            <li>Todas as comunicações usam protocolo padrão da Web (HTTP)</li>
                            <li>Conexão criptografada (SSL de 256 bits)</li>
                            <li><strong>Banda mínima:</strong> 200Kbps por estação</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#9889; Observações Importantes</h4>
                        <ul>
                            <li>&#128272; Servidor de aplicação Wildfly deve ser instalado em máquina separada e independente do servidor de banco de dados (crucial para desempenho)</li>
                            <li>&#128274; Para HTTPS com certificado digital, não utilize o serviço nativo do Wildfly. Recomendamos proxy reverso (Apache/Nginx) em servidor exclusivo</li>
                            <li>&#128190; Separar discos/partições para: diretório de dados, diretório de backups e sistema operacional</li>
                            <li>&#9728; Recomendado hospedagem em CLOUD com players consolidados (Oracle Cloud, AWS, Google Cloud) que garantam SLA e performance adequadas</li>
                            <li>&#128736; NÃO recomendado RAID 5 para nenhum dos servidores (Banco de dados, Aplicação Web ou Windows)</li>
                            <li>&#128273; OBRIGATÓRIO: Alterar senhas das bases (SANKHYA, TESTE, TREINA) após instalação com apoio do profissional Sankhya</li>
                            <li>&#128295; Responsabilidade do cliente: Manutenção periódica do BD (atualização de estatísticas, reorganização de índices, análise de queries)</li>
                            <li>&#128190; Responsabilidade do cliente: Gerenciamento, validação e manutenção dos backups (rotina básica pode ser alterada pelo cliente)</li>
                            <li>&#10060; NÃO criar duas VMs sobre o mesmo disco do servidor físico</li>
                            <li>&#128295; Servidores devem ser dedicados exclusivamente para o sistema</li>
                            <li>&#128273; É necessário acesso irrestrito aos servidores para os analistas da Sankhya</li>
                            <li>&#128736; Utilização de itens de segurança (RAID, fonte redundante, Storage) é recomendada, mas o dimensionamento é responsabilidade do cliente</li>
                            <li>&#128311; Rede: Switch 100/1000</li>
                            <li>&#9997; Cliente deve enviar inventário de estações para avaliação se possuir configurações diferenciadas</li>
                        </ul>
                        
                        <div class="req-alert req-alert-warning">
                            <strong>&#9888; IMPORTANTE:</strong> Para clientes com este perfil, recomendamos hospedagem em CLOUD. A versão gratuita do banco de dados possui limitações que podem ocasionar problemas a médio e longo prazo. Caso opte por manter servidores localmente, recomendamos utilizar a versão Standard do banco de dados.
                        </div>
                        
                        <div class="req-alert req-alert-info">
                            <strong>&#128161; Latência para ambientes fora do Brasil:</strong>
                            <ul style="margin-top: 10px; margin-bottom: 0;">
                                <li><strong>Entre BD e Aplicação:</strong> manter tráfego de rede até 0.5 ms</li>
                                <li><strong>Entre usuários e aplicação:</strong> manter tráfego de rede até 40ms</li>
                            </ul>
                        </div>
                        
                        <div class="req-alert req-alert-warning">
                            <strong>&#9888; Nota Final:</strong> Esses requisitos são mínimos e baseados no volume médio de operação obtido no cálculo de transações. Para volumes mais altos (volume de faturamento, itens por nota, movimentos financeiros, etc.) é necessário análise individual para definição da infraestrutura necessária.
                        </div>
                    </div>
                `;
            }
            
            function getRequirementsB() {
                return `
                    <div class="req-section">
                        <h4>&#128295; Servidor de Banco de Dados</h4>
                        <ul>
                            <li><strong>Processador:</strong> 8 vCPUs / 3.4 GHz (configuração mínima)</li>
                            <li><strong>Memória:</strong> 48 GB RAM</li>
                            <li><strong>Discos:</strong> 200GB (SSD 350 mb/s ou superior) + 200GB backup</li>
                            <li><strong>SGBD:</strong> Oracle Standard / SQL Server Standard</li>
                        </ul>
                        
                        <h5>&#128193; Particionamento Oracle:</h5>
                        <ul>
                            <li>/ = 50 GB (Sistema Operacional)</li>
                            <li>/tmp = 4 GB (mínimo)</li>
                            <li>/u01 = 80 GB (Binários do Oracle)</li>
                            <li>/u02 = 200 GB (Datafiles do banco de dados)</li>
                            <li>/backup = 200 GB (Backup - pode ter taxa de leitura/escrita menor)</li>
                        </ul>
                        
                        <h5>&#128193; Particionamento SQL Server:</h5>
                        <ul>
                            <li>C:\\ = 100 GB (Sistema Operacional e binários)</li>
                            <li>D:\\ = 200 GB (Datafiles - formatado em bloco de 64 KB)</li>
                            <li>E:\\ = 200 GB (Backup - pode ter taxa de leitura/escrita menor)</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128640; Servidor de Aplicação</h4>
                        <ul>
                            <li><strong>Processador:</strong> 6 vCPUs / 3.4 GHz (configuração mínima)</li>
                            <li><strong>Memória:</strong> 24 GB RAM</li>
                            <li><strong>Disco:</strong> 100 GB (SATA-2 ou superior)</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128736; Softwares Homologados</h4>
                        <h5>Banco de Dados:</h5>
                        <ul>
                            <li><strong>Oracle:</strong> Database 12c Release 2, 18c, 19c, 23ai (Standard/Enterprise)</li>
                            <li><strong>SQL Server:</strong> 2017 até 2019 (Standard/Enterprise)</li>
                        </ul>
                        
                        <h5>Sistemas Operacionais (SankhyaOm):</h5>
                        <ul>
                            <li><strong>Linux:</strong> CentOS, Oracle Linux, Red Hat Enterprise Linux</li>
                            <li><strong>Windows:</strong> Windows Server 2012 ou superior</li>
                        </ul>
                        
                        <div class="req-alert req-alert-info">
                            <strong>&#128161; Nota:</strong> Oracle Database 23ai disponível somente em nuvem (OCI). Para utilizar Oracle 23ai, versão do SankhyaOM deve ser 4.33 ou superior.
                        </div>
                    </div>

                    <div class="req-section">
                        <h4>&#128187; Módulos Delphi (Terminal Service)</h4>
                        <h5>Servidor:</h5>
                        <ul>
                            <li><strong>01 a 10 estações:</strong> 4 vCPUs 3 GHz + 6GB RAM</li>
                            <li><strong>10 a 20 estações:</strong> 6 vCPUs 3 GHz + 8GB RAM</li>
                            <li><strong>20 a 30 estações:</strong> 8 vCPUs 3 GHz + 10GB RAM</li>
                            <li><strong>Acima de 30 estações:</strong> 12 vCPUs 3 GHz + 12GB RAM</li>
                            <li><strong>Processador recomendado:</strong> Intel Xeon E-2236 ou E-2244G</li>
                            <li><strong>Disco:</strong> 250GB SSD com 130 mb/s ou superior</li>
                        </ul>
                        
                        <h5>Estações de Trabalho:</h5>
                        <ul>
                            <li><strong>Processador:</strong> I3 3 GHz ou superior</li>
                            <li><strong>Memória:</strong> 8GB RAM</li>
                            <li><strong>Disco:</strong> SSD 120 GB</li>
                            <li><strong>Conexão:</strong> Banda mínima 256Kbps por estação</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128722; Módulo Sankhya Checkout</h4>
                        <ul>
                            <li><strong>Windows:</strong> 10 ou 11</li>
                            <li><strong>Resolução:</strong> 1024x768 pixels</li>
                            <li><strong>USB:</strong> 2.0 ou superior</li>
                            <li><strong>Memória RAM:</strong> 8 GB (Win 10) / 16 GB (Win 11)</li>
                            <li><strong>Disco:</strong> SSD 120 GB</li>
                            <li><strong>Internet:</strong> 100MB</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128101; eSocial</h4>
                        <p>Para a utilização do eSocial, as configurações citadas no servidor de aplicação já atendem os requisitos para o seu funcionamento, pois a sua instalação deverá ser realizada no mesmo servidor onde está configurado o SankhyaOm.</p>
                        <p>Caso o cliente tenha contratado somente o módulo folha, este documento fica válido para a sua configuração.</p>
                    </div>

                    <div class="req-section">
                        <h4>&#128273; Software para conexão do Service Desk Sankhya</h4>
                        <p>A equipe de Service Desk utiliza para conexão aos clientes os softwares <strong>Anydesk/LogMeIn/TeamViewer</strong>.</p>
                        
                        <h5>Informações de Segurança:</h5>
                        <ul>
                            <li>Não há necessidade de abrir portas extras em firewall corporativo</li>
                            <li>Todas as comunicações usam protocolo padrão da Web (HTTP)</li>
                            <li>Conexão criptografada (SSL de 256 bits)</li>
                            <li><strong>Banda mínima:</strong> 200Kbps por estação</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#9889; Observações Importantes</h4>
                        <ul>
                            <li>&#128272; Servidor de aplicação Wildfly deve ser instalado em máquina separada e independente do servidor de banco de dados (crucial para desempenho)</li>
                            <li>&#128274; Para HTTPS com certificado digital, não utilize o serviço nativo do Wildfly. Recomendamos proxy reverso (Apache/Nginx) em servidor exclusivo</li>
                            <li>&#128190; Separar discos/partições para: diretório de dados, diretório de backups e sistema operacional</li>
                            <li>&#9728; Recomendado hospedagem em CLOUD com players consolidados (Oracle Cloud, AWS, Google Cloud) que garantam SLA e performance adequadas</li>
                            <li>&#128736; NÃO recomendado RAID 5 para nenhum dos servidores (Banco de dados, Aplicação Web ou Windows)</li>
                            <li>&#128273; OBRIGATÓRIO: Alterar senhas das bases (SANKHYA, TESTE, TREINA) após instalação com apoio do profissional Sankhya</li>
                            <li>&#128295; Responsabilidade do cliente: Manutenção periódica do BD (atualização de estatísticas, reorganização de índices, análise de queries). Caso não tenha equipe certificada, contratar empresa certificada</li>
                            <li>&#128190; Responsabilidade do cliente: Gerenciamento e validação dos backups. Rotina implementada é básica, podendo ser alterada</li>
                            <li>&#10060; NÃO criar duas VMs sobre o mesmo disco do servidor físico</li>
                            <li>&#128295; Servidores devem ser dedicados exclusivamente para o sistema</li>
                            <li>&#128273; É necessário acesso irrestrito aos servidores para os analistas da Sankhya</li>
                            <li>&#128221; Responsabilidade do cliente: Instalação do sistema operacional Windows, configuração do Terminal Server ou Citrix e aquisição de licenças, configuração de impressoras e criação de usuários</li>
                            <li>&#128311; Rede: Switch 100/1000</li>
                            <li>&#9997; Cliente deve enviar inventário de estações para avaliação se possuir configurações diferenciadas</li>
                        </ul>
                        
                        <div class="req-alert req-alert-info">
                            <strong>&#128161; Recomendação:</strong> Utilizar servidores dedicados e separados para banco de dados e aplicação para garantir performance adequada.
                        </div>
                        
                        <div class="req-alert req-alert-info">
                            <strong>&#128161; Latência para ambientes fora do Brasil:</strong>
                            <ul style="margin-top: 10px; margin-bottom: 0;">
                                <li><strong>Entre BD e Aplicação:</strong> manter tráfego de rede até 0.5 ms</li>
                                <li><strong>Entre usuários e aplicação:</strong> manter tráfego de rede até 40ms</li>
                            </ul>
                        </div>
                        
                        <div class="req-alert req-alert-warning">
                            <strong>&#9888; Nota Final:</strong> Esses requisitos são mínimos e baseados no volume médio de operação obtido no cálculo de transações. Para volumes mais altos (volume de faturamento, itens por nota, movimentos financeiros, etc.) é necessário análise individual para definição da infraestrutura necessária.
                        </div>
                    </div>
                `;
            }
            
            function getRequirementsC() {
                return `
                    <div class="req-section">
                        <h4>&#128295; Servidor de Banco de Dados</h4>
                        <ul>
                            <li><strong>Processador:</strong> 10 vCPUs / 3.4 GHz (configuração mínima)</li>
                            <li><strong>Memória:</strong> 128 GB RAM</li>
                            <li><strong>Discos:</strong> 200GB (SSD 350 mb/s ou superior) + 200GB backup</li>
                            <li><strong>SGBD:</strong> Oracle Standard/Enterprise / SQL Server Standard/Enterprise</li>
                        </ul>
                        
                        <h5>&#128193; Particionamento Oracle:</h5>
                        <ul>
                            <li>/ = 50 GB (Sistema Operacional)</li>
                            <li>/tmp = 4 GB (mínimo)</li>
                            <li>/u01 = 80 GB (Binários do Oracle - mínimo)</li>
                            <li>/u02 = 200 GB (Datafiles do banco de dados - mínimo)</li>
                            <li>/backup = 200 GB (Backup - pode ter taxa de leitura/escrita menor)</li>
                        </ul>
                        
                        <h5>&#128193; Particionamento SQL Server:</h5>
                        <ul>
                            <li>C:\\ = 100 GB (Sistema Operacional e binários)</li>
                            <li>D:\\ = 200 GB (Datafiles - formatado em bloco de 64 KB)</li>
                            <li>E:\\ = 200 GB (Backup - pode ter taxa de leitura/escrita menor)</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128640; Servidor de Aplicação</h4>
                        <ul>
                            <li><strong>Processador:</strong> 10 vCPUs / 3.4 GHz (configuração mínima)</li>
                            <li><strong>Memória:</strong> 48 GB RAM</li>
                            <li><strong>Disco:</strong> 100 GB (SATA-2 ou superior)</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128736; Softwares Homologados</h4>
                        <h5>Banco de Dados:</h5>
                        <ul>
                            <li><strong>Oracle:</strong> Database 12c Release 2, 18c, 19c, 23ai (Standard/Enterprise)</li>
                            <li><strong>SQL Server:</strong> 2017 até 2019 (Standard/Enterprise)</li>
                        </ul>
                        
                        <h5>Sistemas Operacionais (SankhyaOm):</h5>
                        <ul>
                            <li><strong>Linux:</strong> CentOS, Oracle Linux, Red Hat Enterprise Linux</li>
                            <li><strong>Windows:</strong> Windows Server 2012 ou superior</li>
                        </ul>
                        
                        <div class="req-alert req-alert-info">
                            <strong>&#128161; Nota:</strong> Oracle Database 23ai disponível somente em nuvem (OCI). Para utilizar Oracle 23ai, versão do SankhyaOM deve ser 4.33 ou superior.
                        </div>
                    </div>

                    <div class="req-section">
                        <h4>&#128187; Módulos Delphi (Terminal Service)</h4>
                        <h5>Servidor:</h5>
                        <ul>
                            <li><strong>01 a 10 estações:</strong> 4 vCPUs 3 GHz + 6GB RAM</li>
                            <li><strong>10 a 20 estações:</strong> 6 vCPUs 3 GHz + 8GB RAM</li>
                            <li><strong>20 a 30 estações:</strong> 8 vCPUs 3 GHz + 10GB RAM</li>
                            <li><strong>Acima de 30 estações:</strong> 12 vCPUs 3 GHz + 12GB RAM</li>
                            <li><strong>Processador recomendado:</strong> Intel Xeon E-2236 ou E-2244G</li>
                            <li><strong>Disco:</strong> 250GB SSD com 130 mb/s ou superior</li>
                        </ul>
                        
                        <h5>Estações de Trabalho:</h5>
                        <ul>
                            <li><strong>Processador:</strong> I3 3 GHz ou superior</li>
                            <li><strong>Memória:</strong> 8GB RAM</li>
                            <li><strong>Disco:</strong> SSD 120 GB</li>
                            <li><strong>Conexão:</strong> Banda mínima 256Kbps por estação</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128722; Módulo Sankhya Checkout</h4>
                        <ul>
                            <li><strong>Windows:</strong> 10 ou 11</li>
                            <li><strong>Resolução:</strong> 1024x768 pixels</li>
                            <li><strong>USB:</strong> 2.0 ou superior</li>
                            <li><strong>Memória RAM:</strong> 12 GB (Win 10) / 32 GB (Win 11)</li>
                            <li><strong>Disco:</strong> SSD 240 GB</li>
                            <li><strong>Internet:</strong> 200MB</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128101; eSocial</h4>
                        <p>Para a utilização do eSocial, as configurações citadas no servidor de aplicação já atendem os requisitos para o seu funcionamento, pois a sua instalação deverá ser realizada no mesmo servidor onde está configurado o SankhyaOm.</p>
                        <p>Caso o cliente tenha contratado somente o módulo folha, este documento fica válido para a sua configuração.</p>
                    </div>

                    <div class="req-section">
                        <h4>&#128273; Software para conexão do Service Desk Sankhya</h4>
                        <p>A equipe de Service Desk utiliza para conexão aos clientes os softwares <strong>Anydesk/LogMeIn/TeamViewer</strong>.</p>
                        
                        <h5>Informações de Segurança:</h5>
                        <ul>
                            <li>Não há necessidade de abrir portas extras em firewall corporativo</li>
                            <li>Todas as comunicações usam protocolo padrão da Web (HTTP)</li>
                            <li>Conexão criptografada (SSL de 256 bits)</li>
                            <li><strong>Banda mínima:</strong> 200Kbps por estação</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#9889; Observações Importantes</h4>
                        <ul>
                            <li>&#128272; Servidor de aplicação Wildfly deve ser instalado em máquina separada e independente do servidor de banco de dados (crucial para desempenho)</li>
                            <li>&#128274; Para HTTPS com certificado digital, não utilize o serviço nativo do Wildfly. Recomendamos proxy reverso (Apache/Nginx) em servidor exclusivo</li>
                            <li>&#128190; Separar discos/partições para: diretório de dados, diretório de backups e sistema operacional</li>
                            <li>&#9728; Recomendado hospedagem em CLOUD com players consolidados (Oracle Cloud, AWS, Google Cloud) que garantam SLA e performance adequadas</li>
                            <li>&#128736; NÃO recomendado RAID 5 para nenhum dos servidores (Banco de dados, Aplicação Web ou Windows)</li>
                            <li>&#128273; OBRIGATÓRIO: Alterar senhas das bases (SANKHYA, TESTE, TREINA) após instalação com apoio do profissional Sankhya</li>
                            <li>&#128295; Responsabilidade do cliente: Manutenção periódica do BD (atualização de estatísticas, reorganização de índices, análise de queries). Caso não tenha equipe certificada, contratar empresa certificada</li>
                            <li>&#128190; Responsabilidade do cliente: Gerenciamento e validação dos backups. Rotina implementada é básica, podendo ser alterada</li>
                            <li>&#10060; NÃO criar duas VMs sobre o mesmo disco do servidor físico</li>
                            <li>&#128295; Servidores devem ser dedicados exclusivamente para o sistema</li>
                            <li>&#128273; É necessário acesso irrestrito aos servidores para os analistas da Sankhya</li>
                            <li>&#128221; Responsabilidade do cliente: Instalação do sistema operacional Windows, configuração do Terminal Server ou Citrix e aquisição de licenças, configuração de impressoras e criação de usuários</li>
                            <li>&#128311; Rede: Switch 100/1000</li>
                            <li>&#9997; Cliente deve enviar inventário de estações para avaliação se possuir configurações diferenciadas</li>
                        </ul>
                        
                        <div class="req-alert req-alert-info">
                            <strong>&#128161; Recomendação:</strong> Implementar estratégias de alta disponibilidade, backup automatizado e monitoramento proativo do ambiente.
                        </div>
                        
                        <div class="req-alert req-alert-info">
                            <strong>&#128161; Latência para ambientes fora do Brasil:</strong>
                            <ul style="margin-top: 10px; margin-bottom: 0;">
                                <li><strong>Entre BD e Aplicação:</strong> manter tráfego de rede até 0.5 ms</li>
                                <li><strong>Entre usuários e aplicação:</strong> manter tráfego de rede até 40ms</li>
                            </ul>
                        </div>
                        
                        <div class="req-alert req-alert-warning">
                            <strong>&#9888; Nota Final:</strong> Esses requisitos são mínimos e baseados no volume médio de operação obtido no cálculo de transações. Para volumes mais altos (volume de faturamento, itens por nota, movimentos financeiros, etc.) é necessário análise individual para definição da infraestrutura necessária.
                        </div>
                    </div>
                `;
            }
            
            function getRequirementsD() {
                return `
                    <div class="req-section">
                        <h4>&#128295; Servidor de Banco de Dados</h4>
                        <ul>
                            <li><strong>Processador:</strong> 16 vCPUs / 3.4 GHz (configuração mínima)</li>
                            <li><strong>Memória:</strong> 256 GB RAM</li>
                            <li><strong>Discos:</strong> 200GB (SSD 350 mb/s ou superior) + 200GB backup</li>
                            <li><strong>SGBD:</strong> Oracle Standard/Enterprise / SQL Server Standard/Enterprise</li>
                        </ul>
                        
                        <h5>&#128193; Particionamento Oracle:</h5>
                        <ul>
                            <li>/ = 50 GB (Sistema Operacional)</li>
                            <li>/tmp = 4 GB (mínimo)</li>
                            <li>/u01 = 80 GB (Binários do Oracle - mínimo)</li>
                            <li>/u02 = 200 GB (Datafiles do banco de dados - mínimo)</li>
                            <li>/backup = 200 GB (Backup - pode ter taxa de leitura/escrita menor)</li>
                        </ul>
                        
                        <h5>&#128193; Particionamento SQL Server:</h5>
                        <ul>
                            <li>C:\\ = 100 GB (Sistema Operacional e binários)</li>
                            <li>D:\\ = 200 GB (Datafiles - formatado em bloco de 64 KB)</li>
                            <li>E:\\ = 200 GB (Backup - pode ter taxa de leitura/escrita menor)</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128640; Servidor de Aplicação</h4>
                        <ul>
                            <li><strong>Processador:</strong> 12 vCPUs / 3.4 GHz (configuração mínima)</li>
                            <li><strong>Memória:</strong> 64 GB RAM</li>
                            <li><strong>Disco:</strong> 100 GB (SATA-2 ou superior)</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128736; Softwares Homologados</h4>
                        <h5>Banco de Dados:</h5>
                        <ul>
                            <li><strong>Oracle:</strong> Database 12c Release 2, 18c, 19c, 23ai (Standard/Enterprise)</li>
                            <li><strong>SQL Server:</strong> 2017 até 2019 (Standard/Enterprise)</li>
                        </ul>
                        
                        <h5>Sistemas Operacionais (SankhyaOm):</h5>
                        <ul>
                            <li><strong>Linux:</strong> CentOS, Oracle Linux, Red Hat Enterprise Linux</li>
                            <li><strong>Windows:</strong> Windows Server 2012 ou superior</li>
                        </ul>
                        
                        <div class="req-alert req-alert-info">
                            <strong>&#128161; Nota:</strong> Oracle Database 23ai disponível somente em nuvem (OCI). Para utilizar Oracle 23ai, versão do SankhyaOM deve ser 4.33 ou superior.
                        </div>
                    </div>

                    <div class="req-section">
                        <h4>&#128187; Módulos Delphi (Terminal Service)</h4>
                        <h5>Servidor:</h5>
                        <ul>
                            <li><strong>01 a 10 estações:</strong> 4 vCPUs 3 GHz + 6GB RAM</li>
                            <li><strong>10 a 20 estações:</strong> 6 vCPUs 3 GHz + 8GB RAM</li>
                            <li><strong>20 a 30 estações:</strong> 8 vCPUs 3 GHz + 10GB RAM</li>
                            <li><strong>Acima de 30 estações:</strong> 12 vCPUs 3 GHz + 12GB RAM</li>
                            <li><strong>Processador recomendado:</strong> Intel Xeon E-2236 ou E-2244G</li>
                            <li><strong>Disco:</strong> 250GB SSD com 130 mb/s ou superior</li>
                        </ul>
                        
                        <h5>Estações de Trabalho:</h5>
                        <ul>
                            <li><strong>Processador:</strong> I3 3 GHz ou superior</li>
                            <li><strong>Memória:</strong> 8GB RAM</li>
                            <li><strong>Disco:</strong> SSD 120 GB</li>
                            <li><strong>Conexão:</strong> Banda mínima 256Kbps por estação</li>
                        </ul>
                        
                        <h5>Sistemas Operacionais (Terminal Service):</h5>
                        <ul>
                            <li><strong>Servidor:</strong> Windows Server 2012 + Terminal Server (ou superior)</li>
                            <li><strong>Alternativa:</strong> Windows Server 2012 + Citrix (ou superior)</li>
                            <li><strong>Instalação local:</strong> Windows 8.1 ou superior</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#128101; eSocial</h4>
                        <p>Para a utilização do eSocial, as configurações citadas no servidor de aplicação já atendem os requisitos para o seu funcionamento, pois a sua instalação deverá ser realizada no mesmo servidor onde está configurado o SankhyaOm.</p>
                        <p>Caso o cliente tenha contratado somente o módulo folha, este documento fica válido para a sua configuração.</p>
                    </div>

                    <div class="req-section">
                        <h4>&#128273; Software para conexão do Service Desk Sankhya</h4>
                        <p>A equipe de Service Desk utiliza para conexão aos clientes os softwares <strong>Anydesk/LogMeIn/TeamViewer</strong>.</p>
                        
                        <h5>Informações de Segurança:</h5>
                        <ul>
                            <li>Não há necessidade de abrir portas extras em firewall corporativo</li>
                            <li>Todas as comunicações usam protocolo padrão da Web (HTTP)</li>
                            <li>Conexão criptografada (SSL de 256 bits)</li>
                            <li><strong>Banda mínima:</strong> 200Kbps por estação</li>
                        </ul>
                    </div>

                    <div class="req-section">
                        <h4>&#9889; Observações Importantes</h4>
                        <ul>
                            <li>&#128272; Servidor de aplicação Wildfly deve ser instalado em máquina separada e independente do servidor de banco de dados (crucial para desempenho)</li>
                            <li>&#128274; Para HTTPS com certificado digital, não utilize o serviço nativo do Wildfly. Recomendamos proxy reverso (Apache/Nginx) em servidor exclusivo</li>
                            <li>&#128190; Separar discos/partições para: diretório de dados, diretório de backups e sistema operacional</li>
                            <li>&#9728; Recomendado hospedagem em CLOUD com players consolidados (Oracle Cloud, AWS, Google Cloud) que garantam SLA e performance adequadas</li>
                            <li>&#128736; NÃO recomendado RAID 5 para nenhum dos servidores (Banco de dados, Aplicação Web ou Windows)</li>
                            <li>&#128273; OBRIGATÓRIO: Alterar senhas das bases (SANKHYA, TESTE, TREINA) após instalação com apoio do profissional Sankhya</li>
                            <li>&#128295; Responsabilidade do cliente: Manutenção periódica do BD (atualização de estatísticas, reorganização de índices, análise de queries). Caso não tenha equipe certificada, contratar empresa certificada</li>
                            <li>&#128190; Responsabilidade do cliente: Gerenciamento e validação dos backups. Rotina implementada é básica, podendo ser alterada</li>
                            <li>&#10060; NÃO criar duas VMs sobre o mesmo disco do servidor físico</li>
                            <li>&#128295; Servidores devem ser dedicados exclusivamente para o sistema</li>
                            <li>&#128273; É necessário acesso irrestrito aos servidores para os analistas da Sankhya</li>
                            <li>&#128221; Responsabilidade do cliente: Instalação do sistema operacional Windows, configuração do Terminal Server ou Citrix e aquisição de licenças, configuração de impressoras e criação de usuários</li>
                            <li>&#128311; Rede: Switch 100/1000</li>
                            <li>&#9997; Cliente deve enviar inventário de estações para avaliação se possuir configurações diferenciadas</li>
                        </ul>
                        
                        <div class="req-alert req-alert-danger">
                            <strong>&#128293; CRÍTICO:</strong> Requer infraestrutura robusta com alta disponibilidade, redundância, monitoramento 24/7 e plano de disaster recovery.
                        </div>
                        
                        <div class="req-alert req-alert-info">
                            <strong>&#128161; Latência para ambientes fora do Brasil:</strong>
                            <ul style="margin-top: 10px; margin-bottom: 0;">
                                <li><strong>Entre BD e Aplicação:</strong> manter tráfego de rede até 0.5 ms</li>
                                <li><strong>Entre usuários e aplicação:</strong> manter tráfego de rede até 40ms</li>
                            </ul>
                        </div>
                        
                        <div class="req-alert req-alert-warning">
                            <strong>&#9888; Nota Final:</strong> Esses requisitos são mínimos e baseados no volume médio de operação obtido no cálculo de transações. Para volumes mais altos (volume de faturamento, itens por nota, movimentos financeiros, etc.) é necessário análise individual para definição da infraestrutura necessária.
                        </div>
                    </div>
                `;
            }
            
            function showRequirementsModal(classification, requirementsHTML) {
                var modal = document.getElementById('requirementsModal');
                var modalTitle = document.getElementById('modalTitle');
                var modalBody = document.getElementById('modalBody');
                
                modalTitle.textContent = 'Requisitos Técnicos Completos - ' + classification;
                modalBody.innerHTML = requirementsHTML;
                modal.style.display = 'block';
            }
            
            function closeRequirementsModal() {
                var modal = document.getElementById('requirementsModal');
                modal.style.display = 'none';
            }
            
            // Close modal when clicking outside
            window.onclick = function(event) {
                var modal = document.getElementById('requirementsModal');
                if (event.target == modal) {
                    modal.style.display = 'none';
                }
            }
        
            // Funções para o popup de integrações
            function openIntegrationPopup() {
                document.getElementById('integrationPopup').style.display = 'flex';
            }
            
            function closeIntegrationPopup() {
                document.getElementById('integrationPopup').style.display = 'none';
            }
            
            function saveIntegrationValue() {
                var value = parseInt(document.getElementById('integrationInput').value) || 0;
                
                // Calcula o score baseado na lógica: SE(Integrações>=7;480;SE(Integrações>=5;380;SE(Integrações>=3;280;SE(Integrações<=2;180))))
                var score = 0;
                if (value >= 7) {
                    score = 480;
                } else if (value >= 5) {
                    score = 380;
                } else if (value >= 3) {
                    score = 280;
                } else {
                    score = 180;
                }
                
                // Atualiza os valores no card
                document.getElementById('integrationMedia').textContent = value;
                document.getElementById('integrationScore').textContent = score;
                document.getElementById('integrationScore').setAttribute('data-score', score);
                
                // Recalcula o score total
                calculateTotalScore();
                
                closeIntegrationPopup();
            }
            
            function calculateTotalScore() {
                var totalScore = 0;
                var scoreElements = document.querySelectorAll('.metric-value[data-score]');
                
                scoreElements.forEach(function(element) {
                    totalScore += parseInt(element.getAttribute('data-score'));
                });
                
                document.getElementById('totalScore').textContent = totalScore;
                
                var classification = '';
                var pdfLink = '';
                
                // Lógica: SE(SCORE TOTAL>=2751;"D";SE(SCORE TOTAL>=1951;"C";SE(SCORE TOTAL>1150;"B";SE(SCORE TOTAL<=1150;"A"))))
                if (totalScore >= 2751) {
                    classification = 'Classificação D';
                    pdfLink = 'https://sankhya.com.br/wp-content/uploads/2025/10/recursoshardware-d.pdf';
                } else if (totalScore >= 1951) {
                    classification = 'Classificação C';
                    pdfLink = 'https://sankhya.com.br/wp-content/uploads/2025/10/recursoshardware-c.pdf';
                } else if (totalScore > 1150) {
                    classification = 'Classificação B';
                    pdfLink = 'https://sankhya.com.br/wp-content/uploads/2025/10/recursoshardware-b.pdf';
                } else {
                    classification = 'Classificação A';
                    pdfLink = 'https://sankhya.com.br/wp-content/uploads/2025/10/recursoshardware-a.pdf';
                }
                
                document.getElementById('classification').textContent = classification;
                
                // Update footer button to open PDF in new tab
                document.getElementById('viewRequirementsBtn').onclick = function() {
                    window.open(pdfLink, '_blank');
                };
            }

            window.addEventListener('DOMContentLoaded', function () {
                // Calculate initial total score and classification
                calculateTotalScore();
                
                // Show footer with button to view requirements
                document.getElementById('footerDocs').style.display = 'block';
            });

            /*---------Responsive-navbar-active-animation-----------*/
            function test() {
                var tabsNewAnim = $('#navbarSupportedContent');
                var selectorNewAnim = $('#navbarSupportedContent').find('li').length;
                var activeItemNewAnim = tabsNewAnim.find('.active');
                var activeWidthNewAnimHeight = activeItemNewAnim.innerHeight();
                var activeWidthNewAnimWidth = activeItemNewAnim.innerWidth();
                var itemPosNewAnimTop = activeItemNewAnim.position();
                var itemPosNewAnimLeft = activeItemNewAnim.position();
                $(".hori-selector").css({
                    "top": itemPosNewAnimTop.top + "px",
                    "left": itemPosNewAnimLeft.left + "px",
                    "height": activeWidthNewAnimHeight + "px",
                    "width": activeWidthNewAnimWidth + "px"
                });

                $("#navbarSupportedContent").on("click", "li", function (e) {
                    $('#navbarSupportedContent ul li').removeClass("active");
                    $(this).addClass('active');
                    var activeWidthNewAnimHeight = $(this).innerHeight();
                    var activeWidthNewAnimWidth = $(this).innerWidth();
                    var itemPosNewAnimTop = $(this).position();
                    var itemPosNewAnimLeft = $(this).position();
                    $(".hori-selector").css({
                        "top": itemPosNewAnimTop.top + "px",
                        "left": itemPosNewAnimLeft.left + "px",
                        "height": activeWidthNewAnimHeight + "px",
                        "width": activeWidthNewAnimWidth + "px"
                    });
                });
            }
            $(document).ready(function () {
                setTimeout(function () { test(); });
            });
            $(window).on('resize', function () {
                setTimeout(function () { test(); }, 500);
            });
            $(".navbar-toggler").click(function () {
                $(".navbar-collapse").slideToggle(300);
                setTimeout(function () { test(); });
            });

            /*--------------add active class-on another-page move----------*/
            jQuery(document).ready(function ($) {
                // Get current path and find target link
                var path = window.location.pathname.split("/").pop();
                
                // Account for home page with empty path
                if (path == '') {
                    path = 'index.html';
                }
                var target = $('#navbarSupportedContent ul li a[href="' + path + '"]');
                
                // Add active class to target link
                target.parent().addClass('active');
            });
        </script>
        <snk:load /> <!-- essa tag deve ficar nesta posição -->
        <script type='text/javascript'>
            function abrirNivel(cod_nivel) {
                openLevel(cod_nivel, []);
            }
        </script>
</head>

    <body>
        <nav id="navbar" class="navbar navbar-expand-custom navbar-mainbg">
            <div class="divInfoParceiro">
                <c:forEach items="${dados_cliente.rows}" var="row">
                    <div class="info-empresa">
                        <span title="Dashboard de Performance">&#128200;&nbsp;<b><c:out value="${row.NOMEPARC}" /></b></span>
                        <c:forEach items="${versao_oracle.rows}" var="oracle">
                            <div class="oracle-info">
                                <span>Oracle <c:out value="${oracle.RELEASE}" /></span>
                                <span class="oracle-status-badge oracle-status-${oracle.STATUS == 'OK' ? 'ok' : 'alert'}">
                                    <c:out value="${oracle.STATUS}" />
                                </span>
                            </div>
                        </c:forEach>
                    </div>
                </c:forEach>
                
                <div class="info-contexto">
                    <c:forEach items="${info_dashboard.rows}" var="info">
                        <div class="info-item">
                            <span>&#128197;</span>
                            <span>Período: <c:out value="${info.MES_INICIO}" /> - <c:out value="${info.MES_FIM}" /></span>
                        </div>
                        <div class="info-item">
                            <span>&#128337;</span>
                            <span>Atualizado: <c:out value="${info.DATA_ATUAL}" /> <c:out value="${info.HORA_ATUAL}" /></span>
                        </div>
                    </c:forEach>
                    <c:forEach items="${usuarios_ativos.rows}" var="user">
                        <div class="info-item">
                            <span>&#128101;</span>
                            <span>Usuários hoje: <c:out value="${user.USUARIOS_ATIVOS_HOJE}" /></span>
                        </div>
                    </c:forEach>
                </div>
            </div>
            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <ul class="navbar-nav ml-auto">
                    <div class="hori-selector">
                        <div id="circuloNavbarEsq" class="left"></div>
                        <div id="circuloNavbarDir" class="right"></div>
                    </div>

                    <li class="nav-item active">
                        <a class="nav-link" href="javascript:abrirNivel('lvl_performance')">
                            &#9889; Performance
                        </a>
                    </li>

                <li class="nav-item">
                    <a class="nav-link" href="javascript:abrirNivel('lvl_parametros');">
                        &#9881; Parâmetros
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="javascript:abrirNivel('lvl_diagnostico');">
                        &#128269; Diagnóstico
                    </a>
                </li>
            </ul>
        </div>
    </nav>        <div class="container">
            <h2>&#9889; Dashboard de Performance - Cálculo de Requisitos</h2>
            
            <div class="performance-grid">
                <div class="performance-card">
                    <div class="card-title">&#128203; MÉDIA DE PEDIDOS DE VENDAS (ÚLTIMOS 3 MESES)</div>
                    <c:forEach items="${media_pedidos.rows}" var="row">
                        <div class="metric-row">
                            <span class="metric-label">Média:</span>
                            <span class="metric-value"><c:out value="${row.MEDIA}" /></span>
                        </div>
                        <div class="metric-row">
                            <span class="metric-label">Score:</span>
                            <span class="metric-value" data-score="${row.SCORE}"><c:out value="${row.SCORE}" /></span>
                        </div>
                    </c:forEach>
                </div>

                <div class="performance-card">
                    <div class="card-title">&#128195; MÉDIA DE NF DE VENDA (ÚLTIMOS 3 MESES)</div>
                    <c:forEach items="${media_nf.rows}" var="row">
                        <div class="metric-row">
                            <span class="metric-label">Média:</span>
                            <span class="metric-value"><c:out value="${row.MEDIA}" /></span>
                        </div>
                        <div class="metric-row">
                            <span class="metric-label">Score:</span>
                            <span class="metric-value" data-score="${row.SCORE}"><c:out value="${row.SCORE}" /></span>
                        </div>
                    </c:forEach>
                </div>

                <div class="performance-card">
                    <div class="card-title">&#128230; MÉDIA DE ITENS POR NOTA (ÚLTIMOS 3 MESES)</div>
                    <c:forEach items="${media_itens.rows}" var="row">
                        <div class="metric-row">
                            <span class="metric-label">Média:</span>
                            <span class="metric-value"><c:out value="${row.MEDIA}" /></span>
                        </div>
                        <div class="metric-row">
                            <span class="metric-label">Score:</span>
                            <span class="metric-value" data-score="${row.SCORE}"><c:out value="${row.SCORE}" /></span>
                        </div>
                    </c:forEach>
                </div>

                <div class="performance-card">
                    <div class="card-title">&#128202; MÉDIA DE MOVIMENTAÇÕES CONTÁBIL (ÚLTIMOS 3 MESES)</div>
                    <c:forEach items="${media_contabil.rows}" var="row">
                        <div class="metric-row">
                            <span class="metric-label">Média:</span>
                            <span class="metric-value"><c:out value="${row.MEDIA}" /></span>
                        </div>
                        <div class="metric-row">
                            <span class="metric-label">Score:</span>
                            <span class="metric-value" data-score="${row.SCORE}"><c:out value="${row.SCORE}" /></span>
                        </div>
                    </c:forEach>
                </div>

                <div class="performance-card">
                    <div class="card-title">&#128176; MÉDIA DE MOVIMENTAÇÕES FINANCEIRAS (ÚLTIMOS 3 MESES)</div>
                    <c:forEach items="${media_financeiro.rows}" var="row">
                        <div class="metric-row">
                            <span class="metric-label">Média:</span>
                            <span class="metric-value"><c:out value="${row.MEDIA}" /></span>
                        </div>
                        <div class="metric-row">
                            <span class="metric-label">Score:</span>
                            <span class="metric-value" data-score="${row.SCORE}"><c:out value="${row.SCORE}" /></span>
                        </div>
                    </c:forEach>
                </div>

                <div class="performance-card">
                    <div class="card-title">&#128218; MÉDIA DE LIVROS FISCAIS (ÚLTIMOS 3 MESES)</div>
                    <c:forEach items="${media_livros.rows}" var="row">
                        <div class="metric-row">
                            <span class="metric-label">Média:</span>
                            <span class="metric-value"><c:out value="${row.MEDIA}" /></span>
                        </div>
                        <div class="metric-row">
                            <span class="metric-label">Score:</span>
                            <span class="metric-value" data-score="${row.SCORE}"><c:out value="${row.SCORE}" /></span>
                        </div>
                    </c:forEach>
                </div>

                <div class="performance-card">
                    <div class="card-title">&#128101; MÉDIA DE LOGINS DE USUÁRIOS (ÚLTIMOS 3 MESES)</div>
                    <c:forEach items="${media_usuarios.rows}" var="row">
                        <div class="metric-row">
                            <span class="metric-label">Média:</span>
                            <span class="metric-value"><c:out value="${row.MEDIA}" /></span>
                        </div>
                        <div class="metric-row">
                            <span class="metric-label">Score:</span>
                            <span class="metric-value" data-score="${row.SCORE}"><c:out value="${row.SCORE}" /></span>
                        </div>
                    </c:forEach>
                </div>

                <div class="performance-card performance-card-clickable" onclick="openIntegrationPopup()">
                    <div class="card-title">&#128279; QUANTIDADE DE INTEGRAÇÕES</div>
                    <div class="metric-row">
                        <span class="metric-label">Quantidade:</span>
                        <span class="metric-value" id="integrationMedia">0</span>
                    </div>
                    <div class="metric-row">
                        <span class="metric-label">Score:</span>
                        <span class="metric-value" data-score="180" id="integrationScore">180</span>
                    </div>
                </div>
            </div>

            <div class="score-summary">
                <h3>&#127942; Score Total do Sistema</h3>
                <div class="total-score" id="totalScore">0</div>
                <div class="classification" id="classification">Calculando...</div>
                <p style="margin-top: 1rem; opacity: 0.8; font-size: 0.9rem;">
                    &#128161; Classificação baseada no volume de movimentações dos últimos 3 meses
                </p>
            </div>

            <!-- Footer com botão para visualizar requisitos -->
            <div class="footer-documentation" id="footerDocs" style="display: none;">
                <div class="requirements-summary">
                    <p>&#128196; Com base na classificação do seu sistema, você pode visualizar os requisitos técnicos completos necessários para garantir a melhor performance.</p>
                    <button class="req-button" id="viewRequirementsBtn">
                        &#128269; Visualizar Requisitos Técnicos Completos
                    </button>
                </div>
            </div>
        </div>

        <!-- Modal de Requisitos -->
        <div id="requirementsModal" class="modal-overlay">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 id="modalTitle">Requisitos Técnicos Completos</h3>
                    <button class="modal-close" onclick="closeRequirementsModal()">&#10005;</button>
                </div>
                <div class="modal-body" id="modalBody">
                    <!-- Requirements content will be populated by JavaScript -->
                </div>
            </div>
        </div>

        <!-- Popup de Integrações -->
        <div id="integrationPopup" class="integration-popup-overlay">
            <div class="integration-popup">
                <h4>&#128279; Quantidade de Integrações</h4>
                <div class="integration-popup-content">
                    <label for="integrationInput">Informe a quantidade de integrações habilitadas no sistema:</label>
                    <input type="number" id="integrationInput" min="0" value="0" placeholder="Digite a quantidade...">
                </div>
                <div class="integration-popup-buttons">
                    <button class="integration-popup-btn integration-popup-btn-save" onclick="saveIntegrationValue()">
                        &#10004; Salvar
                    </button>
                    <button class="integration-popup-btn integration-popup-btn-cancel" onclick="closeIntegrationPopup()">
                        &#10006; Cancelar
                    </button>
                </div>
            </div>
        </div>
    </body>
</html>