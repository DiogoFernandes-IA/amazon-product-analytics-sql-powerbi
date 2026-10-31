# Metodologia e histórico técnico

## 1. Escopo e origem
O trabalho partiu de um CSV público do Kaggle. A pergunta central foi como organizar um catálogo para comparar quantidade de produtos, preços, descontos e avaliações. O escopo foi delimitado pelos campos disponíveis: não existem dados suficientes para medir vendas, lucro, conversão ou evolução temporal.

## 2. Importação e preservação da origem
Foi utilizado o SQL Server, banco `AmazonAnalytics`, tabela `dbo.Amazon_Original`. A camada bruta preserva os valores recebidos. A limpeza ocorre em views, permitindo consultar a origem e revisar regras sem sobrescrever o CSV. Views comuns armazenam a definição da consulta e não uma cópia materializada dos resultados.

Antes da importação, confira delimitador, codificação UTF-8 e tratamento de aspas do CSV. A seleção dos campos evita trazer dados de usuários e textos de avaliações que não são necessários para os objetivos do dashboard.

## 3. Diagnóstico inicial
Foram identificados 1.465 registros e 1.351 IDs distintos, sem IDs ausentes no diagnóstico realizado. A diferença de 114 corresponde a registros excedentes quando se deseja uma linha por produto. Não se deve descrevê-la como 114 produtos duplicados nem assumir que todos os campos dessas linhas são iguais.

Os preços vieram como texto, com símbolo de rúpia e vírgulas de milhar. O percentual incluía `%`. A contagem de avaliações também continha separadores. Foi identificado um valor de nota `|`, não conversível, e dois registros com contagem de avaliações ausente, em três linhas brutas distintas. Esses números se referem à camada original; a reprodução posterior confirmou a permanência de uma nota nula e duas contagens nulas após a seleção.

As verificações de faixas não apontaram preços não positivos, preço com desconto maior que o original, percentuais fora de 0 a 100, notas válidas fora de 1 a 5 ou contagens negativas. Nulos são auditados separadamente: comparações de faixa não os detectam.

## 4. Conversão de tipos
A view `vw_Amazon_Preparada` aplica `TRIM`, `REPLACE`, `NULLIF` e `TRY_CONVERT`. Remover `₹` e a vírgula de milhar transforma, por exemplo, `₹1,099` em `1099`. Isso não é conversão cambial. Todos os preços permanecem em INR.

Preços usam `DECIMAL(12,2)`, desconto `DECIMAL(5,2)`, nota `DECIMAL(3,2)` e quantidade de avaliações `INT`. Falhas de conversão resultam em `NULL`. Uma nota inválida não deve virar zero, porque zero teria significado numérico e reduziria artificialmente a média. Campos originais de nota e contagem foram mantidos para auditoria.

## 5. Uma observação por produto
A view `vw_Amazon_Produtos` utiliza `ROW_NUMBER()` particionado por `ProdutoID`. Ordena pelo menor preço com desconto e, no empate, pela maior quantidade de avaliações, seguidos de outros atributos. Seleciona `Ordem = 1`.

A regra preserva o conjunto de atributos de uma mesma observação. Não combina o menor preço de uma linha com a nota de outra. Como não existe data, não é possível declarar que a linha escolhida seja a mais recente. Maior quantidade de avaliações também não comprova recência.

A ausência de preços nulos precisa ser confirmada antes da execução: no SQL Server, nulos em ordenação crescente podem ser priorizados. No conjunto diagnosticado, os preços eram conversíveis. Empates em todos os campos expostos podem escolher qualquer uma dessas linhas sem alterar a saída publicada. Collation do SQL Server pode influenciar desempates textuais.

Essa regra define a interpretação dos indicadores. Ela responde ao cenário do menor preço observado por produto e pode produzir médias diferentes de uma seleção aleatória, de uma média de observações ou de outra política. Não representa uma recomendação de compra atual.

## 6. Camada analítica
`vw_Amazon_Analise` extrai a categoria principal como o conteúdo anterior ao primeiro `|`. O campo completo é preservado para rastreabilidade. A camada final contém uma linha por produto e os atributos necessários aos visuais.

O modelo usado neste projeto é uma única view analítica. Não foi implementado um modelo estrela com dimensões independentes. Essa organização é suficiente para o recorte exploratório proposto; a documentação não atribui ao projeto uma arquitetura que não foi construída.

## 7. Medidas e contexto de filtro
No Power BI, `DISTINCTCOUNT` calcula produtos distintos. `AVERAGE` calcula o preço com desconto e a nota média. O desconto é armazenado em escala de 0 a 100 no SQL; a medida divide por 100 e recebe formato percentual. Aplicar apenas o formato percentual ao valor 46,7 produziria 4.670%, por isso a divisão é necessária.

As médias são simples por produto e ignoram nulos. A nota média não é ponderada pela quantidade de avaliações. A segmentação de categoria altera o contexto das medidas e dos gráficos; os valores globais devem ser conferidos com o filtro em Todos.

## 8. Construção e evolução visual
A primeira versão utilizava barras horizontais para as comparações. O layout foi reorganizado para alinhar cartões e eliminar sobreposições. Quantidade e preço permaneceram em barras, favorecendo leitura dos nomes longos. Desconto e nota passaram a colunas para variar a apresentação e ocupar a largura disponível.

O painel contém filtro suspenso de categoria principal, quatro cartões no topo, quantidade e preço em duas colunas, desconto em largura total e nota em largura total. A página recebeu o nome Visão Geral e o título Amazon | Produtos, Preços e Avaliações. O tamanho trabalhado foi 1280 × 1350, com exportação em PDF.

A paleta usa azul-escuro `#232F3E` para quantidade e nota, e laranja `#FF9900` para preço e desconto. Fundos brancos e espaçamento regular separam os blocos. Os cartões exibem separador de milhar, duas casas no preço, uma no desconto e duas na nota. Eixos de colunas partem de zero para evitar amplificar visualmente pequenas diferenças. A nota usa escala que acomoda os valores; limite visual acima de 5 não significa que a escala de avaliação da base seja de 0 a 6.

A orientação de formatação adotou Segoe UI, títulos em negrito e hierarquia entre rótulos e indicadores. A conferência final deve ser feita no PDF, pois o zoom do editor pode esconder problemas de legibilidade.

## 9. Leitura responsável
As três maiores categorias concentram aproximadamente 97,2% dos produtos. Não é possível extrapolar esse percentual para todo o catálogo da Amazon. HomeImprovement tem desconto médio de 57,50%, mas n=2. Categorias com n=1 reproduzem os atributos de um único produto. O maior desconto não demonstra maior venda; notas próximas não comprovam diferença estatística.

## 10. Rastreabilidade e status
O PDF registra o resultado disponível. Os SQLs e DAX deste pacote consolidam as regras documentadas e devem ser validados no ambiente de destino. A execução no SQL Server não foi repetida durante a montagem deste pacote. O notebook Python foi criado agora para reprodução no Kaggle, não como uma etapa histórica já executada. O código foi posteriormente executado com o CSV original fornecido, incluindo gráficos, e confirmou os indicadores. As definições das três views enviadas do banco coincidiram com os scripts. Consulte VALIDACAO.md para o status atual.

O PBIX recebido foi incluído no pacote e os indicadores foram conferidos com o CSV. Antes de publicar, executar o notebook no Kaggle, conferir fonte e licença no relatório final e substituir o PDF se houver alterações.
