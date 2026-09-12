/*
    Análise Exploratória de Dados (EDA)
 
    Objetivo: entender volume, período coberto, qualidade dos dados
    (nulos, outliers) ANTES de calcular qualquer métrica de negócio.
*/

-- Volume dos dados por tabela

SELECT 'orders' AS table_name, COUNT(*) AS total_rows FROM orders
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation

-- INTERVALO DE DATAS
-- Cobertura da Base: Intervalo registrado entre 04/09/2016 e 17/10/2018.


-- Verificação do intervalo temporal
SELECT 
    MIN(order_purchase_timestamp) AS fisrt_purchase_date,
    MAX(order_purchase_timestamp) AS last_purchase_date
FROM 
    orders

-- Verificação de nulos na tabela orders

SELECT 
    COUNT(*) AS total_orders,
    COUNT(*) - COUNT(order_purchase_timestamp) AS null_purchase_timestamp,
    COUNT(*) - COUNT(order_approved_at) AS null_approved_at,
    COUNT(*) - COUNT(order_delivered_carrier_date) AS null_carrier_date,
    COUNT(*) - COUNT(order_delivered_customer_date) AS null_customer_date,
    COUNT(*) - COUNT(order_estimated_delivery_date) AS null_delivery_date
FROM orders


-- Verificação de nulos nas tabelas order_items e order_payments

SELECT 
    COUNT(*) - COUNT(shipping_limit_date) AS null_shipping_limit_date,
    COUNT(*) - COUNT(price) AS null_price, 
    COUNT(*) - COUNT(freight_value) AS null_freight
FROM order_items


SELECT 
    COUNT(*) - COUNT(payment_type) AS null_payment_type,
    COUNT(*) - COUNT(payment_installments) AS null_installments,
    COUNT(*) - COUNT(payment_value) AS null_payment_value
FROM order_payments

-- VALORES ÚNICOS EM COLUNAS CATEGÓRICAS
/* 
    - Status de Entrega: 
      A operação apresenta alto nível de conclusão logística, 
      com a grande maioria dos pedidos categorizada com status 'delivered' (entregue), 
      evidenciando baixa taxa de cancelamento na base.
    - Meio de Pagamento: 
      O cartão de crédito é o método predominante 
      entre os consumidores.
*/

-- Verificando as categorias em orders
SELECT 
    order_status,
    COUNT(*) AS occurrence_count
FROM orders
GROUP BY order_status
ORDER BY occurrence_count DESC

-- Verificando as categorias em order_payment
SELECT 
    payment_type,
    COUNT(*) AS occurrence_count
FROM order_payments
GROUP BY payment_type
ORDER BY occurrence_count DESC



-- ANÁLISE DE OUTLIERS
/* 
    OBS:
    1. Dispersão e Sensibilidade da Média:
      - A ampla distância entre os valores mínimos e máximos indica uma distribuição 
        assimétrica com forte presença de outliers.
      - A média aritmética é altamente sensível a esses valores extremos. Recomenda-se 
        o uso complementar da mediana ou percentis (P25, P75) para avaliar a tendência 
        central com maior robustez estatística.
        
   2. Transações com Valor Zerado (R$ 0,00):
      - Foram identificados registros com 'payment_value = 0'. 
      - Hipótese técnica: 
      - Trata-se de pedidos cobertos integralmente por vouchers 
        promocionais ou ajustes operacionais.
      - Decisão analítica: 
      - Por representarem menos de 0,01% do total de transações 
        esses registros não geram impacto mensurável no faturamento 
        nem no ticket médio global. Optou-se por não aplicar 
        filtros de exclusão (ex.: payment_value > 0), mantendo a integridade do total 
        de pedidos transacionados.
*/


-- Verificando a distribuição na tabela
-- Order_payments
SELECT 
    MIN(payment_value) AS min_payment, 
    MAX(payment_value) AS max_payment, 
    AVG(payment_value) AS avg_payment
FROM 
    order_payments

-- Verificando a distribuição na tabela 
-- Ordem_items
SELECT 
    MIN(price) AS min_payment, 
    MAX(price) AS max_payment, 
    AVG(price) AS avg_payment, 
    MIN(freight_value) AS min_payment_freight, 
    MAX(freight_value) AS max_payment_freight, 
    AVG(freight_value) AS avg_payment_freight
FROM 
    order_items

-- Verificando quantidade de pagamentos zerados 
SELECT 
    COUNT(*) AS zero_payment_orders,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_payments) AS DECIMAL(10, 4)) AS percentage_share
FROM order_payments
WHERE payment_value = 0