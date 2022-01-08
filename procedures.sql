CREATE OR ALTER PROCEDURE SearchBy (
	@chapter nvarchar(32),
	@topic nvarchar(32), 
	@author nvarchar(64), 
	@keyword nvarchar(64), 
	@startdate int, 
	@enddate int
)	
AS
	SELECT 
		DISTINCT bi.IDBook AS IDBook,
		bi.[Name] AS [Name],
		dbo.getAuthors(bi.IDBook) AS Authors,
		p.[Name] AS Publisher,
		bi.PublishedDate AS PublishedDate,
		bi.WrittenDate AS WrittenDate
	FROM BookInfo AS bi
	JOIN Publisher AS p ON bi.IDPublisher = p.IDPublisher
	JOIN BookCategory AS bc ON bi.IDBook = bc.IDBook
	JOIN Category AS c ON c.CategoryCode = bc.CategoryCode
	WHERE
			(@chapter IS NULL OR bc.CategoryCode IN (SELECT CategoryCode FROM Category WHERE CategoryName = @chapter))
		AND (@topic IS NULL OR bc.CategoryCode IN (SELECT CategoryCode FROM Category WHERE CategoryName = @topic))
		AND (@author IS NULL OR dbo.getAuthors(bi.IDBook) LIKE ('%' + @author + '%'))
		AND (@keyword IS NULL OR bi.IDBook IN (SELECT bi2.IDBook  FROM BookInfo AS bi2 JOIN BookWord AS bw ON bi2.IDBook = bw.IDBook
											JOIN KeyWord AS kw ON kw.IDWord = bw.IDWord WHERE Word = @keyword))
		AND (ISNULL(@startdate, 0) <= YEAR(bi.WrittenDate)) AND (ISNULL(@enddate, 9999) >= YEAR(bi.WrittenDate))
GO


CREATE OR ALTER PROCEDURE TakenForNWeeks
	@ticketnumber int,
	@idbook int,
	@weeks int
AS
	IF @weeks <= 0
		THROW 50001, 'Некорректное количество недель', 0
	IF NOT EXISTS(SELECT * FROM Reader WHERE @ticketnumber = TicketNumber)
		THROW 50001, 'Читатель не записан', 0
	IF NOT EXISTS(SELECT * FROM BookInfo WHERE @idbook = IDBook)
		THROW 50001, 'Книга отстуствует в базе', 0

	IF EXISTS(SELECT * FROM Book WHERE IsAvailable = 1 AND IDBook = @idbook)
	   AND (NOT EXISTS(SELECT * FROM Hold WHERE IDBook = @idbook)
		  OR (SELECT TOP 1 @ticketnumber FROM Hold WHERE IDBook = @idbook
				ORDER BY RequestDate ASC) = @ticketnumber)
	BEGIN
		DECLARE @inventorynumber int = 
				(SELECT MIN(InventoryNumber) FROM Book WHERE IDBook = @idbook AND IsAvailable = 1)

		INSERT INTO TakenBook (TicketNumber, InventoryNumber, TakenDate, DeadLine, OnTime)
		VALUES (@ticketnumber, @inventorynumber, GETDATE(), DATEADD(WEEK, @weeks, GETDATE()), NULL)

		DELETE FROM Hold
		WHERE IDBook = @idbook AND TicketNumber = @ticketnumber
	END
	ELSE
	BEGIN
		EXEC PutOnHold @idbook, @ticketnumber
		DECLARE @message nvarchar(64) = 'Свободных копий нет! Читатель добавлен в очередь';
	    THROW 50001, @message, 0
	END
GO


CREATE OR ALTER PROCEDURE PutOnHold
	@idbook int,
	@ticketnumber int
AS
	INSERT INTO Hold (TicketNumber, IDBook, RequestDate)
	VALUES
	(@ticketnumber, @idbook, GETDATE())
GO


CREATE OR ALTER PROCEDURE TakenBack
	@ticketnumber int,
	@inventorynumber int
AS
	IF NOT EXISTS(SELECT * FROM Reader WHERE @ticketnumber = TicketNumber)
		THROW 50001, 'Читатель не записанí', 0

	IF NOT EXISTS(SELECT * FROM Book WHERE @inventorynumber = InventoryNumber)
		THROW 50001, 'Книга не принадлежит библиотеке', 0

	IF NOT EXISTS(SELECT * FROM TakenBook WHERE @ticketnumber = TicketNumber
						AND @inventorynumber = InventoryNumber)
		THROW 50001, 'Книга выдана другому читателю', 0

	DECLARE @ontime int = 1
	IF GETDATE() > (SELECT TOP 1 DeadLine FROM TakenBook WHERE @ticketnumber = TicketNumber
								AND @inventorynumber = InventoryNumber ORDER BY Deadline DESC)
		SET @ontime = 0

	IF @ontime = 1
		PRINT 'Книга возвращена вовремя'
	ELSE
		PRINT 'Книга возвращена с опозданием'

	UPDATE TakenBook
	SET OnTime = @ontime
	WHERE @ticketnumber = TicketNumber AND @inventorynumber = InventoryNumber

	UPDATE Book
	SET IsAvailable = 1
	WHERE @inventorynumber = InventoryNumber
