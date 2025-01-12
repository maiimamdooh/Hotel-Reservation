--- take a look on the data
SELECT * FROM hotels;


--- creating a new table to do the cleaning on it 
SELECT *
INTO Temp_All_Hotel
FROM hotels;

SELECT * FROM Temp_All_Hotel;


--- fix reservation_status_date type
UPDATE Temp_All_Hotel
SET reservation_status_date = NULL
WHERE reservation_status_date = '00:00.0';

ALTER TABLE Temp_ALL_Hotel
ALTER COLUMN reservation_status_date DATE;

--- to ensure that all months have the same formate
SELECT DISTINCT arrival_date_month
FROM Temp_All_Hotel

--- deal with null vallue
UPDATE Temp_All_Hotel
SET agent = 0
WHERE agent IS NULL;

UPDATE Temp_All_Hotel
SET company = 0
WHERE company IS NULL;

--- there is a rest null vallue in company collumn that not recoginzed
SELECT *
FROM Temp_All_Hotel
where company not IN ('NULL', 0)

UPDATE Temp_All_Hotel
SET company = 0
WHERE company = 'NULL';

SELECT DISTINCT company 
FROM Temp_All_Hotel
------------------------------------------
--- discover is_canceled column
SELECT DISTINCT is_canceled
FROM Temp_All_Hotel

SELECT *
FROM Temp_All_Hotel
WHERE is_canceled IS NULL
---> one null value with no name hotel so we maybe delete it

DELETE Temp_All_Hotel
WHERE is_canceled IS NULL

-----------------------------------------
--- discover hotel column
SELECT DISTINCT hotel
FROM Temp_All_Hotel

SELECT *
FROM Temp_All_Hotel
WHERE hotel IS NULL  ---> no null value
----------------------------------------
SELECT *
FROM Temp_All_Hotel
WHERE lead_time IS NULL
OR arrival_date_day_of_month IS NULL 
OR arrival_date_year IS NULL
OR arrival_date_month IS NULL 
OR arrival_date_week_number IS NULL
OR stays_in_week_nights IS NULL 
OR stays_in_weekend_nights IS NULL 
OR adults IS NULL 
OR children IS NULL  ---- found some nulls 
OR babies IS NULL

UPDATE Temp_ALL_Hotel
SET children = 0
WHERE children IS NULL
---------------------------------------

SELECT DISTINCT meal
FROM Temp_All_Hotel  ---> find undefined(null)

SELECT * 
FROM Temp_All_Hotel
WHERE meal = 'Undefined' 

--- replace undefind value with the most frequent value
UPDATE Temp_All_Hotel
SET meal = (
    SELECT TOP 1 meal
    FROM Temp_All_Hotel
    WHERE meal IS NOT NULL
)
WHERE meal = 'Undefined'; 
-------------------------------------------
SELECT DISTINCT country
FROM Temp_All_Hotel  --- all have the same formate and no null

SELECT DISTINCT market_segment
FROM Temp_All_Hotel

SELECT DISTINCT distribution_channel
FROM Temp_All_Hotel

SELECT DISTINCT customer_type
FROM Temp_All_Hotel

SELECT DISTINCT deposit_type
FROM Temp_All_Hotel

SELECT DISTINCT reservation_status
FROM Temp_All_Hotel   --- found no show value which equal canceled

UPDATE Temp_All_Hotel
SET reservation_status = 'Canceled'
WHERE reservation_status = 'No-Show'
----------------------------------------------------
---- check if the rest columns have wrong or null value

SELECT DISTINCT is_repeated_guest
FROM Temp_All_Hotel

SELECT DISTINCT previous_cancellations
FROM Temp_All_Hotel

SELECT DISTINCT previous_bookings_not_canceled
FROM Temp_All_Hotel

SELECT DISTINCT reserved_room_type
FROM Temp_All_Hotel

SELECT DISTINCT assigned_room_type
FROM Temp_All_Hotel

SELECT DISTINCT booking_changes
FROM Temp_All_Hotel

SELECT DISTINCT days_in_waiting_list
FROM Temp_All_Hotel

SELECT DISTINCT adr
FROM Temp_All_Hotel

SELECT DISTINCT required_car_parking_spaces
FROM Temp_All_Hotel

SELECT DISTINCT total_of_special_requests
FROM Temp_All_Hotel

SELECT DISTINCT reservation_status
FROM Temp_All_Hotel
------------------------------------------------
SELECT *
FROM Temp_All_Hotel
WHERE adr = 0 ---1863 row 

SELECT *
FROM Temp_All_Hotel
WHERE adr = 0 and is_canceled = 0 --- 1624 row 

--> so we have 1624 reservation has adr equal zero allthough there are not cancel
--> change their adr(which was 0) value with the most frequent value

UPDATE Temp_All_Hotel
SET adr = (SELECT TOP 1 adr
    FROM Temp_All_Hotel
    WHERE adr != 0)
WHERE adr = 0 and is_canceled = 0  
------------------------------------------------------------
----Check for illogical values-------

SELECT * FROM Temp_All_Hotel
WHERE adults = 0 AND children = 0 AND babies = 0 AND is_canceled = 1; --- 17 row 

--> impossible to have a reservation with no people so it considre a wrong data and must be removed

DELETE FROM Temp_All_Hotel
WHERE adults = 0 AND children = 0 AND babies = 0 AND is_canceled = 1;
-------------------
SELECT * FROM Temp_All_Hotel
WHERE stays_in_week_nights = 0 AND stays_in_weekend_nights = 0 AND is_canceled = 1;  -- 23 row
 
 --> same concept can' have a reservation with no stay in night
 
DELETE FROM Temp_All_Hotel
WHERE stays_in_week_nights = 0 AND stays_in_weekend_nights = 0 AND is_canceled = 1;
------------------------------------------------------------------------------------------------------------------
----------Ensure consistency------------

SELECT * 
FROM Temp_All_Hotel
WHERE is_canceled = 1 AND reservation_status ='Check-Out'  --no row

----------------------------------------------------------------------------------------------------------------
---------add calulated columns----------------
--  total stay in night

ALTER TABLE Temp_All_Hotel 
ADD total_nights INT;

UPDATE Temp_All_Hotel
SET total_nights = stays_in_weekend_nights + stays_in_week_nights;
----------------------------------
--- full arrival date

ALTER TABLE Temp_All_Hotel 
ADD full_arrival_date DATE;

UPDATE Temp_All_Hotel
SET full_arrival_date = CAST(
    CONCAT(
        arrival_date_year, '-',
        MONTH(TRY_CONVERT(DATE, CONCAT('1 ', arrival_date_month, ' 2000'))), '-',
        RIGHT('00' + CAST(arrival_date_day_of_month AS VARCHAR), 2)
    ) AS DATE
);
--------------------------------------------
SELECT * FROM Temp_All_Hotel;


