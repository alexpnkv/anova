-- кол-во чеков
SELECT 
    c.client,
    COUNT(*) AS orders_per_client
FROM
    (
        SELECT 
            b.Phone_new AS 'client',
            b.Order_ID AS 'order'
        FROM
            base b
        GROUP BY
            b.Phone_new, b.Order_ID
    ) c
GROUP BY
    c.client
ORDER BY
    c.client

    
-- средний чек 
SELECT
--     c.client,
    avg(c.order_sum) AS avg_order
FROM
    (
        SELECT
            b.Phone_new AS 'client',
            b.Order_ID AS 'order',
            sum(b.RowSum) AS order_sum
        FROM
            base b
        GROUP BY
            b.Phone_new, b.Order_ID
    ) c
GROUP BY
    c.client
ORDER BY
    c.client

-- среднее кол-во товаров в чеке
SELECT 
--     c.client,
    avg(c.items_per_order) AS avg_items_per_order
FROM
    (
        SELECT  
            b.Phone_new AS 'client',
            b.Order_ID AS 'order',
            COUNT(*) AS items_per_order
        FROM
            base b
        GROUP BY
            b.Phone_new, b.Order_ID
    ) c
GROUP BY
    c.client
ORDER BY
    c.client    
    
-- выручка
SELECT  
--     b.Phone_new AS 'client',
    sum(b.RowSum) AS revenue_per_client
FROM
    base b
GROUP BY
    b.Phone_new
ORDER BY
    b.Phone_new
    
-- кол-во товаров
SELECT  
--     b.Phone_new AS 'client',
    COUNT(*) AS items_per_client
FROM
    base b
GROUP BY
    b.Phone_new
ORDER BY
    b.Phone_new
    
-- кол-во выкупленных чеков
SELECT 
--     c.client AS `client`,
    sum(CASE WHEN c.Status = "Выдан клиенту" THEN 1 ELSE 0 END) AS orders_per_client_R
FROM
    (
        SELECT 
            b.Phone_new AS 'client',
            b.Order_ID AS 'order',
            b.Status AS 'status'
        FROM
            base b
--         WHERE
--             b.Status = "Выдан клиенту"
        GROUP BY
            b.Phone_new, b.Order_ID, b.Status
    ) c
GROUP BY
    c.client
ORDER BY
    `client`   
    
-- средний выкупленный чек 
SELECT
--     c.client,
--     avg(c.order_sum) AS avg_order,
    sum(c.order_sum_R) / sum(CASE WHEN c.Status = "Выдан клиенту" THEN 1 ELSE 0 END) AS avg_order_R
FROM
    (
        SELECT
            b.Phone_new AS 'client',
            b.Order_ID AS 'order',
            sum(b.RowSum) AS order_sum,
            sum(CASE WHEN b.Status = "Выдан клиенту" THEN b.RowSum ELSE 0 END) AS order_sum_R,
            b.Status AS 'status'
        FROM
            base b
        GROUP BY
            b.Phone_new, b.Order_ID, b.Status
    ) c
GROUP BY
    c.client
ORDER BY
    c.client    


-- среднее кол-во товаров в выкупленном чеке
SELECT 
--     c.client,
    sum(items_per_order_R) / sum(CASE WHEN c.Status = "Выдан клиенту" THEN 1 ELSE 0 END) AS avg_items_per_order_R
FROM
    (
        SELECT  
            b.Phone_new AS 'client',
            b.Order_ID AS 'order',
            sum(CASE WHEN b.Status = "Выдан клиенту" THEN 1 ELSE 0 END) AS items_per_order_R,
            COUNT(*) AS items_per_order,
            b.Status AS `status`
        FROM
            base b
        GROUP BY
            b.Phone_new, b.Order_ID, b.Status
    ) c
GROUP BY
    c.client
ORDER BY
    c.client    

-- выручка выкупленных
SELECT  
--     b.Phone_new AS 'client',
    sum(CASE WHEN b.Status = "Выдан клиенту" THEN b.RowSum ELSE 0 END) AS revenue_per_client_R
FROM
    base b
GROUP BY
    b.Phone_new
ORDER BY
    b.Phone_new    
    
-- кол-во товаров выкупленных
SELECT  
--     b.Phone_new AS 'client',
    sum(CASE WHEN b.Status = "Выдан клиенту" THEN 1 ELSE 0 END) AS items_per_client_R
FROM
    base b
GROUP BY
    b.Phone_new
ORDER BY
    b.Phone_new     
    
-- доля по категории
SELECT
--     c.client,
    c.pp / c.all_count AS "PayPal",
    c.rbk / c.all_count AS "RBK Money",
    c.t / c.all_count AS "Банк Тинькофф",
    c.c / c.all_count AS "КартойПриПолучении",
    c.s / c.all_count AS "Квитанция Сбербанка",
    c.n / c.all_count AS "Наличные",
    c.cr / c.all_count AS "Кредит в магазине"
FROM
    (
        SELECT  
            b.Phone_new AS 'client',
            COUNT(*) AS all_count,
            sum(CASE WHEN b.PaymentType = "PayPal" THEN 1 ELSE 0 END) AS pp,
            sum(CASE WHEN b.PaymentType = "RBK Money" THEN 1 ELSE 0 END) AS rbk,
            sum(CASE WHEN b.PaymentType = "Банк Тинькофф" THEN 1 ELSE 0 END) AS t,
            sum(CASE WHEN b.PaymentType = "КартойПриПолучении" THEN 1 ELSE 0 END) AS c,
            sum(CASE WHEN b.PaymentType = "Квитанция Сбербанка" THEN 1 ELSE 0 END) AS s,
            sum(CASE WHEN b.PaymentType = "Наличные" THEN 1 ELSE 0 END) AS n,
            sum(CASE WHEN b.PaymentType = "Кредит в магазине" THEN 1 ELSE 0 END) AS cr            
        FROM
            base b
        GROUP BY
            b.Phone_new
    ) AS c
WHERE c.client != "0"
ORDER BY
    c.client
    
-- кол-во выкупленных чеков


CREATE TEMPORARY TABLE valid_clients
SELECT
    d.client
FROM
    (SELECT 
        c.client AS `client`,
        sum(CASE WHEN c.Status = "Выдан клиенту" THEN 1 ELSE 0 END) AS orders_per_client_R
    FROM
        (
            SELECT 
                b.Phone_new AS 'client',
                b.Order_ID AS 'order',
                b.Status AS 'status'
            FROM
                base b
            GROUP BY
                b.Phone_new, b.Order_ID, b.Status
        ) c
    GROUP BY
        c.client
    ORDER BY
        `client`) AS d
WHERE 
    d.client != "0"
    AND orders_per_client_R > 0;

-- исследование акций
SELECT
    c.client,
    c.deliv / c.all_count AS "БесплатнаяДоставкаНаСуммуКорзины"
FROM
    (
        SELECT  
            b.Phone_new AS 'client',
            COUNT(*) AS all_count,
            sum(CASE WHEN b.Actions LIKE("%БесплатнаяДоставкаНаСуммуКорзины%") THEN 1 ELSE 0 END) AS deliv
        FROM
            base b
        GROUP BY
            b.Phone_new
    ) AS c
WHERE 
    c.client != "0"
    AND c.client IN valid_clients
ORDER BY
    c.client
    
