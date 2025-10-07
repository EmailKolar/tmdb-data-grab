USE kinokatalog;

DELIMITER $$


-- STORED FUNCTIONS

CREATE FUNCTION get_avg_rating(p_movie_id INT)
RETURNS DECIMAL(3,2)
DETERMINISTIC
BEGIN
  DECLARE avg_rating DECIMAL(3,2);
  SELECT ROUND(AVG(rating), 2)
  INTO avg_rating
  FROM reviews
  WHERE movie_id = p_movie_id;
  RETURN IFNULL(avg_rating, 0.0);
END $$


CREATE FUNCTION user_review_count(p_user_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM reviews WHERE user_id = p_user_id;
  RETURN total;
END $$


-- STORED PROCEDURES

CREATE PROCEDURE add_review(
  IN p_user_id INT,
  IN p_movie_id INT,
  IN p_rating INT,
  IN p_text TEXT
)
BEGIN
  INSERT INTO reviews (user_id, movie_id, rating, review_text, created_at)
  VALUES (p_user_id, p_movie_id, p_rating, p_text, NOW());

  CALL update_movie_avg_rating(p_movie_id);
END $$


CREATE PROCEDURE update_movie_avg_rating(IN p_movie_id INT)
BEGIN
  DECLARE new_avg DECIMAL(3,2);
  SELECT get_avg_rating(p_movie_id) INTO new_avg;
  UPDATE movies SET average_rating = new_avg WHERE id = p_movie_id;
END $$


CREATE PROCEDURE get_movie_details(IN p_movie_id INT)
BEGIN
  SELECT
    m.id,
    m.title,
    m.release_date,
    m.runtime,
    get_avg_rating(m.id) AS average_rating,
    GROUP_CONCAT(g.name SEPARATOR ', ') AS genres
  FROM movies m
  LEFT JOIN movie_genres mg ON mg.movie_id = m.id
  LEFT JOIN genres g ON g.id = mg.genre_id
  WHERE m.id = p_movie_id
  GROUP BY m.id;
END $$

DELIMITER ;
