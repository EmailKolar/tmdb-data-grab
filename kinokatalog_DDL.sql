drop database if exists KinoKatalog;
create database KinoKatalog;
use KinoKatalog;

-- USERS
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255),
  is_verified BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  last_login DATETIME,
  role ENUM('USER','ADMIN') DEFAULT 'USER'
);

-- MOVIES
CREATE TABLE movies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tmdb_id INT UNIQUE,
  title VARCHAR(512),
  overview VARCHAR(5000),
  release_date DATE,
  runtime INT,
  average_rating DECIMAL(3,2) DEFAULT 0.00,
  review_count INT DEFAULT 0,
  poster_url VARCHAR(1024),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- REVIEWS
CREATE TABLE reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  movie_id INT NOT NULL,
  rating TINYINT NOT NULL CHECK (rating BETWEEN 0 AND 10),
  review_text VARCHAR(5000),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);

-- WATCHLISTS
CREATE TABLE watchlists (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  movie_id INT NOT NULL,
  added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY ux_watchlist_user_movie (user_id, movie_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);

-- GENRES
CREATE TABLE genres (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL
);

-- PEOPLE
CREATE TABLE people (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tmdb_id INT UNIQUE,
  name VARCHAR(255),
  birth_date DATE,
  bio VARCHAR(5000)
);

-- COMPANIES
CREATE TABLE companies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) UNIQUE,
  origin_country VARCHAR(50)
);

-- COLLECTIONS
CREATE TABLE collections (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(5000),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- TAGS
CREATE TABLE tags (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL
);





-- JOIN TABLES
CREATE TABLE movie_genres (
  movie_id INT,
  genre_id INT,
  PRIMARY KEY (movie_id, genre_id),
  FOREIGN KEY (movie_id) REFERENCES movies(id),
  FOREIGN KEY (genre_id) REFERENCES genres(id)
);

CREATE TABLE movie_cast (
  movie_id INT,
  person_id INT,
  movie_character VARCHAR(255),
  billing_order INT,
  PRIMARY KEY (movie_id, person_id),
  FOREIGN KEY (movie_id) REFERENCES movies(id),
  FOREIGN KEY (person_id) REFERENCES people(id)
);

CREATE TABLE movie_crew (
  movie_id INT,
  person_id INT,
  job VARCHAR(100),
  PRIMARY KEY (movie_id, person_id, job),
  FOREIGN KEY (movie_id) REFERENCES movies(id),
  FOREIGN KEY (person_id) REFERENCES people(id)
);

CREATE TABLE collection_movies (
  collection_id INT,
  movie_id INT,
  PRIMARY KEY (collection_id, movie_id),
  FOREIGN KEY (collection_id) REFERENCES collections(id),
  FOREIGN KEY (movie_id) REFERENCES movies(id)
);

CREATE TABLE movie_tags (
  movie_id INT,
  tag_id INT,
  PRIMARY KEY (movie_id, tag_id),
  FOREIGN KEY (movie_id) REFERENCES movies(id),
  FOREIGN KEY (tag_id) REFERENCES tags(id)
);



