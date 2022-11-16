-- ������� ������: ������� RFM-������ �� ������ ������ �� �������� �� 2 ���� (�� ����������� ��).
?
-- ��� ������:
-- 1. ���������� �������� ��� ������ ����� R, F, M (�.�. � �������, R � 3 ��� ��������, ������� �������� <= 30 ���� �� ��������� ���� � ����, R � 2 ��� ��������, 
-- ������� �������� > 30 � ����� 60 ���� �� ��������� ���� � ���� � �.�.)
-- 2. ��� ������� ������������ �������� ����� �� 3 ���� (�� 111 �� 333, ��� 333 � ����� �������� ������������)
-- 3. ������ �����������, � �������, 333 � 233 � ��� Vip, 1XX � ��� Lost, ��������� Regular ( ������ ������ ���� �������� �����������)
-- 4. ��� ������ ������ �� �. 3 ������� ���-�� �������������, ���. ������ � ��� � % �������������, ������� ��� ������� �� ��� 2 ����.
-- 5. ���������, ��� ����� ���-�� ������������� ������ � ������ ���-�� ������������� �� ������� �� �. 3 (���� � ��� ���� ���������� ������ � �������� �����, 
-- � ��� �� �������� �����). �� �� ����� ������ � �� �������.
-- 6. ���������� ���������.

-- ��� �������: �������� ������� ������������ ��� ������ (������ 12 ��� �����)


USE Lesson1;

DROP TABLE IF EXISTS new_table_orders_4;
CREATE TABLE new_table_orders_4 SELECT * FROM new_table_orders;

/*
R - Recency - ��������
R1 - ������ ������ 90 ����
R2 - ������ �� 46 �� 90 ����
R3 - ������ �� 45 ����
F - Frecuency - ������� 
F1 - 1 �����
F2 - �� 2-� �� 4-� �������
F3 - �� 5-�� �������
M - Monetary - �����
M1 - ����� ����� 10 000
M2 - ����� �� 10 000 �� 20 000
M3 - ����� �� 20 000
� VIP ��������� RFM = 333, 233 � 323
� LOST = 1__, �.�. ���� ������������ � �������
� REGULAR - ���� ���������
*/


-- ����� ���������� ������������� 1 011 757 :

SET @total_users_in_the_database := (SELECT COUNT(DISTINCT user_id) FROM new_table_orders_4);
SELECT @total_users_in_the_database;


-- ��� ����� ������� 4 491 109 425:

SET @total_prices_in_the_database := (SELECT ROUND(SUM(price)) FROM new_table_orders_4);
SELECT @total_prices_in_the_database;


/* 
�������� ���� SELECT-������, � ������� ������� ��������� �������: 
1) rfm_category - RFM-���������
2) count - ���������� ���������� ������������� � ��� 
3) % count - % ������������� � ������ ��������� 
4) status - ������ ������������� � ����������� �� RFM-���������
5) sum_price - ����� ������������� ������������� � ����������� �� RFM-���������
6) % sum_price - % ������������� ������������� � ����������� �� RFM-���������
7) sum from status - ����� ������������� ������������� � ����������� �� ������� �������������
8) % sum from status - % ������������� ������������� � ����������� �� ������� �������������
 
7 � 8 ������� - ������� �������, ������� �������� ��� ���������� �������� ����������� ����������, � ����� 3 ����� ������� ���� 100%
������������ ������� � Excel
 */


SELECT 
	*,
	SUM(sum_price) OVER(PARTITION BY status) AS `sum from status`,
	SUM(`% sum_price`) OVER(PARTITION BY status) AS `% from status`
FROM
	(SELECT 
		rfm_category,
		COUNT(DISTINCT `table`.user_id) AS `count`,
		ROUND(SUM(COUNT(DISTINCT `table`.user_id)) OVER(PARTITION BY rfm_category) / @total_users_in_the_database * 100, 2) AS `% count`,
		(CASE
			WHEN rfm_category = '333' OR rfm_category = '233' OR rfm_category = '323' THEN 'VIP'
			WHEN rfm_category LIKE '1%' THEN 'LOST'
			ELSE 'REGULAR'
		END
		) AS status,
		ROUND(SUM(`price`)) AS sum_price,
		ROUND(SUM(`price`) / @total_prices_in_the_database * 100, 3) AS `% sum_price` 
	FROM(
		SELECT 
			rfm.user_id,
			rfm.`sum` AS `price`,
			CONCAT(
				(CASE
					WHEN days BETWEEN 0 AND 45 THEN '3'
					WHEN days BETWEEN 46 AND 90 THEN '2'
					ELSE '1' 
				END),
				(CASE
					WHEN count_orders >= 5 THEN '3'
					WHEN count_orders BETWEEN 2 AND 4 THEN '2'
					ELSE '1' 
				END),
				(CASE 
					WHEN `sum` > 20000 THEN '3'
					WHEN `sum` BETWEEN 10000 AND 20000 THEN '2'
					ELSE '1' 
				END)
			) AS rfm_category
		FROM (SELECT
				user_id,
				TIMESTAMPDIFF(DAY, MAX(o_date), '2017-12-31') AS days,
				COUNT(id_o) AS count_orders,
				SUM(price) AS `sum`
			FROM new_table_orders_4
			GROUP BY user_id) AS rfm) AS `table`
	GROUP BY `table`.rfm_category) AS rfm
ORDER BY `% from status` DESC, `% count` DESC;


-- ��������, ��� ����� ���-�� ������������� ������ � ������ ���-�� ������������� �� ������� �� �. 3:

SELECT 
	SUM(s.`count`) AS `������������� � RFM`,
	@total_users_in_the_database AS `����� ������������� � ����`,
	(CASE WHEN (SELECT SUM(s.`count`) = (SELECT COUNT(DISTINCT user_id) FROM new_table_orders_4)) = 1 THEN '��' ELSE '���'END) AS `��������� �� ���-��?`
FROM
	(SELECT rfm_category, COUNT(DISTINCT `table`.user_id) AS `count` FROM(
		SELECT user_id,	CONCAT(
			(CASE WHEN days BETWEEN 0 AND 45 THEN '3' WHEN days BETWEEN 46 AND 90 THEN '2' ELSE '1' END),
			(CASE WHEN count_orders >= 5 THEN '3' WHEN count_orders BETWEEN 2 AND 4 THEN '2' ELSE '1' END),
			(CASE WHEN `sum` > 20000 THEN '3' WHEN `sum` BETWEEN 10000 AND 20000 THEN '2' ELSE '1' END)) AS rfm_category
		FROM (SELECT user_id, TIMESTAMPDIFF(DAY, MAX(o_date), '2017-12-31') AS days, COUNT(id_o) AS count_orders,	SUM(price) AS `sum`
			FROM new_table_orders_4 GROUP BY user_id) AS rfm) AS `table`
	GROUP BY `table`.rfm_category) AS s;


/*
����� �������� ������� �����:
1) cohort - ������� (�������� ������� - �����, � ������� ��� �������� ������ �����)
2) time interval - �������� ������ ������� �� �� ����� � ����� (�� 24-� ������� ��� ������� 201601 �� 1-�� ������ ��� ������� 201712)
3) sum price - �����, ������� �������� ������� � ������ ����� ����� �����
������������ ������� � Excel
*/

SELECT 
	cohort,
	DATE_FORMAT(o_date, '%Y%m') AS `time interval`,
	SUM(price) AS `sum price`
FROM
	(SELECT 
		date_and_price.price AS price, 
		date_and_price.o_date AS o_date,
		cohorts.cohort AS cohort
	FROM new_table_orders_4 AS date_and_price
	JOIN  
	(SELECT 
		user_id,
		DATE_FORMAT(MIN(o_date), '%Y%m') AS cohort
	FROM new_table_orders_4
	GROUP BY user_id) AS cohorts
	ON date_and_price.user_id = cohorts.user_id) AS `table`
GROUP BY cohort, `time interval`
ORDER BY cohort, `time interval`;

