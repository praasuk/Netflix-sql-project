-- NETFLIX PROJECT 
-- 15 BUSINESS PROBLEMS 

--1. Count the number of Movies vs TV Shows

SELECT count(*),
type FROM 
netflix 
group by type


-- 2. Find the most common rating for movies and TV shows

 
SELECT type, rating 
FROM (
    SELECT type, rating, COUNT(*) as count, 
           RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
    FROM netflix 
    GROUP BY 1,2 
) as z
WHERE ranking = 1;

-- 3.  List all movies released in a specific year (e.g., 2020)

select title from netflix where  type = 'Movie' and  release_year = 2020\


-- 4. Find the top 5 countries with the most content on Netflix
select  unnest(STRING_TO_ARRAY(country,',')) as new_country, count(show_id)  from netflix
group by new_country
order by count(show_id) desc 
limit 5

--5. Identify the longest movie
select * from netflix 
where
type = 'Movie'
and 
duration = (select max(duration) from netflix)

--6. Find content added in the last 5 years 
select *  from netflix where TO_DATE(date_added,' month DD,YYYY')>= current_date - interval'5 years'

-- 7. . Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from netflix where director like '%Rajiv Chilaka%'

-- 8. List all TV shows with more than 5 seasons
select * from netflix where type = 'TV Show' and split_part(duration,' ',1):: numeric>5 

--9. Count the number of content items in each genre
select  unnest(STRING_TO_ARRAY(listed_in,',')) as genre , count(show_id)  from netflix
group by genre

--10. .Find each year and the average numbers of content release in India on netflix. 

SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5 



--11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries'
 
-- 12. Find all content without a director
select * from netflix  where director is null

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country ilike  '%India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


-- 15Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category. 
ALTER TABLE netflix  ADD COLUMN status TEXT;

UPDATE netflix
SET status = CASE 
                WHEN description  LIKE '%kill%' or description  LIKE '%violence%'  THEN 'Bad'
                ELSE 'Good'
            END;

			
select count(show_id),  status from netflix group by status


