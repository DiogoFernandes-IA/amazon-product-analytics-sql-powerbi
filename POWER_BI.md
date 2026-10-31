# Montagem e conferência do dashboard

## Conexão
No Power BI Desktop: Obter dados → SQL Server. Informar o servidor da instalação e banco AmazonAnalytics. Selecionar Importação e a view dbo.vw_Amazon_Analise. Na instalação utilizada, a conexão local usou autenticação Windows. Não incluir credenciais no repositório.

Confirmar tipos: preços e nota como número decimal; desconto como decimal em escala 0–100; quantidade como inteiro; ID e categorias como texto. Criar as quatro medidas do arquivo DAX. Conferir 1.351 produtos antes de montar o painel.

## Configuração dos visuais

| Visual | Categoria/eixo | Valor | Ordenação |
|---|---|---|---|
| Cartão 1 | — | Total de Produtos | — |
| Cartão 2 | — | Preço Médio (INR) | — |
| Cartão 3 | — | Desconto Médio | — |
| Cartão 4 | — | Nota Média | — |
| Barras: Produtos por categoria | CategoriaPrincipal | Total de Produtos | Valor decrescente |
| Barras: Preço médio por categoria (INR) | CategoriaPrincipal | Preço Médio (INR) | Valor decrescente |
| Colunas: Desconto médio por categoria | CategoriaPrincipal | Desconto Médio | Valor decrescente |
| Colunas: Nota média por categoria | CategoriaPrincipal | Nota Média | Valor decrescente |
| Segmentação suspensa | CategoriaPrincipal | — | Categoria crescente |

## Organização
Página Visão Geral, dimensões trabalhadas 1280 × 1350. Reservar cabeçalho para título e filtro, quatro cartões com a mesma largura e altura, duas áreas superiores lado a lado e duas inferiores de largura total. Selecionar os quatro cartões e utilizar alinhamento superior e distribuição horizontal; conferir também X, Y, largura e altura nas propriedades gerais. Ajustar as margens em relação aos gráficos, não apenas em relação à página.

Usar branco nos fundos, #232F3E para quantidade e nota e #FF9900 para preço e desconto. Manter contraste nos rótulos e textos. Os rótulos de categorias longas nos gráficos de colunas podem ficar inclinados; conferir se continuam completos no PDF. Para leitura pública, considerar nomes de exibição mais curtos, preservando o campo original.

Ativar rótulos de dados, manter eixos de colunas iniciando em zero e evitar excesso de linhas de grade. A escala original de notas é de 1 a 5; o limite visual do eixo não altera a escala do dado. Se houver espaço, usar limite superior 5; se a configuração do visual exibir 6, explicitar a escala no texto e não sugerir notas de seis estrelas.

## Créditos sem sobrecarregar o rodapé
Manter uma referência curta visível e criar uma segunda página Sobre o projeto, com fonte completa, link, licença e metodologia. Exportar as duas páginas para o PDF final. A página extra é uma proposta de publicação, não uma etapa já comprovada no arquivo disponível.

## Conferência antes da publicação
1. Filtro em Todos: conferir os quatro indicadores com o SQL.
2. Selecionar uma categoria: verificar resposta dos cartões e gráficos.
3. Limpar filtro: confirmar retorno aos valores globais.
4. Conferir milhar e casas decimais; desativar abreviações nos cartões.
5. Garantir tamanhos e espaçamento iguais entre cartões.
6. Exportar PDF e conferir cortes, sobreposições, créditos e leitura em tamanho normal.
7. Salvar PBIX, PDF e imagem final com a mesma versão de dados.
