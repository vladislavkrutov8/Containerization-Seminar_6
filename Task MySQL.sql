/*
3. 
.
5. 
6. Объединить все таблицы в одну, при этом сохраняя поля, указывающие на прошлую принадлежность к старым таблицам.*/

# В подключенном MySQL репозитории создать базу данных “Друзья человека”
DROP SCHEMA IF EXISTS Human_friends;
CREATE DATABASE Human_friends;
USE Human_friends;

#Создать таблицы с иерархией из диаграммы в БД
DROP TABLE IF EXISTS animal_classes;
CREATE TABLE animal_classes
(
	Id INT AUTO_INCREMENT PRIMARY KEY, 
	Class_name VARCHAR(20)
);
INSERT INTO animal_classes (Class_name)
VALUES ('PackAnimals'),
('Pets');  
DROP TABLE IF EXISTS pack_animals;
CREATE TABLE pack_animals
(
	Id INT AUTO_INCREMENT PRIMARY KEY,
    Genus_name VARCHAR (20),
    Class_id INT,
    FOREIGN KEY (Class_id) REFERENCES animal_classes (Id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO pack_animals (Genus_name, Class_id)
VALUES ('Horses', 1),
('Donkeys', 1),  
('Camels', 1); 
DROP TABLE IF EXISTS pets;
CREATE TABLE pets
(
	  Id INT AUTO_INCREMENT PRIMARY KEY,
    Genus_name VARCHAR (20),
    Class_id INT,
    FOREIGN KEY (Class_id) REFERENCES animal_classes (Id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO pets (Genus_name, Class_id)
VALUES ('Cats', 2),
('Dogs', 2),  
('Hamsters', 2); 


#Заполнить низкоуровневые таблицы именами(животных), командами которые они выполняют и датами рождения
CREATE TABLE cats 
(       
    Id INT AUTO_INCREMENT PRIMARY KEY, 
    Name VARCHAR(20), 
    Birthday DATE,
    Commands VARCHAR(50),
    Genus_id int,
    Foreign KEY (Genus_id) REFERENCES pets (Id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO cats (Name, Birthday, Commands, Genus_id)
VALUES ('Барсик', '2011-01-01', 'кс-кс-кс', 1),
('Муся', '2016-01-01', "отставить!", 1),  
('Тишка', '2017-01-01', "", 1); 

CREATE TABLE dogs 
(       
    Id INT AUTO_INCREMENT PRIMARY KEY, 
    Name VARCHAR(20), 
    Birthday DATE,
    Commands VARCHAR(50),
    Genus_id int,
    Foreign KEY (Genus_id) REFERENCES pets (Id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO dogs (Name, Birthday, Commands, Genus_id)
VALUES ('Барбос', '2020-01-01', 'ко мне, лежать, лапу, голос', 2),
('Барон', '2022-06-12', "сидеть, лежать, лапу", 2),  
('Шарик', '2019-03-01', "сидеть, лежать, лапу, след, фас", 2), 
('Лайка', '2020-05-10', "сидеть, лежать, фу, место", 2);

CREATE TABLE hamsters 
(       
    Id INT AUTO_INCREMENT PRIMARY KEY, 
    Name VARCHAR(20), 
    Birthday DATE,
    Commands VARCHAR(50),
    Genus_id int,
    Foreign KEY (Genus_id) REFERENCES pets (Id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO hamsters (Name, Birthday, Commands, Genus_id)
VALUES ('Дуся', '2020-10-12', '', 3),
('Пуся', '2021-03-12', "атака сверху", 3),  
('Нуся', '2022-07-11', NULL, 3), 
('Люся', '2022-05-10', NULL, 3);

CREATE TABLE horses 
(       
    Id INT AUTO_INCREMENT PRIMARY KEY, 
    Name VARCHAR(20), 
    Birthday DATE,
    Commands VARCHAR(50),
    Genus_id int,
    Foreign KEY (Genus_id) REFERENCES pack_animals (Id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO horses (Name, Birthday, Commands, Genus_id)
VALUES ('Пикник', '2020-01-12', 'бегом, шагом', 1),
('Марс', '2017-03-12', "бегом, шагом, хоп", 1),  
('Сникерс', '2016-07-12', "бегом, шагом, хоп, брр", 1), 
('Натс', '2020-11-10', "бегом, шагом, хоп", 1);

CREATE TABLE donkeys 
(       
    Id INT AUTO_INCREMENT PRIMARY KEY, 
    Name VARCHAR(20), 
    Birthday DATE,
    Commands VARCHAR(50),
    Genus_id int,
    Foreign KEY (Genus_id) REFERENCES pack_animals (Id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO donkeys (Name, Birthday, Commands, Genus_id)
VALUES ('Первый', '2019-04-10', NULL, 2),
('Второй', '2020-03-12', "", 2),  
('Третий', '2021-07-12', "", 2), 
('Четвертый', '2022-12-10', NULL, 2);

CREATE TABLE camels 
(       
    Id INT AUTO_INCREMENT PRIMARY KEY, 
    Name VARCHAR(20), 
    Birthday DATE,
    Commands VARCHAR(50),
    Genus_id int,
    Foreign KEY (Genus_id) REFERENCES pack_animals (Id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO camels (Name, Birthday, Commands, Genus_id)
VALUES ('Лохматый', '2022-04-10', 'вернись', 3),
('Лысый', '2019-03-12', "остановись", 3),  
('Бородатый', '2015-07-12', "плевок", 3), 
('Хвостатый', '2022-12-10', "улыбнись", 3);

#  Удалив из таблицы верблюдов, т.к. верблюдов решили перевезти в другой питомник на зимовку. 
SET SQL_SAFE_UPDATES = 0;
DELETE FROM camels;

# Объединить таблицы лошади, и ослы в одну таблицу.
SELECT * FROM horses
UNION
SELECT * FROM donkeys;

# Создать новую таблицу “молодые животные” в которую попадут все животные старше 1 года, но младше 3 лет и в отдельном столбце с точностью до месяца подсчитать возраст животных в новой таблице
CREATE VIEW all_animals AS
SELECT * FROM horses
UNION
SELECT * FROM donkeys
UNION
SELECT * FROM dogs
UNION
SELECT * FROM cats
UNION
SELECT * FROM hamsters;

DROP TABLE IF EXISTS young_animals;
CREATE TABLE young_animals
SELECT Id, Name, Birthday, Commands, Genus_id, TIMESTAMPDIFF(MONTH, Birthday, CURDATE()) AS Age_in_monthss
FROM all_animals
WHERE Birthday BETWEEN ADDDATE(curdate(), INTERVAL -3 YEAR) AND ADDDATE(CURDATE(), INTERVAL -1 YEAR);

# Объединить все таблицы в одну, при этом сохраняя поля, указывающие на прошлую принадлежность к старым таблицам

SELECT h.Name, h.Birthday, h.Commands, pa.Genus_name, ya.Age_in_months 
FROM horses h
LEFT JOIN young_animals ya ON ya.Name = h.Name
LEFT JOIN pack_animals pa ON pa.Id = h.Genus_id
UNION 
SELECT d.Name, d.Birthday, d.Commands, pa.Genus_name, ya.Age_in_months 
FROM donkeys d 
LEFT JOIN young_animals ya ON ya.Name = d.Name
LEFT JOIN pack_animals pa ON pa.Id = d.Genus_id
UNION
SELECT c.Name, c.Birthday, c.Commands, ha.Genus_name, ya.Age_in_months 
FROM cats c
LEFT JOIN young_animals ya ON ya.Name = c.Name
LEFT JOIN pets ha ON ha.Id = c.Genus_id
UNION
SELECT d.Name, d.Birthday, d.Commands, ha.Genus_name, ya.Age_in_months 
FROM dogs d
LEFT JOIN young_animals ya ON ya.Name = d.Name
LEFT JOIN pets ha ON ha.Id = d.Genus_id
UNION
SELECT hm.Name, hm.Birthday, hm.Commands, ha.Genus_name, ya.Age_in_months 
FROM hamsters hm
LEFT JOIN young_animals ya ON ya.Name = hm.Name
LEFT JOIN pets ha ON ha.Id = hm.Genus_id;