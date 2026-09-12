# Dashboard de Vendas — Olist E-commerce (SQL + Power BI)

Análise de dados de vendas do **Brazilian E-Commerce Public Dataset by Olist** (Kaggle), com extração e resolução de perguntas de negócio em SQL Server e um dashboard interativo construído em Power BI.

## Objetivo

Responder perguntas de negócio reais sobre vendas e receita de um marketplace, usando SQL para análise exploratória e validação, e Power BI para consolidar os resultados num painel interativo — replicando o fluxo de trabalho real de um analista de dados: **extrair e validar em SQL → modelar e visualizar em Power BI**.

## Perguntas de negócio respondidas

- Qual a distribuição de pedidos por status, e qual a taxa de cancelamento?
- Qual a taxa de recompra da empresa (clientes com mais de 1 pedido)?
- Qual a receita por mês, ao longo do período analisado?
- Qual a receita e o ticket médio por categoria de produto?
- Qual a receita por estado?
- Quem são os top 10 vendedores por receita gerada?

## Stack utilizada

- **SQL Server** — extração, limpeza e resolução das perguntas de negócio
- **Power BI** — modelagem de dados (Power Query + modelo estrela) e dashboard interativo (DAX)

## Modelagem no Power BI

O modelo segue uma estrutura de estrela, com `DimOrders` funcionando como tabela central (hub) ligando as dimensões de cliente, produto e vendedor às duas tabelas fato:

```
DimCustomers ──1:1── DimOrders ──1:N── FactOrderItems ──N:1── DimProduct
                          │                    │
                          │                    └──N:1── DimSellers
                          └──1:N── FactOrderPayments
```

As tabelas foram trazidas no nível de grão original (uma linha por item / por pagamento), sem pré-agregação em SQL — as métricas de negócio (receita, ticket médio, % cancelamento, taxa de recompra) foram recriadas como medidas DAX, permitindo que o dashboard seja totalmente interativo e filtrável por período, estado e categoria.

## Decisões metodológicas e aprendizados

Documentar não só o resultado, mas o raciocínio por trás de cada decisão, foi uma parte importante deste projeto:

**Corte à direita (right censoring) no período analisado.** O volume de pedidos em 2016 e no fim de 2018 é bem menor que o restante da série. Essa não é uma informação documentada oficialmente pelo dataset — é uma hipótese levantada a partir do padrão observado nos dados (queda concentrada nas pontas da série, sem um evento de negócio que a justifique) e de pesquisa própria sobre o dataset, e não uma queda real de demanda confirmada pela fonte. Por precaução, as análises de tendência temporal consideram apenas o período de 01/2017 a 08/2018, evitando distorção por dado potencialmente incompleto.

**Formato numérico correto em colunas financeiras.** Os dados de origem vêm no formato numérico americano (ponto como separador decimal). As colunas `payment_value`, `price` e `freight_value` precisaram de conversão explícita de tipo — sem isso, o valor ficava sujeito a uma interpretação de formato incorreta, e a receita apareceu visivelmente inflada ao carregar os dados no Power BI. A correção: criar uma coluna auxiliar em `DECIMAL(10,2)`, migrar os valores com `CAST()` garantindo a escala numérica correta, remover a coluna original e renomear a nova para o nome definitivo. Ficou como aprendizado validar o formato/tipo de dado de colunas financeiras logo na criação do banco, antes de qualquer análise.

**Direção de filtro cruzado (cross-filter) no modelo.** Ao tentar filtrar o dashboard clicando numa categoria de produto, apenas parte dos visuais respondia — o cartão de receita atualizava, mas estado e outras métricas não. A causa: o relacionamento entre a tabela de pedidos e a tabela de itens filtrava só numa direção (do pedido para o item), então o filtro não conseguia "subir" de volta. A solução foi ativar a direção bidirecional especificamente nesse relacionamento (não no modelo inteiro, para evitar ambiguidade e contagem duplicada entre as duas tabelas fato).

**Duas fontes de receita, propositalmente.** `order_items` (preço + frete) e `order_payments` (valor pago) têm grãos diferentes — item vendido vs. transação de pagamento — e seus totais não fecham 100% entre si (divergência de ~1%, atribuída possivelmente a vouchers e arredondamento de parcelas). `order_payments` foi adotada como fonte oficial de receita; `order_items` foi mantida para métricas que dependem de categoria/vendedor.

## Dashboard

- **Cartões de KPI**: Faturamento, Ticket Médio, % Pedidos Cancelados, Taxa de Recompra
- **Faturamento por Ano/Mês**: gráfico de área, com filtro por ano
- **Faturamento por Estado**, **por Método de Pagamento** e **por Categoria** (Top 5)
- **Faturamento por Vendedores**: ranking dos principais vendedores por receita (Top 5)

## Estrutura do repositório

```
├── sql/
    └── importacao_dos_dados.sql #importação dos dados para o SSMS 
    └── EDA.sql #análise exploratoria 
    └── views.sql # views feitas para a importação dos dados para o power BI
│   └── analise_vendas_receita.sql   # queries comentadas com a pergunta de negócio respondida em cada bloco
├── powerbi/
│   └── dashboard_olist.pbix
└── README.md
```

## Autor

**Wagner Duarte**
[LinkedIn](https://www.linkedin.com/in/wagnerldsfilho/) · [GitHub](https://github.com/wagnerldsfilho)

Imagem do dashboard em Power Bi 

<img width="1432" height="795" alt="image" src="https://github.com/user-attachments/assets/8426869d-4339-4b6f-bd2f-d638a1a3eee0" />

