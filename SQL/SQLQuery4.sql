create view Satisfaction_Analysis as 

--1. Overall Satisfaction Analysis

SELECT 
    Satisfaction, 
    COUNT(*) AS TotalCustomers
FROM Feedback
GROUP BY Satisfaction
--ORDER BY TotalCustomers DESC;

--2. Average Rating for Each Service
create view Avrage_rating as
SELECT 
    AVG(CAST(SeatComfort AS FLOAT)) AS AvgSeatComfort,
    AVG(CAST(FoodAndDrink AS FLOAT)) AS AvgFoodAndDrink,
    AVG(CAST(InflightEntertainment AS FLOAT)) AS AvgInflightEntertainment,
    AVG(CAST(OnBoardService AS FLOAT)) AS AvgOnBoardService,
    AVG(CAST(LegRoomService AS FLOAT)) AS AvgLegRoomService,
    AVG(CAST(Cleanliness AS FLOAT)) AS AvgCleanliness
FROM Feedback;

--3. Satisfaction by Customer Type
create view Satisfaction as 
SELECT 
    C.CustomerType,
    F.Satisfaction,
    COUNT(*) AS TotalCustomers
FROM Feedback F
JOIN Customer C ON F.CustomerID = C.CustomerID
GROUP BY C.CustomerType, F.Satisfaction
--ORDER BY C.CustomerType, F.Satisfaction;

--4. Feedback Summary by Class and Type of Travel
create view feedback_summary as 
SELECT 
    FL.Class,
    FL.TypeOfTravel,
    AVG(CAST(F.SeatComfort AS FLOAT)) AS AvgSeatComfort,
    AVG(CAST(F.FoodAndDrink AS FLOAT)) AS AvgFoodAndDrink,
    AVG(CAST(F.InflightEntertainment AS FLOAT)) AS AvgInflightEntertainment,
    AVG(CAST(F.OnBoardService AS FLOAT)) AS AvgOnBoardService,
    COUNT(*) AS TotalFeedbacks
FROM Feedback F
JOIN Flight FL ON F.FlightID = FL.FlightID
GROUP BY FL.Class, FL.TypeOfTravel
--ORDER BY FL.Class, FL.TypeOfTravel;

--5. Top 5 Worst-Rated Services
create view Worst as
SELECT 
    'Seat Comfort' AS Category, AVG(CAST(SeatComfort AS FLOAT)) AS AvgRating FROM Feedback
UNION ALL
SELECT 
    'Food And Drink' AS Category, AVG(CAST(FoodAndDrink AS FLOAT)) AS AvgRating FROM Feedback
UNION ALL
SELECT 
    'Inflight Entertainment' AS Category, AVG(CAST(InflightEntertainment AS FLOAT)) AS AvgRating FROM Feedback
UNION ALL
SELECT 
    'OnBoard Service' AS Category, AVG(CAST(OnBoardService AS FLOAT)) AS AvgRating FROM Feedback
UNION ALL
SELECT 
    'LegRoom Service' AS Category, AVG(CAST(LegRoomService AS FLOAT)) AS AvgRating FROM Feedback
--ORDER BY AvgRating ASC
--LIMIT 5;

--6. Delays Impact on Satisfaction
create view delay_impact as 
SELECT 
    CASE 
        WHEN DepartureDelayInMinutes > 0 THEN 'Delayed'
        ELSE 'On Time'
    END AS DepartureStatus,
    CASE 
        WHEN ArrivalDelayInMinutes > 0 THEN 'Delayed'
        ELSE 'On Time'
    END AS ArrivalStatus,
    Satisfaction,
    COUNT(*) AS TotalFeedbacks
FROM Feedback
GROUP BY 
    CASE WHEN DepartureDelayInMinutes > 0 THEN 'Delayed' ELSE 'On Time' END,
    CASE WHEN ArrivalDelayInMinutes > 0 THEN 'Delayed' ELSE 'On Time' END,
    Satisfaction
--ORDER BY TotalFeedbacks DESC;

--7. Satisfaction by Age Group
create view Satisfaction_age as 

SELECT 
    CASE
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 50 THEN '36-50'
        WHEN Age > 50 THEN '50+'
        ELSE 'Unknown'
    END AS AgeGroup,
    Satisfaction,
    COUNT(*) AS TotalCustomers
FROM Feedback F
JOIN Customer C ON F.CustomerID = C.CustomerID
GROUP BY 
    CASE 
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 50 THEN '36-50'
        WHEN Age > 50 THEN '50+' 
        ELSE 'Unknown'
    END,
    Satisfaction
--ORDER BY AgeGroup, Satisfaction;

--8. Correlating Flight Distance with Service Ratings
create view Correlating_Flight as 
SELECT 
    FL.FlightDistance,
    AVG(CAST(F.SeatComfort AS FLOAT)) AS AvgSeatComfort,
    AVG(CAST(F.FoodAndDrink AS FLOAT)) AS AvgFoodAndDrink,
    AVG(CAST(F.OnBoardService AS FLOAT)) AS AvgOnBoardService
FROM Feedback F
JOIN Flight FL ON F.FlightID = FL.FlightID
GROUP BY FL.FlightDistance
--ORDER BY FL.FlightDistance;

--9. Customer Type Satisfaction for Delayed Flights
create view customer_type as 
SELECT 
    C.CustomerType,
    CASE 
        WHEN DepartureDelayInMinutes > 0 THEN 'Delayed'
        ELSE 'On Time'
    END AS DepartureStatus,
    Satisfaction,
    COUNT(*) AS TotalCustomers
FROM Feedback F
JOIN Customer C ON F.CustomerID = C.CustomerID
WHERE DepartureDelayInMinutes > 0 OR ArrivalDelayInMinutes > 0
GROUP BY C.CustomerType, 
    CASE WHEN DepartureDelayInMinutes > 0 THEN 'Delayed' ELSE 'On Time' END,
    Satisfaction
--ORDER BY TotalCustomers DESC;

--10. Percentage of Satisfied Customers
create view satisfaction_percentage as 
SELECT 
    (SELECT COUNT(*) FROM Feedback WHERE Satisfaction = 'Satisfied') * 100.0 / COUNT(*) AS SatisfiedPercentage
FROM Feedback;
