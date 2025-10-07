USE kinokatalog;

DELIMITER $$


-- TRIGGERS

CREATE TRIGGER trg_after_insert_review
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
  CALL update_movie_avg_rating(NEW.movie_id);
END $$


CREATE TRIGGER trg_after_delete_review
AFTER DELETE ON reviews
FOR EACH ROW
BEGIN
  CALL update_movie_avg_rating(OLD.movie_id);
END $$


CREATE TRIGGER trg_before_insert_comment
BEFORE INSERT ON comments
FOR EACH ROW
BEGIN
  IF NEW.comment_text IS NULL OR CHAR_LENGTH(TRIM(NEW.comment_text)) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Comment text cannot be empty';
  END IF;
END $$


-- EVENTS

CREATE EVENT IF NOT EXISTS evt_cleanup_unverified_users
ON SCHEDULE EVERY 1 DAY
DO
  DELETE FROM users
  WHERE is_verified = FALSE
  AND created_at < (NOW() - INTERVAL 7 DAY); $$

DELIMITER ;


-- VIEWS

CREATE OR REPLACE VIEW movie_summary_view AS
SELECT
  m.id AS movie_id,
  m.title,
  COUNT(r.id) AS review_count,
  ROUND(AVG(r.rating), 2) AS avg_rating
FROM movies m
LEFT JOIN reviews r ON r.movie_id = m.id
GROUP BY m.id, m.title;


CREATE OR REPLACE VIEW user_profile_view AS
SELECT
  u.id AS user_id,
  u.username,
  COUNT(r.id) AS total_reviews,
  ROUND(AVG(r.rating), 2) AS avg_rating_given
FROM users u
LEFT JOIN reviews r ON r.user_id = u.id
GROUP BY u.id, u.username;


CREATE OR REPLACE VIEW comment_thread_view AS
SELECT
  c.id AS comment_id,
  c.comment_text,
  c.created_at,
  u.username AS commenter,
  r.id AS review_id,
  r.review_text,
  m.title AS movie_title
FROM comments c
JOIN users u ON u.id = c.user_id
JOIN reviews r ON r.id = c.review_id
JOIN movies m ON m.id = r.movie_id;
