/*
    ARQUIVO 04: Análise de Vendas e Receita
 
    Cada bloco abaixo está comentado com a pergunta de negócio
    que responde.
*/
 
-- Pergunta: qual a distribuição de pedidos por status, 
-- e qual % isso representa do total?
-- Resposta: 0.59%

SELECT 
    order_status,
    COUNT(order_id) AS total_orders,
    CAST(COUNT(order_id) AS FLOAT) * 100 / (SELECT COUNT(order_id) FROM orders) AS percentage_share
FROM orders o
WHERE 
    o.order_purchase_timestamp >= '2017-01-01'
    AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY order_status
 
/* 
    OBSERVAÇÃO: cancelamentos representam 0.63% do total de pedidos 
    taxa baixa, sem indício de problema estrutural na operação.

    HIPÓTESE (com base na leitura de comentários de review associados
    a pedidos cancelados): as menções mais recorrentes envolvem atraso
    na entrega e problemas de comunicação durante o processo. Não foi
    feita categorização sistemática dos comentários trata-se de leitura
    exploratória, não de contagem estatística.

    RECOMENDAÇÃO: ainda que o volume seja baixo, investir em comunicação
    proativa com o cliente durante o processo (status de pedido, prazos)
    pode reduzir ainda mais essa taxa — estratégia usada por players como
    Magazine Luiza (fonte: tray.com.br/escola/taxa-de-cancelamento).
*/

SELECT 
    o.order_status,
    r.order_id,
    r.review_comment_title,
    r.review_comment_message
FROM orders o
INNER JOIN 
    order_reviews r ON o.order_id = r.order_id
WHERE 
    order_status = 'canceled'
    AND r.review_comment_title IS NOT NULL 
    AND r.review_comment_message IS NOT NULL 


-- Pergunta: qual a taxa de recompra da empresa 
-- (clientes com mais de 1 pedido?)
-- Resposta é de aproximadamente 3.11% 

WITH customer_order_counts AS(
    SELECT 
        customer_unique_id,
        COUNT(order_id) AS total_orders
    FROM 
    orders o
INNER JOIN 
    customers c ON o.customer_id = c.customer_id
GROUP BY 
    customer_unique_id
)
SELECT 
    CAST(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS FLOAT) * 100 / COUNT(*) AS repeat_purchase_rate
FROM customer_order_counts


-- Pergunta: qual a receita por mês, ao longo de todo o período?

SELECT 
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS month_year,
    SUM(op.payment_value) AS total_revenue
FROM 
    orders o 
INNER JOIN 
    order_payments op ON o.order_id = op.order_id
WHERE 
    order_status NOT IN ('canceled', 'unavailable') 
    AND o.order_purchase_timestamp >= '2017-01-01'
    AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY 
    FORMAT(order_purchase_timestamp, 'yyyy-MM')
ORDER BY 
    month_year

/* 
    OBSERVAÇÃO: o volume de pedidos entre 2016 e o início de 2017, e
    entre agosto/setembro de 2018, é substancialmente menor que o
    restante da série — em 2018, o declínio é gradual (não abrupto),
    padrão consistente com censura à direita (extração do dataset em
    andamento, não queda real de demanda).

    DECISÃO METODOLÓGICA: análises de tendência temporal consideram
    apenas o período de 01/01/2017 a 31/08/2018, para evitar distorção
    por dado incompleto nas pontas da série.

    OBSERVAÇÃO ADICIONAL: novembro/2017 apresenta o maior volume de
    receita da série, coincidindo com o período de Black Friday no
    Brasil — hipótese razoável de sazonalidade, não confirmada pela
    documentação oficial do dataset.
*/

-- Verificando o ano de 2016 para entender melhor como está os dados 
SELECT 
    CAST(order_purchase_timestamp AS DATE) AS dia,
    COUNT(order_id) AS qtd_pedidos
FROM 
    orders
WHERE 
    YEAR(order_purchase_timestamp) = 2016
GROUP BY 
    CAST(order_purchase_timestamp AS DATE)
ORDER BY 
    dia

-- Verificando o ano de 2017 para entender melhor como está os dados 
SELECT 
    CAST(order_purchase_timestamp AS DATE) AS order_date,
    COUNT(order_id) AS daily_order
FROM 
    orders
WHERE 
    YEAR(order_purchase_timestamp) = 2017
GROUP BY 
    CAST(order_purchase_timestamp AS DATE)
ORDER BY 
    order_date

-- Verificando o ano de 2018 para entender melhor como está os dados 
SELECT 
    CAST(order_purchase_timestamp AS DATE) AS order_date,
    COUNT(order_id) AS daily_order
FROM 
    orders
WHERE 
    YEAR(order_purchase_timestamp) = 2018
GROUP BY 
    CAST(order_purchase_timestamp AS DATE)
ORDER BY 
    order_date

-- Pergunta: qual a receita e o ticket médio por categoria de produto? 
/*
    OBSERVAÇÃO: 
    a categoria pcs apresenta o maior ticket médio R$1286
    enquanto beleza_saude lidera em receita total R$1.448.729
*/

WITH order_categories AS (
    SELECT DISTINCT 
        order_id, 
        product_category_name
    FROM   
        order_items
    INNER JOIN 
        products ON order_items.product_id = products.product_id
)
SELECT 
    product_category_name, 
    AVG(vw_ro.order_revenue) AS average_order_value, 
    SUM(vw_ro.order_revenue) AS total_revenue
FROM
    order_categories oc
INNER JOIN
    vw_revenue_per_order vw_ro ON oc.order_id = vw_ro.order_id
GROUP BY 
    oc.product_category_name
ORDER BY 
    total_revenue DESC 


 
-- Pergunta: qual a receita por estado?
/*
    RESPOSTA: 
    AS 3 maiores receitas são da região sudeste (SP, RJ, MG) 
    SP concentra a maior fatia da receita, seguido de RJ e MG.

    RECOMENDAÇÃO: 
    campanhas de marketing direcionadas a essa região
    tendem a ter maior retorno por volume de clientes já ativos; ao
    mesmo tempo, estados com baixa receita podem representar oportunidade
    de expansão, sujeita a viabilidade logística.
*/

SELECT 
    customer_state,
    SUM(op.payment_value) AS total_revenue
FROM
    orders o
INNER JOIN 
    customers c ON o.customer_id = c.customer_id
INNER JOIN 
    order_payments op ON o.order_id = op.order_id
WHERE 
    order_status NOT IN ('canceled', 'unavailable')
GROUP BY 
    customer_state
ORDER BY 
    total_revenue DESC


-- Pergunta: quem são os top 10 vendedores por receita gerada?
/*
    OBSERVAÇÃO: 
    os 10 vendedores de maior receita possuem juntos R$2.023.089

    RECOMENDAÇÃO: 
    um programa de reconhecimento/incentivo para
    vendedores de alto desempenho pode ajudar a mantê-los engajados e
    reduzir o risco de perda desses parceiros estratégicos.
*/ 

SELECT TOP(10)
    oi.seller_id,
    SUM(oi.price + oi.freight_value) AS total_revenue
FROM order_items oi 
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY seller_id
ORDER BY total_revenue DESC

SELECT 
    SUM(total_revenue) AS top_10_total_revenue
FROM (
    SELECT TOP(10)
        SUM(oi.price + oi.freight_value) AS total_revenue
    FROM order_items oi 
    INNER JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY oi.seller_id
    ORDER BY total_revenue DESC
) AS top_10




