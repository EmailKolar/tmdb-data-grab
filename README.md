

install guide:

1. run kinokatalog_DDL.sql in workbench

2. to fill the database with initial test data run the seed_data.sql script

3. Install Stored Procedures and Functions tbd

4. Create Triggers, Events, and Views tbd






create view for average movie rating

```
CREATE OR REPLACE VIEW movie_ratings AS
SELECT m.id AS movie_id, m.title,
       COUNT(r.id) AS review_count,
       ROUND(AVG(r.rating),2) AS avg_rating
FROM movies m
LEFT JOIN reviews r ON m.id = r.movie_id
GROUP BY m.id, m.title;
```

