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

-- procedure to checkout an item (throw error if the number of copies is not greater than the number of reservations for the item)
CREATE PROCEDURE CheckOutItem
    @CheckoutID INT,
    @ItemID INT,
    @CardID INT,
    @BorrowDate DATE,
    @ReturnByDate DATE
AS
BEGIN

END;

-- procedure to return an item (if return date is later than return by date then update library account with overdue fees of $0.25 for each day late)
CREATE PROCEDURE ReturnItem
    @ReturnID INT,
    @CheckoutID INT,
    @ReturnDate DATE
AS
BEGIN

END;

-- get number of books written by an author
CREATE FUNCTION dbo.GetTotalBooksWritten
(
    @AuthorID INT
)
RETURNS INT
AS
BEGIN

END;

-- get number of checkouts + current reservations for an item (add count from checkout table and reservation count from item state table)
CREATE FUNCTION dbo.GetTotalInteractionCount
(
    @ItemID INT
)
RETURNS INT
AS
BEGIN

END;


-- get total count of items by book and movie type (multiple group by)
CREATE FUNCTION dbo.GetItemTypeCounts ()
RETURNS TABLE
AS
RETURN (

);


-- view book information with author
CREATE VIEW BookInfo AS
    SELECT b.ItemID, b.Title, b.Genre, b.PublicationYear, a.Name AS Author
    FROM Books b
    JOIN Book_Author ba ON b.ItemID = ba.ItemID
    JOIN Authors a ON ba.AuthorID = a.AuthorID;

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

-- 1 trigger


-- zip code column encryption
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'LibraryPassword$2024';

CREATE CERTIFICATE Account_Certificate
WITH SUBJECT = 'Certificate for Account Zip Code Encryption';

CREATE SYMMETRIC KEY Account_Key
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE Account_Certificate;

ALTER TABLE LibraryAccount
ADD EncryptedZipCode VARBINARY(128);

-- 3 non-clustered indexes
