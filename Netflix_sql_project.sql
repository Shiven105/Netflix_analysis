-- Project On Netflix

CREATE TABLE netflix
                     (show_id VARCHAR(6), 
					 type	VARCHAR(10),
					 title VARCHAR(150),
					 director VARCHAR(208),
					 casts VARCHAR(800),
					 country	VARCHAR(150),
					 date_added	VARCHAR(50),
					 release_year INT,
					 rating	VARCHAR(10),
					 duration VARCHAR(15),
					 listed_in VARCHAR(25),
					 description VARCHAR(250)
					 );
ALTER TABLE netflix
ALTER COLUMN listed_in TYPE VARCHAR(100);

SELECT * FROM netflix;


SELECT COUNT (*)
AS Total_count
FROM netflix;

SELECT DISTINCT TYPE
FROM netflix;

-- Business problems 
-- 1. Count the number of movies vs TV shows
SELECT  
type,
COUNT(*) AS total_content 
FROM netflix
GROUP BY TYPE;

--2. Find the most common rating for movies and tv shows
SELECT 
type,
rating
FROM
(SELECT
type,
rating,
COUNT(*),
RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking 
FROM netflix
GROUP BY 1 , 2)
AS R1
WHERE ranking = 1;



--3. List all the movies released in specific year (eg 2020)
SELECT * FROM netflix
WHERE
type = 'Movie'
AND
release_year = 2020;

--4. Find top 5 countries with the most content on netflix
SELECT
UNNEST(STRING_TO_ARRAY(COUNTRY, ',')) AS new_country,
COUNT(show_id)  AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q5 Identify the longest movie
SELECT * FROM netflix
WHERE
type = 'Movie'
AND
duration = (SELECT MAX(duration) FROM netflix);


-- Q6 Find content added in the last 5 years           

SELECT *
FROM netflix
WHERE date_added IS NOT NULL
AND TO_DATE(date_added, 'DD-Mon-YY')
    >= CURRENT_DATE - INTERVAL '5 years';
	
-- Q7 Find all the movies/tv shows by director 'rajiv chilaka'
SELECT * FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';


-- Q8 List all TV shows with more than 5 Seasons
SELECT *
FROM netflix
WHERE duration > '5 Season'
AND 
type = 'TV Show';

--Q9 Count the number of content items in each genre
SELECT 
UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1 

-- Q10 List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in ILIKE '%Documentaries%';

-- Q11 Find all content without director
SELECT * 
FROM netflix
WHERE director IS NULL

-- Q12 Find how many movies actor 'SALMAN KHAN' appeared in last 10 years
SELECT * FROM netflix
WHERE casts ILIKE '%Salman khan%'
AND
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- Q13 Find top 10 actors who appeared in the highest number of movies produced in India
SELECT 
--show_id,
--casts,
UNNEST(STRING_TO_ARRAY(casts , ',')) AS actors,
COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Q14 Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. label
--the content containig these words as 'bad' and all other as 'good'. count how many items in each category

WITH new_table
AS
(
SELECT
*,
CASE
WHEN 
description ILIKE '%violence%' OR
description ILIKE '%kills%' THEN 'Bad_content'
ELSE 'Good_content'
END Category
FROM netflix
)
SELECT 
category,
COUNT(*) AS total_content
FROM new_table
GROUP BY  1
