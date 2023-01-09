
-- Прочитать статью и на основе данных к прошлому ДЗ сделать прогноз ТО на 2018 по этой методологии. Сравнить с фактом:
-- ГГММ Сумма
-- 1801 256798898
-- 1802 232640416
-- 1803 267994924
-- 1804 262849522
-- 1805 276933049
-- 1806 251486085
-- 1807 250559778
-- 1808 261724749
-- 1809 276675505
-- 1810 287647539
-- 1811 363102609
-- 1812 422386052
-- Почему прогноз получается выше факта?


-- Создадим копию базы для 2 дз:

USE Lesson1;

DROP TABLE IF EXISTS new_table_orders;
CREATE TABLE new_table_orders SELECT * FROM `orders_20190822`;


-- Удалим отрицательные цены и заказы выше 150 тыс.:

DELETE FROM new_table_orders WHERE price < 100;

DELETE FROM new_table_orders WHERE price > 150000;


-- Проверим выбросы:

SELECT * FROM new_table_orders WHERE id_o = '' OR id_o IS NULL OR user_id = '' OR user_id IS NULL OR price = '' OR price IS NULL OR o_date IS NULL; 


-- Удалим пользователей с количеством заказов более 2 тыс.:

DROP TEMPORARY TABLE IF EXISTS delete_users;
CREATE TEMPORARY TABLE delete_users SELECT user_id FROM new_table_orders GROUP BY user_id HAVING COUNT(user_id) > 2000;
DELETE FROM new_table_orders WHERE user_id IN (SELECT user_id FROM delete_users);


-- Проверим наличие одинаковых id  заказов:

SELECT COUNT(*), COUNT(DISTINCT id_o) FROM new_table_orders;


-- Посчитаем общие суммы по месяцам:

SELECT 
	YEAR(o_date) AS `year`, 
	MONTH(o_date) AS `month`, 
	ROUND(AVG(price)) AS `avg`, 
	ROUND(SUM(price)) AS `sum` 
FROM new_table_orders 
GROUP BY `year`, `month`;


-- Почему прогноз получается выше факта?

-- Мы делаем расчет исходя из данных таблицы, без учета маркетинговых инструментов (например, рекламы). Также не учитывается влияние внешних факторов, таких как: 
-- продажи конкурентов, наличие товаров-заменителей, сопутствующих товаров. А также внутренних факторов: наличие товарного запаса, изменения поставщиков и т. д.
-- Если проанализировать прирост по месяцам 2017 года по отношению к 2016, то мы можем наблюдать, что скорость прироста распределена равномерно и прогноз 
-- на 2018 год будет примерно в том же направлении
-- (Графики в Excel)
