-- Netflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(6),
	type  	VARCHAR(10),
	title	VARCHAR(150),
	director VARCHAR(208),	
	casts	 VARCHAR(1000),
	country	 VARCHAR(154),
	date_added	VARCHAR(50),
	release_year	INT,
	rating	VARCHAR(10),
	duration VARCHAR(15),
	listed_in	VARCHAR(150),
	description VARCHAR(250)
);


-- 15 Business Problems
-- 1. Count the number of Movies and TV shows

SELECT 
	type,
	COUNT (*) as total_content
FROM netflix
GROUP BY type

-- 2. Find the most common rating for movies and TV Shows.
SELECT 
	 type,
	 rating
FROM

(
SELECT
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix
GROUP BY 1, 2
) as t1

WHERE ranking = 1

-- 3. List all Movies released in a specific year
SELECT * FROM netflix
WHERE 
	type = 'Movie' 
	AND
	release_year = 2020

-- 4. Find the top 5 countries with the most content on netflix

SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) new_country,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- 5 . Identify the longest movies

SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration)FROM netflix)

-- 6. Find content added in the last 5 years

SELECT 
	*
FROM netflix
WHERE
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'
ORDER BY date_added DESC

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT 
	* 
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'


-- 8. List all TV Shows with more than 5 seasons

SELECT 
	title,
	duration
	--SPLIT_PART(duration, ' ', 1) as season
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1) :: numeric > 5 

-- 9. Count the number of content items in each genre

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) genre,
	COUNT(show_id) total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC

-- 10. Find each year and the average numbers of content released by Canada on netflix. Return top 5 year with highest avg content release

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country ILIKE '%Canada%')::numeric * 100
	, 0) as avg_content_per_year
FROM netflix
WHERE country ILIKE '%Canada%'
GROUP BY 1
ORDER BY 1

-- 11. List all movies that are documentaries.

SELECT 
	* 
FROM netflix
WHERE
	listed_in ILIKE '%Documentaries%'
	AND
	type = 'Movie'
	

-- 12. Find all content wothout a director

SELECT 
	* 
FROM netflix
WHERE
	director IS NULL

--13. Find how many movies actor 'Samuel L. Jackson' appeared in the last 10 years

SELECT 
	*
FROM netflix
WHERE
	type = 'Movie'
	AND
	release_year > EXTRACT (YEAR FROM CURRENT_DATE) - 10
	AND
	casts ILIKE '%Samuel L. Jackson%'

--14. Find the top 10 actors who have appeared in the highest number of movies produced in United States

SELECT 
	--show_id,
	--casts,
	TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) actors,
	COUNT(*) total_content
FROM netflix
WHERE country ILIKE '%United States%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

 /*15. Categorize the content based on the presence of Keywords 'kill' and 'violence' in the description field. 
Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall 
into each category */

WITH new_table 
AS
(
SELECT 
	*, 
	CASE
	WHEN description ILIKE '%kill%' OR
		description ILIKE '%violence%' THEN 'Bad_Content'
		ELSE 'Good_content'
	END category
FROM netflix
)

SELECT
	category,
	COUNT(*) as total_content
FROM new_table
GROUP BY 1














