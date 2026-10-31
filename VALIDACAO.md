# Conferência do projeto

## Views recebidas do banco
As definições enviadas pelo autor para vw_Amazon_Preparada, vw_Amazon_Produtos e vw_Amazon_Analise foram comparadas ao script sql/01_views.sql. A lógica coincide, incluindo todos os critérios de desempate do ROW_NUMBER. A diferença operacional é CREATE VIEW no banco versus CREATE OR ALTER VIEW no pacote, para facilitar reexecuções; formatação e capitalização também variam.

## Reprodução com o CSV original
Todas as seis células de código do notebook foram executadas no ambiente local, incluindo os quatro gráficos. Apenas o caminho de entrada foi adaptado. A execução no ambiente Kaggle ainda deve ser feita ao publicar.

- Linhas originais: 1.465.
- IDs distintos: 1.351; IDs ausentes: zero.
- IDs com múltiplas observações: 92; observações excedentes: 114.
- Preços e descontos ausentes após conversão: zero.
- Nota ausente após conversão: uma, inclusive após seleção por produto.
- Contagens de avaliações ausentes: duas, inclusive após seleção.
- Violações das faixas verificadas: zero.
- Preço médio com desconto: 3304,587098445596 INR → 3.304,59.
- Desconto médio: 46,681717246484084% → 46,7%.
- Nota média: 4,091851851851852 → 4,09, com 1.350 notas válidas.
- As contagens e médias por categoria coincidem com o relatório na precisão apresentada.

Isso confirma a reprodução dos indicadores e a correspondência das definições SQL fornecidas. Não equivale a uma nova execução no SQL Server nem a uma leitura validada das fórmulas DAX internas do modelo binário.

## Power BI e publicação
O PBIX recebido foi incluído em powerbi/. Os quatro cartões visíveis têm posições verticais e dimensões iguais no arquivo inspecionado. Há também um cartão adicional fora da página. A captura mais recente fornecida pelo autor mostra mínimo 0, máximo 6 e controle de escala logarítmica indisponível; essa configuração foi aceita, sem solicitar nova tentativa de alteração. O PBIX anexado é a versão recebida anteriormente, sem modificação de seus bytes.

A fonte e a autoria estão presentes no rodapé do PBIX. Links completos e licença constam de DATA_LICENSE.md. Para uma atribuição completa dentro do PDF isolado, acrescentar a referência à licença e exportar novamente. A atualização visual permanece a cargo do Power BI Desktop; não foi simulada nesta entrega.

## Próximos passos
Publicar o notebook no Kaggle com execução nesse ambiente, conferir a exportação final com créditos e preencher os links públicos. O CSV original não é redistribuído no ZIP; obtenha-o da fonte indicada.
