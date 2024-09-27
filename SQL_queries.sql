-- MAIN ANALYSIS --
-- 1. Count the number of Movies vs TV Shows
SELECT type,
       COUNT(*) AS total
FROM DATA
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
WITH ranking AS(
	SELECT type,
		   rating,
		   COUNT(*),
		   RANK() OVER (PARTITION BY type ORDER BY COUNT(*) desc) as ranks
	FROM data
	GROUP BY type,rating)
SELECT type,
       rating,
	   ranks
FROM ranking
WHERE ranks = 1
	   
-- 3. List all movies released in a specific year (e.g., 2020)
SELECT type,
       title,
       release_year
FROM data
WHERE release_year = 2020 AND type = 'Movie'

-- 4. Find the top 5 countries with the most content on Netflix
SELECT TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS country_array,
       COUNT(*) AS content
FROM data
GROUP BY country_array
ORDER BY content DESC
LIMIT 5;

-- 5. Identify the longest movie
WITH extract AS (
SELECT DISTINCT title,
       SPLIT_PART(duration,' ',1):: numeric AS duration
FROM data
WHERE type = 'Movie'
)
SELECT * 
FROM extract
WHERE duration = (SELECT MAX(duration) FROM extract)

-- 6. Find content added in the last 5 years
SELECT *
FROM data 
WHERE TO_DATE(date_added, 'DD/MM/YYYY') >= CURRENT_DATE - INTERVAL '5 years' 

-- 7. Find all the movies/TV shows by director 'Christopher Nolan'!
SELECT * 
FROM data
WHERE director ILIKE 'Christopher Nolan'; 

-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM data
WHERE type = 'TV Show'
      AND
	  SPLIT_PART(duration,' ',1):: numeric > 5;
	  
-- 9. Count the number of content items in each genre
SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
       COUNT(show_id)
FROM data
GROUP BY genre;

-- 10.Find each year and the average numbers of content release in United States on netflix. 
-- return top 5 year with highest avg content release!
SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'DD/MM/YYYY')) AS year,
       COUNT(*) AS yearly_content,
	   ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM data WHERE country='United States')::numeric * 100,2) AS avg_content_per_year
FROM data
WHERE country = 'United States'
GROUP BY year
ORDER BY year DESC;

-- 11. List all movies that are documentaries
SELECT *
FROM data
WHERE listed_in ILIKE '%documentaries%'
      
-- 12. Find all content without a director
SELECT *
FROM data
WHERE director IS NULL

-- 13. Find how many movies actor 'Ryan Reynolds' appeared in last 10 years!
SELECT *
FROM data
WHERE casts ILIKE '%Ryan Reynolds%'
      AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in United States.
SELECT UNNEST(STRING_TO_ARRAY(casts,',')) AS actors,
       COUNT(*) AS total_content
FROM data
WHERE type = 'Movie' 
      AND 
	  country ILIKE '%United States%'
GROUP BY actors
ORDER BY total_content DESC
LIMIT 10;

-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
WITH category_col AS (
SELECT *,
       CASE 
	   WHEN description ILIKE '%kill%' OR
	        description ILIKE '%violence%'
	   		THEN 'Bad Content'
	        ELSE 'Good Content'
	   END category
FROM data)
SELECT category,
       COUNT(*) AS total
FROM category_col
GROUP BY category

