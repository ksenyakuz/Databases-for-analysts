-- 1. �������� ��������� ������ � ������:

-- �������� ���������� ����� � �������:

SELECT * FROM orders_20190822;
SELECT COUNT(*) FROM orders_20190822;
-- (�� 2002804 ��.)


-- �������� ���������� ��������� � ������ ��:

SELECT * FROM orders_20190822 WHERE id_o = '' OR id_o = NULL OR user_id = '' OR user_id = NULL OR price LIKE '0,%';
DELETE FROM orders_20190822 WHERE id_o = '' OR id_o = NULL OR user_id = NULL OR price LIKE '0,%';


-- �������� ����������� � ������������ ���� � ������ ������ (������������� ��������� ��� �������):

SELECT price FROM orders_20190822 ORDER BY price;
DELETE FROM orders_20190822 cotpf WHERE price < 50

SELECT price FROM orders_20190822 cotpf ORDER BY price DESC;
DELETE FROM orders_20190822 cotpf ORDER BY price DESC LIMIT 1;


-- �������� ������� ���������� id  �������:

SELECT COUNT(*), COUNT(DISTINCT id_o) FROM orders_20190822;
-- (�� ���)


-- 2. ��������������, ����� ������ ������ ��������:

SELECT MONTH(o_date) AS `month`, YEAR(o_date) AS `year` FROM orders_20190822 GROUP BY `month`, `year`;
-- (2016 � 2017 ����)


-- 3. ��������� ���������� �����, ���������� ������� � ���������� ���������� �������������, ��� �������� ������:

SELECT COUNT(*) FROM orders_20190822;
-- (���������� ����� ����� ��������� = 1999462)

SELECT 
	(SELECT COUNT(id_o) FROM orders_20190822) AS `���������� �������`, 
	(SELECT COUNT(DISTINCT user_id) FROM orders_20190822) AS `���������� ���������� �������������`;
-- (���������� ���������� ������������� = 1014352)
-- (���������� ������� = 1999462)


-- 4. �� ����� � ������� ��������� ������� ���, ������� ���������� ������� �� ������������. ������� �����, ��� ���������� ��� ���������� ��� �� ����:

-- �������� ����� ����� �� �������:

SELECT 
	YEAR(o_date) AS `year`, 
	MONTH(o_date) AS `month`, 
	ROUND(SUM(price)) AS `sum` 
FROM orders_20190822 
GROUP BY `year`, `month`;

-- �������� ������� ������� �������:

SELECT
ROUND((SELECT ROUND(SUM(price)) FROM orders_20190822 WHERE YEAR(o_date) = 2016)/(SELECT COUNT(DISTINCT o_date) FROM orders_20190822 WHERE YEAR(o_date) = 2016)) 
AS `������� ������� ������� � 2016`,
ROUND((SELECT ROUND(SUM(price)) FROM orders_20190822 WHERE YEAR(o_date) = 2017)/(SELECT COUNT(DISTINCT o_date) FROM orders_20190822 WHERE YEAR(o_date) = 2017)) 
AS `������� ������� ������� � 2017`;
-- (������� ������� ������� � 2016 = 4929280, � 2017 = 7500387)


-- �������� ������� ���:

SELECT
ROUND((SELECT ROUND(SUM(price)) FROM orders_20190822 WHERE YEAR(o_date) = 2016)/(SELECT COUNT(DISTINCT id_o) FROM orders_20190822 WHERE YEAR(o_date) = 2016)) 
AS `������� ��� � 2016`,
ROUND((SELECT ROUND(SUM(price)) FROM orders_20190822 WHERE YEAR(o_date) = 2017)/(SELECT COUNT(DISTINCT id_o) FROM orders_20190822 WHERE YEAR(o_date) = 2017)) 
AS `������� ��� � 2017`;
-- (������� ��� � 2016 = 2101, � 2017 = 2400)


-- �������� ������� ��� �� �������:

SELECT 
	YEAR(o_date) AS `year`, 
	MONTH(o_date) AS `month`, 
	ROUND(AVG(price)) AS `sum` 
FROM orders_20190822 
GROUP BY `year`, `month`;
-- (�����, ��� ���������� ������)


-- �������� ������� ������� � ������� ������������:

SELECT user_id, COUNT(user_id) AS `count` FROM orders_20190822 GROUP BY user_id;
SET @unique_users := (SELECT COUNT(*) FROM (SELECT COUNT(user_id) FROM orders_20190822 GROUP BY user_id) AS c);
SET @all_orders := (SELECT COUNT(id_o) FROM orders_20190822);
SELECT @all_orders AS '����� �������', @unique_users AS '���������� �������������', ROUND(@all_orders/@unique_users, 2) AS `������� ���-�� ������� ������ ������������`;
-- (������� ���������� ������� � ������ ������������ = 1,97)


-- 5. ������ ���������� �������������, ������� �������� � ����� ���� � ��������� �������� � ���������:

SET @users_2016 := (SELECT COUNT(DISTINCT user_id) FROM orders_20190822 WHERE user_id NOT IN (SELECT user_id FROM orders_20190822 WHERE YEAR(o_date) = 2017));
SELECT @users_2016 AS `������������ 2016, ������� �� �������� � 2017`, (ROUND(@users_2016/@unique_users*100)) AS `% �� ������ ���-�� ���������� �������������`;
-- (���������� �������������, ������� �������� � ����� ���� � ��������� � ��������� = 359605 = 35%)


-- 6. ������ ID ������ ��������� �� ���������� ������� ������������:

SELECT user_id AS `id ������������`, COUNT(user_id) AS `���������� �������` FROM orders_20190822 cotpf GROUP BY user_id ORDER BY `���������� �������` DESC LIMIT 1;
-- (������������ � id = 765871, � ����������� ������� = 3182)


-- 7. ������ ������������ ���������� �� �������:

SELECT 
	YEAR(o_date) AS `year`, 
	MONTH(o_date) AS `month`, 
	ROUND(SUM(price)) AS `sum`
FROM orders_20190822 
GROUP BY `year`, `month`;
-- (������ �������� � excel)


