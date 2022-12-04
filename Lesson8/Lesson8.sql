
/*
�� ������ �� �� orders
� �������� �� ������� ����� ��������� �������������. �� ���������, ��� ���� ������������� ����� ���������, � �������, �� New (��������� ������ 1 �������), 
Regular (��������� 2 ��� ����� �� ����� �� ����� �������-��), Vip (��������� ������� ������� � ���������� �����), 
Lost (������ �������� ���� �� ��� � � ���� ��������� ������� ������ ������ 3 �������). 
��� ���� ������ ����� � ��� ������ (�.�. ������ ������������ ������ �������� ������ � ���� �� ���� �����).
������:
1. �������� �������� ����� New,Regular,Vip,Lost
2. �� ��������� �� 1.01.2017 ��������, ��� �������� � ����� ������, ������������ ���-�� ������������� � ������.
3. �� ��������� �� 1.02.2017 ��������, ��� ����� �� ������ �� �����, � ��� �����.
4. ���������� ������� ��������� �� 1.03.2017, �������� ��� ����� �� ������ �� �����, � ��� �����.
5. � ����� ������ �����, ����� ������ �����������, ����� ������������� � �����������, � ��� ����� ���� �������.
���������� ����� � pdf
 */


USE lesson1;

DROP TABLE IF EXISTS new_table_orders_8;
CREATE TABLE new_table_orders_8 (diapason VARCHAR(20), category VARCHAR(20), value INT);

DELIMITER //
DROP PROCEDURE IF EXISTS create_a_user_card//
CREATE PROCEDURE create_a_user_card (base_range VARCHAR(20))
BEGIN
	-- New - ���������� � 1-� ������� �� ��������� 90 ����.
	DROP TEMPORARY TABLE IF EXISTS new_users;
	CREATE TEMPORARY TABLE new_users AS
	SELECT 
		COUNT(id_o) AS count_id_o,
		user_id,
		price,
		o_date, 
		TIMESTAMPDIFF(DAY, MAX(o_date), base_range) AS days,
		'new'
	FROM new_table_orders
	WHERE o_date <= base_range
	GROUP BY user_id 
	HAVING count_id_o = 1 AND days < 91; 
	
	-- Regular - ���������� � 2+ �������� �� 50000 �., � ������� ���� �� 1 ����� ��� �� ��������� 120 ����.
	DROP TEMPORARY TABLE IF EXISTS regular_users;
	CREATE TEMPORARY TABLE regular_users AS
	SELECT 
		COUNT(id_o) AS count_id_o,
		user_id,
		price,
		SUM(price) AS sum_price,
		o_date,
		TIMESTAMPDIFF(DAY, MAX(o_date), base_range) AS days,
		'regular'
	FROM new_table_orders
	WHERE o_date <= base_range
	GROUP BY user_id 
	HAVING count_id_o > 1 AND price < 50000 AND days < 121;
	
	-- lost - � 1 ������� ������ 90 ���� �����.
	DROP TEMPORARY TABLE IF EXISTS lost_users;
	CREATE TEMPORARY TABLE lost_users AS
	SELECT 
		COUNT(id_o) AS count_id_o,
		user_id,
		price,
		price AS sum_price,
		o_date, 
		TIMESTAMPDIFF(DAY, MAX(o_date), base_range) AS days,
		'lost'
	FROM new_table_orders
	WHERE o_date <= base_range
	GROUP BY user_id 
	HAVING COUNT(*) = 1 AND days >= 91; 
	
	-- ������� � lost ���, � ���� ���� > 1 ������, ��, ���, > 120-�� ���� �����. 
	INSERT INTO lost_users
	SELECT 
		COUNT(id_o) AS count_id_o,
		user_id,
		price,
		SUM(price) AS sum_price,
		o_date,
		TIMESTAMPDIFF(DAY, MAX(o_date), base_range) AS days,
		'lost'
	FROM new_table_orders
	WHERE o_date <= base_range
	GROUP BY user_id 
	HAVING count_id_o > 1 AND price < 50000 AND days >= 121;
	
	-- Vip - ������������, ����������� ������ 2-� ������� �������, �� � ������� ������� ����� ����� �������� ������ 60-�� ����. 
	DROP TEMPORARY TABLE IF EXISTS vip_users;
	CREATE TEMPORARY TABLE vip_users AS
	SELECT 
		COUNT(id_o) AS count_id_o,
		user_id,
		price,
		SUM(price) AS sum_price,
		o_date,
		ROUND(TIMESTAMPDIFF(DAY, MIN(o_date), base_range)/(COUNT(id_o))-1) AS count_days,
		'vip'
	FROM new_table_orders
	WHERE o_date <= base_range
	GROUP BY user_id 
	HAVING COUNT(*) > 1 AND price > 50000 AND count_days > 61;
	
	-- SuperVip - ������������, ����������� ������ 2-� ������� ������� � � ������� ������� ����� ����� �������� �� ������ 60-�� ����.
	DROP TEMPORARY TABLE IF EXISTS supervip_users;
	CREATE TEMPORARY TABLE supervip_users AS
	SELECT 
		COUNT(id_o) AS count_id_o,
		user_id,
		price,
		SUM(price) AS sum_price,
		o_date,
		ROUND(TIMESTAMPDIFF(DAY, MIN(o_date), base_range)/(COUNT(id_o))-1) AS count_days,
		'supervip'
	FROM new_table_orders
	WHERE o_date <= base_range
	GROUP BY user_id 
	HAVING COUNT(*) > 1 AND price > 50000 AND count_days < 61;
	
	-- �������� ��� ��������� ������� � ���� ��� ��������� table_for_base_range
	DROP TABLE IF EXISTS table_for_base_range;
	CREATE TABLE table_for_base_range  AS
	SELECT * FROM(
	SELECT count_id_o, user_id, price AS sum_price, o_date, 'new' AS category FROM new_users
	UNION ALL
	SELECT count_id_o, user_id, sum_price, o_date, 'lost' FROM lost_users
	UNION ALL
	SELECT count_id_o, user_id, sum_price, o_date, 'regular' FROM regular_users
	UNION ALL
	SELECT count_id_o, user_id, sum_price, o_date, 'vip' FROM vip_users
	UNION ALL
	SELECT count_id_o, user_id, sum_price, o_date, 'supervip' FROM supervip_users) t;
	
	-- �������� ���������� ����� � ����� ����� � ������������ �������, ��� ������ ��������� � ���������� ����������� � new_table_orders
	SELECT 
		(SELECT COUNT(DISTINCT user_id) FROM new_table_orders WHERE o_date <= base_range) AS new_table_orders, 
		(SELECT COUNT(*) FROM table_for_base_range) AS table_for_base_range,
		(CASE 
			WHEN (SELECT COUNT(DISTINCT user_id) FROM new_table_orders WHERE o_date <= base_range) = (SELECT COUNT(*) FROM table_for_base_range) THEN 
				'��' 
			ELSE 
				'���' 
		END) AS '���������� ����� ���������?',
		CEILING((SELECT SUM(price) FROM new_table_orders WHERE o_date <= base_range)) AS sum_price_in_new_table_orders, 
		CEILING((SELECT SUM(sum_price) FROM table_for_base_range)) AS sum_price_in_table_for_base_range,
		(CASE
			WHEN CEILING((SELECT SUM(price) FROM new_table_orders WHERE o_date <= base_range)) = CEILING((SELECT SUM(sum_price) FROM table_for_base_range)) THEN
				'��'
			ELSE
				'���'
		END) AS '����� ���������?';
	
	SELECT COUNT(category) FROM table_for_base_range GROUP BY category;
	
	-- ��������� ������� �������� ������� new_table_orders_8
	INSERT INTO new_table_orders_8
	SELECT 
		base_range AS diapason,
		category,
		COUNT(user_id) AS `�� @base_range`
	FROM table_for_base_range
	WHERE o_date <= base_range
	GROUP BY category;
END//
DELIMITER ;

-- � ��������� repeat_call ������� ���������� �������, �������� � 31 ������ 2017-��, ������� ������ �� ����� ������
-- � ��� � ����� ���������� �� ������ � �������� �� ����� ������� �� ����� � ����� ������ � ������� new_table_orders_8
-- �������� � ������ ������ �� �������

DELIMITER //
DROP PROCEDURE IF EXISTS repeat_call//
CREATE PROCEDURE repeat_call()
BEGIN
	DECLARE i INT DEFAULT 6;
	DECLARE start_time VARCHAR(20);
	SET start_time = '2016-12-31';
	REPEAT
		SET start_time = start_time + INTERVAL 1 MONTH;
		CALL create_a_user_card(start_time);
		SET i = i-1;
	UNTIL i <= 0
	END REPEAT;
END//
DELIMITER ;

CALL repeat_call;

-- ���������
SELECT 
	january.category AS category, 
	january.value AS `jan value`,
	february.value AS `feb value`,
	march.value AS `mar value`,
	april.value AS `apr value`,
	may.value AS `may value`,
	june.value AS `june value`,
	ROUND(((february.value/january.value -1)*100 + (march.value/february.value -1)*100 + (april.value/march.value -1)*100
	+ (may.value/april.value -1)*100 + (june.value/may.value -1)*100)/5, 2) AS `changes in indicators`
FROM new_table_orders_8 AS january
JOIN new_table_orders_8 AS february ON january.category = february.category
JOIN new_table_orders_8 AS march ON january.category = march.category 
JOIN new_table_orders_8 AS april ON january.category = april.category 
JOIN new_table_orders_8 AS may ON january.category = may.category 
JOIN new_table_orders_8 AS june ON january.category = june.category 
WHERE 
	MONTH(january.diapason) = 1 AND 
	MONTH(february.diapason) = 2 AND 
	MONTH(march.diapason) = 3 AND 
	MONTH(april.diapason) = 4 AND
	MONTH(may.diapason) = 5 AND
	MONTH(june.diapason) = 6;



/*
- regular - ��� ��������� ��������� ����� �� ����� ���������� � �� 6 ������� ����������� �� ����������. ��� ����������� ������, ������� ����� 
3 ������ � �� ��������. ������� ���� �� ���������� ��� ���������� ����������� � regular, ��� ��� ��� ���������� ���������� ������� ����������� � � �� ����� ������
- new - ��������� � ������ ���� ��������� �� 6,62%, ��� ������� � ����� ��������� ��������� ���-�� ������� (� ����������� ����� � ����). ����� �������� �������� �� ��, 
��� ��� � ����� ���� ����� �������� ������� �����, �������� �� 8-� ����� (����������� ����)
- ��� ���� ���������� ������� ������� �����, ��� ��� ������� ��������� vip � supervip �� 12,4 � 5,85 % ��������������
��� ����������� � � ����� ������ ��������, ������� ������ ����� � ����������� �������� ������ �� ����� �������
- �� � ���������� ��������� (lost) �������� �������������, �� 6 ������� ��������� ������� �� 14,23% � ��������� �����, �.�. ������ ���������� � ������-�� ������� 
���� ������������. ������ ������� ��� ����� ������������� ���� ����� �����������
*/

