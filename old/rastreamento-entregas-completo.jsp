<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         isELIgnored="false" %>

<%@ page import="java.sql.*" %>
<%@ page import="com.sankhya.util.JdbcUtils" %>

<%

String api = request.getParameter("api");

if("S".equals(api)) {

    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    String numeroNota = request.getParameter("numeronota");
    String dataIni = request.getParameter("dataini");
    String dataFim = request.getParameter("datafim");

    Connection conn = null;
    PreparedStatement pst = null;
    ResultSet rs = null;

    StringBuilder json = new StringBuilder();

    json.append("[");

    try {

        conn = JdbcUtils.getConnection();

        String sql =
            " SELECT " +
            "     NUMERONOTA, " +
            "     SERIENOTA, " +
            "     TRANSPORTADORA, " +
            "     NOMEOCORRENCIA, " +
            "     CODIGOOCORRENCIATRANSPORTADORA, " +
            "     TO_CHAR(DATA, 'DD/MM/YYYY HH24:MI') DATAFMT, " +
            "     TO_CHAR(DATAPREVISAOENTREGA, 'DD/MM/YYYY') PREVISAO, " +
            "     TO_CHAR(DATAENTREGA, 'DD/MM/YYYY') ENTREGA, " +
            "     OBSERVACAO " +
            " FROM AD_OCORRENCIAS " +
            " WHERE 1 = 1 ";

        if(numeroNota != null && !numeroNota.trim().isEmpty()) {
            sql += " AND NUMERONOTA = ? ";
        }

        if(dataIni != null && !dataIni.trim().isEmpty()) {
            sql += " AND TRUNC(DATA) >= TO_DATE(?, 'YYYY-MM-DD') ";
        }

        if(dataFim != null && !dataFim.trim().isEmpty()) {
            sql += " AND TRUNC(DATA) <= TO_DATE(?, 'YYYY-MM-DD') ";
        }

        sql += " ORDER BY NUMERONOTA, DATA ASC ";

        pst = conn.prepareStatement(sql);

        int idx = 1;

        if(numeroNota != null && !numeroNota.trim().isEmpty()) {
            pst.setString(idx++, numeroNota);
        }

        if(dataIni != null && !dataIni.trim().isEmpty()) {
            pst.setString(idx++, dataIni);
        }

        if(dataFim != null && !dataFim.trim().isEmpty()) {
            pst.setString(idx++, dataFim);
        }

        rs = pst.executeQuery();

        boolean first = true;

        while(rs.next()) {

            if(!first) {
                json.append(",");
            }

            json.append("{");

            json.append("\"NUMERONOTA\":\"")
                .append(rs.getString("NUMERONOTA"))
                .append("\",");

            json.append("\"SERIENOTA\":\"")
                .append(rs.getString("SERIENOTA"))
                .append("\",");

            json.append("\"TRANSPORTADORA\":\"")
                .append(rs.getString("TRANSPORTADORA"))
                .append("\",");

            json.append("\"NOMEOCORRENCIA\":\"")
                .append(rs.getString("NOMEOCORRENCIA"))
                .append("\",");

            json.append("\"CODIGO\":\"")
                .append(rs.getString("CODIGOOCORRENCIATRANSPORTADORA"))
                .append("\",");

            json.append("\"DATA\":\"")
                .append(rs.getString("DATAFMT"))
                .append("\",");

            json.append("\"PREVISAO\":\"")
                .append(rs.getString("PREVISAO"))
                .append("\",");

            json.append("\"ENTREGA\":\"")
                .append(rs.getString("ENTREGA"))
                .append("\"");

            json.append("}");

            first = false;
        }

        json.append("]");

        out.clear();
        out.print(json.toString());

    } finally {

        if(rs != null) rs.close();
        if(pst != null) pst.close();
        if(conn != null) conn.close();
    }

    return;
}

%>

<!DOCTYPE html>
<html lang="pt-br">

<head>

<meta charset="UTF-8">

<title>Rastreamento de Entregas</title>

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<style>

body{
    background:#121212;
    color:#FFF;
    padding:20px;
    font-family:Arial;
}

.main-card{
    background:#232323;
    border-radius:16px;
    overflow:hidden;
}

.header{
    background:#1976d2;
    padding:20px;
}

.filter-area{
    padding:20px;
}

.form-control{
    background:#2d2d2d;
    border:1px solid #444;
    color:#FFF;
}

.form-control:focus{
    background:#2d2d2d;
    color:#FFF;
}

.result-card{
    background:#2b2b2b;
    border-radius:14px;
    margin-bottom:24px;
    overflow:hidden;
}

.result-header{
    background:#1976d2;
    padding:16px;
    display:flex;
    justify-content:space-between;
}

.timeline{
    padding:24px;
}

.timeline-item{
    border-left:4px solid #1976d2;
    padding-left:20px;
    margin-bottom:24px;
}

.timeline-title{
    font-size:20px;
    font-weight:bold;
}

.timeline-date{
    color:#CCC;
}

</style>

</head>

<body>

<div class="main-card">

    <div class="header">
        <h2>🚚 Rastreamento de Entregas</h2>
    </div>

    <div class="filter-area">

        <div class="row g-3">

            <div class="col-md-4">
                <label>Número Nota</label>
                <input type="text" id="numeroNota" class="form-control">
            </div>

            <div class="col-md-3">
                <label>Data Início</label>
                <input type="date" id="dataIni" class="form-control">
            </div>

            <div class="col-md-3">
                <label>Data Fim</label>
                <input type="date" id="dataFim" class="form-control">
            </div>

            <div class="col-md-2 d-flex align-items-end">
                <button class="btn btn-primary w-100" onclick="pesquisar()">
                    Pesquisar
                </button>
            </div>

        </div>

    </div>

    <div class="p-4" id="resultado"></div>

</div>

<script>

async function pesquisar(){

    const numeroNota = $('#numeroNota').val();
    const dataIni = $('#dataIni').val();
    const dataFim = $('#dataFim').val();

    const response = await $.ajax({
        url: window.location.pathname,
        method:'GET',
        dataType:'json',
        data:{
            api:'S',
            numeronota:numeroNota,
            dataini:dataIni,
            datafim:dataFim
        }
    });

    renderizar(response);
}

function agrupar(lista){

    return lista.reduce((acc,item)=>{

        if(!acc[item.NUMERONOTA]){
            acc[item.NUMERONOTA] = [];
        }

        acc[item.NUMERONOTA].push(item);

        return acc;

    }, {});
}

function renderizar(lista){

    const agrupado = agrupar(lista);

    let html = '';

    Object.keys(agrupado).forEach(nota=>{

        const ocorrencias = agrupado[nota];

        html += `
            <div class="result-card">

                <div class="result-header">
                    <div>
                        <h4>NF ${nota}</h4>
                        <small>${ocorrencias.length} ocorrência(s)</small>
                    </div>

                    <div>
                        🚚 EM TRÂNSITO
                    </div>
                </div>

                <div class="timeline">
        `;

        ocorrencias.forEach(item=>{

            html += `
                <div class="timeline-item">

                    <div class="timeline-title">
                        ${item.NOMEOCORRENCIA}
                    </div>

                    <div class="timeline-date">
                        ${item.DATA}
                    </div>

                    <div>
                        Transportadora: ${item.TRANSPORTADORA}
                    </div>

                    <div>
                        Código: ${item.CODIGO}
                    </div>

                </div>
            `;
        });

        html += `
                </div>
            </div>
        `;
    });

    $('#resultado').html(html);
}

</script>

</body>

</html>
