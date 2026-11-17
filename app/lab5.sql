USE imdb_lab;
SET NAMES utf8mb4;

DROP TRIGGER IF EXISTS trg_awards_bi;
DROP TRIGGER IF EXISTS trg_awards_bu;
DROP TRIGGER IF EXISTS trg_movies_ad_awards;
DROP TRIGGER IF EXISTS trg_movies_ad_log;
DROP TRIGGER IF EXISTS trg_movies_bu_awards;
DROP TRIGGER IF EXISTS trg_ratings_bi;
DROP TRIGGER IF EXISTS trg_ratings_bu;
DROP TRIGGER IF EXISTS trg_countries_bd;

DROP PROCEDURE IF EXISTS sp_insert_person;
DROP PROCEDURE IF EXISTS sp_add_movie_genre;
DROP PROCEDURE IF EXISTS sp_add_movie_country;
DROP PROCEDURE IF EXISTS sp_insert_noname_genres;
DROP PROCEDURE IF EXISTS sp_delete_noname_genres;
DROP PROCEDURE IF EXISTS sp_rating_stat;
DROP PROCEDURE IF EXISTS sp_split_persons_by_cursor;
DROP PROCEDURE IF EXISTS sp_drop_split_tables;
DROP FUNCTION IF EXISTS fn_rating_stat;

DROP TABLE IF EXISTS awards;
DROP TABLE IF EXISTS movie_delete_log;

CREATE TABLE awards (
    award_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    award_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    award_year YEAR NOT NULL,
    INDEX idx_awards_movie (movie_id)
) ENGINE = INNODB;

CREATE TABLE movie_delete_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    release_year YEAR,
    deleted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = INNODB;

DELIMITER $$

CREATE TRIGGER trg_awards_bi BEFORE INSERT ON awards
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM movies WHERE movie_id = NEW.movie_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Фільм із таким movie_id не існує';
    END IF;
END$$

CREATE TRIGGER trg_awards_bu BEFORE UPDATE ON awards
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM movies WHERE movie_id = NEW.movie_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Фільм із таким movie_id не існує';
    END IF;
END$$

CREATE TRIGGER trg_movies_ad_awards AFTER DELETE ON movies
FOR EACH ROW
BEGIN
    DELETE FROM awards WHERE movie_id = OLD.movie_id;
END$$

CREATE TRIGGER trg_movies_bu_awards BEFORE UPDATE ON movies
FOR EACH ROW
BEGIN
    IF NEW.movie_id <> OLD.movie_id
       AND EXISTS (SELECT 1 FROM awards WHERE movie_id = OLD.movie_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Не можна змінити movie_id фільму, що має нагороди';
    END IF;
END$$

CREATE TRIGGER trg_movies_ad_log AFTER DELETE ON movies
FOR EACH ROW FOLLOWS trg_movies_ad_awards
BEGIN
    INSERT INTO movie_delete_log (movie_id, title, release_year, deleted_at)
    VALUES (OLD.movie_id, OLD.title, OLD.release_year, NOW());
END$$

CREATE TRIGGER trg_ratings_bi BEFORE INSERT ON ratings
FOR EACH ROW
BEGIN
    IF NEW.user_name LIKE '%00' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'user_name не може закінчуватися двома нулями';
    END IF;
END$$

CREATE TRIGGER trg_ratings_bu BEFORE UPDATE ON ratings
FOR EACH ROW
BEGIN
    IF NEW.user_name LIKE '%00' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'user_name не може закінчуватися двома нулями';
    END IF;
END$$

CREATE TRIGGER trg_countries_bd BEFORE DELETE ON countries
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Видалення рядків з таблиці countries заборонено';
END$$

DELIMITER ;

INSERT INTO awards (movie_id, award_name, category, award_year) VALUES
 (1, 'Academy Award', 'Best Cinematography', 2011),
 (1, 'Academy Award', 'Best Visual Effects', 2011),
 (2, 'Academy Award', 'Best Supporting Actor', 2009),
 (3, 'Academy Award', 'Best Original Screenplay', 1995),
 (4, 'Academy Award', 'Best Visual Effects', 2015),
 (5, 'Academy Award', 'Best Actress', 2017),
 (6, 'Academy Award', 'Best Visual Effects', 2000),
 (7, 'Academy Award', 'Best Picture', 1995),
 (10, 'Palme d''Or', 'Main Competition', 2019),
 (10, 'Academy Award', 'Best Picture', 2020),
 (11, 'Academy Award', 'Best Picture', 2024),
 (14, 'Academy Award', 'Best Original Song', 2024);

DELIMITER $$

CREATE PROCEDURE sp_insert_person(
    IN p_full_name VARCHAR(150),
    IN p_birth_date DATE,
    IN p_birth_place VARCHAR(150),
    IN p_biography TEXT
)
BEGIN
    IF p_full_name IS NULL OR TRIM(p_full_name) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ім''я особи не може бути порожнім';
    END IF;
    INSERT INTO persons (full_name, birth_date, birth_place, biography)
    VALUES (TRIM(p_full_name), p_birth_date, p_birth_place, p_biography);
    SELECT LAST_INSERT_ID() AS person_id, TRIM(p_full_name) AS full_name;
END$$

CREATE PROCEDURE sp_add_movie_genre(
    IN p_title VARCHAR(255),
    IN p_genre VARCHAR(50)
)
BEGIN
    DECLARE v_movie INT;
    DECLARE v_genre INT;
    SET v_movie = (SELECT movie_id FROM movies WHERE title = p_title ORDER BY movie_id LIMIT 1);
    SET v_genre = (SELECT genre_id FROM genres WHERE name = p_genre LIMIT 1);
    IF v_movie IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Фільм із такою назвою не знайдено';
    END IF;
    IF v_genre IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Жанр із такою назвою не знайдено';
    END IF;
    IF EXISTS (SELECT 1 FROM movie_genres WHERE movie_id = v_movie AND genre_id = v_genre) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Цей жанр уже додано до фільму';
    END IF;
    INSERT INTO movie_genres (movie_id, genre_id) VALUES (v_movie, v_genre);
    SELECT v_movie AS movie_id, p_title AS movie_title, v_genre AS genre_id, p_genre AS genre_name;
END$$

CREATE PROCEDURE sp_add_movie_country(
    IN p_title VARCHAR(255),
    IN p_country VARCHAR(100)
)
BEGIN
    DECLARE v_movie INT;
    DECLARE v_country INT;
    SET v_movie = (SELECT movie_id FROM movies WHERE title = p_title ORDER BY movie_id LIMIT 1);
    SET v_country = (SELECT country_id FROM countries WHERE name = p_country LIMIT 1);
    IF v_movie IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Фільм із такою назвою не знайдено';
    END IF;
    IF v_country IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Країну з такою назвою не знайдено';
    END IF;
    IF EXISTS (SELECT 1 FROM movie_countries WHERE movie_id = v_movie AND country_id = v_country) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ця країна вже додана до фільму';
    END IF;
    INSERT INTO movie_countries (movie_id, country_id) VALUES (v_movie, v_country);
    SELECT v_movie AS movie_id, p_title AS movie_title, v_country AS country_id, p_country AS country_name;
END$$

CREATE PROCEDURE sp_insert_noname_genres()
BEGIN
    DECLARE v_start INT;
    DECLARE v_i INT DEFAULT 0;
    SELECT COALESCE(MAX(CAST(SUBSTRING(name, 7) AS UNSIGNED)), 0) + 1
      INTO v_start
      FROM genres
     WHERE name REGEXP '^Noname[0-9]+$';
    WHILE v_i < 10 DO
        INSERT INTO genres (name) VALUES (CONCAT('Noname', v_start + v_i));
        SET v_i = v_i + 1;
    END WHILE;
    SELECT genre_id, name
      FROM genres
     WHERE name REGEXP '^Noname[0-9]+$'
       AND CAST(SUBSTRING(name, 7) AS UNSIGNED) >= v_start
     ORDER BY genre_id;
END$$

CREATE PROCEDURE sp_delete_noname_genres()
BEGIN
    DECLARE v_deleted INT;
    DELETE FROM genres WHERE name REGEXP '^Noname[0-9]+$';
    SET v_deleted = ROW_COUNT();
    SELECT v_deleted AS deleted_rows;
END$$

CREATE FUNCTION fn_rating_stat(p_func VARCHAR(3))
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_result DECIMAL(12,2);
    CASE UPPER(p_func)
        WHEN 'MAX' THEN SELECT MAX(score) INTO v_result FROM ratings;
        WHEN 'MIN' THEN SELECT MIN(score) INTO v_result FROM ratings;
        WHEN 'SUM' THEN SELECT SUM(score) INTO v_result FROM ratings;
        WHEN 'AVG' THEN SELECT AVG(score) INTO v_result FROM ratings;
        ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Невідома функція: використайте MAX, MIN, SUM або AVG';
    END CASE;
    RETURN v_result;
END$$

CREATE PROCEDURE sp_rating_stat(IN p_func VARCHAR(3))
BEGIN
    SELECT UPPER(p_func) AS func, fn_rating_stat(p_func) AS value;
END$$

CREATE PROCEDURE sp_split_persons_by_cursor()
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_id INT;
    DECLARE v_stamp VARCHAR(40);
    DECLARE v_t1 VARCHAR(100);
    DECLARE v_t2 VARCHAR(100);
    DECLARE v_n1 INT DEFAULT 0;
    DECLARE v_n2 INT DEFAULT 0;
    DECLARE cur CURSOR FOR SELECT person_id FROM persons ORDER BY person_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    SET v_stamp = DATE_FORMAT(NOW(6), '%Y%m%d_%H%i%s_%f');
    SET v_t1 = CONCAT('persons_', v_stamp, '_a');
    SET v_t2 = CONCAT('persons_', v_stamp, '_b');

    SET @ddl_a = CONCAT('CREATE TABLE `', v_t1, '` LIKE persons');
    PREPARE st_a FROM @ddl_a;
    EXECUTE st_a;
    DEALLOCATE PREPARE st_a;

    SET @ddl_b = CONCAT('CREATE TABLE `', v_t2, '` LIKE persons');
    PREPARE st_b FROM @ddl_b;
    EXECUTE st_b;
    DEALLOCATE PREPARE st_b;

    SET @ins_a = CONCAT('INSERT INTO `', v_t1, '` SELECT * FROM persons WHERE person_id = ?');
    SET @ins_b = CONCAT('INSERT INTO `', v_t2, '` SELECT * FROM persons WHERE person_id = ?');
    PREPARE copy_a FROM @ins_a;
    PREPARE copy_b FROM @ins_b;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id;
        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;
        SET @pid = v_id;
        IF RAND() < 0.5 THEN
            EXECUTE copy_a USING @pid;
            SET v_n1 = v_n1 + 1;
        ELSE
            EXECUTE copy_b USING @pid;
            SET v_n2 = v_n2 + 1;
        END IF;
    END LOOP;
    CLOSE cur;

    DEALLOCATE PREPARE copy_a;
    DEALLOCATE PREPARE copy_b;

    SELECT v_t1 AS table_1, v_n1 AS rows_1, v_t2 AS table_2, v_n2 AS rows_2;
END$$

CREATE PROCEDURE sp_drop_split_tables()
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_name VARCHAR(128);
    DECLARE v_count INT DEFAULT 0;
    DECLARE cur CURSOR FOR
        SELECT table_name FROM information_schema.tables
         WHERE table_schema = DATABASE()
           AND table_name REGEXP '^persons_[0-9]{8}_[0-9]{6}_[0-9]{6}_[ab]$';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    OPEN cur;
    drop_loop: LOOP
        FETCH cur INTO v_name;
        IF v_done = 1 THEN
            LEAVE drop_loop;
        END IF;
        SET @ddl_drop = CONCAT('DROP TABLE `', v_name, '`');
        PREPARE st_drop FROM @ddl_drop;
        EXECUTE st_drop;
        DEALLOCATE PREPARE st_drop;
        SET v_count = v_count + 1;
    END LOOP;
    CLOSE cur;

    SELECT v_count AS dropped_tables;
END$$

DELIMITER ;
