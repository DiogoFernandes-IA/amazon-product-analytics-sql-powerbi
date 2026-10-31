USE AmazonAnalytics;
GO
-- Diagnóstico de granularidade: versão trabalhada 1465 linhas / 1351 IDs.
SELECT COUNT(*) AS Registros, COUNT(DISTINCT ProdutoID) AS ProdutosDistintos,
       SUM(CASE WHEN NULLIF(ProdutoID,N'') IS NULL THEN 1 ELSE 0 END) AS IDsAusentes
FROM dbo.vw_Amazon_Preparada;
SELECT ProdutoID, COUNT(*) AS Observacoes
FROM dbo.vw_Amazon_Preparada GROUP BY ProdutoID HAVING COUNT(*) > 1;

-- Nulos: auditar separadamente de faixas. Conferir novamente após seleção.
SELECT N'Preparada' AS Camada, COUNT(*) AS Registros,
       SUM(CASE WHEN PrecoComDesconto IS NULL THEN 1 ELSE 0 END) AS PrecoNulo,
       SUM(CASE WHEN PrecoSemDesconto IS NULL THEN 1 ELSE 0 END) AS ReferenciaNula,
       SUM(CASE WHEN DescontoPercentual IS NULL THEN 1 ELSE 0 END) AS DescontoNulo,
       SUM(CASE WHEN Nota IS NULL THEN 1 ELSE 0 END) AS NotaNula,
       SUM(CASE WHEN QuantidadeAvaliacoes IS NULL THEN 1 ELSE 0 END) AS ContagemNula
FROM dbo.vw_Amazon_Preparada
UNION ALL
SELECT N'Analise', COUNT(*),
       SUM(CASE WHEN PrecoComDesconto IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN PrecoSemDesconto IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN DescontoPercentual IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN Nota IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN QuantidadeAvaliacoes IS NULL THEN 1 ELSE 0 END)
FROM dbo.vw_Amazon_Analise;
SELECT ProdutoID, NotaOriginal, ContagemOriginal
FROM dbo.vw_Amazon_Preparada WHERE Nota IS NULL OR QuantidadeAvaliacoes IS NULL;

-- Esperado: nenhuma linha fora de faixa.
SELECT * FROM dbo.vw_Amazon_Preparada
WHERE PrecoComDesconto <= 0 OR PrecoSemDesconto <= 0
   OR PrecoComDesconto > PrecoSemDesconto
   OR DescontoPercentual NOT BETWEEN 0 AND 100
   OR Nota NOT BETWEEN 1 AND 5 OR QuantidadeAvaliacoes < 0;
-- Esperado: nenhuma repetição na camada final.
SELECT ProdutoID, COUNT(*) AS Linhas FROM dbo.vw_Amazon_Analise
GROUP BY ProdutoID HAVING COUNT(*) > 1;
-- Comparar com cartões sem filtros.
SELECT COUNT(DISTINCT ProdutoID) AS TotalProdutos,
       AVG(PrecoComDesconto) AS PrecoMedioINR,
       AVG(DescontoPercentual)/100.0 AS DescontoMedioFracao,
       AVG(Nota) AS NotaMedia FROM dbo.vw_Amazon_Analise;
SELECT CategoriaPrincipal, COUNT(*) AS Produtos,
       AVG(PrecoComDesconto) AS PrecoMedioINR,
       AVG(DescontoPercentual) AS DescontoMedioEscala100,
       AVG(Nota) AS NotaMedia
FROM dbo.vw_Amazon_Analise GROUP BY CategoriaPrincipal ORDER BY Produtos DESC;
