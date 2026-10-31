# Dicionário da camada analítica

Granularidade: um produto por `ProdutoID`, após a regra de seleção do menor preço observado.

| Campo | Tipo SQL | Origem/regra | Uso |
|---|---|---|---|
| ProdutoID | Texto | product_id sem espaços nas extremidades | Identificação e contagem distinta |
| NomeProduto | Texto | product_name tratado com TRIM | Identificação descritiva |
| CategoriaCompleta | Texto | category com TRIM | Hierarquia original |
| CategoriaPrincipal | Texto | Primeiro nível antes de `|` | Segmentação e comparação |
| PrecoComDesconto | decimal(12,2) | discounted_price sem ₹ e vírgulas de milhar | Preço em INR |
| PrecoSemDesconto | decimal(12,2) | actual_price sem ₹ e vírgulas de milhar | Preço de referência em INR |
| DescontoPercentual | decimal(5,2) | discount_percentage sem % | Escala SQL 0–100 |
| Nota | decimal(3,2) | rating convertido; inválidos NULL | Nota agregada do produto, escala válida 1–5 |
| QuantidadeAvaliacoes | int | rating_count sem vírgulas | Contagem informada na observação |
| LinkProduto | Texto | product_link | Rastreabilidade |

`NotaOriginal` e `ContagemOriginal` permanecem nas views de preparação e produtos para auditoria. A tabela bruta pode conter outros campos; eles não são necessários aos indicadores apresentados.

## Critérios de aceitação
- ID preenchido e único na camada analítica.
- Preços convertidos, positivos e preço com desconto ≤ preço sem desconto.
- Desconto entre 0 e 100; nota válida entre 1 e 5; contagem não negativa.
- Nulos auditados por campo e camada; não substituir automaticamente por zero.
- Contagem final esperada para a versão trabalhada: 1.351 produtos.
- Totais globais do Power BI comparados às agregações SQL com Todos selecionado.
