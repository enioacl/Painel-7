
--Resíduo meta 7

SELECT tabela1.PROCESSO_NUMERO_UNICO, tabela1.TXT_UNIDADE from

(


--7.3
﻿--P 7.3 (pendentes dos dez maiores litigantes)

SELECT saida.TXT_UNIDADE, saida.PROCESSO_NUMERO_UNICO
FROM

(SELECT 
       parametro.DTA_VALOR,
       detalhe.ID_SOLICITACAO_ESTATISTICAS,
       detalhe.ID_RESULT_ESTAT_QUANT,
       detalhe.ID_RESULT_ESTAT_DET,
	   estatistica.ID_ESTATISTICA,
	   estatistica.TXT_HASH_CODE,
	   estatistica.TXT_SIGLA,
	   estatistica.TXT_DESCRICAO,
	   estatistica.IND_ATIVA,
	   estatistica.NUM_ITEM_EGESTAO,
	   item.DES_ITEM,
	   quantidade.NUM_QUANTIDADE_RESULTADOS,
	   quantidade.NUM_VALOR_RESULTADOS,
	   quantidade.NUM_VALOR_RESULTADOS_2,
	   quantidade.NUM_ORDEM_IRMAOS,
	   detalhe.NUM_ID_PROCESSO_ORIGEM,
	   detalhe.NUM_ID_PROCESSO_ORIGEM2,
	   classe.NUM_CLASSE, 
	   classe.NUM_CLASSE_CNJ, 
	   classe.TXT_SIGLA_CLASSE,
	   classe.NOM_CLASSE,
	   detalhe.NUM_PROC,
	   detalhe.NUM_DIGITO,
	   detalhe.NUM_ANO,
	   detalhe.NUM_JUSTICA,
	   detalhe.NUM_REGIONAL,
	   detalhe.NUM_VARA,
	   LPAD(detalhe.NUM_PROC,7,0)||'-'||LPAD(detalhe.NUM_DIGITO,2,0)||'.'||LPAD(detalhe.NUM_ANO,4,0)||'.'|| detalhe.NUM_JUSTICA || '.' || LPAD(detalhe.NUM_REGIONAL,2,0) ||'.'||LPAD(detalhe.NUM_VARA,4,0) AS PROCESSO_NUMERO_UNICO,
	   servidor1.ID_SERVIDOR AS ID_SERVIDOR_1,
	   servidor1.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_1,
	   servidor1.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_1,
	   servidor1.TXT_NOME AS TXT_NOME_SERVIDOR_1,
	   servidor2.ID_SERVIDOR AS ID_SERVIDOR_2,
	   servidor2.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_2,
	   servidor2.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_2,
	   servidor2.TXT_NOME AS TXT_NOME_SERVIDOR_2,
	   servidor3.ID_SERVIDOR AS ID_SERVIDOR_3,
	   servidor3.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_3,
	   servidor3.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_3,
	   servidor3.TXT_NOME AS TXT_NOME_SERVIDOR_3,
	   detalhe.NUM_VALOR_RESULTADO,
	   detalhe.NUM_VALOR_RESULTADO2,
	   detalhe.DTA_EVENTO1,
	   detalhe.DTA_EVENTO2,
	   detalhe.DTA_EVENTO3,
	   detalhe.DTA_EVENTO4,
	   detalhe.TXT_ADICIONAL,
	   detalhe.TXT_ADICIONAL2,
	   detalhe.TXT_ADICIONAL3,
	   detalhe.TXT_ADICIONAL4,
	   detalhe.TXT_ADICIONAL5,
	   orgao.NUM_ORGAO_ESTATISTICA,
	   orgao.TXT_DESCRICAO as TXT_UNIDADE,
	   detalhe.NUM_TRIBUNAL_EGESTAO,
	   detalhe.TAREFA,
	   detalhe.DTA_ENTRADA_TAREFA,
	   unidade_colegiado.NUM_UNIDADE AS num_unidade_turma,
	   unidade_colegiado.TXT_UNIDADE AS txt_unidade_turma,
	   unidade_gabinete.NUM_UNIDADE AS num_unidade_gabinete,
	   unidade_gabinete.TXT_UNIDADE AS txt_unidade_gabinete
FROM sicond.RESULT_ESTAT_DET detalhe
INNER JOIN sicond.RESULT_ESTAT_QUANT quantidade ON quantidade.ID_RESULT_ESTAT_QUANT = detalhe.ID_RESULT_ESTAT_QUANT
INNER JOIN sicond.ESTATISTICA estatistica ON estatistica.ID_ESTATISTICA = quantidade.ID_ESTATISTICA
LEFT JOIN eg.EGT_ESTRUTURA_ITEM item ON item.NUM_ITEM = estatistica.NUM_ITEM_EGESTAO
LEFT JOIN eg.EGT_CLASSE_PROCESSUAL classe ON classe.NUM_CLASSE = detalhe.NUM_CLASSE_EGESTAO
LEFT JOIN sicond.SERVIDOR_V servidor1 ON servidor1.ID_SERVIDOR = detalhe.ID_SERVIDOR
LEFT JOIN sicond.SERVIDOR_V servidor2 ON servidor2.ID_SERVIDOR = detalhe.ID_SERVIDOR2
LEFT JOIN sicond.SERVIDOR_V servidor3 ON servidor3.ID_SERVIDOR = detalhe.ID_SERVIDOR3
LEFT JOIN sicond.ORGAO_ESTATISTICA_V orgao ON (orgao.NUM_ORGAO_ESTATISTICA = detalhe.NUM_ORGAO_ESTATISTICA)
LEFT JOIN eg.EGT_ORGAO_UNIDADE unidade_colegiado ON (unidade_colegiado.NUM_TRIBUNAL = 7 AND unidade_colegiado.NUM_UNIDADE = detalhe.NUM_UNIDADE_COLEGIADO_EGESTAO)
LEFT JOIN eg.EGT_ORGAO_UNIDADE unidade_gabinete ON (unidade_gabinete.NUM_TRIBUNAL = 7 AND unidade_gabinete.NUM_UNIDADE = detalhe.NUM_UNIDADE_GABINETE_EGESTAO)
LEFT JOIN sicond.VALOR_PARAMETRO_EM_SOLICIT parametro ON (detalhe.ID_SOLICITACAO_ESTATISTICAS=parametro.ID_SOLICITACAO_ESTATISTICAS)
--colocar a solicitação de apenas um mês pois é pergunta única
WHERE detalhe.ID_SOLICITACAO_ESTATISTICAS IN (12126)  AND parametro.ID_PARAMETRO=2 --pra buscar somente as linhas com "data final"
ORDER BY quantidade.ID_SOLICITACAO_ESTATISTICAS, quantidade.ID_RESULT_ESTAT_QUANT, detalhe.ID_RESULT_ESTAT_DET) saida
where saida.TXT_SIGLA = 'P7.3'
--group by saida.TXT_SIGLA


union



--7.4
﻿--P 7.4 

SELECT  saida.TXT_UNIDADE, saida.PROCESSO_NUMERO_UNICO
FROM

(SELECT 
       parametro.DTA_VALOR,
       detalhe.ID_SOLICITACAO_ESTATISTICAS,
       detalhe.ID_RESULT_ESTAT_QUANT,
       detalhe.ID_RESULT_ESTAT_DET,
	   estatistica.ID_ESTATISTICA,
	   estatistica.TXT_HASH_CODE,
	   estatistica.TXT_SIGLA,
	   estatistica.TXT_DESCRICAO,
	   estatistica.IND_ATIVA,
	   estatistica.NUM_ITEM_EGESTAO,
	   item.DES_ITEM,
	   quantidade.NUM_QUANTIDADE_RESULTADOS,
	   quantidade.NUM_VALOR_RESULTADOS,
	   quantidade.NUM_VALOR_RESULTADOS_2,
	   quantidade.NUM_ORDEM_IRMAOS,
	   detalhe.NUM_ID_PROCESSO_ORIGEM,
	   detalhe.NUM_ID_PROCESSO_ORIGEM2,
	   classe.NUM_CLASSE, 
	   classe.NUM_CLASSE_CNJ, 
	   classe.TXT_SIGLA_CLASSE,
	   classe.NOM_CLASSE,
	   detalhe.NUM_PROC,
	   detalhe.NUM_DIGITO,
	   detalhe.NUM_ANO,
	   detalhe.NUM_JUSTICA,
	   detalhe.NUM_REGIONAL,
	   detalhe.NUM_VARA,
	   LPAD(detalhe.NUM_PROC,7,0)||'-'||LPAD(detalhe.NUM_DIGITO,2,0)||'.'||LPAD(detalhe.NUM_ANO,4,0)||'.'|| detalhe.NUM_JUSTICA || '.' || LPAD(detalhe.NUM_REGIONAL,2,0) ||'.'||LPAD(detalhe.NUM_VARA,4,0) AS PROCESSO_NUMERO_UNICO,
	   servidor1.ID_SERVIDOR AS ID_SERVIDOR_1,
	   servidor1.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_1,
	   servidor1.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_1,
	   servidor1.TXT_NOME AS TXT_NOME_SERVIDOR_1,
	   servidor2.ID_SERVIDOR AS ID_SERVIDOR_2,
	   servidor2.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_2,
	   servidor2.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_2,
	   servidor2.TXT_NOME AS TXT_NOME_SERVIDOR_2,
	   servidor3.ID_SERVIDOR AS ID_SERVIDOR_3,
	   servidor3.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_3,
	   servidor3.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_3,
	   servidor3.TXT_NOME AS TXT_NOME_SERVIDOR_3,
	   detalhe.NUM_VALOR_RESULTADO,
	   detalhe.NUM_VALOR_RESULTADO2,
	   detalhe.DTA_EVENTO1,
	   detalhe.DTA_EVENTO2,
	   detalhe.DTA_EVENTO3,
	   detalhe.DTA_EVENTO4,
	   detalhe.TXT_ADICIONAL,
	   detalhe.TXT_ADICIONAL2,
	   detalhe.TXT_ADICIONAL3,
	   detalhe.TXT_ADICIONAL4,
	   detalhe.TXT_ADICIONAL5,
	   orgao.NUM_ORGAO_ESTATISTICA,
	   orgao.TXT_DESCRICAO as TXT_UNIDADE,
	   detalhe.NUM_TRIBUNAL_EGESTAO,
	   detalhe.TAREFA,
	   detalhe.DTA_ENTRADA_TAREFA,
	   unidade_colegiado.NUM_UNIDADE AS num_unidade_turma,
	   unidade_colegiado.TXT_UNIDADE AS txt_unidade_turma,
	   unidade_gabinete.NUM_UNIDADE AS num_unidade_gabinete,
	   unidade_gabinete.TXT_UNIDADE AS txt_unidade_gabinete
FROM sicond.RESULT_ESTAT_DET detalhe
INNER JOIN sicond.RESULT_ESTAT_QUANT quantidade ON quantidade.ID_RESULT_ESTAT_QUANT = detalhe.ID_RESULT_ESTAT_QUANT
INNER JOIN sicond.ESTATISTICA estatistica ON estatistica.ID_ESTATISTICA = quantidade.ID_ESTATISTICA
LEFT JOIN eg.EGT_ESTRUTURA_ITEM item ON item.NUM_ITEM = estatistica.NUM_ITEM_EGESTAO
LEFT JOIN eg.EGT_CLASSE_PROCESSUAL classe ON classe.NUM_CLASSE = detalhe.NUM_CLASSE_EGESTAO
LEFT JOIN sicond.SERVIDOR_V servidor1 ON servidor1.ID_SERVIDOR = detalhe.ID_SERVIDOR
LEFT JOIN sicond.SERVIDOR_V servidor2 ON servidor2.ID_SERVIDOR = detalhe.ID_SERVIDOR2
LEFT JOIN sicond.SERVIDOR_V servidor3 ON servidor3.ID_SERVIDOR = detalhe.ID_SERVIDOR3
LEFT JOIN sicond.ORGAO_ESTATISTICA_V orgao ON (orgao.NUM_ORGAO_ESTATISTICA = detalhe.NUM_ORGAO_ESTATISTICA)
LEFT JOIN eg.EGT_ORGAO_UNIDADE unidade_colegiado ON (unidade_colegiado.NUM_TRIBUNAL = 7 AND unidade_colegiado.NUM_UNIDADE = detalhe.NUM_UNIDADE_COLEGIADO_EGESTAO)
LEFT JOIN eg.EGT_ORGAO_UNIDADE unidade_gabinete ON (unidade_gabinete.NUM_TRIBUNAL = 7 AND unidade_gabinete.NUM_UNIDADE = detalhe.NUM_UNIDADE_GABINETE_EGESTAO)
LEFT JOIN sicond.VALOR_PARAMETRO_EM_SOLICIT parametro ON (detalhe.ID_SOLICITACAO_ESTATISTICAS=parametro.ID_SOLICITACAO_ESTATISTICAS)
--colocar a solicitação de cada mês
WHERE detalhe.ID_SOLICITACAO_ESTATISTICAS IN (12123,12126,12130,12302)  AND parametro.ID_PARAMETRO=2 --pra buscar somente as linhas com "data final"
ORDER BY quantidade.ID_SOLICITACAO_ESTATISTICAS, quantidade.ID_RESULT_ESTAT_QUANT, detalhe.ID_RESULT_ESTAT_DET) saida
where saida.TXT_SIGLA = 'P7.4'
--group by saida.TXT_SIGLA



union



--7.5

﻿--P 7.5 

SELECT saida.TXT_UNIDADE, saida.PROCESSO_NUMERO_UNICO
FROM

(SELECT 
       parametro.DTA_VALOR,
       detalhe.ID_SOLICITACAO_ESTATISTICAS,
       detalhe.ID_RESULT_ESTAT_QUANT,
       detalhe.ID_RESULT_ESTAT_DET,
	   estatistica.ID_ESTATISTICA,
	   estatistica.TXT_HASH_CODE,
	   estatistica.TXT_SIGLA,
	   estatistica.TXT_DESCRICAO,
	   estatistica.IND_ATIVA,
	   estatistica.NUM_ITEM_EGESTAO,
	   item.DES_ITEM,
	   quantidade.NUM_QUANTIDADE_RESULTADOS,
	   quantidade.NUM_VALOR_RESULTADOS,
	   quantidade.NUM_VALOR_RESULTADOS_2,
	   quantidade.NUM_ORDEM_IRMAOS,
	   detalhe.NUM_ID_PROCESSO_ORIGEM,
	   detalhe.NUM_ID_PROCESSO_ORIGEM2,
	   classe.NUM_CLASSE, 
	   classe.NUM_CLASSE_CNJ, 
	   classe.TXT_SIGLA_CLASSE,
	   classe.NOM_CLASSE,
	   detalhe.NUM_PROC,
	   detalhe.NUM_DIGITO,
	   detalhe.NUM_ANO,
	   detalhe.NUM_JUSTICA,
	   detalhe.NUM_REGIONAL,
	   detalhe.NUM_VARA,
	   LPAD(detalhe.NUM_PROC,7,0)||'-'||LPAD(detalhe.NUM_DIGITO,2,0)||'.'||LPAD(detalhe.NUM_ANO,4,0)||'.'|| detalhe.NUM_JUSTICA || '.' || LPAD(detalhe.NUM_REGIONAL,2,0) ||'.'||LPAD(detalhe.NUM_VARA,4,0) AS PROCESSO_NUMERO_UNICO,
	   servidor1.ID_SERVIDOR AS ID_SERVIDOR_1,
	   servidor1.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_1,
	   servidor1.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_1,
	   servidor1.TXT_NOME AS TXT_NOME_SERVIDOR_1,
	   servidor2.ID_SERVIDOR AS ID_SERVIDOR_2,
	   servidor2.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_2,
	   servidor2.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_2,
	   servidor2.TXT_NOME AS TXT_NOME_SERVIDOR_2,
	   servidor3.ID_SERVIDOR AS ID_SERVIDOR_3,
	   servidor3.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_3,
	   servidor3.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_3,
	   servidor3.TXT_NOME AS TXT_NOME_SERVIDOR_3,
	   detalhe.NUM_VALOR_RESULTADO,
	   detalhe.NUM_VALOR_RESULTADO2,
	   detalhe.DTA_EVENTO1,
	   detalhe.DTA_EVENTO2,
	   detalhe.DTA_EVENTO3,
	   detalhe.DTA_EVENTO4,
	   detalhe.TXT_ADICIONAL,
	   detalhe.TXT_ADICIONAL2,
	   detalhe.TXT_ADICIONAL3,
	   detalhe.TXT_ADICIONAL4,
	   detalhe.TXT_ADICIONAL5,
	   orgao.NUM_ORGAO_ESTATISTICA,
	   orgao.TXT_DESCRICAO as TXT_UNIDADE,
	   detalhe.NUM_TRIBUNAL_EGESTAO,
	   detalhe.TAREFA,
	   detalhe.DTA_ENTRADA_TAREFA,
	   unidade_colegiado.NUM_UNIDADE AS num_unidade_turma,
	   unidade_colegiado.TXT_UNIDADE AS txt_unidade_turma,
	   unidade_gabinete.NUM_UNIDADE AS num_unidade_gabinete,
	   unidade_gabinete.TXT_UNIDADE AS txt_unidade_gabinete
FROM sicond.RESULT_ESTAT_DET detalhe
INNER JOIN sicond.RESULT_ESTAT_QUANT quantidade ON quantidade.ID_RESULT_ESTAT_QUANT = detalhe.ID_RESULT_ESTAT_QUANT
INNER JOIN sicond.ESTATISTICA estatistica ON estatistica.ID_ESTATISTICA = quantidade.ID_ESTATISTICA
LEFT JOIN eg.EGT_ESTRUTURA_ITEM item ON item.NUM_ITEM = estatistica.NUM_ITEM_EGESTAO
LEFT JOIN eg.EGT_CLASSE_PROCESSUAL classe ON classe.NUM_CLASSE = detalhe.NUM_CLASSE_EGESTAO
LEFT JOIN sicond.SERVIDOR_V servidor1 ON servidor1.ID_SERVIDOR = detalhe.ID_SERVIDOR
LEFT JOIN sicond.SERVIDOR_V servidor2 ON servidor2.ID_SERVIDOR = detalhe.ID_SERVIDOR2
LEFT JOIN sicond.SERVIDOR_V servidor3 ON servidor3.ID_SERVIDOR = detalhe.ID_SERVIDOR3
LEFT JOIN sicond.ORGAO_ESTATISTICA_V orgao ON (orgao.NUM_ORGAO_ESTATISTICA = detalhe.NUM_ORGAO_ESTATISTICA)
LEFT JOIN eg.EGT_ORGAO_UNIDADE unidade_colegiado ON (unidade_colegiado.NUM_TRIBUNAL = 7 AND unidade_colegiado.NUM_UNIDADE = detalhe.NUM_UNIDADE_COLEGIADO_EGESTAO)
LEFT JOIN eg.EGT_ORGAO_UNIDADE unidade_gabinete ON (unidade_gabinete.NUM_TRIBUNAL = 7 AND unidade_gabinete.NUM_UNIDADE = detalhe.NUM_UNIDADE_GABINETE_EGESTAO)
LEFT JOIN sicond.VALOR_PARAMETRO_EM_SOLICIT parametro ON (detalhe.ID_SOLICITACAO_ESTATISTICAS=parametro.ID_SOLICITACAO_ESTATISTICAS)
--colocar a solicitação de cada mês
WHERE detalhe.ID_SOLICITACAO_ESTATISTICAS IN (12123,12126,12130,12302)  AND parametro.ID_PARAMETRO=2 --pra buscar somente as linhas com "data final"
ORDER BY quantidade.ID_SOLICITACAO_ESTATISTICAS, quantidade.ID_RESULT_ESTAT_QUANT, detalhe.ID_RESULT_ESTAT_DET) saida
where saida.TXT_SIGLA = 'P7.5'
--group by saida.TXT_SIGLA




) tabela1


left outer join




(

--7.6

﻿--P 7.6 

SELECT saida.TXT_UNIDADE, saida.PROCESSO_NUMERO_UNICO
FROM

(SELECT 
       parametro.DTA_VALOR,
       detalhe.ID_SOLICITACAO_ESTATISTICAS,
       detalhe.ID_RESULT_ESTAT_QUANT,
       detalhe.ID_RESULT_ESTAT_DET,
	   estatistica.ID_ESTATISTICA,
	   estatistica.TXT_HASH_CODE,
	   estatistica.TXT_SIGLA,
	   estatistica.TXT_DESCRICAO,
	   estatistica.IND_ATIVA,
	   estatistica.NUM_ITEM_EGESTAO,
	   item.DES_ITEM,
	   quantidade.NUM_QUANTIDADE_RESULTADOS,
	   quantidade.NUM_VALOR_RESULTADOS,
	   quantidade.NUM_VALOR_RESULTADOS_2,
	   quantidade.NUM_ORDEM_IRMAOS,
	   detalhe.NUM_ID_PROCESSO_ORIGEM,
	   detalhe.NUM_ID_PROCESSO_ORIGEM2,
	   classe.NUM_CLASSE, 
	   classe.NUM_CLASSE_CNJ, 
	   classe.TXT_SIGLA_CLASSE,
	   classe.NOM_CLASSE,
	   detalhe.NUM_PROC,
	   detalhe.NUM_DIGITO,
	   detalhe.NUM_ANO,
	   detalhe.NUM_JUSTICA,
	   detalhe.NUM_REGIONAL,
	   detalhe.NUM_VARA,
	   LPAD(detalhe.NUM_PROC,7,0)||'-'||LPAD(detalhe.NUM_DIGITO,2,0)||'.'||LPAD(detalhe.NUM_ANO,4,0)||'.'|| detalhe.NUM_JUSTICA || '.' || LPAD(detalhe.NUM_REGIONAL,2,0) ||'.'||LPAD(detalhe.NUM_VARA,4,0) AS PROCESSO_NUMERO_UNICO,
	   servidor1.ID_SERVIDOR AS ID_SERVIDOR_1,
	   servidor1.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_1,
	   servidor1.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_1,
	   servidor1.TXT_NOME AS TXT_NOME_SERVIDOR_1,
	   servidor2.ID_SERVIDOR AS ID_SERVIDOR_2,
	   servidor2.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_2,
	   servidor2.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_2,
	   servidor2.TXT_NOME AS TXT_NOME_SERVIDOR_2,
	   servidor3.ID_SERVIDOR AS ID_SERVIDOR_3,
	   servidor3.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_3,
	   servidor3.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_3,
	   servidor3.TXT_NOME AS TXT_NOME_SERVIDOR_3,
	   detalhe.NUM_VALOR_RESULTADO,
	   detalhe.NUM_VALOR_RESULTADO2,
	   detalhe.DTA_EVENTO1,
	   detalhe.DTA_EVENTO2,
	   detalhe.DTA_EVENTO3,
	   detalhe.DTA_EVENTO4,
	   detalhe.TXT_ADICIONAL,
	   detalhe.TXT_ADICIONAL2,
	   detalhe.TXT_ADICIONAL3,
	   detalhe.TXT_ADICIONAL4,
	   detalhe.TXT_ADICIONAL5,
	   orgao.NUM_ORGAO_ESTATISTICA,
	   orgao.TXT_DESCRICAO as TXT_UNIDADE,
	   detalhe.NUM_TRIBUNAL_EGESTAO,
	   detalhe.TAREFA,
	   detalhe.DTA_ENTRADA_TAREFA,
	   unidade_colegiado.NUM_UNIDADE AS num_unidade_turma,
	   unidade_colegiado.TXT_UNIDADE AS txt_unidade_turma,
	   unidade_gabinete.NUM_UNIDADE AS num_unidade_gabinete,
	   unidade_gabinete.TXT_UNIDADE AS txt_unidade_gabinete
FROM sicond.RESULT_ESTAT_DET detalhe
INNER JOIN sicond.RESULT_ESTAT_QUANT quantidade ON quantidade.ID_RESULT_ESTAT_QUANT = detalhe.ID_RESULT_ESTAT_QUANT
INNER JOIN sicond.ESTATISTICA estatistica ON estatistica.ID_ESTATISTICA = quantidade.ID_ESTATISTICA
LEFT JOIN eg.EGT_ESTRUTURA_ITEM item ON item.NUM_ITEM = estatistica.NUM_ITEM_EGESTAO
LEFT JOIN eg.EGT_CLASSE_PROCESSUAL classe ON classe.NUM_CLASSE = detalhe.NUM_CLASSE_EGESTAO
LEFT JOIN sicond.SERVIDOR_V servidor1 ON servidor1.ID_SERVIDOR = detalhe.ID_SERVIDOR
LEFT JOIN sicond.SERVIDOR_V servidor2 ON servidor2.ID_SERVIDOR = detalhe.ID_SERVIDOR2
LEFT JOIN sicond.SERVIDOR_V servidor3 ON servidor3.ID_SERVIDOR = detalhe.ID_SERVIDOR3
LEFT JOIN sicond.ORGAO_ESTATISTICA_V orgao ON (orgao.NUM_ORGAO_ESTATISTICA = detalhe.NUM_ORGAO_ESTATISTICA)
LEFT JOIN eg.EGT_ORGAO_UNIDADE unidade_colegiado ON (unidade_colegiado.NUM_TRIBUNAL = 7 AND unidade_colegiado.NUM_UNIDADE = detalhe.NUM_UNIDADE_COLEGIADO_EGESTAO)
LEFT JOIN eg.EGT_ORGAO_UNIDADE unidade_gabinete ON (unidade_gabinete.NUM_TRIBUNAL = 7 AND unidade_gabinete.NUM_UNIDADE = detalhe.NUM_UNIDADE_GABINETE_EGESTAO)
LEFT JOIN sicond.VALOR_PARAMETRO_EM_SOLICIT parametro ON (detalhe.ID_SOLICITACAO_ESTATISTICAS=parametro.ID_SOLICITACAO_ESTATISTICAS)
--colocar a solicitação de cada mês
WHERE detalhe.ID_SOLICITACAO_ESTATISTICAS IN (12123,12126,12130,12302)  AND parametro.ID_PARAMETRO=2 --pra buscar somente as linhas com "data final"
ORDER BY quantidade.ID_SOLICITACAO_ESTATISTICAS, quantidade.ID_RESULT_ESTAT_QUANT, detalhe.ID_RESULT_ESTAT_DET) saida
where saida.TXT_SIGLA = 'P7.6'
--group by saida.TXT_SIGLA



union




--7.7

﻿--P 7.7

SELECT  saida.TXT_UNIDADE, saida.PROCESSO_NUMERO_UNICO
FROM

(SELECT 
       parametro.DTA_VALOR,
       detalhe.ID_SOLICITACAO_ESTATISTICAS,
       detalhe.ID_RESULT_ESTAT_QUANT,
       detalhe.ID_RESULT_ESTAT_DET,
	   estatistica.ID_ESTATISTICA,
	   estatistica.TXT_HASH_CODE,
	   estatistica.TXT_SIGLA,
	   estatistica.TXT_DESCRICAO,
	   estatistica.IND_ATIVA,
	   estatistica.NUM_ITEM_EGESTAO,
	   item.DES_ITEM,
	   quantidade.NUM_QUANTIDADE_RESULTADOS,
	   quantidade.NUM_VALOR_RESULTADOS,
	   quantidade.NUM_VALOR_RESULTADOS_2,
	   quantidade.NUM_ORDEM_IRMAOS,
	   detalhe.NUM_ID_PROCESSO_ORIGEM,
	   detalhe.NUM_ID_PROCESSO_ORIGEM2,
	   classe.NUM_CLASSE, 
	   classe.NUM_CLASSE_CNJ, 
	   classe.TXT_SIGLA_CLASSE,
	   classe.NOM_CLASSE,
	   detalhe.NUM_PROC,
	   detalhe.NUM_DIGITO,
	   detalhe.NUM_ANO,
	   detalhe.NUM_JUSTICA,
	   detalhe.NUM_REGIONAL,
	   detalhe.NUM_VARA,
	   LPAD(detalhe.NUM_PROC,7,0)||'-'||LPAD(detalhe.NUM_DIGITO,2,0)||'.'||LPAD(detalhe.NUM_ANO,4,0)||'.'|| detalhe.NUM_JUSTICA || '.' || LPAD(detalhe.NUM_REGIONAL,2,0) ||'.'||LPAD(detalhe.NUM_VARA,4,0) AS PROCESSO_NUMERO_UNICO,
	   servidor1.ID_SERVIDOR AS ID_SERVIDOR_1,
	   servidor1.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_1,
	   servidor1.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_1,
	   servidor1.TXT_NOME AS TXT_NOME_SERVIDOR_1,
	   servidor2.ID_SERVIDOR AS ID_SERVIDOR_2,
	   servidor2.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_2,
	   servidor2.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_2,
	   servidor2.TXT_NOME AS TXT_NOME_SERVIDOR_2,
	   servidor3.ID_SERVIDOR AS ID_SERVIDOR_3,
	   servidor3.NUM_PESSOA_EGESTAO AS NUM_PESSOA_EGESTAO_SERVIDOR_3,
	   servidor3.TXT_MATRICULA AS TXT_MATRICULA_SERVIDOR_3,
	   servidor3.TXT_NOME AS TXT_NOME_SERVIDOR_3,
	   detalhe.NUM_VALOR_RESULTADO,
	   detalhe.NUM_VALOR_RESULTADO2,
	   detalhe.DTA_EVENTO1,
	   detalhe.DTA_EVENTO2,
	   detalhe.DTA_EVENTO3,
	   detalhe.DTA_EVENTO4,
	   detalhe.TXT_ADICIONAL,
	   detalhe.TXT_ADICIONAL2,
	   detalhe.TXT_ADICIONAL3,
	   detalhe.TXT_ADICIONAL4,
	   detalhe.TXT_ADICIONAL5,
	   orgao.NUM_ORGAO_ESTATISTICA,
	   orgao.TXT_DESCRICAO as TXT_UNIDADE,
	   detalhe.NUM_TRIBUNAL_EGESTAO,
	   detalhe.TAREFA,
	   detalhe.DTA_ENTRADA_TAREFA,
	   unidade_colegiado.NUM_UNIDADE AS num_unidade_turma,
	   unidade_colegiado.TXT_UNIDADE AS txt_unidade_turma,
	   unidade_gabinete.NUM_UNIDADE AS num_unidade_gabinete,
	   unidade_gabinete.TXT_UNIDADE AS txt_unidade_gabinete
FROM sicond.RESULT_ESTAT_DET detalhe
INNER JOIN sicond.RESULT_ESTAT_QUANT quantidade ON quantidade.ID_RESULT_ESTAT_QUANT = detalhe.ID_RESULT_ESTAT_QUANT
INNER JOIN sicond.ESTATISTICA estatistica ON estatistica.ID_ESTATISTICA = quantidade.ID_ESTATISTICA
LEFT JOIN eg.EGT_ESTRUTURA_ITEM item ON item.NUM_ITEM = estatistica.NUM_ITEM_EGESTAO
LEFT JOIN eg.EGT_CLASSE_PROCESSUAL classe ON classe.NUM_CLASSE = detalhe.NUM_CLASSE_EGESTAO
LEFT JOIN sicond.SERVIDOR_V servidor1 ON servidor1.ID_SERVIDOR = detalhe.ID_SERVIDOR
LEFT JOIN sicond.SERVIDOR_V servidor2 ON servidor2.ID_SERVIDOR = detalhe.ID_SERVIDOR2
LEFT JOIN sicond.SERVIDOR_V servidor3 ON servidor3.ID_SERVIDOR = detalhe.ID_SERVIDOR3
LEFT JOIN sicond.ORGAO_ESTATISTICA_V orgao ON (orgao.NUM_ORGAO_ESTATISTICA = detalhe.NUM_ORGAO_ESTATISTICA)
LEFT JOIN eg.EGT_ORGAO_UNIDADE unidade_colegiado ON (unidade_colegiado.NUM_TRIBUNAL = 7 AND unidade_colegiado.NUM_UNIDADE = detalhe.NUM_UNIDADE_COLEGIADO_EGESTAO)
LEFT JOIN eg.EGT_ORGAO_UNIDADE unidade_gabinete ON (unidade_gabinete.NUM_TRIBUNAL = 7 AND unidade_gabinete.NUM_UNIDADE = detalhe.NUM_UNIDADE_GABINETE_EGESTAO)
LEFT JOIN sicond.VALOR_PARAMETRO_EM_SOLICIT parametro ON (detalhe.ID_SOLICITACAO_ESTATISTICAS=parametro.ID_SOLICITACAO_ESTATISTICAS)
--colocar a solicitação de cada mês
WHERE detalhe.ID_SOLICITACAO_ESTATISTICAS IN (12123,12126,12130,12302)  AND parametro.ID_PARAMETRO=2 --pra buscar somente as linhas com "data final"
ORDER BY quantidade.ID_SOLICITACAO_ESTATISTICAS, quantidade.ID_RESULT_ESTAT_QUANT, detalhe.ID_RESULT_ESTAT_DET) saida
where saida.TXT_SIGLA = 'P7.7'
--group by saida.TXT_SIGLA





) tabela2 on (tabela1.PROCESSO_NUMERO_UNICO=tabela2.PROCESSO_NUMERO_UNICO and tabela1.TXT_UNIDADE=tabela2.TXT_UNIDADE)
where tabela2.PROCESSO_NUMERO_UNICO is null and tabela2.TXT_UNIDADE is null





