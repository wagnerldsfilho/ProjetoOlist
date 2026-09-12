/*
   ARQUIVO: Views Base Reutilizáveis
   
   Centralizar e padronizar as regras de negócio em views base,
   estabelecendo granularidades atômicas confiáveis (por pedido e
   por cliente) para consumo em relatórios e ferramentas de BI.
*/

-- 1. VIEW: Receita por Pedido (vw_revenue_per_order)
-- Granularidade: 1 linha por order_id
-- Finalidade: Base analítica para métricas monetárias e volume transacional

GO
CREATE OR ALTER VIEW vw_revenue_per_order AS
SELECT
    order_id,
    SUM(payment_value) AS order_revenue
FROM
    order_payments
GROUP BY
    order_id
GO

-- Exemplo de Uso:
-- Métricas como (Receita Bruta, Ticket Médio e Volume de Pedidos)

SELECT
    SUM(order_revenue) AS total_revenue,
    AVG(order_revenue) AS average_order_value,
    COUNT(order_id) AS total_orders
FROM
    vw_revenue_per_order
----
/*
    2. VIEW: Volume de Pedidos por Cliente (vw_orders_by_customer)
    Granularidade: 1 linha por customer_unique_id
    Regra de Negócio: Considera apenas pedidos faturados/válidos
    (exclui status 'canceled' e 'unavailable')
    Finalidade: Base para cálculo de retenção e taxa de recompra
*/
----
GO
CREATE OR ALTER VIEW vw_orders_by_customer AS
SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM
    orders o
INNER JOIN
    customers c ON o.customer_id = c.customer_id
WHERE 
    o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY
    c.customer_unique_id
GO

-- Exemplo de Uso:
-- Taxa de Recompra (Percentual de clientes com mais de 1 pedido faturado)
SELECT
    AVG(CASE WHEN total_orders > 1 THEN 1.0 ELSE 0.0 END) * 100 AS repeat_purchase_rate
FROM
    vw_orders_by_customer


-- 1. DIMENSÃO CLIENTES (Quem comprou e onde mora)
GO
CREATE OR ALTER VIEW vw_dim_customers AS
SELECT 
    customer_id, 
    customer_unique_id,
    customer_city, 
    customer_state
FROM customers
GO

-- 2. TABELA FATO PEDIDOS (Cabeçalho do pedido, status e data do evento)
GO
CREATE OR ALTER VIEW vw_fact_orders AS
SELECT 
    order_id,
    customer_id,
    order_status, 
    CAST(order_purchase_timestamp AS DATE) AS order_purchase_date
FROM orders
WHERE 
    order_purchase_timestamp >= '2017-01-01'
    AND order_purchase_timestamp <  '2018-09-01'
GO

-- 3. TABELA FATO ITENS DO PEDIDO (Granularidade por item vendido)
GO
CREATE OR ALTER VIEW vw_fact_order_items AS
SELECT
    order_id, 
    order_item_id, 
    product_id, 
    seller_id,
    (price + freight_value) AS total_item_value
FROM order_items
GO 

-- 4. TABELA FATO PAGAMENTOS (Transações financeiras e métodos)
GO
CREATE OR ALTER VIEW vw_fact_order_payments AS
SELECT
    order_id,
    payment_sequential,
    payment_type, 
    payment_value
FROM order_payments
GO 

-- 5. DIMENSÃO PRODUTOS (Catálogo e categorização)
GO
CREATE OR ALTER VIEW vw_dim_product AS
SELECT 
    product_id, 
    COALESCE(product_category_name, 'unknown') AS product_category_name
FROM products
GO 

-- 6. DIMENSÃO VENDEDORES (Lojistas parceiros e localização)
GO
CREATE OR ALTER VIEW vw_dim_sellers AS
SELECT 
    seller_id, 
    seller_city, 
    seller_state
FROM sellers
GO 

