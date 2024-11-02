drop table CustomerProfile_Staging
CREATE TABLE CustomerProfile_Staging (
    satisfaction VARCHAR(20),
    Gender VARCHAR(10),
    CustomerType VARCHAR(50),
    Age VARCHAR(10),
    TypeOfTravel VARCHAR(50),
    Class VARCHAR(20),
    FlightDistance VARCHAR(50),
    SeatComfort VARCHAR(10),
    DepartureArrivalTimeConvenient VARCHAR(10),
    FoodAndDrink VARCHAR(10),
    GateLocation VARCHAR(10),
    InflightWifiService VARCHAR(10),
    InflightEntertainment VARCHAR(10),
    OnlineSupport VARCHAR(10),
    EaseOfOnlineBooking VARCHAR(10),
    OnBoardService VARCHAR(10),
    LegRoomService VARCHAR(10),
    BaggageHandling VARCHAR(10),
    CheckinService VARCHAR(10),
    Cleanliness VARCHAR(10),
    OnlineBoarding VARCHAR(10),
    DepartureDelayInMinutes VARCHAR(10),
    ArrivalDelayInMinutes VARCHAR(10)
);

BULK INSERT CustomerProfile_Staging
FROM 'C:\Heba_PC\Project\Invistico_Airline.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

select *
from CustomerProfile_Staging

CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    Gender VARCHAR(10),
    CustomerType VARCHAR(50),
    Age INT
);

CREATE TABLE Flight (
    FlightID INT IDENTITY(1,1) PRIMARY KEY,
    TypeOfTravel VARCHAR(50),
    Class VARCHAR(20),
    FlightDistance INT
);

CREATE TABLE Feedback (
    FeedbackID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
    FlightID INT FOREIGN KEY REFERENCES Flight(FlightID),
    Satisfaction VARCHAR(20),
    SeatComfort INT,
    DepartureArrivalTimeConvenient INT,
    FoodAndDrink INT,
    GateLocation INT,
    InflightWifiService INT,
    InflightEntertainment INT,
    OnlineSupport INT,
    EaseOfOnlineBooking INT,
    OnBoardService INT,
    LegRoomService INT,
    BaggageHandling INT,
    CheckinService INT,
    Cleanliness INT,
    OnlineBoarding INT,
    DepartureDelayInMinutes INT,
    ArrivalDelayInMinutes INT
);

INSERT INTO Customer (Gender, CustomerType, Age)
SELECT DISTINCT Gender, CustomerType, CAST(Age AS INT)
FROM CustomerProfile_Staging;

INSERT INTO Flight (TypeOfTravel, Class, FlightDistance)
SELECT DISTINCT TypeOfTravel, Class, CAST(FlightDistance AS INT)
FROM CustomerProfile_Staging;

INSERT INTO Feedback (CustomerID, FlightID, Satisfaction, SeatComfort, DepartureArrivalTimeConvenient, FoodAndDrink, GateLocation, InflightWifiService, InflightEntertainment, OnlineSupport, EaseOfOnlineBooking, OnBoardService, LegRoomService, BaggageHandling, CheckinService, Cleanliness, OnlineBoarding, DepartureDelayInMinutes, ArrivalDelayInMinutes)
SELECT 
    C.CustomerID,
    F.FlightID,
    CPS.Satisfaction,
    CAST(CPS.SeatComfort AS INT),
    CAST(CPS.DepartureArrivalTimeConvenient AS INT),
    CAST(CPS.FoodAndDrink AS INT),
    CAST(CPS.GateLocation AS INT),
    CAST(CPS.InflightWifiService AS INT),
    CAST(CPS.InflightEntertainment AS INT),
    CAST(CPS.OnlineSupport AS INT),
    CAST(CPS.EaseOfOnlineBooking AS INT),
    CAST(CPS.OnBoardService AS INT),
    CAST(CPS.LegRoomService AS INT),
    CAST(CPS.BaggageHandling AS INT),
    CAST(CPS.CheckinService AS INT),
    CAST(CPS.Cleanliness AS INT),
    CAST(CPS.OnlineBoarding AS INT),
    CAST(CPS.DepartureDelayInMinutes AS INT),
    CAST(CPS.ArrivalDelayInMinutes AS INT)
FROM CustomerProfile_Staging CPS
JOIN Customer C ON CPS.Gender = C.Gender AND CPS.CustomerType = C.CustomerType AND CAST(CPS.Age AS INT) = C.Age
JOIN Flight F ON CPS.TypeOfTravel = F.TypeOfTravel AND CPS.Class = F.Class AND CAST(CPS.FlightDistance AS INT) = F.FlightDistance;

-- Index on CustomerID in Feedback (for fast lookup when joining)
CREATE NONCLUSTERED INDEX idx_Feedback_CustomerID
ON Feedback(CustomerID);

-- Index on FlightID in Feedback (for fast lookup when joining)
CREATE NONCLUSTERED INDEX idx_Feedback_FlightID
ON Feedback(FlightID);

-- Optionally, you may add an index on frequently queried satisfaction or delay columns
CREATE NONCLUSTERED INDEX idx_Feedback_Satisfaction
ON Feedback(Satisfaction);

CREATE NONCLUSTERED INDEX idx_Feedback_DepartureDelay
ON Feedback(DepartureDelayInMinutes);

CREATE NONCLUSTERED INDEX idx_Feedback_ArrivalDelay
ON Feedback(ArrivalDelayInMinutes);


-- Add foreign key constraint from Feedback to Customer
ALTER TABLE Feedback
ADD CONSTRAINT FK_Feedback_Customer
FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID);

-- Add foreign key constraint from Feedback to Flight
ALTER TABLE Feedback
ADD CONSTRAINT FK_Feedback_Flight
FOREIGN KEY (FlightID) REFERENCES Flight(FlightID);

