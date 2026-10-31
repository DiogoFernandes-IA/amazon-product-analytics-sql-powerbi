-- Executar após importar o CSV como dbo.Amazon_Original.
-- SQL Server com suporte a TRIM e CREATE OR ALTER VIEW.
USE AmazonAnalytics;
GO
CREATE OR ALTER VIEW dbo.vw_Amazon_Preparada AS
SELECT TRIM(product_id) AS ProdutoID,
       TRIM(product_name) AS NomeProduto,
       TRIM(category) AS CategoriaCompleta,
       TRY_CONVERT(decimal(12,2), NULLIF(TRIM(REPLACE(REPLACE(discounted_price,N'₹',N''),N',',N'')),N'')) AS PrecoComDesconto,
       TRY_CONVERT(decimal(12,2), NULLIF(TRIM(REPLACE(REPLACE(actual_price,N'₹',N''),N',',N'')),N'')) AS PrecoSemDesconto,
       TRY_CONVERT(decimal(5,2), NULLIF(TRIM(REPLACE(discount_percentage,N'%',N'')),N'')) AS DescontoPercentual,
       TRY_CONVERT(decimal(3,2), NULLIF(TRIM(rating),N'')) AS Nota,
       TRY_CONVERT(int, NULLIF(TRIM(REPLACE(rating_count,N',',N'')),N'')) AS QuantidadeAvaliacoes,
       rating AS NotaOriginal, rating_count AS ContagemOriginal,
       product_link AS LinkProduto
FROM dbo.Amazon_Original;
GO
-- Antes de consumir esta view, confirmar ausência de preços nulos.
CREATE OR ALTER VIEW dbo.vw_Amazon_Produtos AS
WITH Classificacao AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY ProdutoID
        ORDER BY PrecoComDesconto ASC, QuantidadeAvaliacoes DESC,
                 PrecoSemDesconto ASC, DescontoPercentual DESC, Nota DESC,
                 NomeProduto ASC, CategoriaCompleta ASC, LinkProduto ASC,
                 NotaOriginal ASC, ContagemOriginal ASC
    ) AS Ordem
    FROM dbo.vw_Amazon_Preparada
)
SELECT ProdutoID, NomeProduto, CategoriaCompleta, PrecoComDesconto,
       PrecoSemDesconto, DescontoPercentual, Nota, QuantidadeAvaliacoes,
       NotaOriginal, ContagemOriginal, LinkProduto
FROM Classificacao WHERE Ordem = 1;
GO
CREATE OR ALTER VIEW dbo.vw_Amazon_Analise AS
SELECT ProdutoID, NomeProduto, CategoriaCompleta,
       TRIM(LEFT(CategoriaCompleta, CHARINDEX(N'|',CategoriaCompleta + N'|') - 1)) AS CategoriaPrincipal,
       PrecoComDesconto, PrecoSemDesconto, DescontoPercentual,
       Nota, QuantidadeAvaliacoes, LinkProduto
FROM dbo.vw_Amazon_Produtos;
GO
