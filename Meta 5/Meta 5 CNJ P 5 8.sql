﻿
SELECT  
saida.TXT_unidade,
saida.mes,
count(DISTINCT(saida.PROCESSO_NUMERO_UNICO)) AS quantidade
FROM (SELECT  
		processo.NUM_REMESSA,
		processo.NUM_LOTE,
		processo.NUM_ITEM,
		processo.NUM_ORGAO_ESTATISTICA,
		--processo.DTA_EVENTO_FINAL - processo.DTA_EVENTO_INICIAL AS NUM_DIAS,
        processo.NUM_INTERNO_PROCESSO,
        to_date(to_char(processo.DTA_EVENTO_FINAL,'DD/MM/YYYY'),'DD/MM/YYYY') - to_date(to_char(processo.DTA_EVENTO_INICIAL, 'DD/MM/YYYY'), 'DD/MM/YYYY') AS  NUM_DIAS,
		LPAD(proc.NUM_PROC,7,0)||'-'||LPAD(proc.NUM_DIG_PROC,2,0)||'.'||LPAD(proc.ANO_PROC,4,0)||'.'|| proc.NUM_JUSTICA || '.' || LPAD(proc.NUM_TRIBUNAL,2,0) ||'.'||LPAD(proc.NUM_VARA,4,0) AS PROCESSO_NUMERO_UNICO,		
		classe.NUM_CLASSE,
		classe.NUM_CLASSE_CNJ,
		classe.TXT_SIGLA_CLASSE,
		classe.NOM_CLASSE,
        vt.TXT_UNIDADE,
		processo.DTA_OCORRENCIA,    
        proc.ANO_PROC,
        2018-proc.ANO_PROC AS Idade_do_processo_em_anos,
        extract(MONTH from remessa.DTA_INICIO_PERIODO_REFERENCIA) AS mes
FROM eg.egt_info_processo processo
LEFT JOIN eg.EGT_PROCESSO proc ON (	proc.NUM_TRIBUNAL = processo.NUM_TRIBUNAL 
							AND proc.NUM_ORGAO_ESTATISTICA = processo.NUM_ORGAO_ESTATISTICA 
							AND proc.NUM_INTERNO_PROCESSO = processo.NUM_INTERNO_PROCESSO)
LEFT JOIN eg.EGT_ESTRUTURA_ITEM estrutura_item ON estrutura_item.NUM_ITEM = processo.NUM_ITEM
LEFT JOIN eg.EGT_ORGAO_ESTATISTICA orgao ON (orgao.NUM_TRIBUNAL = processo.NUM_TRIBUNAL AND orgao.NUM_ORGAO_ESTATISTICA = processo.NUM_ORGAO_ESTATISTICA)
LEFT JOIN eg.EGT_CLASSE_PROCESSUAL classe ON (classe.NUM_CLASSE = processo.NUM_CLASSE)
LEFT JOIN eg.EGT_MUNICIPIO municipio ON (municipio.COD_MUNICIPIO = processo.COD_MUNICIPIO_ORIGEM)
LEFT JOIN (SELECT 
	orgao.NUM_ORGAO_ESTATISTICA,
    LPAD(vara.NUM_VARA,2,0)||'ª VT DE '||RPAD(vara.txt_cidade,25) AS TXT_UNIDADE
FROM eg.EGT_ORGAO_ESTATISTICA orgao
LEFT JOIN eg.EGT_VARA vara ON (vara.NUM_TRIBUNAL = orgao.NUM_TRIBUNAL AND vara.NUM_INTERNO_VARA = orgao.NUM_INTERNO_VARA)
WHERE orgao.IND_EXCLUSAO = 'N'
	AND vara.COD_CLASSIFICACAO_VARA = 'V'
ORDER BY NUM_ORGAO_ESTATISTICA) vt ON vt.NUM_ORGAO_ESTATISTICA = processo.num_orgao_estatistica
INNER JOIN (SELECT rem.NUM_REMESSA, max(rem.NUM_LOTE) NUM_LOTE
              FROM eg.EGT_REMESSA_LOTE rem
        WHERE rem.DTA_INICIO_PERIODO_REFERENCIA BETWEEN 
            TO_DATE('01/01/2019','dd/mm/yy') AND 
            TO_DATE('31/12/2019','dd/mm/yy') 
            AND rem.COD_SITUACAO_REMESSA = 'G'               
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)
WHERE
	processo.NUM_TRIBUNAL = 7
        -- G - Gerada
	--AND REMESSA.COD_SITUACAO_REMESSA = 'G'
	-- M - Mensal
	AND REMESSA.COD_PERIODICIDADE = 'M'
	-- Se desejar, faça filtro por orgaos estatistica aqui
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	-- Filtro por remessa e lote (se desejar, filtre por mes da remessa de maneira similar ao SQL que recupera remessa e lote a partir do mes)
	-- Apenas itens com detalhes de processos 
    --AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
	-- Filtro por item - Exemplo com indicadores 90074 e 92198
    AND classe.NUM_CLASSE_CNJ IN (1116)
	AND processo.NUM_ITEM IN (392,90392,98,90098)
    AND processo.NUM_INTERNO_PROCESSO IN (SELECT  
		processo.NUM_INTERNO_PROCESSO
FROM eg.egt_info_processo processo
LEFT JOIN eg.EGT_PROCESSO proc ON (	proc.NUM_TRIBUNAL = processo.NUM_TRIBUNAL 
							AND proc.NUM_ORGAO_ESTATISTICA = processo.NUM_ORGAO_ESTATISTICA 
							AND proc.NUM_INTERNO_PROCESSO = processo.NUM_INTERNO_PROCESSO)
LEFT JOIN eg.EGT_ESTRUTURA_ITEM estrutura_item ON estrutura_item.NUM_ITEM = processo.NUM_ITEM
LEFT JOIN eg.EGT_ORGAO_ESTATISTICA orgao ON (orgao.NUM_TRIBUNAL = processo.NUM_TRIBUNAL AND orgao.NUM_ORGAO_ESTATISTICA = processo.NUM_ORGAO_ESTATISTICA)
LEFT JOIN eg.EGT_CLASSE_PROCESSUAL classe ON (classe.NUM_CLASSE = processo.NUM_CLASSE)
LEFT JOIN eg.EGT_MUNICIPIO municipio ON (municipio.COD_MUNICIPIO = processo.COD_MUNICIPIO_ORIGEM)
LEFT JOIN (SELECT 
	orgao.NUM_ORGAO_ESTATISTICA,
    LPAD(vara.NUM_VARA,2,0)||'ª VT DE '||RPAD(vara.txt_cidade,25) AS TXT_UNIDADE
FROM eg.EGT_ORGAO_ESTATISTICA orgao
LEFT JOIN eg.EGT_VARA vara ON (vara.NUM_TRIBUNAL = orgao.NUM_TRIBUNAL AND vara.NUM_INTERNO_VARA = orgao.NUM_INTERNO_VARA)
WHERE orgao.IND_EXCLUSAO = 'N'
	AND vara.COD_CLASSIFICACAO_VARA = 'V'
ORDER BY NUM_ORGAO_ESTATISTICA) vt ON vt.NUM_ORGAO_ESTATISTICA = processo.num_orgao_estatistica
INNER JOIN (SELECT rem.NUM_REMESSA, max(rem.NUM_LOTE) NUM_LOTE
              FROM eg.EGT_REMESSA_LOTE rem
        WHERE rem.DTA_INICIO_PERIODO_REFERENCIA BETWEEN 
            TO_DATE('01/01/2019','dd/mm/yy') AND 
            TO_DATE('31/12/2019','dd/mm/yy')   
            AND rem.COD_SITUACAO_REMESSA = 'G'             
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
        -- G - Gerada
	--AND REMESSA.COD_SITUACAO_REMESSA = 'G'
	-- M - Mensal
	AND REMESSA.COD_PERIODICIDADE = 'M'
	-- Se desejar, faça filtro por orgaos estatistica aqui
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	-- Filtro por remessa e lote (se desejar, filtre por mes da remessa de maneira similar ao SQL que recupera remessa e lote a partir do mes)
	-- Apenas itens com detalhes de processos 
	AND estrutura_item.num_tipo_complemento = 1
	-- Filtro por item - Exemplo com indicadores 90074 e 92198
    AND processo.NUM_ITEM IN (329,90329,391,90391,31,90091)
    
    )

ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida
group by saida.txt_unidade, saida.mes
order by saida.txt_unidade, saida.mes