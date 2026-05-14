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
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            background: linear-gradient(135deg, #0d47a1 0%, #1565c0 40%, #1976d2 100%);
            min-height: 100vh;
            padding: 24px 16px 48px;
            color: #343a40;
        }

        .tracking-wrapper {
            max-width: 640px;
            margin: 0 auto;
        }

        .page-header {
            text-align: center;
            margin-bottom: 32px;
        }
        .page-header .logo-icon { font-size: 3.5rem; line-height: 1; margin-bottom: 10px; }
        .page-header h1 { font-size: 1.9rem; font-weight: 700; color: #fff; letter-spacing: -.5px; }
        .page-header p  { color: rgba(255,255,255,.75); font-size: .95rem; margin-top: 6px; }

        .search-card {
            background: #fff;
            border-radius: 20px;
            padding: 36px 36px 32px;
            box-shadow: 0 8px 32px rgba(0,0,0,.18);
            margin-bottom: 28px;
        }
        .search-card h2 {
            font-size: .85rem;
            font-weight: 700;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: .6px;
            margin-bottom: 22px;
        }

        .field-wrap { margin-bottom: 20px; }
        .field-wrap label {
            display: block;
            font-size: .78rem;
            font-weight: 700;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: .5px;
            margin-bottom: 7px;
        }
        .field-wrap input {
            width: 100%;
            height: 52px;
            border: 2px solid #e9ecef;
            border-radius: 12px;
            padding: 0 18px;
            font-size: 1.15rem;
            font-weight: 600;
            color: #343a40;
            transition: all .25s ease;
            outline: none;
            letter-spacing: .5px;
        }
        .field-wrap input:focus {
            border-color: #1a73e8;
            box-shadow: 0 0 0 4px rgba(26,115,232,.12);
        }
        .field-wrap input::placeholder { font-weight: 400; color: #adb5bd; font-size: 1rem; }

        .btn-row { display: flex; gap: 12px; }
        .btn-search {
            flex: 1;
            height: 52px;
            background: #1a73e8;
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            transition: all .25s ease;
            letter-spacing: .3px;
        }
        .btn-search:hover {
            background: #0d47a1;
            transform: translateY(-1px);
            box-shadow: 0 4px 14px rgba(26,115,232,.4);
        }
        .btn-search:active { transform: translateY(0); }

        .hint-text {
            text-align: center;
            margin-top: 14px;
            font-size: .8rem;
            color: #adb5bd;
        }

        .welcome-state {
            background: rgba(255,255,255,.12);
            border: 1px solid rgba(255,255,255,.2);
            border-radius: 20px;
            padding: 40px 32px;
            text-align: center;
        }
        .welcome-state .icon { font-size: 4rem; margin-bottom: 16px; }
        .welcome-state h3 { font-size: 1.15rem; font-weight: 700; color: #fff; margin-bottom: 8px; }
        .welcome-state p  { color: rgba(255,255,255,.7); font-size: .9rem; line-height: 1.65; }

        .features {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 12px;
            margin-top: 24px;
        }
        .feature-item {
            background: rgba(255,255,255,.1);
            border-radius: 12px;
            padding: 16px 12px;
            text-align: center;
        }
        .feature-item .fi { font-size: 1.6rem; margin-bottom: 6px; }
        .feature-item p { font-size: .75rem; color: rgba(255,255,255,.75); line-height: 1.4; }

        @media (max-width: 500px) {
            .search-card { padding: 24px 20px 20px; }
            .features { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<div class="tracking-wrapper">

    <div class="page-header">
        <div class="logo-icon">🚚</div>
        <h1>Rastreamento de Entregas</h1>
        <p>Consulta de ocorrências por nota fiscal · AD_OCORRENCIAS</p>
    </div>

    <div class="search-card">
        <h2>🔍 Pesquisar Nota Fiscal</h2>
        <div class="field-wrap">
            <label for="NUMERONOTA">Número da Nota</label>
            <input
                type="text"
                id="NUMERONOTA"
                name="NUMERONOTA"
                placeholder="Ex: 157405"
                autocomplete="off"
                autofocus
                maxlength="50"
            />
        </div>
        <div class="btn-row">
            <button class="btn-search" id="btnRastrear" onclick="rastrear()">
                🔍 Rastrear Entrega
            </button>
        </div>
        <p class="hint-text">Pressione Enter ou clique em Rastrear para consultar</p>
    </div>

    <div class="welcome-state">
        <div class="icon">📦</div>
        <h3>Acompanhe sua entrega em tempo real</h3>
        <p>Digite o número da nota fiscal acima para visualizar o histórico completo de ocorrências e a posição atual da entrega.</p>
        <div class="features">
            <div class="feature-item">
                <div class="fi">📍</div>
                <p>Timeline completa de ocorrências</p>
            </div>
            <div class="feature-item">
                <div class="fi">🕐</div>
                <p>Datas e horários de cada evento</p>
            </div>
            <div class="feature-item">
                <div class="fi">💬</div>
                <p>Observações detalhadas por ocorrência</p>
            </div>
        </div>
    </div>

</div>

<script>
    function rastrear() {
        var num = document.getElementById('NUMERONOTA').value.trim();
        if (!num) {
            document.getElementById('NUMERONOTA').focus();
            document.getElementById('NUMERONOTA').style.borderColor = '#d93025';
            setTimeout(function(){ document.getElementById('NUMERONOTA').style.borderColor = ''; }, 2000);
            return;
        }
        window.location.href = 'rastreamento-resultado.jsp?NUMERONOTA=' + encodeURIComponent(num);
    }

    document.addEventListener('DOMContentLoaded', function () {
        document.getElementById('NUMERONOTA').addEventListener('keydown', function (e) {
            if (e.key === 'Enter') rastrear();
        });
    });
</script>

</body>
</html>
