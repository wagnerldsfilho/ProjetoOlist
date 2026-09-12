/*
    PROJETO: Análise de Vendas e Receita - Olist E-commerce
    ARQUIVO 01: Criação do banco e notas sobre a importação
 
    Fonte dos dados: Brazilian E-Commerce Public Dataset by Olist (Kaggle)
    https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
*/ 

/*
    NOTAS SOBRE A IMPORTAÇÃO (Import Wizard - SSMS):
 
    1. geolocation_lat / geolocation_lng
       - Marcadas como Nullable (algumas linhas vêm sem coordenada).
       - Tipo definido como FLOAT (não INT), pois o wizard tentou ler
         como número inteiro gigante e quebrou a escala dos valores.
 
    2. geolocation_zip_code_prefix / customer_zip_code_prefix / seller_zip_code_prefix
       - Definidas como VARCHAR (não INT/SMALLINT).
       - Motivo: CEP é um código de identificação, não uma quantidade.
         Como INT, o zero à esquerda (ex: '01037') seria perdido.
*/

CREATE DATABASE Olist
 
USE Olist

-- Modificando o tipo da coluna 
SELECT payment_value 
FROM order_payments 
WHERE payment_value NOT LIKE '%.%'

ALTER TABLE order_payments 
ADD payment_value_fixed DECIMAL(10,2)

UPDATE order_payments 
SET payment_value_fixed = CAST(payment_value AS DECIMAL(10,2))

ALTER TABLE order_payments 
DROP COLUMN payment_value

EXEC sp_rename 'order_payments.payment_value_fixed', 'payment_value', 'COLUMN'

SELECT * FROM order_items

-- Modificando o tipo da coluna 
SELECT price, freight_value 
FROM order_items 
WHERE 
    price NOT LIKE '%.%' 
    AND freight_value NOT LIKE '%.%'

ALTER TABLE order_items 
ADD 
    price_value_fixed DECIMAL(10, 2), 
    freight_value_fixed DECIMAL(10,2)

UPDATE order_items 
SET price_value_fixed = CAST(price AS DECIMAL(10,2))
UPDATE order_items 
SET freight_value_fixed = CAST(freight_value AS DECIMAL(10,2))

ALTER TABLE order_items 
DROP COLUMN price, freight_value 

EXEC sp_rename 'order_items.price_value_fixed', 'price', 'COLUMN'
EXEC sp_rename 'order_items.freight_value_fixed', 'freight_value', 'COLUMN'

