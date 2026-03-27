USE booking;

-- Задача 1
SELECT 
	c.name,
	c.email,
	c.phone,
	COUNT(b.ID_customer) AS total_bookings,
	GROUP_CONCAT(DISTINCT h.name ORDER BY h.name) AS visited_hotels,
	AVG(DATEDIFF(b.check_out_date, b.check_in_date)) AS average_days_spent
FROM
	Customer c
JOIN
	Booking b ON c.ID_customer = b.ID_customer
JOIN
	Room r ON b.ID_room = r.ID_room
JOIN
	Hotel h ON r.ID_hotel = h.ID_hotel
GROUP BY
	c.ID_customer,
	c.name,
	c.email,
	c.phone
HAVING
	COUNT(b.ID_customer) > 2
	AND
	COUNT(DISTINCT h.ID_hotel) > 1
ORDER BY
	total_bookings DESC;
	
-- Задача 2
WITH multi_hotel_customers AS (
    SELECT
        c.ID_customer,
        c.name,
        COUNT(b.ID_booking) AS total_bookings,
        COUNT(DISTINCT h.ID_hotel) AS unique_hotels,
        SUM(DATEDIFF(b.check_out_date, b.check_in_date) * r.price) AS total_spent
    FROM 
    	Customer c
    JOIN
    	Booking b ON b.ID_customer = c.ID_customer
    JOIN
    	Room r ON r.ID_room = b.ID_room
    JOIN
    	Hotel h ON h.ID_hotel = r.ID_hotel
    GROUP BY
    	c.ID_customer,
    	c.name
    HAVING 
    	COUNT(b.ID_customer) > 2
       	AND
       	COUNT(DISTINCT h.ID_hotel) > 1
),
high_spenders AS (
    SELECT
        c.ID_customer,
        c.name,
        SUM(DATEDIFF(b.check_out_date, b.check_in_date) * r.price) AS total_spent,
        COUNT(b.ID_booking) AS total_bookings
    FROM
    	Customer c
    JOIN
    	Booking b ON b.ID_customer = c.ID_customer
    JOIN
    	Room r ON r.ID_room = b.ID_room
    GROUP BY
    	c.ID_customer,
        c.name
    HAVING
    	SUM(DATEDIFF(b.check_out_date, b.check_in_date) * r.price) > 500
)
SELECT
    mhc.ID_customer,
    mhc.name,
    mhc.total_bookings,
    mhc.total_spent,
    mhc.unique_hotels
FROM 
	multi_hotel_customers mhc
JOIN
	high_spenders hs ON hs.ID_customer = mhc.ID_customer
ORDER BY
	mhc.total_spent;

-- Задача 3
WITH hotel_categories AS (
    SELECT
        h.ID_hotel,
        h.name AS hotel_name,
        AVG(r.price) AS average_price,
        CASE
            WHEN AVG(r.price) < 175 THEN 'Дешевый'
            WHEN AVG(r.price) BETWEEN 175 AND 300 THEN 'Средний'
            ELSE 'Дорогой'
        END AS hotel_category
    FROM 
    	Hotel h
    JOIN
    	Room r ON r.ID_hotel = h.ID_hotel
    GROUP BY
    	h.ID_hotel,
    	hotel_name
),
customer_hotel_data AS (
    SELECT
        c.ID_customer,
        c.name,
        hc.hotel_category,
        hc.hotel_name
    FROM
    	Customer c
    JOIN
    	Booking b ON b.ID_customer = c.ID_customer
    JOIN
    	Room r ON r.ID_room = b.ID_room
    JOIN 
    	hotel_categories hc ON hc.ID_hotel = r.ID_hotel
),
customer_preferences AS (
    SELECT
        ID_customer,
        name,
        CASE
            WHEN SUM(CASE WHEN hotel_category = 'Дорогой' THEN 1 ELSE 0 END) > 0 THEN 'Дорогой'
            WHEN SUM(CASE WHEN hotel_category = 'Средний' THEN 1 ELSE 0 END) > 0 THEN 'Средний'
            ELSE 'Дешевый'
        END AS preferred_hotel_type,
        GROUP_CONCAT(DISTINCT hotel_name ORDER BY hotel_name) AS visited_hotels
    FROM
    	customer_hotel_data
    GROUP BY
    	ID_customer,
    	name
)
SELECT
    ID_customer,
    name,
    preferred_hotel_type,
    visited_hotels
FROM
	customer_preferences
ORDER BY
    CASE preferred_hotel_type
        WHEN 'Дешевый' THEN 1
        WHEN 'Средний' THEN 2
        WHEN 'Дорогой' THEN 3
    END;
