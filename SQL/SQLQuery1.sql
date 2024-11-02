BULK INSERT CustomerProfile_Staging
FROM 'C:\Heba_PC\Project\Invistico_Airline.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);