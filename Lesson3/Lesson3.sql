-- В качестве ДЗ делам прогноз ТО на 05.2017. В качестве метода прогноза - считаем сколько денег тратят группы клиентов в день:
-- 1. Группа часто покупающих (3 и более покупок) и которые последний раз покупали не так давно. Считаем сколько денег оформленного заказа приходится на 1 день. 
-- Умножаем на 30.
-- 2. Группа часто покупающих, но которые не покупали уже значительное время. Так же можем сделать вывод, из такой группы за след месяц сколько купят и на какую 
-- сумму. (постараться продумать логику)
-- 3. Отдельно разобрать пользователей с 1 и 2 покупками за все время, прогнозируем их.
-- 4. В итоге у вас будет прогноз ТО и вы сможете его сравнить с фактом и оценить грубо разлет по данным.
-- Как источник данных используем данные по продажам за 2 года.



-- Определим группу пользователей для проверки:

USE Lesson1;

SELECT 
	id_o,
	user_id,
	price,
	o_date
FROM new_table_orders 
WHERE o_date BETWEEN '2017-05-01' AND '2017-05-31'
AND user_id IN (SELECT DISTINCT user_id FROM new_table_orders WHERE o_date < '2017-05-01')
ORDER BY o_date;


-- Сумма заказов в мае = 215094052,6:

SET @actual_values := (SELECT ROUND(SUM(price), 2) FROM new_table_orders WHERE o_date BETWEEN '2017-05-01' AND '2017-05-31');
SELECT @actual_values 


-- В апреле 2016-го было:
-- Старых пользователей 25218 на сумму 46130801
-- Новых пользователей 40813 на сумму 91263364 
-- Доля новых пользователей составила 62% (по суммам 66%)

SELECT 
	COUNT(*)
FROM new_table_orders
WHERE o_date BETWEEN '2016-04-01' AND '2016-04-30'
AND user_id NOT IN (SELECT DISTINCT user_id FROM new_table_orders WHERE o_date < '2016-04-01');


-- В мае 2016-го было:
-- Старых пользователей 24001 на сумму 41584521
-- Новых пользователей 29229 на сумму 65372303
-- Доля новых пользователей составила 55% (по суммам 61%)

SELECT 
	SUM(price)
FROM new_table_orders
WHERE o_date BETWEEN '2016-05-01' AND '2016-05-31'
AND user_id NOT IN (SELECT DISTINCT user_id FROM new_table_orders WHERE o_date < '2016-05-01');


-- Оставляем данные до мая: 

DROP TABLE IF EXISTS new_table_orders_2; 
CREATE TABLE new_table_orders_2 SELECT * FROM new_table_orders WHERE o_date BETWEEN '2016-04-01' AND '2017-04-30';


-- Создадим временную таблицу с пользователями, которые сделали более 2 заказов до мая:

DROP TEMPORARY TABLE IF EXISTS temporary_users;
CREATE TEMPORARY TABLE temporary_users
SELECT 
	user_id, 
	AVG(price) price, 
	COUNT(id_o) id_o,
	GROUP_CONCAT(o_date ORDER BY o_date SEPARATOR ', ') o_date
FROM new_table_orders_2
GROUP BY user_id
HAVING COUNT(*) < 3;


-- Удалим из неё записи старше полугода у тех, кто сделал всего один заказ:

DELETE FROM temporary_users WHERE id_o = 1 AND o_date < '2016-11-01';


-- Удалим пользователей, которые сделали 2 заказа, но первый заказ был более 7 месяцев назад:

DELETE FROM temporary_users WHERE id_o = 2 AND o_date < '2016-10-01';


-- Посмотрим на результирующую таблицу, в которой осталось 274962 строк:

DESCRIBE temporary_users;
SELECT COUNT(*) FROM temporary_users;


-- Создадим еще одну таблицу с пользователями, у которых есть 1 заказ, но он сделан за 6 месяцев
-- Из пользователей с 2 заказами сохраним тех, у кого разница между заказами не больше 60 дней:

DROP TABLE IF EXISTS users_with_one_or_two_orders;
CREATE TABLE users_with_one_or_two_orders (user_id INT, price DOUBLE, o_date DATE);

DELIMITER $$
DROP PROCEDURE IF EXISTS insert_to_users_with_one_or_two_orders$$
CREATE PROCEDURE insert_to_users_with_one_or_two_orders()
BEGIN
	DECLARE user_id INT;
	DECLARE price DOUBLE;
	DECLARE id_o BIGINT;
	DECLARE o_date MEDIUMTEXT;
	DECLARE is_end INT DEFAULT 0;
	DECLARE curcat CURSOR FOR SELECT * FROM temporary_users;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET is_end = 1;

	OPEN curcat;
		cyc: LOOP
			FETCH curcat INTO user_id, price, id_o, o_date;
			IF is_end = 1 THEN
				LEAVE cyc;
			END IF;
			IF LENGTH(o_date) < 11 OR TIMESTAMPDIFF(
				DAY, 
				SUBSTRING_INDEX(o_date, ',', 1), 
				SUBSTRING_INDEX(o_date, ',', -1)) < 60 THEN
				INSERT INTO users_with_one_or_two_orders VALUES(
					user_id,
					price,
					CONVERT(SUBSTRING_INDEX(o_date, ',', -1), DATE));
			END IF;
		END LOOP cyc;
	CLOSE curcat;
END$$
DELIMITER ;

CALL insert_to_users_with_one_or_two_orders;


-- Осталось 268989 строк:

SELECT COUNT(*) FROM users_with_one_or_two_orders;


-- В апреле 2017 в день пользователи приносили в среднем 3228581,11 * 30 = 98657433,30 в месяц
-- Сумма каждого заказа по дням для пользователей с 1-2 заказами в апреле 2017:

DROP TEMPORARY TABLE IF EXISTS average_daily_check_for_1_2_orders;
CREATE TEMPORARY TABLE average_daily_check_for_1_2_orders
	SELECT SUM(price) AS s 
	FROM users_with_one_or_two_orders 
	WHERE o_date BETWEEN '2017-04-01' AND '2017-04-30' 
	GROUP BY DAY(o_date);
SELECT 
	ROUND(AVG(s), 2) AS `сумма заказа у юзеров с 1-2`, 
	ROUND(AVG(s), 2) * 30 AS `сумма заказа у юзеров с 1-2 в мес` 
FROM average_daily_check_for_1_2_orders;


-- Пользователи, сделавшие 3 и более заказа в апреле 2017 = 36632163,80:

DROP TEMPORARY TABLE IF EXISTS average_daily_check_for_3_plus_orders;
CREATE TEMPORARY TABLE average_daily_check_for_3_plus_orders
	SELECT SUM(price) AS s 
	FROM new_table_orders_2 
	WHERE o_date BETWEEN '2017-04-01' AND '2017-04-30' 
	GROUP BY user_id HAVING 
	COUNT(*) >= 3;
SELECT 
	ROUND(SUM(s), 2) AS `сумма заказов у юзеров 3+ в апреле 2017` 
FROM average_daily_check_for_3_plus_orders;


-- ВЫВОДЫ:

-- Возьмем сумму заказов в день в апреле 2017 пользователей 1-2 = 3228581,11 и умножим на 30:

SELECT 3228581.11 * 30;


-- Получаем 96857433,30. Прибавим сумму заказов пользователей 3+ в апреле 2017 = 36632136,8:

SELECT 96857433.30 + 36632136.8;


-- Полученная сумма 133489570,10 - это наш прогноз на май 2017
-- Добавим к прогнозу коэффициент новых пользователей в 2016 году:

SET @predict := (SELECT ROUND(133489570.10 * 1.635, 2));
SELECT @predict `прогноз`;


-- Сверим с фактическими данными за май 2017:

SELECT @predict `прогноз`, @actual_values `факт`, ROUND(@predict / @actual_values * 100, 2) `%`;


-- Получили разницу в 1.47%


