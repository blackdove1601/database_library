CREATE OR ALTER VIEW vDebtors
AS
	SELECT
		DISTINCT r.TicketNumber AS TicketNumber,
		r.FirstName AS FirstName,
		ISNULL(r.MiddleName, 'Отсутствует') AS MiddleName,
		r.LastName AS LastName,
		r.PhoneNumber AS PhoneNumber
	FROM TakenBook AS tb
	JOIN Reader AS r ON tb.TicketNumber = r.TicketNumber
	WHERE 
			GETDATE() > tb.Deadline 
		AND OnTime IS NULL
GO


CREATE OR ALTER VIEW vPublicationRating
AS
	SELECT
		dbo.getAuthors(bi.IDBook) AS Authors,
		bi.[Name] AS [Name],
		p.[Name] AS Publisher,
		YEAR(PublishedDate) AS YearOfPublication,
		dbo.getNumberOfReaders(bi.IDBook) AS NumberOfReaders,
		dbo.getLastTakenDate(bi.IDBook) AS getLastTakenDate,
		dbo.getBookRaiting(bi.IDBook) AS AvgRate
	FROM BookInfo AS bi
	JOIN Publisher AS p ON p.IDPublisher = bi.IDPublisher
GO 


CREATE OR ALTER VIEW vReviews
AS
	SELECT
		f.IDResponse AS IDResponse,
		r.FirstName + ' ' + r.LastName AS NameOfReader,
		f.[Date] AS [Date],
		dbo.getAuthors(bi.IDBook) AS Authors,
		bi.[Name] AS NameOfBook,
		f.Rate AS Rate,
		f.Comment AS Comment,
		f.TicketNumber AS TicketNumber,
		f.InventoryNumber AS InventoryNumber
	FROM Feedback AS f
	JOIN Reader AS r ON f.TicketNumber = r.TicketNumber
	JOIN Book AS b ON b.InventoryNumber = f.InventoryNumber
	JOIN BookInfo AS bi ON bi.IDBook = b.IDBook
GO


CREATE OR ALTER VIEW vNumberOfRequestsByCategory
AS
	SELECT
			a.CategoryName,
			COUNT(*) AS NumberOfRequests
	FROM (
			SELECT
				tb.IDTaking,
				r.TicketNumber AS TicketNumber,
				r.FirstName + ' ' + r.LastName AS [Name],
				c.CategoryName
			FROM TakenBook AS tb
			JOIN Reader AS r ON r.TicketNumber = tb.TicketNumber
			JOIN Book AS b ON b.InventoryNumber = tb.InventoryNumber
			JOIN BookInfo AS bi ON bi.IDBook = b.IDBook
			JOIN BookCategory AS bc ON bc.IDBook = bi.IDBook
			JOIN Category AS c ON c.CategoryCode = bc.CategoryCode ) AS a
	GROUP BY a.CategoryName
