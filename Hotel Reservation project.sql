-- Define a VIEW named 'hotels' that combines data from three tables (2018, 2019, 2020):
CREATE VIEW dbo.hotels AS
SELECT * FROM dbo.h2018
UNION
SELECT * FROM dbo.h2019
UNION
SELECT * FROM dbo.h2020;


-- Now, we can query the 'Hotels' view as if it's a table.
SELECT * FROM hotels;


-- The total number of nights stayed by guests
SELECT stays_in_weekend_nights + stays_in_week_nights AS Total_Nights
FROM hotels


-- The yearly total revenue from both weekend and weekday stays
SELECT arrival_date_year,arrival_date_month,
(stays_in_weekend_nights + stays_in_week_nights)*adr AS Revenue
FROM hotels


-- The total revenue generated for all stays in the data(years--> 2018, 2019, and 2020)
SELECT ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights)*adr),0) AS Revenue
FROM hotels


-- The total revenue per year
SELECT arrival_date_year,
ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights)*adr),0) AS Revenue -- rounded to the nearest integer
FROM hotels
GROUP BY arrival_date_year


-- Total Revenue per year, broken down by hotel type
SELECT arrival_date_year,hotel,
ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights)*adr),0) AS Revenue
FROM hotels
GROUP BY arrival_date_year,hotel


-- Adding meal cost and market segment information using JOIN
SELECT *
FROM hotels h LEFT JOIN meal_cost mc
ON h.meal = mc.meal
LEFT JOIN market_segment ms
ON h.market_segment = ms.market_segment

-- Meal cost variation for each customer type
SELECT
	h.customer_type,
	ROUND(AVG(mc.Cost),0) AS average_meal_cost
FROM hotels AS h
LEFT JOIN meal_cost mc
on h.meal = mc.meal
GROUP BY h.customer_type
ORDER BY average_meal_cost DESC;


-- The profit percentage for each month across all years
SELECT 
	arrival_date_year , arrival_date_month,
	SUM ((stays_in_week_nights + stays_in_weekend_nights) * adr) AS Revenue
FROM 
	hotels
GROUP BY
	arrival_date_year , arrival_date_month
ORDER BY 
	arrival_date_year ,
    MONTH(CONVERT(DATE, CONCAT('01-', arrival_date_month, '-', arrival_date_year))) -- converting data type of month (str => data)


--  meals and market segments contribute the most to the total revenue for each hotel annually
SELECT
	hotel,
	market_segment,
	meal,arrival_date_year,
	COUNT(*) AS Total_reservation,
	ROUND(SUM ((stays_in_week_nights + stays_in_weekend_nights) * adr),0) AS Revenue
FROM 
	hotels 
GROUP BY 
	arrival_date_year,hotel, market_segment, meal
ORDER BY 
	arrival_date_year


-- Compare the total revenue between weekdays and weekends
SELECT 
	hotel, arrival_date_year,
	ROUND(SUM(stays_in_week_nights * adr),0) AS Weekdays_revenue,
	ROUND(SUM(stays_in_weekend_nights * adr),0) AS Weekends_revenue
FROM
    hotels
GROUP BY
	hotel, arrival_date_year


-- Compare the total revenue between public holidays and regular days each year
SELECT 
    arrival_date_year,
    CASE 
        WHEN CONVERT(DATE, CONCAT(arrival_date_year, '-', arrival_date_month, '-',arrival_date_day_of_month)) 
             IN ('2018-07-04', '2018-09-03', '2018-10-08', '2018-11-11', '2018-11-22', '2018-12-25',
                 '2019-01-01', '2019-01-21', '2019-02-18', '2019-05-27', '2019-07-04', '2019-09-02', 
                 '2019-10-14', '2019-11-11', '2019-11-28',
                 '2020-01-01', '2020-01-20', '2020-02-17', '2020-05-25', '2020-07-04', '2020-09-07', 
                 '2020-10-12', '2020-11-11', '2020-11-26') THEN 'Public Holiday'
        ELSE 'Normal Day'
    END AS Day_type,
    COUNT(*) AS Number_of_Days, 
	SUM((stays_in_week_nights + stays_in_weekend_nights)*adr )AS Total_Revenue 
FROM 
    hotels
GROUP BY 
    arrival_date_year, 
    CASE 
        WHEN CONVERT(DATE, CONCAT(arrival_date_year, '-', arrival_date_month,'-',arrival_date_day_of_month)) 
             IN ('2018-07-04', '2018-09-03', '2018-10-08', '2018-11-11', '2018-11-22', '2018-12-25',
                 '2019-01-01', '2019-01-21', '2019-02-18', '2019-05-27', '2019-07-04', '2019-09-02', 
                 '2019-10-14', '2019-11-11', '2019-11-28',
                 '2020-01-01', '2020-01-20', '2020-02-17', '2020-05-25', '2020-07-04', '2020-09-07', 
                 '2020-10-12', '2020-11-11', '2020-11-26') THEN 'Public Holiday'
        ELSE 'Normal Day'
    END;


--  The key factors (e.g., hotel type, market type, meals offered, number of nights booked) significantly impact hotel revenue annually?
SELECT
    arrival_date_year ,
    hotel ,
    market_segment,
    meal ,
	COUNT(*) AS Total_reservation,
    SUM(stays_in_week_nights + stays_in_weekend_nights) AS Total_Night,
    SUM((stays_in_week_nights + stays_in_weekend_nights) * adr) AS Total_Revenue
FROM
    hotels 
GROUP BY
	arrival_date_year,
    hotel,
    market_segment,
    meal
ORDER BY
    arrival_date_year,
    Total_Revenue DESC;


-- The yearly trends in customer preferences for room types, and how do these preferences influence revenue
SELECT
    arrival_date_year ,
    CASE 
        WHEN adults >=2 and children > 0 THEN 'Family Room'
		WHEN adults =2 and children = 0 THEN 'Double Room'
		WHEN adults =3 and children = 0 THEN 'Triple Room'
		WHEN adults =4 and children = 0 THEN 'Quarter Room'
        ELSE 'Single Room'
    END AS Room_type,
    COUNT(*) AS Total_reservation,
    ROUND(SUM((stays_in_week_nights + stays_in_weekend_nights) * adr),0) AS Total_revenue
FROM
    hotels 
GROUP BY
    arrival_date_year,
    CASE 
		 WHEN adults >=2 and children > 0 THEN 'Family Room'
		WHEN adults =2 and children = 0 THEN 'Double Room'
		WHEN adults =3 and children = 0 THEN 'Triple Room'
		WHEN adults =4 and children = 0 THEN 'Quarter Room'
        ELSE 'Single Room'
    END
ORDER BY
    arrival_date_year, Total_revenue DESC;


--  The percentage of cancelled bookings per year for each hotel and segment:
SELECT
	hotel,
    arrival_date_year,
	market_segment,
    COUNT(*) AS Total_reservation,
    SUM(CASE 
		WHEN is_canceled = 1 THEN 1
		ELSE 0 
		END) AS Total_cancelation,
    ROUND((SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END) * 100) / COUNT(*),0) AS Cancelation_percentage
FROM
    hotelS
GROUP BY
    arrival_date_year,hotel,market_segment
ORDER BY
    arrival_date_year;


-- Relation between cancelation rate and lead time for each hotel per year
SELECT 
	arrival_date_year,hotel,
	CASE 
		WHEN lead_time <= 50 THEN '0-50 Days'
		WHEN lead_time > 50 AND lead_time <= 200 THEN '51-200 Days'
		ELSE 'More than 201 Days'
	END AS lead_time_range,
	SUM(CASE 
	WHEN is_canceled = 1 THEN 1 
	ELSE 0 
	END) AS NO_of_cancelation,
	COUNT(*) AS total_recervation,
	ROUND((SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END) * 100 ) / COUNT(*),0) AS cancellation_rate
FROM
	hotels
GROUP BY 
	arrival_date_year,hotel,
	CASE 
		WHEN lead_time <= 50 THEN '0-50 Days'
		WHEN lead_time > 50 AND lead_time <= 200 THEN '51-200 Days'
		ELSE 'More than 201 Days'
	END 
ORDER BY
	cancellation_rate DESC;


-- Repeated guest
SELECt
	hotel,
	arrival_date_year,
	market_segment,
	COUNT(*) AS Total_reservation,
    SUM(CASE 
		WHEN is_repeated_guest = 1 THEN 1
		ELSE 0 
		END) AS No_of_repeated_guest,
    ROUND((SUM(CASE WHEN is_repeated_guest = 1 THEN 1 ELSE 0 END) * 100) / COUNT(*),0) AS percent_of_repeated_guest
FROM
    hotels
GROUP BY
    arrival_date_year,hotel,market_segment


-- Impact of offering free stays or promotions on recervation
SELECT
	arrival_date_year,hotel,
    CASE 
        WHEN market_segment = 'Complementary' THEN 'Promoted stay'
        ELSE 'UN promoted stay '
    END AS Reservation_type,
    COUNT(*) AS Total_reservation,
    SUM((stays_in_week_nights + stays_in_weekend_nights) * adr) AS Total_revenue
FROM
    hotels
GROUP BY
	arrival_date_year,hotel,
    CASE 
		WHEN market_segment = 'Complementary' THEN 'Promoted stay'
        ELSE 'UN promoted stay '
    END;


