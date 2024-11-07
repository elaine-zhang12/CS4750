-- CS 4750 P3
-- Hieu Vu (brr2tu), Elaine Zhang (zzb2rf), Janice Guo (vdq8tp)

Use Library
GO

-- procedure to create new library account
CREATE PROCEDURE CreateNewAccount
    @CardID INT,
    @Name VARCHAR(30)
AS
BEGIN
    INSERT INTO LibraryAccount (CardID, [Name], NumChecked, NumReserved, OverdueFees)
    VALUES (@CardID, @Name, 0, 0, 0);
END;
GO

-- procedure to checkout an item (throw error if the number of copies is not greater than the number of reservations for the item)
CREATE PROCEDURE CheckOutItem
    @ItemID INT,
    @CardID INT,
    @BorrowDate DATE = NULL,
    @ReturnByDate DATE = NULL
AS
BEGIN
    DECLARE @CopiesAvailable INT;
    SELECT @CopiesAvailable = CopiesAvailable
    FROM LibraryItemState
    WHERE ItemID = @ItemID;

    IF @CopiesAvailable IS NULL
    BEGIN
        RAISERROR('Library item does not exist', 16, 1);
        RETURN;
    END

    IF @CopiesAvailable <= 0
    BEGIN
        RAISERROR('No copies of this book are available', 16, 1);
        RETURN;
    END

    INSERT INTO CheckOutLibraryItem (ItemID, CardID, BorrowDate, ReturnByDate)
    VALUES (@ItemID, @CardID, GETDATE(), DATEADD(DAY, 14, GETDATE()));

    -- Update the number of copies available in LibraryItemState
    UPDATE LibraryItemState
    SET CopiesAvailable = CopiesAvailable - 1
    WHERE ItemID = @ItemID;

END;
GO

-- procedure to return an item (if return date is later than return by date then update library account with overdue fees of $0.25 for each day late)


-- get number of books written by an author
CREATE FUNCTION dbo.GetTotalBooksWritten
(
    @AuthorID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @bookswritten INT;
    SELECT @bookswritten = COUNT(*)
    FROM Book_Author
    WHERE AuthorID = @AuthorID; 

    RETURN @bookswritten;
END;
GO


-- get number of checkouts + current reservations for an item (add count from checkout table and reservation count from item state table)
CREATE FUNCTION dbo.GetTotalInteractionCount
(
    @ItemID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @NumberCheckedOut INT;
    DECLARE @NumberofReservations INT;

    SELECT @NumberCheckedOut = COUNT(*) 
    FROM CheckOutLibraryItem
    WHERE ItemID = @ItemID;
    
    SELECT @NumberofReservations = ReservationCount 
    FROM LibraryItemState
    WHERE ItemID = @ItemID;
    
    RETURN @NumberCheckedOut + @NumberofReservations;
END;
GO


-- get total count of items by book and movie type (multiple group by)
CREATE FUNCTION dbo.GetTotalCountofItem
()
RETURNS TABLE
AS
RETURN (
    SELECT ItemType, COUNT(*) AS ItemCount
    FROM LibraryItem
    GROUP BY ItemType
);

GO

-- view book information with author
CREATE VIEW BookInfo AS
    SELECT b.ItemID, b.Title, b.Genre, b.PublicationYear, a.Name AS Author
    FROM Books b
    JOIN Book_Author ba ON b.ItemID = ba.ItemID
    JOIN Authors a ON ba.AuthorID = a.AuthorID;

GO
-- view review information with item of review
CREATE VIEW ReviewInfo AS
    SELECT r.ReviewID, bm.Title, bm.ItemType, r.Rating, r.Comments
    FROM Reviews r 
    JOIN 
        (SELECT l.ItemID, l.ItemType, b.Title
        FROM LibraryItem l
        JOIN Books b ON l.ItemID = b.ItemID
        UNION ALL 
        SELECT l.ItemID, l.ItemType, m.Title
        FROM LibraryItem l
        JOIN Movies m ON l.ItemID = m.ItemID) bm
    ON r.ItemID = bm.ItemID;

GO

-- view item and location
CREATE VIEW ItemLocation AS
    SELECT s.ShelfID, bm.Title, bm.ItemType, s.Floor, s.Section, s.Aisle
    FROM Shelf s 
    JOIN Shelf_PhysicalCopy sp ON s.ShelfID = sp.ShelfID
    JOIN 
        (SELECT l.ItemID, l.ItemType, b.Title
        FROM LibraryItem l
        JOIN Books b ON l.ItemID = b.ItemID
        UNION ALL 
        SELECT l.ItemID, l.ItemType, m.Title
        FROM LibraryItem l
        JOIN Movies m ON l.ItemID = m.ItemID) bm
    ON sp.ItemID = bm.ItemID;

GO

-- 1 trigger

CREATE TRIGGER trg_AfterReturn
ON CheckOutLibraryItem
AFTER UPDATE
AS
BEGIN
    DECLARE @ItemID INT;
    DECLARE @CardID INT;
    DECLARE @ReturnDate DATE;
    DECLARE @ReturnByDate DATE;
    DECLARE @DaysOverdue INT;
    DECLARE @OverdueFee DECIMAL(10, 2);
    DECLARE @FeePerDay DECIMAL(10, 2) = 0.25; -- this is just adding a $0.25 fee per day late

    -- this solution uses a cursor to handle cases where multiple values are inserted in one batch together
    -- this processes all of the insert values one at a time
    DECLARE return_cursor CURSOR FOR
        SELECT ItemID, CardID, ReturnByDate
        FROM inserted;

    OPEN return_cursor;
    FETCH NEXT FROM return_cursor INTO @ItemID, @CardID, @ReturnByDate;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Calculate days overdue
        SET @DaysOverdue = DATEDIFF(DAY, @ReturnByDate, GETDATE());

        -- Apply overdue fee only if item was returned after the ReturnByDate
        IF @DaysOverdue > 0
        BEGIN
            SET @OverdueFee = @DaysOverdue * @FeePerDay;

            -- Update the OverdueFees column in LibraryAccount
            UPDATE LibraryAccount
            SET OverdueFees = OverdueFees + @OverdueFee
            WHERE CardID = @CardID;
        END

        FETCH NEXT FROM return_cursor INTO @ItemID, @CardID, @ReturnByDate;
    END

    CLOSE return_cursor;
    DEALLOCATE return_cursor;
END;
GO


-- zip code column encryption
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'LibraryPassword$2024';

CREATE CERTIFICATE Account_Certificate
WITH SUBJECT = 'Certificate for Account Zip Code Encryption';

CREATE SYMMETRIC KEY Account_Key
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE Account_Certificate;

ALTER TABLE LibraryAccount
ADD EncryptedZipCode VARBINARY(128);

-- -- 3 non-clustered indexes
