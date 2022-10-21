-- 1. Проверим возможные ошибки в данных:

-- Проверим количество строк в таблице:

SELECT * FROM orders_20190822;
SELECT COUNT(*) FROM orders_20190822;
-- (Их 2002804 шт.)


-- Проверим количество пропусков и удалим их:

SELECT * FROM orders_20190822 WHERE id_o = '' OR id_o = NULL OR user_id = '' OR user_id = NULL OR price LIKE '0,%';
DELETE FROM orders_20190822 WHERE id_o = '' OR id_o = NULL OR user_id = NULL OR price LIKE '0,%';


-- Проверим минимальные и максимальные цены и удалим лишние (подозрительно маленькие или большие):

SELECT price FROM orders_20190822 ORDER BY price;
DELETE FROM orders_20190822 cotpf WHERE price < 50

SELECT price FROM orders_20190822 cotpf ORDER BY price DESC;
DELETE FROM orders_20190822 cotpf ORDER BY price DESC LIMIT 1;


-- Проверим наличие одинаковых id  заказов:

SELECT COUNT(*), COUNT(DISTINCT id_o) FROM orders_20190822;
-- (Их нет)


-- 2. Проанализируем, какой период данных выгружен:

SELECT MONTH(o_date) AS `month`, YEAR(o_date) AS `year` FROM orders_20190822 GROUP BY `month`, `year`;
-- (2016 и 2017 годы)


-- 3. Посчитаем количество строк, количество заказов и количество уникальных пользователей, кто совершал заказы:

SELECT COUNT(*) FROM orders_20190822;
-- (Количество строк после обработки = 1999462)

SELECT 
	(SELECT COUNT(id_o) FROM orders_20190822) AS `количество заказов`, 
	(SELECT COUNT(DISTINCT user_id) FROM orders_20190822) AS `количество уникальных пользователей`;
-- (Количество уникальных пользователей = 1014352)
-- (Количество заказов = 1999462)


-- 4. По годам и месяцам посчитаем средний чек, среднее количество заказов на пользователя. Сделаем вывод, как изменялись эти показатели год от года:

-- Проверим общую сумму по месяцам:

SELECT 
	YEAR(o_date) AS `year`, 
	MONTH(o_date) AS `month`, 
	ROUND(SUM(price)) AS `sum` 
FROM orders_20190822 
GROUP BY `year`, `month`;

-- Проверим среднюю годовую выручку:

SELECT
ROUND((SELECT ROUND(SUM(price)) FROM orders_20190822 WHERE YEAR(o_date) = 2016)/(SELECT COUNT(DISTINCT o_date) FROM orders_20190822 WHERE YEAR(o_date) = 2016)) 
AS `средняя годовая выручка в 2016`,
ROUND((SELECT ROUND(SUM(price)) FROM orders_20190822 WHERE YEAR(o_date) = 2017)/(SELECT COUNT(DISTINCT o_date) FROM orders_20190822 WHERE YEAR(o_date) = 2017)) 
AS `средняя годовая выручка в 2017`;
-- (Средняя годовая выручка в 2016 = 4929280, в 2017 = 7500387)


-- Проверим средний чек:

SELECT
ROUND((SELECT ROUND(SUM(price)) FROM orders_20190822 WHERE YEAR(o_date) = 2016)/(SELECT COUNT(DISTINCT id_o) FROM orders_20190822 WHERE YEAR(o_date) = 2016)) 
AS `средний чек в 2016`,
ROUND((SELECT ROUND(SUM(price)) FROM orders_20190822 WHERE YEAR(o_date) = 2017)/(SELECT COUNT(DISTINCT id_o) FROM orders_20190822 WHERE YEAR(o_date) = 2017)) 
AS `средний чек в 2017`;
-- (Средний чек в 2016 = 2101, в 2017 = 2400)


-- Проверим средний чек по месяцам:

SELECT 
	YEAR(o_date) AS `year`, 
	MONTH(o_date) AS `month`, 
	ROUND(AVG(price)) AS `sum` 
FROM orders_20190822 
GROUP BY `year`, `month`;
-- (Видим, что показатель растет)


-- Проверим сколько заказов у каждого пользователя:

SELECT user_id, COUNT(user_id) AS `count` FROM orders_20190822 GROUP BY user_id;
SET @unique_users := (SELECT COUNT(*) FROM (SELECT COUNT(user_id) FROM orders_20190822 GROUP BY user_id) AS c);
SET @all_orders := (SELECT COUNT(id_o) FROM orders_20190822);
SELECT @all_orders AS 'всего заказов', @unique_users AS 'уникальных пользователей', ROUND(@all_orders/@unique_users, 2) AS `среднее кол-во заказов одного пользователя`;
-- (Среднее количество заказов у одного пользователя = 1,97)


-- 5. Найдем количество пользователей, которые покупали в одном году и перестали покупать в следующем:

SET @users_2016 := (SELECT COUNT(DISTINCT user_id) FROM orders_20190822 WHERE user_id NOT IN (SELECT user_id FROM orders_20190822 WHERE YEAR(o_date) = 2017));
SELECT @users_2016 AS `пользователи 2016, которые не покупали в 2017`, (ROUND(@users_2016/@unique_users*100)) AS `% от общего кол-ва уникальных пользователей`;
-- (Количество пользователей, которые покупали в одном году и перестали в следующем = 359605 = 35%)


-- 6. Найдем ID самого активного по количеству покупок пользователя:

SELECT user_id AS `id пользователя`, COUNT(user_id) AS `количество заказов` FROM orders_20190822 cotpf GROUP BY user_id ORDER BY `количество заказов` DESC LIMIT 1;
-- (Пользователь с id = 765871, с количеством заказов = 3182)


-- 7. Найдем коэффициенты сезонности по месяцам:

SELECT 
	YEAR(o_date) AS `year`, 
	MONTH(o_date) AS `month`, 
	ROUND(SUM(price)) AS `sum`
FROM orders_20190822 
GROUP BY `year`, `month`;
-- (График построен в excel)


