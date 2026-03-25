USE racing;

-- Задача 1
WITH cars_stats AS (
	SELECT
		c.name AS car_name,
		c.class AS car_class,
		AVG(r.position) AS average_position,
		COUNT(r.race) AS race_count
	FROM
		Cars c
	JOIN 
		Results r ON c.name = r.car 
	GROUP BY
		c.class,
		c.name
),
best_per_class AS (
	SELECT
		car_class,
		MIN(average_position) AS min_average_position
	FROM
		cars_stats
	GROUP BY
		car_class
)
SELECT
	cs.car_name,
	cs.car_class,
	cs.average_position,
	cs.race_count
FROM
	cars_stats cs
JOIN
	best_per_class bps ON cs.car_class  = bps.car_class
	AND cs.average_position = bps.min_average_position
ORDER BY
	cs.average_position;

-- Задача 2
SELECT
	c.name AS car_name,
	c.class AS car_class,
	AVG(r.position) AS average_position,
	COUNT(r.race) AS race_count,
	cl.country AS car_country
FROM
	Cars c
JOIN
	Results r ON c.name = r.car
JOIN
	Classes cl ON c.class = cl.class 
GROUP BY
	car_name
ORDER BY
	average_position,
	car_name 
LIMIT 1;

-- Задача 3
WITH class_average_position AS (
    SELECT
        c.class,
        AVG(r.position) AS class_avg_position
    FROM
    	Cars c
    JOIN
    	Results r ON c.name = r.car
    GROUP BY
    	c.class
),
min_class_average AS (
    SELECT
    	MIN(class_avg_position) AS min_avg_position
    FROM
    	class_average_position
),
top_classes AS (
    SELECT
    	cap.class
    FROM
    	class_average_position cap
    JOIN
    	min_class_average mca ON cap.class_avg_position = mca.min_avg_position
),
class_total_races AS (
    SELECT
        c.class,
        COUNT(r.race) AS total_races
    FROM
    	Cars c
    JOIN
    	Results r ON c.name = r.car
    WHERE
    	c.class IN (SELECT class FROM top_classes)
    GROUP BY
    	c.class
)
SELECT
    c.name AS car_name,
    c.class AS car_class,
    AVG(r.position) AS average_position,
    COUNT(r.race) AS race_count,
    cl.country AS car_country,
    ctr.total_races
FROM
	Cars c
JOIN
	Classes cl ON c.class = cl.class
JOIN
	Results r  ON c.name  = r.car
JOIN
	class_total_races ctr ON c.class = ctr.class
WHERE
	c.class IN (SELECT class FROM top_classes)
GROUP BY
    c.name,
    c.class,
    cl.country,
    ctr.total_races
ORDER BY
    c.class,
    average_position;

-- Задача 4
WITH cars_stats AS (
	SELECT
		c.name AS car_name,
		c.class AS car_class,
		AVG(r.position) AS average_position,
		COUNT(r.race) AS race_count
	FROM
		Cars c
	JOIN 
		Results r ON c.name = r.car 
	GROUP BY
		c.class,
		c.name
),
classes_stats AS (
    SELECT
        car_class,
        AVG(average_position) AS class_average_position,
        COUNT(car_name) AS cars_in_class
    FROM 
    	cars_stats
    GROUP BY 
    	car_class
    HAVING
    	COUNT(*) >= 2
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cs.race_count,
    cl.country AS car_country
FROM
	cars_stats cs
JOIN
	classes_stats cls ON cs.car_class = cls.car_class
    AND cs.average_position < cls.class_average_position
JOIN
	Classes cl ON cs.car_class = cl.class
ORDER BY
    cs.car_class,
    cs.average_position;

-- Задача 5
WITH cars_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM 
    	Cars c
    JOIN 
    	Results r ON c.name = r.car
    GROUP BY
    	c.class,
    	c.name
),
classes_stats AS (
    SELECT
        car_class,
        SUM(average_position > 3.0) AS low_position_count,
        SUM(race_count) AS total_races
    FROM
    	cars_stats
    GROUP BY
    	car_class
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cl.country AS car_country,
    cs.race_count,
    cls.total_races,
    cls.low_position_count
FROM 
	cars_stats cs
JOIN 
	classes_stats cls ON cs.car_class = cls.car_class
JOIN 
	Classes cl ON cs.car_class = cl.class
WHERE
	cs.average_position > 3.0
ORDER BY
    cls.low_position_count DESC;