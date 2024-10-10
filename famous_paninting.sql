-- 1) Fetch all the paintings which are not displayed on any museums?
	select * from painting.work where museum_id is null;


-- 2) Are there museuems without any paintings?
	select * from painting.museum m
	where not exists (select 1 from painting.work w
					 where w.museum_id=m.museum_id);


-- 3) How many paintings have an asking price of more than their regular price? 
	select * from painting.product_size
	where sale_price > regular_price;


-- 4) Identify the paintings whose asking price is less than 50% of its regular price
	select * 
	from painting.product_size
	where sale_price < (regular_price*0.5);


-- Query to find the canva size with the highest sale price
-- Query to find the canva size with the highest sale price
SELECT cs.label AS canva, ps.sale_price
FROM (
    SELECT size_id, sale_price, RANK() OVER (ORDER BY sale_price DESC) AS rnk
    FROM painting.product_size
) ps
JOIN painting.canvas_size cs ON cs.size_id = ps.size_id
WHERE ps.rnk = 1;

				 


-- 6) Delete duplicate records from work, product_size, subject and image_link tables
DELETE w1
FROM painting.work w1
JOIN (
    SELECT work_id, MIN(work_id) AS min_work_id
    FROM painting.work
    GROUP BY work_id
) w2 ON w1.work_id = w2.work_id AND w1.work_id != w2.min_work_id;

DELETE ps1
FROM painting.product_size ps1
JOIN (
    SELECT work_id, size_id, MIN(size_id) AS min_size_id
    FROM painting.product_size
    GROUP BY work_id, size_id
) ps2 ON ps1.work_id = ps2.work_id AND ps1.size_id = ps2.size_id AND ps1.size_id != ps2.min_size_id;



DELETE s1
FROM painting.subject s1
JOIN (
    SELECT MIN(subject_id) AS min_subject_id, work_id, subject
    FROM painting.subject
    GROUP BY work_id, subject
) s2 ON s1.work_id = s2.work_id AND s1.subject = s2.subject AND s1.subject_id != s2.min_subject_id;


DELETE il1
FROM painting.image_link il1
JOIN (
    SELECT MIN(work_id) AS min_work_id, work_id, image_url
    FROM painting.image_link
    GROUP BY work_id, image_url
) il2 ON il1.work_id = il2.work_id AND il1.image_url = il2.image_url AND il1.work_id != il2.min_work_id;


-- 7) Identify the museums with invalid city information in the given dataset
SELECT * 
FROM painting.museum 
WHERE city REGEXP '^[0-9]';


-- 8) Museum_Hours table has 1 invalid entry. Identify it and remove it.
DELETE mh1
FROM painting.museum_hours mh1
JOIN (
    SELECT MIN(some_column) AS min_value, museum_id, day
    FROM painting.museum_hours
    GROUP BY museum_id, day
) mh2 ON mh1.museum_id = mh2.museum_id 
       AND mh1.day = mh2.day 
       AND mh1.some_column != mh2.min_value;


-- 9) Fetch the top 10 most famous painting subject
SELECT *
FROM (
    SELECT 
        s.subject,
        COUNT(1) AS no_of_paintings,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS ranking
    FROM painting.work w
    JOIN painting.subject s ON s.work_id = w.work_id
    GROUP BY s.subject
) x
WHERE ranking <= 10;


-- 10) Identify the museums which are open on both Sunday and Monday. Display museum name, city.
	SELECT DISTINCT 
    m.name AS museum_name, 
    m.city, 
    m.state, 
    m.country
FROM 
    painting.museum_hours mh 
JOIN 
    painting.museum m ON m.museum_id = mh.museum_id
WHERE 
    mh.day = 'Sunday' 
    AND EXISTS (
        SELECT 1 
        FROM painting.museum_hours mh2 
        WHERE mh2.museum_id = mh.museum_id 
        AND mh2.day = 'Monday'
    );



-- 11) How many museums are open every single day?
SELECT COUNT(1) AS total_museums
FROM (
    SELECT museum_id
    FROM painting.museum_hours
    GROUP BY museum_id
    HAVING COUNT(DISTINCT day) = 7  -- Ensure there are entries for all 7 days
) x;



-- 12) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
	SELECT 
    m.name AS museum, 
    m.city, 
    m.country, 
    x.no_of_paintings
FROM (
    SELECT 
        m.museum_id, 
        COUNT(1) AS no_of_paintings,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM 
        painting.work w
    JOIN 
        painting.museum m ON m.museum_id = w.museum_id
    GROUP BY 
        m.museum_id
) x
JOIN 
    painting.museum m ON m.museum_id = x.museum_id
WHERE 
    x.rnk <= 5;



-- 13) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
	SELECT 
    a.full_name AS artist, 
    a.nationality, 
    x.no_of_paintings
FROM (
    SELECT 
        a.artist_id, 
        COUNT(1) AS no_of_paintings,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM 
        painting.work w
    JOIN 
        painting.artist a ON a.artist_id = w.artist_id
    GROUP BY 
        a.artist_id
) x
JOIN 
    painting.artist a ON a.artist_id = x.artist_id
WHERE 
    x.rnk <= 5;



-- 14) Display the 3 least popular canva sizes
SELECT 
    x.label, 
    x.ranking, 
    x.no_of_paintings
FROM (
    SELECT 
        cs.size_id, 
        cs.label, 
        COUNT(1) AS no_of_paintings,
        DENSE_RANK() OVER (ORDER BY COUNT(1) DESC) AS ranking
    FROM 
        painting.work w
    JOIN 
        painting.product_size ps ON ps.work_id = w.work_id
    JOIN 
        painting.canvas_size cs ON cs.size_id = ps.size_id
    GROUP BY 
        cs.size_id, cs.label
) x
WHERE 
    x.ranking <= 3;


-- 15) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
SELECT 
    museum_name, 
    state AS city, 
    day, 
    open, 
    close, 
    TIMEDIFF(STR_TO_DATE(close, '%h:%i %p'), STR_TO_DATE(open, '%h:%i %p')) AS duration
FROM (
    SELECT 
        m.name AS museum_name, 
        m.state, 
        mh.day, 
        mh.open, 
        mh.close,
        TIMEDIFF(STR_TO_DATE(close, '%h:%i %p'), STR_TO_DATE(open, '%h:%i %p')) AS duration,
        RANK() OVER (ORDER BY TIMEDIFF(STR_TO_DATE(close, '%h:%i %p'), STR_TO_DATE(open, '%h:%i %p')) DESC) AS rnk
    FROM 
        painting.museum_hours mh
    JOIN 
        painting.museum m ON m.museum_id = mh.museum_id
) x
WHERE 
    x.rnk = 1;



-- 16) Which museum has the most no of most popular painting style?
WITH pop_style AS (
    SELECT 
        style,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM 
        painting.work
    GROUP BY 
        style
),
cte AS (
    SELECT 
        w.museum_id,
        m.name AS museum_name,
        ps.style,
        COUNT(1) AS no_of_paintings,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM 
        painting.work w
    JOIN 
        painting.museum m ON m.museum_id = w.museum_id  -- Adjusted table name
    JOIN 
        pop_style ps ON ps.style = w.style
    WHERE 
        w.museum_id IS NOT NULL
        AND ps.rnk = 1
    GROUP BY 
        w.museum_id, m.name, ps.style
)
SELECT 
    museum_name,
    style,
    no_of_paintings
FROM 
    cte 
WHERE 
    rnk = 1;




-- 17) Identify the artists whose paintings are displayed in multiple countries
	WITH cte AS (
    SELECT DISTINCT 
        a.full_name AS artist,
        m.country
    FROM 
        painting.work w
    JOIN 
        painting.artist a ON a.artist_id = w.artist_id
    JOIN 
        painting.museum m ON m.museum_id = w.museum_id
)
SELECT 
    artist,
    COUNT(DISTINCT country) AS no_of_countries  -- Count distinct countries
FROM 
    cte
GROUP BY 
    artist
HAVING 
    COUNT(DISTINCT country) > 1  -- Ensure artists are counted only if they are in more than one country
ORDER BY 
    no_of_countries DESC;  -- Order by the number of countries in descending order



-- 18) Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.
WITH cte_country AS (
    SELECT country, COUNT(1) AS count,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM painting.museum
    GROUP BY country
),
cte_city AS (
    SELECT city, COUNT(1) AS count,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM painting.museum
    GROUP BY city
)
SELECT 
    GROUP_CONCAT(DISTINCT country.country SEPARATOR ', ') AS countries,
    GROUP_CONCAT(DISTINCT city.city SEPARATOR ', ') AS cities
FROM cte_country country
CROSS JOIN cte_city city
WHERE country.rnk = 1
AND city.rnk = 1;



-- 19) Identify the artist and the museum where the most expensive and least expensive painting is placed. 
WITH cte AS (
    SELECT 
        *,
        RANK() OVER (ORDER BY sale_price DESC) AS rnk,
        RANK() OVER (ORDER BY sale_price) AS rnk_asc
    FROM 
        painting.product_size
)
SELECT 
    w.name AS painting,
    cte.sale_price,
    a.full_name AS artist,
    m.name AS museum,
    m.city,
    cz.label AS canvas
FROM 
    cte
JOIN 
    painting.work w ON w.work_id = cte.work_id
JOIN 
    painting.museum m ON m.museum_id = w.museum_id
JOIN 
    painting.artist a ON a.artist_id = w.artist_id
JOIN 
    painting.canvas_size cz ON cz.size_id = cte.size_id
WHERE 
    rnk = 1 OR rnk_asc = 1;
;


-- 20) Which country has the 5th highest no of paintings?
	WITH cte AS (
    SELECT 
        m.country, 
        COUNT(1) AS no_of_Paintings,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM 
        painting.work w
    JOIN 
        painting.museum m ON m.museum_id = w.museum_id
    GROUP BY 
        m.country
)
SELECT 
    country, 
    no_of_Paintings
FROM 
    cte 
WHERE 
    rnk = 5;



-- 21) Which are the 3 most popular and 3 least popular painting styles?
WITH cte AS (
    SELECT 
        style, 
        COUNT(1) AS cnt,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk,
        COUNT(1) OVER () AS no_of_records
    FROM 
        painting.work
    WHERE 
        style IS NOT NULL
    GROUP BY 
        style
)
SELECT 
    style,
    CASE 
        WHEN rnk <= 3 THEN 'Most Popular' 
        ELSE 'Least Popular' 
    END AS remarks
FROM 
    cte
WHERE 
    rnk <= 3 OR rnk > no_of_records - 3;


-- 22) Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.
SELECT full_name AS artist_name, nationality, no_of_paintings
FROM (
    SELECT a.full_name, a.nationality,
           COUNT(1) AS no_of_paintings,
           RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM painting.work w
    JOIN painting.artist a ON a.artist_id = w.artist_id
    JOIN painting.subject s ON s.work_id = w.work_id
    JOIN painting.museum m ON m.museum_id = w.museum_id
    WHERE s.subject = 'Portraits'
      AND m.country != 'USA'
    GROUP BY a.full_name, a.nationality
) x
WHERE rnk = 1;




