-- � �������� �� ����� ������� �� �� 05.2017. � �������� ������ �������� - ������� ������� ����� ������ ������ �������� � ����:
-- 1. ������ ����� ���������� (3 � ����� �������) � ������� ��������� ��� �������� �� ��� �����. ������� ������� ����� ������������ ������ ���������� �� 1 ����. 
-- �������� �� 30.
-- 2. ������ ����� ����������, �� ������� �� �������� ��� ������������ �����. ��� �� ����� ������� �����, �� ����� ������ �� ���� ����� ������� ����� � �� ����� 
-- �����. (����������� ��������� ������)
-- 3. �������� ��������� ������������� � 1 � 2 ��������� �� ��� �����, ������������ ��.
-- 4. � ����� � ��� ����� ������� �� � �� ������� ��� �������� � ������ � ������� ����� ������ �� ������.
-- ��� �������� ������ ���������� ������ �� �������� �� 2 ����.



-- ��������� ������ ������������� ��� ��������:

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


-- ����� ������� � ��� = 215094052,6:

SET @actual_values := (SELECT ROUND(SUM(price), 2) FROM new_table_orders WHERE o_date BETWEEN '2017-05-01' AND '2017-05-31');
SELECT @actual_values 


-- � ������ 2016-�� ����:
-- ������ ������������� 25218 �� ����� 46130801
-- ����� ������������� 40813 �� ����� 91263364 
-- ���� ����� ������������� ��������� 62% (�� ������ 66%)

SELECT 
	COUNT(*)
FROM new_table_orders
WHERE o_date BETWEEN '2016-04-01' AND '2016-04-30'
AND user_id NOT IN (SELECT DISTINCT user_id FROM new_table_orders WHERE o_date < '2016-04-01');


-- � ��� 2016-�� ����:
-- ������ ������������� 24001 �� ����� 41584521
-- ����� ������������� 29229 �� ����� 65372303
-- ���� ����� ������������� ��������� 55% (�� ������ 61%)

SELECT 
	SUM(price)
FROM new_table_orders
WHERE o_date BETWEEN '2016-05-01' AND '2016-05-31'
AND user_id NOT IN (SELECT DISTINCT user_id FROM new_table_orders WHERE o_date < '2016-05-01');


-- ��������� ������ �� ���: 

DROP TABLE IF EXISTS new_table_orders_2; 
CREATE TABLE new_table_orders_2 SELECT * FROM new_table_orders WHERE o_date BETWEEN '2016-04-01' AND '2017-04-30';


-- �������� ��������� ������� � ��������������, ������� ������� ����� 2 ������� �� ���:

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


-- ������ �� �� ������ ������ �������� � ���, ��� ������ ����� ���� �����:

DELETE FROM temporary_users WHERE id_o = 1 AND o_date < '2016-11-01';


-- ������ �������������, ������� ������� 2 ������, �� ������ ����� ��� ����� 7 ������� �����:

DELETE FROM temporary_users WHERE id_o = 2 AND o_date < '2016-10-01';


-- ��������� �� �������������� �������, � ������� �������� 274962 �����:

DESCRIBE temporary_users;
SELECT COUNT(*) FROM temporary_users;


-- �������� ��� ���� ������� � ��������������, � ������� ���� 1 �����, �� �� ������ �� 6 �������
-- �� ������������� � 2 �������� �������� ���, � ���� ������� ����� �������� �� ������ 60 ����:

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


-- �������� 268989 �����:

SELECT COUNT(*) FROM users_with_one_or_two_orders;


-- � ������ 2017 � ���� ������������ ��������� � ������� 3228581,11 * 30 = 98657433,30 � �����
-- ����� ������� ������ �� ���� ��� ������������� � 1-2 �������� � ������ 2017:

DROP TEMPORARY TABLE IF EXISTS average_daily_check_for_1_2_orders;
CREATE TEMPORARY TABLE average_daily_check_for_1_2_orders
	SELECT SUM(price) AS s 
	FROM users_with_one_or_two_orders 
	WHERE o_date BETWEEN '2017-04-01' AND '2017-04-30' 
	GROUP BY DAY(o_date);
SELECT 
	ROUND(AVG(s), 2) AS `����� ������ � ������ � 1-2`, 
	ROUND(AVG(s), 2) * 30 AS `����� ������ � ������ � 1-2 � ���` 
FROM average_daily_check_for_1_2_orders;


-- ������������, ��������� 3 � ����� ������ � ������ 2017 = 36632163,80:

DROP TEMPORARY TABLE IF EXISTS average_daily_check_for_3_plus_orders;
CREATE TEMPORARY TABLE average_daily_check_for_3_plus_orders
	SELECT SUM(price) AS s 
	FROM new_table_orders_2 
	WHERE o_date BETWEEN '2017-04-01' AND '2017-04-30' 
	GROUP BY user_id HAVING 
	COUNT(*) >= 3;
SELECT 
	ROUND(SUM(s), 2) AS `����� ������� � ������ 3+ � ������ 2017` 
FROM average_daily_check_for_3_plus_orders;


-- ������:

-- ������� ����� ������� � ���� � ������ 2017 ������������� 1-2 = 3228581,11 � ������� �� 30:

SELECT 3228581.11 * 30;


-- �������� 96857433,30. �������� ����� ������� ������������� 3+ � ������ 2017 = 36632136,8:

SELECT 96857433.30 + 36632136.8;


-- ���������� ����� 133489570,10 - ��� ��� ������� �� ��� 2017
-- ������� � �������� ����������� ����� ������������� � 2016 ����:

SET @predict := (SELECT ROUND(133489570.10 * 1.635, 2));
SELECT @predict `�������`;


-- ������ � ������������ ������� �� ��� 2017:

SELECT @predict `�������`, @actual_values `����`, ROUND(@predict / @actual_values * 100, 2) `%`;


-- �������� ������� � 1.47%


