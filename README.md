# Amazon | Análise de Produtos, Preços e Avaliações

Projeto de análise de dados desenvolvido com **SQL Server e Power BI**, abrangendo preparação dos dados, validação de qualidade, definição de regras analíticas, medidas DAX e construção de dashboard.

**Autor:** Diogo Soares Fernandes
<img width="1711" height="1800" alt="dashboard" src="https://github.com/user-attachments/assets/aca5f070-76c9-4c62-84d2-88ea4ec9b270" />


## 1. Objetivo do projeto

Organizar uma base pública de produtos da Amazon para analisar:

- Quantidade de produtos por categoria.
- Preço médio com desconto.
- Percentual médio de desconto.
- Nota média dos produtos.

O projeto conecta o tratamento técnico dos dados à apresentação de indicadores, documentando as decisões que influenciam a interpretação dos resultados.

Apesar do nome original *Amazon Sales Dataset*, os campos utilizados descrevem produtos, preços e avaliações. A análise não calcula faturamento, quantidade vendida ou lucro.

## 2. Fonte dos dados

Dataset: **Amazon Sales Dataset**  
Disponibilizado por: **karkavelrajaj**, no Kaggle.

Fonte: https://www.kaggle.com/datasets/karkavelrajaj/amazon-sales-dataset

Licença informada para o dataset: **CC BY-NC-SA 4.0**.

Licença: https://creativecommons.org/licenses/by-nc-sa/4.0/

Transformações realizadas neste projeto: limpeza de formatos, conversão de tipos, seleção de uma observação por produto, extração da categoria principal e agregações analíticas.

Os preços permanecem em **rúpias indianas (INR)**. Não foi realizada conversão cambial.

## 3. Ferramentas utilizadas

| Ferramenta | Aplicação |
|---|---|
| SQL Server | Armazenamento, preparação e organização dos dados em views |
| SQL Server Management Studio | Execução das consultas e inspeção dos resultados |
| Power BI Desktop | Importação da camada analítica e construção do relatório |
| DAX | Cálculo dos indicadores apresentados no dashboard |
| Python, pandas e Matplotlib | Reprodução complementar e conferência dos resultados |

A implementação principal foi construída em SQL Server e Power BI. A reprodução em Python foi acrescentada posteriormente para validar os indicadores e preparar um notebook complementar para o Kaggle.

## 4. Diagnóstico inicial

O arquivo original contém **1.465 registros e 1.351 produtos distintos**.

| Verificação | Resultado |
|---|---:|
| Registros originais | 1.465 |
| IDs distintos | 1.351 |
| IDs ausentes | 0 |
| IDs com mais de uma observação | 92 |
| Observações excedentes em relação a uma linha por produto | 114 |
| Notas não conversíveis | 1 |
| Contagens de avaliações ausentes | 2 |

As 114 observações excedentes não correspondem a 114 produtos duplicados. Existem 92 IDs com múltiplas observações, cujos atributos não precisam ser idênticos.

A nota inválida estava representada pelo caractere `|`. Esse valor foi convertido para `NULL`, preservando a distinção entre informação ausente e uma nota numérica.

## 5. Preparação no SQL Server

O CSV foi importado para a tabela `dbo.Amazon_Original`, no banco `AmazonAnalytics`.

A tabela original foi preservada. As transformações foram organizadas em três views:

| View | Responsabilidade |
|---|---|
| `dbo.vw_Amazon_Preparada` | Limpeza dos campos e conversão dos tipos |
| `dbo.vw_Amazon_Produtos` | Seleção de uma observação por produto |
| `dbo.vw_Amazon_Analise` | Disponibilização dos campos utilizados no Power BI |

### 5.1. Limpeza e conversão dos campos

Na view de preparação foram utilizadas:

- `TRIM`: remoção de espaços nas extremidades dos textos.
- `REPLACE`: remoção do símbolo monetário, das vírgulas de milhar e do símbolo de percentual.
- `NULLIF`: transformação de textos vazios em `NULL`.
- `TRY_CONVERT`: conversão de valores sem interromper a consulta quando um campo não é conversível.

Exemplo: o texto `₹1,099` foi convertido para o número `1099.00`, mantendo a unidade INR.

| Campo tratado | Tipo SQL |
|---|---|
| PrecoComDesconto | DECIMAL(12,2) |
| PrecoSemDesconto | DECIMAL(12,2) |
| DescontoPercentual | DECIMAL(5,2) |
| Nota | DECIMAL(3,2) |
| QuantidadeAvaliacoes | INT |

Os campos originais de nota e contagem foram mantidos na camada de preparação para permitir auditoria.

### 5.2. Regra para uma linha por produto

Para evitar que produtos com múltiplas observações tivessem maior participação nas médias, foi definida a granularidade de **uma linha por ProdutoID**.

A seleção utiliza `ROW_NUMBER()`, com:

- `PARTITION BY ProdutoID` para separar as observações de cada produto.
- Ordenação pelo menor preço com desconto.
- Desempate pela maior quantidade de avaliações e pelos demais atributos.
- Seleção do registro classificado com `Ordem = 1`.

A sequência completa de ordenação utilizada foi:

```sql
ORDER BY
    PrecoComDesconto ASC,
    QuantidadeAvaliacoes DESC,
    PrecoSemDesconto ASC,
    DescontoPercentual DESC,
    Nota DESC,
    NomeProduto ASC,
    CategoriaCompleta ASC,
    LinkProduto ASC,
    NotaOriginal ASC,
    ContagemOriginal ASC
```

Todos os atributos permanecem associados à mesma linha selecionada. Não foi combinado o menor preço de uma observação com a nota de outra.

**Essa regra identifica o menor preço observado por produto, não o preço mais recente.** A base não oferece uma data que permita ordenar essas observações cronologicamente.

A regra também pode reduzir o preço médio em comparação com outras formas de selecionar ou agregar os registros.

### 5.3. Extração da categoria principal

A categoria original contém uma hierarquia separada pelo caractere `|`.

A view analítica extrai o primeiro nível dessa hierarquia utilizando `LEFT` e `CHARINDEX`, criando o campo `CategoriaPrincipal`.

O campo completo foi preservado para manter a rastreabilidade.

## 6. Validações de qualidade

Foram verificados:

- Preenchimento e unicidade dos IDs.
- Conversão dos preços e descontos.
- Preços maiores que zero.
- Preço com desconto menor ou igual ao preço de referência.
- Percentuais de desconto entre 0 e 100.
- Notas válidas entre 1 e 5.
- Quantidades de avaliações não negativas.
- Presença de valores nulos antes e depois da seleção por produto.

Não foram identificadas violações dessas faixas no arquivo analisado.

Após a seleção, a camada final permaneceu com:

- **1.351 produtos distintos.**
- **Uma nota nula.**
- **Duas contagens de avaliações nulas.**

Os valores nulos não foram substituídos automaticamente por zero.

## 7. Construção no Power BI

O Power BI foi conectado à view `dbo.vw_Amazon_Analise` em modo **Importação**.

O modelo utiliza uma única view analítica, com uma linha por produto. Não foi implementado um modelo dimensional em estrela neste projeto.

Foram criadas quatro medidas:

```dax
Total de Produtos =
DISTINCTCOUNT('vw_Amazon_Analise'[ProdutoID])
```

```dax
Preço Médio (INR) =
AVERAGE('vw_Amazon_Analise'[PrecoComDesconto])
```

```dax
Desconto Médio =
DIVIDE(
    AVERAGE('vw_Amazon_Analise'[DescontoPercentual]),
    100
)
```

```dax
Nota Média =
AVERAGE('vw_Amazon_Analise'[Nota])
```

O desconto é armazenado no SQL em escala de 0 a 100. A divisão por 100 permite utilizar corretamente o formato percentual no Power BI.

As médias são simples por produto e ignoram valores nulos. A nota média considera **1.350 produtos com nota válida** e não é ponderada pela quantidade de avaliações.

### Organização visual

A página **Visão Geral** foi organizada com:

- Segmentação suspensa por categoria principal.
- Quatro cartões de indicadores.
- Gráfico de barras de produtos por categoria.
- Gráfico de barras de preço médio por categoria.
- Gráfico de colunas de desconto médio por categoria.
- Gráfico de colunas de nota média por categoria.

Os gráficos de barras facilitam a leitura das categorias com nomes longos. Os gráficos de colunas apresentam as comparações de desconto e nota em áreas de largura total.

A identidade visual utiliza:

- Azul-escuro `#232F3E` para quantidade de produtos e notas.
- Laranja `#FF9900` para preços e descontos.
- Fundos brancos, títulos padronizados e espaçamento entre os visuais.
- Cartões com dimensões iguais e alinhamento horizontal.
- Separador de milhar e casas decimais adequadas a cada indicador.

## 8. Resultados

Indicadores globais, com todas as categorias selecionadas:

| Indicador | Resultado |
|---|---:|
| Produtos distintos | 1.351 |
| Preço médio com desconto | INR 3.304,59 |
| Desconto médio | 46,7% |
| Nota média | 4,09 |

### Comparação por categoria

| Categoria | Produtos | Preço médio (INR) | Desconto médio | Nota média |
|---|---:|---:|---:|---:|
| Electronics | 490 | 6.225,28 | 49,92% | 4,08 |
| Home&Kitchen | 448 | 2.330,62 | 40,12% | 4,04 |
| Computers&Accessories | 375 | 947,49 | 53,20% | 4,15 |
| OfficeProducts | 31 | 301,58 | 12,35% | 4,31 |
| HomeImprovement | 2 | 337,00 | 57,50% | 4,25 |
| MusicalInstruments | 2 | 638,00 | 46,00% | 3,90 |
| Car&Motorbike | 1 | 2.339,00 | 42,00% | 3,80 |
| Health&PersonalCare | 1 | 899,00 | 53,00% | 4,00 |
| Toys&Games | 1 | 150,00 | 0,00% | 4,30 |

## 9. Principais conclusões

### Concentração do catálogo

Electronics, Home&Kitchen e Computers&Accessories reúnem **1.313 produtos**, aproximadamente **97,2% da amostra**.

Essa concentração descreve o arquivo analisado e não comprova a distribuição do catálogo completo da Amazon.

### Diferenças de preço

Electronics apresenta o maior preço médio com desconto entre as categorias observadas: **INR 6.225,28**.

O indicador compara médias de produtos de naturezas diferentes. Ele não demonstra, isoladamente, que uma categoria esteja cara ou barata.

### Descontos e tamanho dos grupos

HomeImprovement apresenta o maior desconto médio, **57,50%**, mas contém apenas **dois produtos**.

Esse resultado exige cautela: grupos pequenos podem produzir rankings pouco representativos da categoria.

### Avaliações

OfficeProducts apresenta a maior nota média, **4,31**, com 31 produtos.

As diferenças entre as notas são descritivas. Não foram realizados testes que comprovem diferenças estatisticamente significativas entre categorias.

## 10. Conferência dos resultados

A lógica dos scripts foi comparada às definições das três views extraídas do SQL Server, incluindo os critérios de desempate.

Também foi realizada uma reprodução complementar em Python com o CSV original, executando a preparação, a seleção por produto, as agregações e os gráficos.

Os quatro indicadores globais e os resultados por categoria coincidiram com o dashboard na precisão apresentada.

Essa conferência não corresponde a uma nova execução dos scripts em outra instalação do SQL Server.

## 11. Limitações da análise

- A base não contém dados suficientes para calcular faturamento, lucro ou volume vendido.
- Não há data disponível para construir uma análise temporal confiável.
- O menor preço observado não deve ser interpretado como preço atual ou mais recente.
- A escolha de uma observação por produto influencia os indicadores.
- Categorias com um ou dois produtos exigem cautela nas comparações.
- Médias ignoram valores nulos, podendo apresentar denominadores diferentes.
- Não foi demonstrado que a amostra represente todo o catálogo da Amazon.
- Não é possível concluir que descontos causem mais vendas ou melhores avaliações.

## 12. Competências demonstradas

- Importação e inspeção de dados.
- Tratamento de textos e conversão de tipos em SQL.
- Diagnóstico de valores inválidos e ausentes.
- Definição de granularidade e regras de seleção.
- Uso de CTE e função de janela.
- Organização de transformações em views.
- Construção de medidas DAX.
- Visualização e interpretação de indicadores.
- Validação independente de resultados.
- Documentação de decisões e limitações.

## 13. Créditos

Análise desenvolvida por **Diogo Soares Fernandes** para portfólio de dados e analytics.

Dados: **Amazon Sales Dataset**, disponibilizado por **karkavelrajaj**, no Kaggle, sob **CC BY-NC-SA 4.0**.

Este projeto não indica vínculo ou endosso da Amazon ou do disponibilizador do dataset.
