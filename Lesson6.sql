/*
������� ��������� �� �������� (����� � ������, ��� � ��������� �� ��������).
��� ������ �����������: ��� ���� �����, �����, ����� ������, ����� ������ ������, ����� ���� ��������� �� ������, 
����� ������ ��� ������, ����� ������ � �����, ���������� �����, ��� ������� � ������, ������ � ����������, 
������������� ���, �����������, ���� �������, ����� ����������� ������������, ������ � ��������� � �.�.
��� ��������� - ����������)
 */

-- 1) user_acquisition_channel - ����� �����������
-- 2) clients - �������
-- 3) name_of_the_group_of_clients - ������� �� ������, ���� ����� ������
-- 4) clients_name_of_the_group_of_clients - ������ ����-��-������ ��������-������
-- 5) countries - ������
-- 6) airport_name - ���������
-- 7) countries_airport_name - ������ ����-��-������ ������-���������
-- 8) payment_methods - ������� ������
-- 9) transfer - ���� �������������� ���������
-- 10) cities - ������
-- 11) food_types - ���� �������
-- 12) number_of_rooms - ���������� ������
-- 13) room_types - ���� ������
-- 14) hotel - ���������
-- 15) photo_bank - ��������
-- 16) list_of_tours - ������ �����
-- 17) photo_bank_list_of_tours - ������ ����-�� ������ ���� � ����
-- 18) bonus_programs - �������� ���������
-- 19) ticket - �����
-- 20) payment_methods_ticket - ������ ����-�� ������ ����� � ������� ��� ������
-- 21) ticket_status - ������ ������ (����)
-- 22) ticket_bonus_programs - ������ ����-��-������ �����-�������� ���������


DROP DATABASE IF EXISTS databases_for_analysts;
CREATE DATABASE databases_for_analysts;
USE databases_for_analysts;

DROP TABLE IF EXISTS user_acquisition_channel;
CREATE TABLE user_acquisition_channel(
	id INT,
	name CHAR COMMENT '�������� �������',
	
	INDEX(id)
) COMMENT '������ �����������';


DROP TABLE IF EXISTS clients;
CREATE TABLE clients(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
	firstname VARCHAR(100) NOT NULL COMMENT '���',
	lastname VARCHAR(100) COMMENT '�������',
	phone BIGINT UNSIGNED UNIQUE NOT NULL COMMENT '�������',
	email VARCHAR(100) UNIQUE COMMENT '�����',
	address TEXT COMMENT '�����',
	comment TEXT DEFAULT NULL COMMENT '�����������',
	created_at DATETIME DEFAULT NOW() COMMENT '���� ����������� ���������',
	updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP COMMENT '���� ��������� ������ � ���������',
	user_acquisition_channel INT COMMENT '����� �����������',
	
	CONSTRAINT sh_phone_check CHECK (REGEXP_LIKE(phone, '^[0-9]{11}$')),
	CONSTRAINT sh_email_check CHECK (REGEXP_LIKE(email, '^((([0-9A-Za-z]{1}[-0-9A-z\.]{0,30}[0-9A-Za-z]?)|([0-9�-��-�]{1}[-0-9�-�\.]{0,30}[0-9�-��-�]?))@([-A-Za-z]{1,}\.){1,}[-A-Za-z]{2,})$')),
	CONSTRAINT fk_user_acquisition_channel FOREIGN KEY (user_acquisition_channel) REFERENCES user_acquisition_channel(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT '�������-���������';


DROP TABLE IF EXISTS name_of_the_group_of_clients;
CREATE TABLE name_of_the_group_of_clients(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
	name VARCHAR(200) COMMENT '�������� �����',
	
	INDEX (id)
) COMMENT '���� ����� ������';


DROP TABLE IF EXISTS clients_name_of_the_group_of_clients;
CREATE TABLE clients_name_of_the_group_of_clients(
	id_group BIGINT UNSIGNED NOT NULL,
	id_client BIGINT UNSIGNED NOT NULL,
	
	CONSTRAINT fk_id_group_p_g FOREIGN KEY (id_group) REFERENCES name_of_the_group_of_clients(id),
	CONSTRAINT fk_id_client_p_g FOREIGN KEY (id_client) REFERENCES clients(id)
) COMMENT '������ ����-��-������ ��������-������';


DROP TABLE IF EXISTS countries;
CREATE TABLE countries(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
	name VARCHAR(200) COMMENT '��������',
	
	INDEX (id)
) COMMENT '������';


DROP TABLE IF EXISTS airport_name;
CREATE TABLE airport_name(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
	name VARCHAR(200) COMMENT '��������',
	
	INDEX (id)
) COMMENT '��������';


DROP TABLE IF EXISTS countries_airport_name;
CREATE TABLE countries_airport_name(
	id_countries BIGINT UNSIGNED NOT NULL,
	id_airport_name BIGINT UNSIGNED NOT NULL,
	
	CONSTRAINT fk_id_countries FOREIGN KEY (id_countries) REFERENCES countries(id),
	CONSTRAINT fk_id_airport_name FOREIGN KEY (id_airport_name) REFERENCES airport_name(id)
) COMMENT '����-��-������ ������-��������';


DROP TABLE IF EXISTS payment_methods;
CREATE TABLE payment_methods(
	id INT,
	name VARCHAR(100) COMMENT '�������� ��������',
	
	INDEX(id)
) COMMENT '������� ������';


DROP TABLE IF EXISTS transfer;
CREATE TABLE transfer(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
	transfer_in_the_country BIGINT UNSIGNED NOT NULL,
	transfer_in_the_airport BIGINT UNSIGNED NOT NULL,
	
	INDEX (id),
	CONSTRAINT fk_transfer_in_the_country FOREIGN KEY (transfer_in_the_country) REFERENCES countries(id),
	CONSTRAINT fk_transfer_in_the_airport FOREIGN KEY (transfer_in_the_airport) REFERENCES airport_name(id)
) COMMENT '���� �������������� ���������';


DROP TABLE IF EXISTS cities;
CREATE TABLE cities(
	id_city INT,
	name VARCHAR(200) COMMENT '��������',
	
	INDEX (id_city)
) COMMENT '�������� �������';


DROP TABLE IF EXISTS food_types;
CREATE TABLE food_types(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT,
	name VARCHAR(100) COMMENT '��������',
	description TEXT COMMENT '��������',
	
	INDEX (id)
) COMMENT '���� �������';


DROP TABLE IF EXISTS number_of_rooms;
CREATE TABLE number_of_rooms(
	number_of_rooms INT COMMENT '����������',
	
	INDEX (number_of_rooms)
) COMMENT '���������� ������';


DROP TABLE IF EXISTS room_types;
CREATE TABLE room_types(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT,
	title VARCHAR(100) COMMENT '������� ��������',
	number_of_rooms INT COMMENT '���-�� ������',
	description TEXT COMMENT '��������',
	
	INDEX(id),
	CONSTRAINT fk_number_of_rooms FOREIGN KEY (number_of_rooms) REFERENCES number_of_rooms(number_of_rooms) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT '���� ������';


DROP TABLE IF EXISTS hotel;
CREATE TABLE hotel(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(300) COMMENT '��������',
	city INT COMMENT '�����',
	address TEXT COMMENT '�����',
	hotel_category ENUM ('not category', '*', '**', '***', '****', '*****') COMMENT '���-�� ����',
	food_type INT UNSIGNED NOT NULL COMMENT '��� ���',
	room_types INT UNSIGNED NOT NULL COMMENT '��� ������',
	description TEXT DEFAULT NULL COMMENT '��������',
	
	CONSTRAINT fk_city FOREIGN KEY (city) REFERENCES cities(id_city) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_food_type FOREIGN KEY (food_type) REFERENCES food_types(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_room_types FOREIGN KEY (room_types) REFERENCES room_types(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT '���������';


DROP TABLE IF EXISTS photo_bank;
CREATE TABLE photo_bank(
	id BIGINT,
	photo_link VARCHAR(200) COMMENT '������ �� ����',
	
	INDEX (id)
) COMMENT '��������';


DROP TABLE IF EXISTS list_of_tours;
CREATE TABLE list_of_tours(
	id INT,
	title VARCHAR(350) COMMENT '�������� �����',
	description TEXT COMMENT '��������',
	special_notes TEXT COMMENT '������ �������',
	a_photo BIGINT DEFAULT NULL COMMENT '����',
	
	INDEX (id)
) COMMENT '������ �����';


DROP TABLE IF EXISTS photo_bank_list_of_tours;
CREATE TABLE photo_bank_list_of_tours(
	id_photo_bank BIGINT,
	id_tour INT,
	
	CONSTRAINT fk_id_photo_bank FOREIGN KEY (id_photo_bank) REFERENCES photo_bank(id),
	CONSTRAINT fk_id_tour FOREIGN KEY (id_tour) REFERENCES list_of_tours(id)
) COMMENT '����-��-������ ���� � �����';


DROP TABLE IF EXISTS bonus_programs;
CREATE TABLE bonus_programs(
	id BIGINT,
	title VARCHAR(250) COMMENT '��� ���������',
	description TEXT DEFAULT NULL COMMENT '��������',
	
	INDEX (id)
) COMMENT '������ �������� ��������';


DROP TABLE IF EXISTS ticket;
CREATE TABLE ticket(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name_travel INT COMMENT '�������� ����',
	ticket_issue_date DATETIME DEFAULT NOW() COMMENT '����� ���������� ������',
	date_and_time_of_flight DATETIME NOT NULL COMMENT '���� � ����� �����',
	client_id BIGINT UNSIGNED NOT NULL COMMENT '������',
	id_countries BIGINT UNSIGNED NOT NULL COMMENT '� ������',
	id_airport_name BIGINT UNSIGNED NOT NULL COMMENT '� ��������',
	is_there_a_transplant BIGINT UNSIGNED DEFAULT NULL COMMENT '���� �� ���������',
	need_for_a_visa ENUM('yes', 'no') COMMENT '����� �� ����',
	restrictions TEXT DEFAULT NULL COMMENT '�����������',
	purpose_of_travel TEXT DEFAULT NULL COMMENT '���� �������',
	hotel BIGINT UNSIGNED NOT NULL COMMENT '���������',
	price DECIMAL(10, 2) NOT NULL COMMENT '����',
	bonus_program BIGINT DEFAULT NULL COMMENT '�������� ���������',
	payment_methods BIGINT UNSIGNED NOT NULL COMMENT '������ ������',
	
	CONSTRAINT fk_client_id FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_id_countries_ticket FOREIGN KEY (id_countries) REFERENCES countries(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_id_airport_name_ticket FOREIGN KEY (id_airport_name) REFERENCES airport_name(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_hotel FOREIGN KEY (hotel) REFERENCES hotel(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_name_travel FOREIGN KEY (name_travel) REFERENCES list_of_tours(id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT '�����';


DROP TABLE IF EXISTS payment_methods_ticket;
CREATE TABLE  payment_methods_ticket(
	id_payment_methods INT,
	id_ticket BIGINT UNSIGNED NOT NULL,
	
	CONSTRAINT fk_pt_id_payment_methods FOREIGN KEY (id_payment_methods) REFERENCES payment_methods(id),
	CONSTRAINT fk_pt_id_ticket FOREIGN KEY (id_ticket) REFERENCES ticket(id)
) COMMENT '�������� ����-��-������ ���-������';


DROP TABLE IF EXISTS ticket_status;
CREATE TABLE ticket_status(
	id_ticket BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
	status ENUM('�����', '� ������', '��������', '������') COMMENT  '������',
	
	CONSTRAINT fk_ts_id_ticket FOREIGN KEY (id_ticket) REFERENCES ticket(id)
) COMMENT '������ ������ (����)';


DROP TABLE IF EXISTS ticket_bonus_programs;
CREATE TABLE ticket_bonus_programs(
	id_ticket BIGINT UNSIGNED NOT NULL,
	id_bonus_program BIGINT,

	CONSTRAINT fk_id_bonus_program FOREIGN KEY (id_bonus_program) REFERENCES bonus_programs(id),
	CONSTRAINT fk_id_ticket FOREIGN KEY (id_ticket) REFERENCES ticket(id)
) COMMENT '�������� ����-��-������';


