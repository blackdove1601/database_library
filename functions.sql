-- Возвращает имена всех авторов
CREATE OR ALTER FUNCTION getAuthors(@IDBook int)
RETURNS varchar(100)
AS
BEGIN
	DECLARE myCursor CURSOR FOR 
								SELECT
									 FirstName + ' ' + LastName AS FullName
								FROM BookInfo AS bi
								JOIN BookAuthor AS ba ON bi.IDBook = ba.IDBook
								JOIN Author AS a ON a.IDAuthor = ba.IDAuthor
								WHERE bi.IDBook = @IDBook

	OPEN myCursor

	DECLARE @FullName varchar(100) = ''
	FETCH NEXT FROM myCursor INTO @FullName
	DECLARE @Ans varchar(100) = ''

	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		SET @Ans = @Ans + @FullName + ' '
		FETCH NEXT FROM myCursor INTO @FullName
	END
	CLOSE myCursor
	DEALLOCATE myCursor

	RETURN @Ans
END
GO


-- Количество читателей
CREATE OR ALTER FUNCTION getNumberOfReaders(@IDBook int)
RETURNS int
AS
BEGIN
	DECLARE @cnt int = (SELECT COUNT(DISTINCT TicketNumber)
						FROM TakenBook AS tb
						JOIN Book AS b ON tb.InventoryNumber = b.InventoryNumber
						JOIN BookInfo as bi ON bi.IDBook = b.IDBook
						WHERE b.IDBook = @IDBook)
	RETURN @cnt
END
GO


-- Дата последнего обращения
CREATE OR ALTER FUNCTION getLastTakenDate(@IDBook int)
RETURNS date
AS
BEGIN
	DECLARE @LastDate date = (SELECT MAX(TakenDate)
						FROM TakenBook AS tb
						JOIN Book AS b ON tb.InventoryNumber = b.InventoryNumber
						JOIN BookInfo as bi ON bi.IDBook = b.IDBook
						WHERE b.IDBook = @IDBook)
	RETURN @LastDate
END
GO


-- Рейтинг книги
CREATE OR ALTER FUNCTION getBookRaiting(@IDBook int)
RETURNS float
AS
BEGIN
	DECLARE @AvgRate float = (SELECT AVG(Rate)
						FROM Book AS b
						JOIN Feedback AS f ON b.InventoryNumber = f.InventoryNumber
						JOIN BookInfo AS bi ON bi.IDBook = b.IDBook
						WHERE bi.IDBook = @IDBook)
	RETURN @AvgRate
END
GO


-- Список очередей на книги данного автора
CREATE OR ALTER FUNCTION BookQueue(@idauthor int)
RETURNS TABLE
AS
RETURN (
	SELECT 
		h.IDBook AS IDBook,
		bi.[Name] AS NameOfBook,
		ROW_NUMBER() OVER (PARTITION BY h.IDBook ORDER BY RequestDate ASC) AS Number,
		r.FirstName + ' ' + r.LastName AS NameOfReader
	FROM Hold AS h
	JOIN Reader AS r ON r.TicketNumber = h.TicketNumber
	JOIN BookInfo AS bi ON bi.IDBook = h.IDBook
	JOIN BookAuthor AS ba ON bi.IDBook = ba.IDBook
	JOIN Author AS a ON a.IDAuthor = ba.IDAuthor
	WHERE @idauthor = ba.IDAuthor
)
GO


-- Очередь на данную книгу
CREATE OR ALTER FUNCTION QueueForBook(@idbook int)
RETURNS TABLE
AS
RETURN  (
	SELECT
		r.TicketNumber AS TicketNumber, 
		r.FirstName + ' ' +  r.LastName AS [Name],
		r.PhoneNumber AS PhoneNumber,
		r.Email AS Email
	FROM Hold AS h
	JOIN Reader AS r
	ON r.TicketNumber = h.TicketNumber
	WHERE h.IDBook = @idbook
)
GO


-- Информация о первом читателе в очереди на данную книгу
CREATE OR ALTER FUNCTION FirstReader(@idbook int)
RETURNS TABLE
AS
RETURN (
	SELECT *
	FROM QueueForBook(@idbook)
	WHERE TicketNumber = (SELECT TicketNumber FROM Hold WHERE RequestDate = (
							SELECT MIN(RequestDate) FROM Hold WHERE IDBook = @idbook))
)
GO

