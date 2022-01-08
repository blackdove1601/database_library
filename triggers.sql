-- Вывод следующего читателя в очереди на данную книгу
CREATE OR ALTER TRIGGER HeldBookReturned 
ON TakenBook
AFTER UPDATE
AS
IF EXISTS (
		SELECT IDBook FROM inserted AS ins JOIN Book AS b ON ins.InventoryNumber = b.InventoryNumber
		INTERSECT 
		SELECT IDBook FROM Hold
	)
	AND
	EXISTS (
		SELECT * FROM inserted WHERE OnTime IS NOT NULL
	)
	BEGIN
		DECLARE @IDBook int = (SELECT TOP 1 IDBook 
							   FROM inserted AS ins 
							   JOIN Book AS b ON ins.InventoryNumber = b.InventoryNumber)

		DECLARE @Name varchar(25) = (SELECT [Name] FROM FirstReader(@IDBook))
		DECLARE @PhoneNumber varchar(11) = (SELECT PhoneNumber FROM FirstReader(@IDBook))
		DECLARE @Email varchar(25) = (SELECT Email FROM FirstReader(@IDBook))

		PRINT 'Информация о следующем в очереди на данную книгу читателе'
		PRINT @Name
		PRINT @PhoneNumber
		PRINT @Email
	END
GO


-- Обновляет статус о доступности книги
CREATE OR ALTER TRIGGER BookWasTaken
ON TakenBook
AFTER INSERT
AS
	DECLARE @inventorynumber int = (SELECT TOP 1 InventoryNumber FROM inserted AS ins)

	UPDATE Book
	SET IsAvailable = 0
	WHERE @inventorynumber = InventoryNumber
GO


-- Триггер на удаление отзыва
CREATE OR ALTER TRIGGER DeleteReview
ON vReviews
INSTEAD OF DELETE
AS
	BEGIN TRY
		IF NOT EXISTS(SELECT f.IDResponse FROM deleted AS d JOIN Feedback AS f ON f.IDResponse = d.IDResponse)
		BEGIN	
			ROLLBACK
			RAISERROR('Отзыва по таким параметрам не существует' , 0, 0)
		END
		ELSE
		BEGIN
			DELETE FROM Feedback
			WHERE IDResponse IN (SELECT IDResponse FROM deleted)
		END
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE()
	END CATCH
GO


-- Триггер на обновление отзыва
CREATE OR ALTER TRIGGER UpdateReview
ON vReviews
INSTEAD OF UPDATE
AS
	BEGIN TRY
		IF NOT EXISTS(SELECT f.IDResponse FROM deleted AS d JOIN Feedback AS f ON f.IDResponse = d.IDResponse)
		BEGIN
			ROLLBACK
			RAISERROR('Отзыва по таким параметрам не существует' , 0, 0)
		END
		ELSE
		BEGIN
			IF UPDATE(Rate)
				BEGIN
					UPDATE Feedback
					SET Rate = (SELECT Rate FROM inserted)
					WHERE IDResponse IN (SELECT IDResponse FROM inserted)
				END
			ELSE IF UPDATE(Comment)
				BEGIN
					UPDATE Feedback
					SET Comment = (SELECT Comment FROM inserted)
					WHERE IDResponse IN (SELECT IDResponse FROM inserted)
				END
			ELSE 
				BEGIN
					ROLLBACK
					RAISERROR('Нельзя изменить указанные данные' , 0, 0)
				END
		END
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE()
	END CATCH
GO


-- Триггер на создание отзыва
CREATE OR ALTER TRIGGER InsertReview
ON vReviews
INSTEAD OF INSERT
AS
	BEGIN TRY
		IF EXISTS(SELECT InventoryNumber FROM inserted EXCEPT SELECT InventoryNumber FROM Book)
		BEGIN	
			ROLLBACK
			RAISERROR('Такой книги в билиотеке нет' , 0, 0)
		END
		ELSE IF EXISTS(SELECT TicketNumber FROM inserted EXCEPT SELECT TicketNumber FROM Reader)
		BEGIN	
			ROLLBACK
			RAISERROR('Такой читателя в билиотеке нет' , 0, 0)
		END
		ELSE
		BEGIN
			INSERT INTO Feedback ([Date], Rate, Comment, TicketNumber, InventoryNumber)
			SELECT GETDATE(), Rate, Comment, TicketNumber, InventoryNumber FROM inserted
		END
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE()
	END CATCH
