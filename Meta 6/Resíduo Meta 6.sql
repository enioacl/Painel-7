--resíduo meta 6


--6.1 

SELECT tabela1.PROCESSO_NUMERO_UNICO, tabela1.TXT_UNIDADE from

(
SELECT  

saida.TXT_UNIDADE,
saida.processo_numero_unico

--count(saida.num_interno_processo) AS quantidade
--saida.NOM_CLASSE
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
            --TO_DATE((select ADD_MONTHS(trunc(sysdate,'mm'),-extract(MONTH from sysdate)+1) from dual),'dd/mm/yy') AND 
            --TO_DATE((select ADD_MONTHS(last_day(sysdate), -1) from dual ),'dd/mm/yy')  
            TO_DATE('01/12/2019','dd/mm/yy') AND 
            TO_DATE('31/12/2019','dd/mm/yy')
            AND rem.COD_SITUACAO_REMESSA = 'G'                
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
        AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
	AND classe.NUM_CLASSE_CNJ IN (63, 65,74, 119, 980)
    AND processo.NUM_ITEM IN (60,61,62,90060,90061,90062)
    
    AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/12/2019','dd/mm/yy') AND 
            TO_DATE('31/12/2019','dd/mm/yy')
            AND rem.COD_SITUACAO_REMESSA = 'G'                
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
        AND proc.ANO_PROC <=2017
	AND processo.NUM_ITEM IN (315,90315)
    )
    
    
    
    ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida





union





--6.2
--6.2 1º grau
SELECT
saida.txt_unidade,
    saida.PROCESSO_NUMERO_UNICO
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
            TO_DATE((select ADD_MONTHS(trunc(sysdate,'mm'),-extract(MONTH from sysdate)+1) from dual),'dd/mm/yy') AND 
            TO_DATE((select ADD_MONTHS(last_day(sysdate), -1) from dual ),'dd/mm/yy')
            AND rem.COD_SITUACAO_REMESSA = 'G'               
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
        AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
	AND classe.NUM_CLASSE_CNJ IN (63, 65,74, 119, 980)
        AND processo.NUM_ITEM IN (388, 90388)
        AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/01/2000','dd/mm/yy') AND 
            TO_DATE('31/12/2019','dd/mm/yy') 
            AND rem.COD_SITUACAO_REMESSA = 'G'               
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
        AND proc.ANO_PROC <=2017
        AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    )
    
    
    ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida
   
) tabela1


left outer join

(

--6.3 

--6.3
SELECT
saida.txt_unidade,
    saida.PROCESSO_NUMERO_UNICO
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
            TO_DATE((select ADD_MONTHS(trunc(sysdate,'mm'),-extract(MONTH from sysdate)+1) from dual),'dd/mm/yy') AND 
            TO_DATE((select ADD_MONTHS(last_day(sysdate), -1) from dual ),'dd/mm/yy') 
            AND rem.COD_SITUACAO_REMESSA = 'G'               
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
    AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
	AND classe.NUM_CLASSE_CNJ IN (63, 65,74, 119, 980)
    AND processo.NUM_ITEM IN (389,90389)
    
    AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/01/2000','dd/mm/yy') AND 
            TO_DATE('31/12/2019','dd/mm/yy')   
            AND rem.COD_SITUACAO_REMESSA = 'G'             
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
    AND proc.ANO_PROC <=2017
    AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    )
    
    
    ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida
 


union


--6.4


--6.4 1º grau

--não julgado até o mês anterior ao mês de referência
SELECT * 
FROM(


SELECT  


--saida.processo_numero_unico,
saida.txt_unidade,
saida.processo_numero_unico
--saida.NOM_CLASSE

FROM (SELECT  
		processo.NUM_REMESSA,
		processo.NUM_LOTE,
		processo.NUM_ITEM,
		processo.NUM_ORGAO_ESTATISTICA,
		processo.DTA_EVENTO_FINAL - processo.DTA_EVENTO_INICIAL AS NUM_DIAS,
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
            TO_DATE('01/01/2020','dd/mm/yy') AND 
            TO_DATE('31/01/2020','dd/mm/yy')          
            AND REM.COD_SITUACAO_REMESSA = 'G'
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)
WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
    AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
    AND classe.NUM_CLASSE_CNJ IN (63,65,74,119,980)
	AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/01/2000','dd/mm/yy') AND 
            TO_DATE('31/12/2019','dd/mm/yy')    --vai ficar mudando
            --não ter sido julgado até o mês de referência
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_SITUACAO_REMESSA = 'G'
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
    AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    )
   
ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida
--group by saida.TXT_UNIDADE,saida.mes



union

--6.4 1º grau

--não julgado até o mês anterior ao mês de referência

SELECT  
saida.txt_unidade,
saida.processo_numero_unico

FROM (SELECT  
		processo.NUM_REMESSA,
		processo.NUM_LOTE,
		processo.NUM_ITEM,
		processo.NUM_ORGAO_ESTATISTICA,
		processo.DTA_EVENTO_FINAL - processo.DTA_EVENTO_INICIAL AS NUM_DIAS,
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
            TO_DATE('01/02/2020','dd/mm/yy') AND 
            TO_DATE('29/02/2020','dd/mm/yy')      
            AND REM.COD_SITUACAO_REMESSA = 'G'
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)
WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
    AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
    AND classe.NUM_CLASSE_CNJ IN (63,65,74,119,980)
	AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/01/2000','dd/mm/yy') AND 
            TO_DATE('31/01/2020','dd/mm/yy')    --vai ficar mudando
            --não ter sido julgado até o mês de referência
            AND REM.COD_SITUACAO_REMESSA = 'G'
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
    AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    )
   
ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida
--group by saida.TXT_UNIDADE,saida.mes



union

--6.4 1º grau

--não julgado até o mês anterior ao mês de referência

SELECT  

saida.txt_unidade,
saida.processo_numero_unico

FROM (SELECT  
		processo.NUM_REMESSA,
		processo.NUM_LOTE,
		processo.NUM_ITEM,
		processo.NUM_ORGAO_ESTATISTICA,
		processo.DTA_EVENTO_FINAL - processo.DTA_EVENTO_INICIAL AS NUM_DIAS,
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
            TO_DATE('01/03/2020','dd/mm/yy') AND 
            TO_DATE('31/03/2020','dd/mm/yy')      
            AND REM.COD_SITUACAO_REMESSA = 'G'
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)
WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
    AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
    AND classe.NUM_CLASSE_CNJ IN (63,65,74,119,980)
	AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/01/2000','dd/mm/yy') AND 
            TO_DATE('29/02/2020','dd/mm/yy')    --vai ficar mudando
            AND REM.COD_SITUACAO_REMESSA = 'G'
            --não ter sido julgado até o mês de referência
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
    AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    )
   
ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida
--group by saida.TXT_UNIDADE,saida.mes



union

--6.4 1º grau

--não julgado até o mês anterior ao mês de referência

SELECT  
saida.txt_unidade,
saida.processo_numero_unico

FROM (SELECT  
		processo.NUM_REMESSA,
		processo.NUM_LOTE,
		processo.NUM_ITEM,
		processo.NUM_ORGAO_ESTATISTICA,
		processo.DTA_EVENTO_FINAL - processo.DTA_EVENTO_INICIAL AS NUM_DIAS,
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
            TO_DATE('01/04/2020','dd/mm/yy') AND 
            TO_DATE('30/04/2020','dd/mm/yy')         
            AND REM.COD_SITUACAO_REMESSA = 'G'
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)
WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
    AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
    AND classe.NUM_CLASSE_CNJ IN (63,65,74,119,980)
	AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/01/2000','dd/mm/yy') AND 
            TO_DATE('31/03/2020','dd/mm/yy')    --vai ficar mudando
            AND REM.COD_SITUACAO_REMESSA = 'G'
            --não ter sido julgado até o mês de referência
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
    AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    )
   
ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida
--group by saida.TXT_UNIDADE,saida.mes


union

--6.4 1º grau

--não julgado até o mês anterior ao mês de referência

SELECT  
saida.txt_unidade,
saida.processo_numero_unico

FROM (SELECT  
		processo.NUM_REMESSA,
		processo.NUM_LOTE,
		processo.NUM_ITEM,
		processo.NUM_ORGAO_ESTATISTICA,
		processo.DTA_EVENTO_FINAL - processo.DTA_EVENTO_INICIAL AS NUM_DIAS,
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
            TO_DATE('01/05/2020','dd/mm/yy') AND 
            TO_DATE('31/05/2020','dd/mm/yy')  
            AND REM.COD_SITUACAO_REMESSA = 'G'
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)
WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
    AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
    AND classe.NUM_CLASSE_CNJ IN (63,65,74,119,980)
	AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/01/2000','dd/mm/yy') AND 
            TO_DATE('30/04/2020','dd/mm/yy')    --vai ficar mudando
            AND REM.COD_SITUACAO_REMESSA = 'G'
            --não ter sido julgado até o mês de referência
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
    AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    )
   
ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida
--group by saida.TXT_UNIDADE,saida.mes



union

--6.4 1º grau

--não julgado até o mês anterior ao mês de referência

SELECT  
saida.txt_unidade,
saida.processo_numero_unico

FROM (SELECT  
		processo.NUM_REMESSA,
		processo.NUM_LOTE,
		processo.NUM_ITEM,
		processo.NUM_ORGAO_ESTATISTICA,
		processo.DTA_EVENTO_FINAL - processo.DTA_EVENTO_INICIAL AS NUM_DIAS,
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
            TO_DATE('01/06/2020','dd/mm/yy') AND 
            TO_DATE('30/06/2020','dd/mm/yy')      
            AND REM.COD_SITUACAO_REMESSA = 'G'
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)
WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
    AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
    AND classe.NUM_CLASSE_CNJ IN (63,65,74,119,980)
	AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/01/2000','dd/mm/yy') AND 
            TO_DATE('31/05/2020','dd/mm/yy')    --vai ficar mudando
            AND REM.COD_SITUACAO_REMESSA = 'G'
            --não ter sido julgado até o mês de referência
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
    AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    )
   
ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida
--group by saida.TXT_UNIDADE,saida.mes


union

--6.4 1º grau

--não julgado até o mês anterior ao mês de referência

SELECT  
saida.txt_unidade,
saida.processo_numero_unico

FROM (SELECT  
		processo.NUM_REMESSA,
		processo.NUM_LOTE,
		processo.NUM_ITEM,
		processo.NUM_ORGAO_ESTATISTICA,
		processo.DTA_EVENTO_FINAL - processo.DTA_EVENTO_INICIAL AS NUM_DIAS,
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
            TO_DATE('01/07/2020','dd/mm/yy') AND 
            TO_DATE('31/07/2020','dd/mm/yy')      
            AND REM.COD_SITUACAO_REMESSA = 'G'
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)
WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
    AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
    AND classe.NUM_CLASSE_CNJ IN (63,65,74,119,980)
	AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/01/2000','dd/mm/yy') AND 
            TO_DATE('30/06/2020','dd/mm/yy')    --vai ficar mudando
            AND REM.COD_SITUACAO_REMESSA = 'G'
            --não ter sido julgado até o mês de referência
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
    AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    )
   
ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida
--group by saida.TXT_UNIDADE,saida.mes



union

--6.4 1º grau

--não julgado até o mês anterior ao mês de referência

SELECT  
saida.txt_unidade,
saida.processo_numero_unico

FROM (SELECT  
		processo.NUM_REMESSA,
		processo.NUM_LOTE,
		processo.NUM_ITEM,
		processo.NUM_ORGAO_ESTATISTICA,
		processo.DTA_EVENTO_FINAL - processo.DTA_EVENTO_INICIAL AS NUM_DIAS,
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
            TO_DATE('01/08/2020','dd/mm/yy') AND 
            TO_DATE('31/08/2020','dd/mm/yy')       
            AND REM.COD_SITUACAO_REMESSA = 'G'
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)
WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
    AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
    AND classe.NUM_CLASSE_CNJ IN (63,65,74,119,980)
	AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/01/2000','dd/mm/yy') AND 
            TO_DATE('31/07/2020','dd/mm/yy')    --vai ficar mudando
            AND REM.COD_SITUACAO_REMESSA = 'G'
            --não ter sido julgado até o mês de referência
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
    AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    )
   
ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida
--group by saida.TXT_UNIDADE,saida.mes


union

--6.4 1º grau

--não julgado até o mês anterior ao mês de referência

SELECT  
saida.txt_unidade,
saida.processo_numero_unico

FROM (SELECT  
		processo.NUM_REMESSA,
		processo.NUM_LOTE,
		processo.NUM_ITEM,
		processo.NUM_ORGAO_ESTATISTICA,
		processo.DTA_EVENTO_FINAL - processo.DTA_EVENTO_INICIAL AS NUM_DIAS,
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
            TO_DATE('01/09/2020','dd/mm/yy') AND 
            TO_DATE('30/09/2020','dd/mm/yy')           
            AND REM.COD_SITUACAO_REMESSA = 'G'
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)
WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
    AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
    AND classe.NUM_CLASSE_CNJ IN (63,65,74,119,980)
	AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/01/2000','dd/mm/yy') AND 
            TO_DATE('31/08/2020','dd/mm/yy')    --vai ficar mudando
            AND REM.COD_SITUACAO_REMESSA = 'G'
            --não ter sido julgado até o mês de referência
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
    AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    )
   
ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida
--group by saida.TXT_UNIDADE,saida.mes



union

--6.4 1º grau

--não julgado até o mês anterior ao mês de referência

SELECT  
saida.txt_unidade,
saida.processo_numero_unico

FROM (SELECT  
		processo.NUM_REMESSA,
		processo.NUM_LOTE,
		processo.NUM_ITEM,
		processo.NUM_ORGAO_ESTATISTICA,
		processo.DTA_EVENTO_FINAL - processo.DTA_EVENTO_INICIAL AS NUM_DIAS,
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
            TO_DATE('01/10/2020','dd/mm/yy') AND 
            TO_DATE('31/10/2020','dd/mm/yy')      
            AND REM.COD_SITUACAO_REMESSA = 'G'
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)
WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
    AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
    AND classe.NUM_CLASSE_CNJ IN (63,65,74,119,980)
	AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/01/2000','dd/mm/yy') AND 
            TO_DATE('30/09/2020','dd/mm/yy')    --vai ficar mudando
            AND REM.COD_SITUACAO_REMESSA = 'G'
            --não ter sido julgado até o mês de referência
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
    AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    )
   
ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida
--group by saida.TXT_UNIDADE,saida.mes



union

--6.4 1º grau

--não julgado até o mês anterior ao mês de referência

SELECT  
saida.txt_unidade,
saida.processo_numero_unico

FROM (SELECT  
		processo.NUM_REMESSA,
		processo.NUM_LOTE,
		processo.NUM_ITEM,
		processo.NUM_ORGAO_ESTATISTICA,
		processo.DTA_EVENTO_FINAL - processo.DTA_EVENTO_INICIAL AS NUM_DIAS,
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
            TO_DATE('01/11/2020','dd/mm/yy') AND 
            TO_DATE('30/11/2020','dd/mm/yy')            
            AND REM.COD_SITUACAO_REMESSA = 'G'
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)
WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
    AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
    AND classe.NUM_CLASSE_CNJ IN (63,65,74,119,980)
	AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/01/2000','dd/mm/yy') AND 
            TO_DATE('31/10/2020','dd/mm/yy')    --vai ficar mudando
            AND REM.COD_SITUACAO_REMESSA = 'G'
            --não ter sido julgado até o mês de referência
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
    AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    )
   
ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida
--group by saida.TXT_UNIDADE,saida.mes
--order by saida.TXT_UNIDADE,saida.mes


union

--6.4 1º grau

--não julgado até o mês anterior ao mês de referência

SELECT  
saida.txt_unidade,
saida.processo_numero_unico
FROM (SELECT  
		processo.NUM_REMESSA,
		processo.NUM_LOTE,
		processo.NUM_ITEM,
		processo.NUM_ORGAO_ESTATISTICA,
		processo.DTA_EVENTO_FINAL - processo.DTA_EVENTO_INICIAL AS NUM_DIAS,
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
            TO_DATE('01/12/2020','dd/mm/yy') AND 
            TO_DATE('31/12/2020','dd/mm/yy')            
            AND REM.COD_SITUACAO_REMESSA = 'G'
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)
WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
    AND proc.ANO_PROC <=2017
	AND estrutura_item.num_tipo_complemento = 1
    AND classe.NUM_CLASSE_CNJ IN (63,65,74,119,980)
	AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    AND processo.NUM_INTERNO_PROCESSO NOT IN (SELECT  
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
            TO_DATE('01/01/2000','dd/mm/yy') AND 
            TO_DATE('30/11/2020','dd/mm/yy')    --vai ficar mudando
            AND REM.COD_SITUACAO_REMESSA = 'G'
            --não ter sido julgado até o mês de referência
GROUP BY rem.NUM_REMESSA) x ON processo.NUM_REMESSA=x.NUM_REMESSA AND processo.NUM_LOTE=x.NUM_LOTE
LEFT JOIN eg.EGT_REMESSA_LOTE remessa ON (remessa.NUM_TRIBUNAL = PROCESSO.NUM_TRIBUNAL AND 
												remessa.NUM_ORGAO_ESTATISTICA = PROCESSO.NUM_ORGAO_ESTATISTICA AND
												remessa.NUM_REMESSA = PROCESSO.NUM_REMESSA AND
												remessa.NUM_LOTE = PROCESSO.NUM_LOTE)

WHERE
	processo.NUM_TRIBUNAL = 7
	AND REMESSA.COD_PERIODICIDADE = 'M'
	AND processo.NUM_ORGAO_ESTATISTICA IN (SELECT NUM_ORGAO_ESTATISTICA FROM eg.EGT_ORGAO_ESTATISTICA)
	AND estrutura_item.num_tipo_complemento = 1
    AND processo.NUM_ITEM IN (39, 40, 41, 42, 43, 44, 46, 47, 48, 90039, 90040, 90041, 90042, 90043, 90044, 90046, 90047, 90048)
    )
   
ORDER BY processo.NUM_REMESSA, processo.NUM_LOTE, processo.num_item, processo.NUM_ORGAO_ESTATISTICA) saida





)
) tabela2 on (tabela1.PROCESSO_NUMERO_UNICO=tabela2.PROCESSO_NUMERO_UNICO and tabela1.TXT_UNIDADE=tabela2.TXT_UNIDADE)
where tabela2.PROCESSO_NUMERO_UNICO is null and tabela2.TXT_UNIDADE is null
