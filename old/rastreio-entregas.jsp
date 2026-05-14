<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<!DOCTYPE html>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>

<%!
    public String getValor(HttpServletRequest request, String nome) {
        String valor = request.getParameter(nome);
        if (valor == null || valor.trim().isEmpty()) {
            Object attr = request.getAttribute(nome);
            valor = attr != null ? attr.toString() : "";
        }
        return valor != null ? valor.trim() : "";
    }

    public String textoSeguro(String valor) {
        if (valor == null) return "";
        return valor.trim().replaceAll("[^0-9A-Za-z._/-]", "");
    }

    public String dataSegura(String valor) {
        if (valor == null) return "";
        valor = valor.trim();
        return valor.matches("\\d{4}-\\d{2}-\\d{2}") ? valor : "";
    }

    public String sqlSeguro(String valor) {
        if (valor == null) return "";
        return valor.replace("'", "''");
    }

    public String dataBR(String valor) {
        if (valor == null || valor.trim().isEmpty()) return "";
        try {
            String[] partes = valor.substring(0, 10).split("-");
            if (partes.length == 3) {
                return partes[2] + "/" + partes[1] + "/" + partes[0];
            }
        } catch (Exception e) {
        }
        return valor;
    }
%>

<%
    String pNumeroNota = textoSeguro(getValor(request, "NUMERONOTA"));
    String pDataIni = dataSegura(getValor(request, "DATAINI"));
    String pDataFim = dataSegura(getValor(request, "DATAFIM"));

    pageContext.setAttribute("p_numeronota", pNumeroNota);
    pageContext.setAttribute("p_numeronota_sql", sqlSeguro(pNumeroNota));
    pageContext.setAttribute("p_data_ini", pDataIni);
    pageContext.setAttribute("p_data_fim", pDataFim);
    pageContext.setAttribute("p_data_ini_br", dataBR(pDataIni));
    pageContext.setAttribute("p_data_fim_br", dataBR(pDataFim));
%>

<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Rastreamento de Entregas e Ocorr&ecirc;ncias</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <snk:load />

    <snk:query var="info_dashboard">
        SELECT
            TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS DATA_ATUAL,
            TO_CHAR(SYSDATE, 'HH24:MI') AS HORA_ATUAL
        FROM DUAL
    </snk:query>

    <c:if test="${not empty p_numeronota}">
        <snk:query var="resumo_rastreio">
            SELECT
                MAX(OC.NUMERONOTA) AS NUMERONOTA,
                COUNT(1) AS TOTAL_OCORRENCIAS,
                MAX(OC.NUMEROCTE) AS NUMEROCTE,
                MAX(OC.CHAVENOTA) AS CHAVENOTA,
                MAX(OC.CHAVECTE) AS CHAVECTE,
                MAX(OC.UNIDADE) AS UNIDADE,
                MAX(OC.TRANSPORTADORA) AS TRANSPORTADORA,
                MAX(OC.CODIGORASTREIO) AS CODIGORASTREIO,
                MAX(OC.CODIGOOCORRENCIATRANSPORTADORA) AS ULTIMO_CODIGO,
                MAX(OC.NOMEOCORRENCIA) AS ULTIMO_STATUS,
                TO_CHAR(MIN(OC.DATA), 'DD/MM/YYYY HH24:MI') AS PRIMEIRO_EVENTO,
                TO_CHAR(MAX(OC.DATA), 'DD/MM/YYYY HH24:MI') AS ULTIMA_ATUALIZACAO,
                TO_CHAR(MAX(OC.PRAZO), 'DD/MM/YYYY') AS PRAZO,
                TO_CHAR(MAX(OC.DATAPREVISAOENTREGA), 'DD/MM/YYYY') AS DATAPREVISAOENTREGA,
                TO_CHAR(MAX(OC.DATAENTREGA), 'DD/MM/YYYY') AS DATAENTREGA,
                TO_CHAR(MIN(CASE
                    WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) = '00'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%COLETA%'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%INICIADO%'
                    THEN OC.DATA END), 'DD/MM/YYYY') AS DT_INICIO,
                TO_CHAR(MIN(CASE
                    WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) = '52'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%REDESPACH%'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%TRANSITO%'
                    THEN OC.DATA END), 'DD/MM/YYYY') AS DT_TRANSITO,
                TO_CHAR(MIN(CASE
                    WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) = '98'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%DESTINO%'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%FILIAL%'
                    THEN OC.DATA END), 'DD/MM/YYYY') AS DT_DESTINO,
                TO_CHAR(MIN(CASE
                    WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) IN ('01', '001', '1')
                         OR TRIM(OC.CODIGOOCORRENCIA) IN ('01', '001', '1')
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%ENTREG%'
                    THEN OC.DATA END), 'DD/MM/YYYY') AS DT_ENTREGUE,
                MAX(CASE
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
                END) AS PROGRESSO_ORDEM,
                CASE
                    WHEN MAX(CASE
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
                    END) >= 4 THEN 75
                    WHEN MAX(CASE
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
                    END) = 3 THEN 50
                    WHEN MAX(CASE
                        WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) = '52'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%REDESPACH%'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%TRANSITO%' THEN 2
                        WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) = '00'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%COLETA%'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%INICIADO%' THEN 1
                        ELSE 0
                    END) = 2 THEN 25
                    ELSE 0
                END AS PROGRESSO_PERCENTUAL,
                CASE
                    WHEN MAX(CASE
                        WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) IN ('01', '001', '1')
                             OR TRIM(OC.CODIGOOCORRENCIA) IN ('01', '001', '1')
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%ENTREG%' THEN 4
                        ELSE 0
                    END) >= 4 THEN 'ENTREGUE'
                    WHEN SUM(CASE
                        WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) IN ('06', '09', '19', '20', '21', '25', '29', '82', '88')
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%RECUS%'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%DEVOLV%'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%PREJUDIC%'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%DESACORDO%'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%FECHADO%'
                             OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%NAO LOCALIZADO%'
                        THEN 1 ELSE 0
                    END) > 0 THEN 'ATENCAO'
                    WHEN COUNT(1) > 0 THEN 'EM_ANDAMENTO'
                    ELSE 'SEM_DADOS'
                END AS STATUS_GERAL
            FROM AD_OCORRENCIAS OC
            WHERE TRIM(OC.NUMERONOTA) = '${p_numeronota_sql}'
            <c:if test="${not empty p_data_ini}">
                AND OC.DATA >= TO_DATE('${p_data_ini}', 'YYYY-MM-DD')
            </c:if>
            <c:if test="${not empty p_data_fim}">
                AND OC.DATA < TO_DATE('${p_data_fim}', 'YYYY-MM-DD') + 1
            </c:if>
        </snk:query>

        <snk:query var="ocorrencias">
            SELECT
                OC.ID,
                OC.NUMERONOTA,
                OC.NUMEROCTE,
                OC.CHAVENOTA,
                OC.CHAVECTE,
                OC.UNIDADE,
                OC.TRANSPORTADORA,
                OC.CODIGORASTREIO,
                OC.CODIGOOCORRENCIA,
                OC.CODIGOOCORRENCIATRANSPORTADORA,
                NVL(OC.NOMEOCORRENCIA, 'Ocorrencia sem descricao') AS NOMEOCORRENCIA,
                TO_CHAR(OC.DATA, 'DD/MM/YYYY') AS DATA_EVENTO,
                TO_CHAR(OC.DATA, 'HH24:MI') AS HORA_EVENTO,
                TO_CHAR(OC.PRAZO, 'DD/MM/YYYY') AS PRAZO,
                TO_CHAR(OC.DATAPREVISAOENTREGA, 'DD/MM/YYYY') AS DATAPREVISAOENTREGA,
                TO_CHAR(OC.DATAENTREGA, 'DD/MM/YYYY') AS DATAENTREGA,
                CAST(NULL AS VARCHAR2(1000)) AS OBSERVACAO,
                CASE
                    WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) IN ('01', '001', '1')
                         OR TRIM(OC.CODIGOOCORRENCIA) IN ('01', '001', '1')
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%ENTREG%'
                        THEN 'Entregue'
                    WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) = '98'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%DESTINO%'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%FILIAL%'
                        THEN 'Destino'
                    WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) = '52'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%REDESPACH%'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%TRANSITO%'
                        THEN 'Transporte'
                    WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) = '00'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%COLETA%'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%INICIADO%'
                        THEN 'Inicio'
                    ELSE 'Ocorrencia'
                END AS ETAPA_LABEL,
                CASE
                    WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) IN ('06', '09', '19', '20', '21', '25', '29', '82', '88')
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%RECUS%'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%DEVOLV%'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%PREJUDIC%'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%DESACORDO%'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%FECHADO%'
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%NAO LOCALIZADO%'
                        THEN 'alerta'
                    WHEN TRIM(OC.CODIGOOCORRENCIATRANSPORTADORA) IN ('01', '001', '1')
                         OR TRIM(OC.CODIGOOCORRENCIA) IN ('01', '001', '1')
                         OR UPPER(NVL(OC.NOMEOCORRENCIA, ' ')) LIKE '%ENTREG%'
                        THEN 'sucesso'
                    ELSE 'info'
                END AS CLASSE_CSS
            FROM AD_OCORRENCIAS OC
            WHERE TRIM(OC.NUMERONOTA) = '${p_numeronota_sql}'
            <c:if test="${not empty p_data_ini}">
                AND OC.DATA >= TO_DATE('${p_data_ini}', 'YYYY-MM-DD')
            </c:if>
            <c:if test="${not empty p_data_fim}">
                AND OC.DATA < TO_DATE('${p_data_fim}', 'YYYY-MM-DD') + 1
            </c:if>
            ORDER BY OC.DATA ASC, OC.ID ASC
        </snk:query>
    </c:if>

    <style>
        :root {
            --ml-yellow: #fff159;
            --ml-blue: #3483fa;
            --ml-green: #00a650;
            --ml-text: #333333;
            --ml-muted: #666666;
            --ml-border: #e6e6e6;
            --ml-bg: #f5f5f5;
            --alert: #f5a623;
            --danger-soft: #fff4e5;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: var(--ml-bg);
            color: var(--ml-text);
            font-family: Arial, Helvetica, sans-serif;
        }

        .topbar {
            background: var(--ml-yellow);
            border-bottom: 1px solid rgba(0, 0, 0, 0.08);
            padding: 14px 18px 18px;
        }

        .topbar-inner {
            width: min(1180px, 100%);
            margin: 0 auto;
        }

        .brand-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 12px;
        }

        .brand-title {
            font-size: 22px;
            font-weight: 700;
            line-height: 1.2;
        }

        .updated-at {
            color: rgba(51, 51, 51, 0.78);
            font-size: 13px;
            white-space: nowrap;
        }

        .filter-form {
            display: grid;
            grid-template-columns: minmax(220px, 1fr) 170px 170px auto;
            gap: 10px;
            align-items: end;
        }

        .field-label {
            display: block;
            color: rgba(51, 51, 51, 0.78);
            font-size: 12px;
            font-weight: 700;
            margin-bottom: 4px;
        }

        .form-control,
        .btn-search {
            border-radius: 4px;
            min-height: 42px;
        }

        .form-control {
            border: 1px solid rgba(0, 0, 0, 0.12);
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.10);
        }

        .btn-search {
            border: 0;
            background: var(--ml-blue);
            color: #fff;
            font-weight: 700;
            padding: 0 18px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            white-space: nowrap;
        }

        .page {
            width: min(1180px, calc(100% - 32px));
            margin: 22px auto 36px;
        }

        .tracking-panel {
            background: #fff;
            border: 1px solid var(--ml-border);
            border-radius: 6px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.06);
            overflow: hidden;
        }

        .panel-head {
            padding: 22px 24px;
            border-bottom: 1px solid var(--ml-border);
            display: grid;
            grid-template-columns: 1fr auto;
            gap: 18px;
            align-items: start;
        }

        .panel-title {
            font-size: 24px;
            font-weight: 600;
            margin: 0 0 8px;
        }

        .meta-line {
            color: var(--ml-muted);
            font-size: 14px;
            line-height: 1.7;
        }

        .status-pill {
            border-radius: 999px;
            padding: 8px 12px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0;
        }

        .status-entregue {
            background: #e9f8f1;
            color: #007d3c;
        }

        .status-andamento {
            background: #e8f1ff;
            color: #1f66c5;
        }

        .status-atencao {
            background: var(--danger-soft);
            color: #9b5b00;
        }

        .summary-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            border-bottom: 1px solid var(--ml-border);
        }

        .summary-item {
            padding: 16px 20px;
            border-right: 1px solid var(--ml-border);
        }

        .summary-item:last-child {
            border-right: 0;
        }

        .summary-label {
            color: var(--ml-muted);
            font-size: 12px;
            font-weight: 700;
            margin-bottom: 5px;
            text-transform: uppercase;
        }

        .summary-value {
            font-size: 16px;
            font-weight: 600;
            min-height: 24px;
            overflow-wrap: anywhere;
        }

        .timeline-wrap {
            padding: 34px 28px 30px;
            border-bottom: 1px solid var(--ml-border);
        }

        .timeline {
            position: relative;
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 0;
            padding-top: 8px;
        }

        .timeline::before {
            content: "";
            position: absolute;
            top: 31px;
            left: 12.5%;
            right: 12.5%;
            height: 4px;
            background: #e5e5e5;
            border-radius: 99px;
        }

        .timeline-progress {
            position: absolute;
            top: 31px;
            left: 12.5%;
            height: 4px;
            width: 0;
            max-width: 75%;
            background: var(--ml-green);
            border-radius: 99px;
            transition: width .35s ease;
        }

        .timeline-step {
            position: relative;
            z-index: 1;
            text-align: center;
            min-width: 0;
        }

        .step-icon {
            width: 50px;
            height: 50px;
            margin: 0 auto 12px;
            border-radius: 50%;
            border: 4px solid #d8d8d8;
            background: #fff;
            color: #999;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        .timeline-step.active .step-icon {
            border-color: var(--ml-green);
            color: var(--ml-green);
            box-shadow: 0 0 0 5px rgba(0, 166, 80, 0.10);
        }

        .step-title {
            font-size: 14px;
            font-weight: 700;
            line-height: 1.25;
        }

        .step-date {
            min-height: 18px;
            margin-top: 5px;
            color: var(--ml-muted);
            font-size: 12px;
        }

        .history {
            padding: 24px;
        }

        .section-title {
            font-size: 19px;
            font-weight: 600;
            margin: 0 0 18px;
        }

        .event-list {
            display: grid;
            gap: 0;
        }

        .event-item {
            display: grid;
            grid-template-columns: 110px 24px 1fr;
            gap: 14px;
            padding: 0 0 22px;
            position: relative;
        }

        .event-item::before {
            content: "";
            position: absolute;
            left: 121px;
            top: 22px;
            bottom: 0;
            width: 2px;
            background: #ededed;
        }

        .event-item:last-child {
            padding-bottom: 0;
        }

        .event-item:last-child::before {
            display: none;
        }

        .event-time {
            color: var(--ml-muted);
            font-size: 13px;
            line-height: 1.4;
            text-align: right;
        }

        .event-dot {
            width: 14px;
            height: 14px;
            border-radius: 50%;
            margin-top: 3px;
            background: var(--ml-blue);
            border: 3px solid #e8f1ff;
            z-index: 1;
        }

        .event-alerta .event-dot {
            background: var(--alert);
            border-color: #fff3d8;
        }

        .event-sucesso .event-dot {
            background: var(--ml-green);
            border-color: #e9f8f1;
        }

        .event-content {
            min-width: 0;
        }

        .event-title-row {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 6px;
        }

        .event-title {
            font-weight: 700;
            line-height: 1.35;
        }

        .event-chip {
            border-radius: 999px;
            background: #f1f3f5;
            color: #4f5b67;
            font-size: 12px;
            padding: 4px 8px;
            line-height: 1;
            font-weight: 700;
        }

        .event-chip.alerta {
            background: var(--danger-soft);
            color: #9b5b00;
        }

        .event-chip.sucesso {
            background: #e9f8f1;
            color: #007d3c;
        }

        .event-meta {
            color: var(--ml-muted);
            display: flex;
            flex-wrap: wrap;
            gap: 8px 18px;
            font-size: 13px;
            line-height: 1.45;
        }

        .event-obs {
            margin-top: 8px;
            color: #555;
            background: #f8f9fa;
            border-left: 3px solid #d8dee4;
            border-radius: 4px;
            padding: 8px 10px;
            font-size: 13px;
            overflow-wrap: anywhere;
        }

        .empty-state {
            padding: 54px 24px;
            text-align: center;
            color: var(--ml-muted);
        }

        .empty-state .bi {
            display: block;
            color: #c9c9c9;
            font-size: 48px;
            margin-bottom: 16px;
        }

        .empty-title {
            color: var(--ml-text);
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 6px;
        }

        .empty-copy {
            margin: 0;
            font-size: 14px;
        }

        @media (max-width: 900px) {
            .filter-form {
                grid-template-columns: 1fr 1fr;
            }

            .btn-search {
                width: 100%;
            }

            .panel-head {
                grid-template-columns: 1fr;
            }

            .summary-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .summary-item:nth-child(2) {
                border-right: 0;
            }

            .summary-item:nth-child(-n+2) {
                border-bottom: 1px solid var(--ml-border);
            }
        }

        @media (max-width: 620px) {
            .brand-row {
                align-items: flex-start;
                flex-direction: column;
            }

            .updated-at {
                white-space: normal;
            }

            .filter-form {
                grid-template-columns: 1fr;
            }

            .page {
                width: min(100% - 20px, 1180px);
                margin-top: 14px;
            }

            .panel-head,
            .history,
            .timeline-wrap {
                padding-left: 16px;
                padding-right: 16px;
            }

            .summary-grid {
                grid-template-columns: 1fr;
            }

            .summary-item {
                border-right: 0;
                border-bottom: 1px solid var(--ml-border);
            }

            .summary-item:last-child {
                border-bottom: 0;
            }

            .timeline {
                grid-template-columns: 1fr;
                gap: 18px;
            }

            .timeline::before,
            .timeline-progress {
                display: none;
            }

            .timeline-step {
                display: grid;
                grid-template-columns: 50px 1fr;
                gap: 12px;
                text-align: left;
                align-items: center;
            }

            .step-icon {
                margin: 0;
            }

            .event-item {
                grid-template-columns: 1fr;
                gap: 8px;
                border-bottom: 1px solid var(--ml-border);
                padding-bottom: 18px;
                margin-bottom: 18px;
            }

            .event-item::before,
            .event-dot {
                display: none;
            }

            .event-time {
                text-align: left;
                font-weight: 700;
            }
        }
    </style>
</head>

<body>
    <header class="topbar">
        <div class="topbar-inner">
            <div class="brand-row">
                <div class="brand-title">Rastreamento de Entregas e Ocorr&ecirc;ncias</div>
                <c:forEach items="${info_dashboard.rows}" var="info">
                    <div class="updated-at">
                        Atualizado em <c:out value="${info.DATA_ATUAL}" /> &agrave;s <c:out value="${info.HORA_ATUAL}" />
                    </div>
                </c:forEach>
            </div>

            <form class="filter-form" method="get" action="">
                <label>
                    <span class="field-label">N&uacute;mero da nota</span>
                    <input class="form-control" type="text" name="NUMERONOTA" value="${p_numeronota}" placeholder="Ex.: 157405" required>
                </label>

                <label>
                    <span class="field-label">Data inicial</span>
                    <input class="form-control" type="date" name="DATAINI" value="${p_data_ini}">
                </label>

                <label>
                    <span class="field-label">Data final</span>
                    <input class="form-control" type="date" name="DATAFIM" value="${p_data_fim}">
                </label>

                <button class="btn-search" type="submit">
                    <i class="bi bi-search" aria-hidden="true"></i>
                    Buscar
                </button>
            </form>
        </div>
    </header>

    <main class="page">
        <c:choose>
            <c:when test="${empty p_numeronota}">
                <section class="tracking-panel">
                    <div class="empty-state">
                        <i class="bi bi-box-seam" aria-hidden="true"></i>
                        <div class="empty-title">Informe uma nota fiscal para consultar a entrega</div>
                        <p class="empty-copy">Use o n&uacute;mero da nota e, quando necess&aacute;rio, limite a busca por data inicial e final.</p>
                    </div>
                </section>
            </c:when>

            <c:when test="${empty ocorrencias.rows}">
                <section class="tracking-panel">
                    <div class="empty-state">
                        <i class="bi bi-search" aria-hidden="true"></i>
                        <div class="empty-title">Nenhuma ocorr&ecirc;ncia encontrada</div>
                        <p class="empty-copy">
                            Nota <strong><c:out value="${p_numeronota}" /></strong>
                            <c:if test="${not empty p_data_ini_br or not empty p_data_fim_br}">
                                no per&iacute;odo informado
                            </c:if>.
                        </p>
                    </div>
                </section>
            </c:when>

            <c:otherwise>
                <c:forEach items="${resumo_rastreio.rows}" var="resumo">
                    <c:set var="classe_inicio" value="" />
                    <c:set var="classe_transito" value="" />
                    <c:set var="classe_destino" value="" />
                    <c:set var="classe_entregue" value="" />
                    <c:if test="${resumo.PROGRESSO_ORDEM ge 1}"><c:set var="classe_inicio" value="active" /></c:if>
                    <c:if test="${resumo.PROGRESSO_ORDEM ge 2}"><c:set var="classe_transito" value="active" /></c:if>
                    <c:if test="${resumo.PROGRESSO_ORDEM ge 3}"><c:set var="classe_destino" value="active" /></c:if>
                    <c:if test="${resumo.PROGRESSO_ORDEM ge 4}"><c:set var="classe_entregue" value="active" /></c:if>

                    <section class="tracking-panel">
                        <div class="panel-head">
                            <div>
                                <h1 class="panel-title">Acompanhe a sua entrega</h1>
                                <div class="meta-line">
                                    Nota Fiscal: <strong><c:out value="${resumo.NUMERONOTA}" /></strong>
                                    <c:if test="${not empty resumo.CODIGORASTREIO and resumo.CODIGORASTREIO ne '-'}">
                                        &nbsp;|&nbsp; Rastreio: <strong><c:out value="${resumo.CODIGORASTREIO}" /></strong>
                                    </c:if>
                                    <c:if test="${not empty resumo.TRANSPORTADORA}">
                                        &nbsp;|&nbsp; Transportadora: <strong><c:out value="${resumo.TRANSPORTADORA}" /></strong>
                                    </c:if>
                                </div>
                                <div class="meta-line">
                                    &Uacute;ltimo status: <strong><c:out value="${resumo.ULTIMO_STATUS}" /></strong>
                                    <c:if test="${not empty resumo.ULTIMA_ATUALIZACAO}">
                                        em <strong><c:out value="${resumo.ULTIMA_ATUALIZACAO}" /></strong>
                                    </c:if>
                                </div>
                            </div>

                            <c:choose>
                                <c:when test="${resumo.STATUS_GERAL eq 'ENTREGUE'}">
                                    <span class="status-pill status-entregue">Entregue</span>
                                </c:when>
                                <c:when test="${resumo.STATUS_GERAL eq 'ATENCAO'}">
                                    <span class="status-pill status-atencao">Aten&ccedil;&atilde;o</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-pill status-andamento">Em andamento</span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="summary-grid">
                            <div class="summary-item">
                                <div class="summary-label">Ocorr&ecirc;ncias</div>
                                <div class="summary-value"><c:out value="${resumo.TOTAL_OCORRENCIAS}" /></div>
                            </div>
                            <div class="summary-item">
                                <div class="summary-label">Primeiro evento</div>
                                <div class="summary-value"><c:out value="${resumo.PRIMEIRO_EVENTO}" /></div>
                            </div>
                            <div class="summary-item">
                                <div class="summary-label">Previs&atilde;o</div>
                                <div class="summary-value">
                                    <c:choose>
                                        <c:when test="${not empty resumo.DATAPREVISAOENTREGA}">
                                            <c:out value="${resumo.DATAPREVISAOENTREGA}" />
                                        </c:when>
                                        <c:when test="${not empty resumo.PRAZO}">
                                            <c:out value="${resumo.PRAZO}" />
                                        </c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="summary-item">
                                <div class="summary-label">CT-e</div>
                                <div class="summary-value">
                                    <c:choose>
                                        <c:when test="${not empty resumo.NUMEROCTE and resumo.NUMEROCTE ne '-'}">
                                            <c:out value="${resumo.NUMEROCTE}" />
                                        </c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <div class="timeline-wrap">
                            <div class="timeline" aria-label="Linha do tempo da entrega">
                                <div class="timeline-progress" style="width: ${resumo.PROGRESSO_PERCENTUAL}%"></div>

                                <div class="timeline-step ${classe_inicio}">
                                    <div class="step-icon"><i class="bi bi-box2" aria-hidden="true"></i></div>
                                    <div>
                                        <div class="step-title">Transporte iniciado</div>
                                        <div class="step-date"><c:out value="${resumo.DT_INICIO}" /></div>
                                    </div>
                                </div>

                                <div class="timeline-step ${classe_transito}">
                                    <div class="step-icon"><i class="bi bi-truck" aria-hidden="true"></i></div>
                                    <div>
                                        <div class="step-title">Em transporte</div>
                                        <div class="step-date"><c:out value="${resumo.DT_TRANSITO}" /></div>
                                    </div>
                                </div>

                                <div class="timeline-step ${classe_destino}">
                                    <div class="step-icon"><i class="bi bi-geo-alt" aria-hidden="true"></i></div>
                                    <div>
                                        <div class="step-title">No destino</div>
                                        <div class="step-date"><c:out value="${resumo.DT_DESTINO}" /></div>
                                    </div>
                                </div>

                                <div class="timeline-step ${classe_entregue}">
                                    <div class="step-icon"><i class="bi bi-house-check" aria-hidden="true"></i></div>
                                    <div>
                                        <div class="step-title">Entregue</div>
                                        <div class="step-date">
                                            <c:choose>
                                                <c:when test="${not empty resumo.DT_ENTREGUE}">
                                                    <c:out value="${resumo.DT_ENTREGUE}" />
                                                </c:when>
                                                <c:otherwise><c:out value="${resumo.DATAENTREGA}" /></c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="history">
                            <h2 class="section-title">Hist&oacute;rico de atualiza&ccedil;&otilde;es</h2>

                            <div class="event-list">
                                <c:forEach items="${ocorrencias.rows}" var="oc">
                                    <article class="event-item event-${oc.CLASSE_CSS}">
                                        <div class="event-time">
                                            <c:out value="${oc.DATA_EVENTO}" /><br>
                                            <c:out value="${oc.HORA_EVENTO}" />
                                        </div>

                                        <div class="event-dot" aria-hidden="true"></div>

                                        <div class="event-content">
                                            <div class="event-title-row">
                                                <div class="event-title"><c:out value="${oc.NOMEOCORRENCIA}" /></div>
                                                <span class="event-chip ${oc.CLASSE_CSS}">
                                                    <c:out value="${oc.ETAPA_LABEL}" />
                                                </span>
                                            </div>

                                            <div class="event-meta">
                                                <c:if test="${not empty oc.CODIGOOCORRENCIATRANSPORTADORA}">
                                                    <span>C&oacute;d. transp.: <strong><c:out value="${oc.CODIGOOCORRENCIATRANSPORTADORA}" /></strong></span>
                                                </c:if>
                                                <c:if test="${not empty oc.UNIDADE}">
                                                    <span>Unidade: <strong><c:out value="${oc.UNIDADE}" /></strong></span>
                                                </c:if>
                                                <c:if test="${not empty oc.NUMEROCTE and oc.NUMEROCTE ne '-'}">
                                                    <span>CT-e: <strong><c:out value="${oc.NUMEROCTE}" /></strong></span>
                                                </c:if>
                                            </div>

                                            <c:if test="${not empty oc.OBSERVACAO}">
                                                <div class="event-obs"><c:out value="${oc.OBSERVACAO}" /></div>
                                            </c:if>
                                        </div>
                                    </article>
                                </c:forEach>
                            </div>
                        </div>
                    </section>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
