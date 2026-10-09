# Análise de Vendas e Logística — Olist E-commerce

Análise do [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle) com **SQL Server**, **Power BI** e **Python**.

## Objetivo

Responder perguntas de negócio sobre vendas, receita e logística de um marketplace e a partir delas, levantar novas análises que apontem onde há perda de eficiência e concentração de receita.


## Principais achados

- **Concentração de receita (Pareto):** cerca de 20% dos estados, vendedores e categorias respondem por 80% da receita.
- **Atrasos nas entregas:** vêm de um gargalo em períodos de pico de vendas.
- **Logística interestadual:** vários estados têm poucos vendedores locais, o que gera frete e custo logístico interestadual. SP concentra os maiores vendedores e é a principal origem da receita.
- **Recompra baixa:** a taxa de recompra é baixa, o que abre espaço para a próxima análise.

<img width="1416" height="793" alt="dashboardOlist" src="https://github.com/user-attachments/assets/8397af72-f454-47a1-bc6a-26fbfb42d149" />


## Perguntas de negócio

- Qual a distribuição de pedidos por status e a taxa de cancelamento?
- Qual a taxa de recompra dos clientes? 
- Qual a receita por mês, categoria e estado? 
- Quem são os top 10 vendedores por receita?
- Qual é o Ticket médio?

## Próximo passo

Investigar a baixa taxa de recompra (perfil dos clientes, impacto de atraso e avaliações).

## Stack

- **SQL Server:** extração, limpeza, views e resolução das perguntas de negócio
- **Power BI:** modelo estrela (Power Query) e dashboard interativo com medidas DAX
- **Python:** análises aprofundadas (Pareto/curva ABC, atrasos, logística)

## Decisões metodológicas

- **Período analisado:** 01/2017 a 08/2018. O volume nas pontas da série é muito menor, e a hipótese é de dado incompleto (corte à direita), não queda real de demanda.
- **Tipos numéricos:** colunas financeiras convertidas para `DECIMAL(10,2)` para evitar receita inflada no Power BI.
- **Filtro cruzado:** relacionamento bidirecional apenas entre pedidos e itens, evitando ambiguidade entre as tabelas fato.
- **Fonte de receita:** há duas fontes uma para os tipos de pagamentos (cartão, boleto e outros) e uma para a receita dos itens.

## Estrutura do repositório
├── sql/
│ ├── importacao_dos_dados.sql
│ ├── EDA.sql
│ ├── views.sql
│ └── analise_vendas_receita.sql
├── powerbi/
│ └── dashboard_olist.pbix
└── README.md

## Autor

**Wagner Duarte** · [LinkedIn](https://www.linkedin.com/in/wagnerldsfilho/) · [GitHub](https://github.com/wagnerldsfilho)
