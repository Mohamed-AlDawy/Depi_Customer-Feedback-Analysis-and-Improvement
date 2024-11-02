SELECT  [FeedbackID]
      ,[CustomerID]
      ,[FlightID]
      ,[Satisfaction]
      ,[SentimentScore]
      ,[SentimentLabel]
      ,[DepartureDelay]
      ,[ArrivalDelay]
  FROM [dbo].[CustomerFeedback_Fact]

  update CustomerFeedback_Fact set Satisfaction = 'dissatisfied', SentimentLabel='Negative', SentimentScore=-0.4215 
  where FeedbackID > 9 and FeedbackID < 15