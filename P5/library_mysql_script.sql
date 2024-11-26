-- Drop the database if it exists
DROP DATABASE IF EXISTS Library;

-- Create the database
CREATE DATABASE Library;

-- Use the newly created database
USE Library;

CREATE TABLE LibraryAccount (
    CardID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(30),
    NumChecked INT CHECK (NumChecked >= 0),
    NumReserved INT CHECK (NumReserved >= 0),
    OverdueFees NUMERIC(5,2) CHECK (OverdueFees >= 0)
);

CREATE TABLE Publishers (
    PublisherID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(30),
    ContactInfo VARCHAR(30)
);

CREATE TABLE LibraryItem (
    ItemID INT AUTO_INCREMENT PRIMARY KEY,
    ItemType VARCHAR(10) CHECK (ItemType IN ('Book', 'Movie'))
);

CREATE TABLE Books (
    ItemID INT PRIMARY KEY,
    Language VARCHAR(10),
    Genre VARCHAR(20),
    Title VARCHAR(100),
    PublicationYear INT,
    NumCopies INT,
    BookType VARCHAR(20), 
    PublisherID INT,
    CONSTRAINT CHK_Language CHECK (Language IN ('EN', 'ES', 'FR', 'KO', 'IT', 'CH', 'GR', 'RU', 'DE')),
    CONSTRAINT CHK_Genre CHECK (Genre IN ('JFIC', 'YFIC', 'Fiction', 'Biography', 'Mystery', 'Poetry', 'Thriller', 'Romance')),
    CONSTRAINT CHK_BookType CHECK (BookType IN ('AudioBook_Physical', 'Physical_Copy', 'AudioBook_Digital', 'Ebook')),
    FOREIGN KEY (PublisherID) REFERENCES Publishers(PublisherID),
    FOREIGN KEY (ItemID) REFERENCES LibraryItem(ItemID)
);

CREATE TABLE Authors (
    AuthorID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(30),
    DOB VARCHAR(10),
    Nationality VARCHAR(100)
);

CREATE TABLE Book_Author (
    ItemID INT,
    AuthorID INT,
    PRIMARY KEY (ItemID, AuthorID),
    FOREIGN KEY (ItemID) REFERENCES Books(ItemID),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

CREATE TABLE Movies (
    ItemID INT PRIMARY KEY,
    Language VARCHAR(2), 
    Title VARCHAR(100), 
    PublicationYear INT, 
    NumCopies INT, 
    Genre VARCHAR(20), 
    Director VARCHAR(30),
    MovieType VARCHAR(20) CHECK (MovieType IN ('Physical', 'Digital')),
    CONSTRAINT CHK_LanguageM CHECK (Language IN ('EN', 'ES', 'FR', 'KO', 'IT', 'CH')),
    CONSTRAINT CHK_GenreM CHECK (Genre IN ('Comedy', 'Biography', 'Mystery', 'Thriller', 'Romance', 'Documentary', 'Horror', 'Action', 'Sci-Fi', 'Adventure', 'Drama', 'Crime', 'Animation', 'History', 'Fantasy')),
    FOREIGN KEY (ItemID) REFERENCES LibraryItem(ItemID)
);

CREATE TABLE Reviews (
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
    CardID INT,
    ItemID INT,
    Comments VARCHAR(200),
    Rating INT CHECK (Rating > 0 AND Rating < 6),
    FOREIGN KEY (CardID) REFERENCES LibraryAccount(CardID),
    FOREIGN KEY (ItemID) REFERENCES LibraryItem(ItemID)
);

CREATE TABLE Shelf (
    ShelfID INT AUTO_INCREMENT PRIMARY KEY,
    Floor INT CHECK (Floor > 0 AND Floor < 4),
    Section CHAR CHECK (Section in ('A', 'B')),
    Aisle INT CHECK (Aisle > 0 AND Aisle < 6)
);

CREATE TABLE Shelf_PhysicalCopy (
    ItemID INT,
    ShelfID INT,
    PRIMARY KEY (ItemID, ShelfID),
    FOREIGN KEY (ItemID) REFERENCES LibraryItem(ItemID),
    FOREIGN KEY (ShelfID) REFERENCES Shelf(ShelfID)
);

CREATE TABLE CheckOutLibraryItem (
    CheckoutID INT AUTO_INCREMENT PRIMARY KEY,
    ItemID INT,
    CardID INT,
    BorrowDate DATE,
    ReturnByDate DATE,
    FOREIGN KEY (ItemID) REFERENCES LibraryItem(ItemID),
    FOREIGN KEY (CardID) REFERENCES LibraryAccount(CardID)
);

CREATE TABLE ReturnLibraryItem (
    ReturnID INT AUTO_INCREMENT PRIMARY KEY,
    CheckoutID INT,
    ReturnDate DATE,
    FOREIGN KEY (CheckoutID) REFERENCES CheckOutLibraryItem(CheckoutID)
);

CREATE TABLE ReserveLibraryItem (
    ReservationID INT AUTO_INCREMENT PRIMARY KEY,
    ItemID INT,
    CardID INT,
    PlaceInLine INT,
    FOREIGN KEY (ItemID) REFERENCES LibraryItem(ItemID),
    FOREIGN KEY (CardID) REFERENCES LibraryAccount(CardID)
);

CREATE TABLE LibraryItemState (
    ItemID INT PRIMARY KEY,
    CopiesAvailable INT,
    ReservationCount INT,
    FOREIGN KEY (ItemID) REFERENCES LibraryItem(ItemID)
);

INSERT INTO LibraryAccount VALUES
    (1, 'June Lee', 0, 1, 0),
    (2, 'Mark Taylor', 2, 3, 0),
    (3, 'Anna Johnson', 1, 2, 0),
    (4, 'Kevin Smith', 3, 0, 0),
    (5, 'Sarah Brown', 0, 3, 0),
    (6, 'Emily Davis', 2, 1, 0),
    (7, 'Michael White', 1, 0, 0),
    (8, 'Laura Miller', 3, 2, 0),
    (9, 'Chris Garcia', 0, 5, 0),
    (10, 'Emma Wilson', 1, 1, 0),
    (11, 'John Martinez', 0, 0, 1),
    (12, 'Olivia Anderson', 3, 1, 0),
    (13, 'David Thomas', 1, 2, 0),
    (14, 'Sophia Taylor', 0, 0, 2.5),
    (15, 'Liam Jackson', 2, 3, 0),
    (16, 'Noah Harris', 3, 2, 0),
    (17, 'James Clark', 1, 1, 0),
    (18, 'Mia Lewis', 5, 0, 0),
    (19, 'Ethan Allen', 2, 1, 0),
    (20, 'Ava Wright', 3, 2, 0),
    (21, 'Jacob Walker', 0, 3, 0),
    (22, 'Isabella Scott', 2, 0, 0),
    (23, 'Mason King', 1, 4, 0),
    (24, 'Sophia Young', 3, 1, 0),
    (25, 'Lucas Green', 2, 0, 0),
    (26, 'Elijah Hall', 0, 3, 0),
    (27, 'Amelia Adams', 1, 2, 0),
    (28, 'Logan Baker', 3, 1, 0),
    (29, 'Charlotte Nelson', 0, 0, 0),
    (30, 'Benjamin Carter', 4, 2, 0);


INSERT INTO Publishers (PublisherID, Name, ContactInfo) VALUES
    (1, 'Scholastic', 'contact@scholastic.com'),
    (2, 'HarperCollins', 'info@harpercollins.com'),
    (3, 'Penguin Random House', 'info@penguinrandomhouse.com'),
    (4, 'Simon & Schuster', 'info@simonandschuster.com'),
    (5, 'Hachette Book Group', 'contact@hachettebookgroup.com'),
    (6, 'Macmillan', 'info@macmillan.com'),
    (7, 'Bloomsbury', 'contact@bloomsbury.com'),
    (8, 'Wiley', 'info@wiley.com'),
    (9, 'Oxford University Press', 'info@oup.com'),
    (10, 'Cambridge University Press', 'contact@cup.com'),
    (11, 'Harvard University Press', 'info@harvard.edu'),
    (12, 'Little, Brown and Company', 'info@littlebrown.com'),
    (13, 'Doubleday', 'contact@doubleday.com'),
    (14, 'Farrar, Straus and Giroux', 'info@fsgbooks.com'),
    (15, 'St. Martin''s Press', 'contact@stmartins.com'),
    (16, 'Knopf', 'info@knopf.com'),
    (17, 'Random House', 'contact@randomhouse.com'),
    (18, 'Alfred A. Knopf', 'info@alfredknopf.com'),
    (19, 'Harper Perennial', 'info@harperperennial.com'),
    (20, 'Graywolf Press', 'contact@graywolfpress.org'),
    (21, 'Akashic Books', 'info@akashicbooks.com'),
    (22, 'Atria Books', 'contact@atriabooks.com'),
    (23, 'Tyndale House', 'info@tyndale.com'),
    (24, 'Bantam Books', 'contact@bantambooks.com'),
    (25, 'Ingram Content Group', 'info@ingramcontent.com'),
    (26, 'Sourcebooks', 'contact@sourcebooks.com'),
    (27, 'Perseus Books Group', 'info@perseusbooks.com'),
    (28, 'Workman Publishing', 'contact@workman.com'),
    (29, 'Houghton Mifflin Harcourt', 'info@hmhco.com'),
    (30, 'Chronicle Books', 'contact@chroniclebooks.com');

INSERT INTO LibraryItem(ItemID, ItemType) VALUES
    (1, 'Book'), (2, 'Book'), (3, 'Book'), (4, 'Book'), (5, 'Book'),
    (6, 'Book'), (7, 'Book'), (8, 'Book'), (9, 'Book'), (10, 'Book'),
    (11, 'Book'), (12, 'Book'), (13, 'Book'), (14, 'Book'), (15, 'Book'),
    (16, 'Book'), (17, 'Book'), (18, 'Book'), (19, 'Book'), (20, 'Book'),
    (21, 'Book'), (22, 'Book'), (23, 'Book'), (24, 'Book'), (25, 'Book'),
    (26, 'Book'), (27, 'Book'), (28, 'Book'), (29, 'Book'), (30, 'Book'),
    (31, 'Book'), (32, 'Book'), (33, 'Book'), (34, 'Book'), (35, 'Book'),
    (36, 'Book'), (37, 'Book'), (38, 'Book'), (39, 'Book'), (40, 'Book'),
    (101, 'Movie'), (102, 'Movie'), (103, 'Movie'), (104, 'Movie'), (105, 'Movie'),
    (106, 'Movie'), (107, 'Movie'), (108, 'Movie'), (109, 'Movie'), (110, 'Movie'),
    (111, 'Movie'), (112, 'Movie'), (113, 'Movie'), (114, 'Movie'), (115, 'Movie'),
    (116, 'Movie'), (117, 'Movie'), (118, 'Movie'), (119, 'Movie'), (120, 'Movie'),
    (121, 'Movie'), (122, 'Movie'), (123, 'Movie'), (124, 'Movie'), (125, 'Movie'),
    (126, 'Movie'), (127, 'Movie'), (128, 'Movie'), (129, 'Movie'), (130, 'Movie'),
    (131, 'Movie'), (132, 'Movie'), (133, 'Movie'), (134, 'Movie'), (135, 'Movie'),
    (136, 'Movie'), (137, 'Movie'), (138, 'Movie'), (139, 'Movie'), (140, 'Movie');


INSERT INTO Books (ItemID, Language, Genre, Title, PublicationYear, NumCopies, BookType, PublisherID) VALUES
    (1, 'EN', 'JFIC', 'Harry Potter and the Half-Blood Prince', 2005, 17, 'Physical_Copy', 1),            
    (2, 'EN', 'Fiction', 'The Fellowship of the Ring', 1954, 12, 'Physical_Copy', 2),                 
    (3, 'EN', 'Fiction', 'A Game of Thrones', 1996, 10, 'Physical_Copy', 3),                       
    (4, 'EN', 'Mystery', 'Murder on the Orient Express', 1934, 8, 'Physical_Copy', 4),            
    (5, 'EN', 'Thriller', 'The Shining', 1977, 14, 'Ebook', 5),                                  
    (6, 'EN', 'Fiction', 'Foundation', 1951, 9, 'Physical_Copy', 6),                           
    (7, 'EN', 'Romance', 'Pride and Prejudice', 1813, 20, 'Physical_Copy', 7),                      
    (8, 'EN', 'Fiction', 'The Adventures of Huckleberry Finn', 1884, 15, 'Physical_Copy', 8),   
    (9, 'EN', 'Fiction', 'A Tale of Two Cities', 1859, 18, 'AudioBook_Digital', 9),             
    (10, 'EN', 'Fiction', 'Norwegian Wood', 1987, 11, 'Physical_Copy', 10),                
    (11, 'ES', 'Fiction', 'One Hundred Years of Solitude', 1967, 16, 'Physical_Copy', 11),   
    (12, 'RU', 'Fiction', 'War and Peace', 1869, 6, 'Physical_Copy', 12),                       
    (13, 'RU', 'Fiction', 'Crime and Punishment', 1866, 7, 'Ebook', 13),                          
    (14, 'DE', 'Fiction', 'The Metamorphosis', 1915, 13, 'Physical_Copy', 14),           
    (15, 'EN', 'Fiction', 'The Old Man and the Sea', 1952, 19, 'Physical_Copy', 15),       
    (16, 'EN', 'Fiction', 'Hamlet', 1603, 22, 'Physical_Copy', 16),                         
    (17, 'EN', 'Fiction', 'Beloved', 1987, 10, 'Physical_Copy', 17),                         
    (18, 'EN', 'Fiction', 'Ulysses', 1922, 5, 'Physical_Copy', 18),                         
    (19, 'EN', 'Fiction', 'To the Lighthouse', 1927, 12, 'Physical_Copy', 19),                  
    (20, 'GR', 'Fiction', 'The Iliad', -800, 25, 'Physical_Copy', 20),                           
    (21, 'EN', 'Biography', 'I Know Why the Caged Bird Sings', 1969, 9, 'Physical_Copy', 21),       
    (22, 'EN', 'Mystery', 'The Hound of the Baskervilles', 1902, 13, 'Physical_Copy', 22),          
    (23, 'EN', 'Fiction', 'Slaughterhouse-Five', 1969, 7, 'Physical_Copy', 23),                  
    (24, 'EN', 'Fiction', 'The Handmaid’s Tale', 1985, 7, 'Ebook', 24),                           
    (25, 'EN', 'Fiction', 'The War of the Worlds', 1898, 8, 'Physical_Copy', 25),               
    (26, 'EN', 'Fiction', 'Do Androids Dream of Electric Sheep?', 1968, 9, 'Physical_Copy', 26), 
    (27, 'EN', 'Fiction', 'Fahrenheit 451', 1953, 17, 'Physical_Copy', 27),                    
    (28, 'EN', 'Fiction', 'The Picture of Dorian Gray', 1890, 15, 'Physical_Copy', 28),       
    (29, 'EN', 'Fiction', 'Things Fall Apart', 1958, 13, 'Physical_Copy', 29),                    
    (30, 'FR', 'Fiction', 'The Stranger', 1942, 12, 'Physical_Copy', 30),                 
    (31, 'FR', 'Fiction', 'Nausea', 1938, 8, 'Physical_Copy', 30),                        
    (32, 'EN', 'Fiction', 'The Call of the Wild', 1903, 10, 'AudioBook_Physical', 1),      
    (33, 'EN', 'Fiction', 'The Tell-Tale Heart', 1843, 18, 'Physical_Copy', 2),           
    (34, 'EN', 'Fiction', 'Little Women', 1868, 20, 'AudioBook_Digital', 3),              
    (35, 'FR', 'Fiction', 'Madness and Civilization', 1961, 7, 'Physical_Copy', 3),       
    (36, 'EN', 'Fiction', 'The Two Towers', 1954, 12, 'Physical_Copy', 2),                
    (37, 'EN', 'Fiction', 'The Return of the King', 1955, 8, 'Ebook', 2),              
    (38, 'EN', 'Romance', 'Sense and Sensibility', 1811, 6, 'AudioBook_Physical', 7),      
    (39, 'EN', 'Fiction', 'Romeo and Juliet', 1597, 12, 'AudioBook_Physical', 8),          
    (40, 'EN', 'Mystery', 'And Then There Were None', 1939, 12, 'AudioBook_Physical', 4);  


INSERT INTO Authors (AuthorID, Name, DOB, Nationality) VALUES
    (1, 'J.K. Rowling', '1965-07-31', 'British'),
    (2, 'J.R.R. Tolkien', '1892-01-03', 'British'),
    (3, 'George R.R. Martin', '1948-09-20', 'American'),
    (4, 'Agatha Christie', '1890-09-15', 'British'),
    (5, 'Stephen King', '1947-09-21', 'American'),
    (6, 'Isaac Asimov', '1920-01-02', 'American'),
    (7, 'Jane Austen', '1775-12-16', 'British'),
    (8, 'Mark Twain', '1835-11-30', 'American'),
    (9, 'Charles Dickens', '1812-02-07', 'British'),
    (10, 'Haruki Murakami', '1949-01-12', 'Japanese'),
    (11, 'Gabriel García Márquez', '1927-03-06', 'Colombian'),
    (12, 'Leo Tolstoy', '1828-09-09', 'Russian'),
    (13, 'Fyodor Dostoevsky', '1821-11-11', 'Russian'),
    (14, 'Franz Kafka', '1883-07-03', 'Austrian'),
    (15, 'Ernest Hemingway', '1899-07-21', 'American'),
    (16, 'William Shakespeare', '1564-04-23', 'British'),
    (17, 'Toni Morrison', '1931-02-18', 'American'),
    (18, 'James Joyce', '1882-02-02', 'Irish'),
    (19, 'Virginia Woolf', '1882-01-25', 'British'),
    (20, 'Homer', '-800-01-01', 'Greek'),
    (21, 'Maya Angelou', '1928-04-04', 'American'),
    (22, 'Arthur Conan Doyle', '1859-05-22', 'British'),
    (23, 'Kurt Vonnegut', '1922-11-11', 'American'),
    (24, 'Margaret Atwood', '1939-11-18', 'Canadian'),
    (25, 'H.G. Wells', '1866-09-21', 'British'),
    (26, 'Philip K. Dick', '1928-12-16', 'American'),
    (27, 'Ray Bradbury', '1920-08-22', 'American'),
    (28, 'Oscar Wilde', '1854-10-16', 'Irish'),
    (29, 'Chinua Achebe', '1930-11-16', 'Nigerian'),
    (30, 'Albert Camus', '1913-11-07', 'French'),
    (31, 'Jean-Paul Sartre', '1905-06-21', 'French'),
    (32, 'Jack London', '1876-01-12', 'American'),
    (33, 'Edgar Allan Poe', '1809-01-19', 'American'),
    (34, 'Louisa May Alcott', '1832-11-29', 'American'),
    (35, 'Michel Foucault', '1926-10-15', 'French');


INSERT INTO Book_Author (ItemID, AuthorID) VALUES
    (1, 1),  -- Harry Potter and the Half-Blood Prince by J.K. Rowling 
    (2, 2),  -- The Fellowship of the Ring by J.R.R. Tolkien
    (3, 3),  -- A Game of Thrones by George R.R. Martin
    (4, 4),  -- Murder on the Orient Express by Agatha Christie
    (5, 5),  -- The Shining by Stephen King
    (6, 6),  -- Foundation by Isaac Asimov
    (7, 7),  -- Pride and Prejudice by Jane Austen
    (8, 8),  -- The Adventures of Huckleberry Finn by Mark Twain
    (9, 9),  -- A Tale of Two Cities by Charles Dickens
    (10, 10), -- Norwegian Wood by Haruki Murakami
    (11, 11), -- One Hundred Years of Solitude by Gabriel García Márquez
    (12, 12), -- War and Peace by Leo Tolstoy
    (13, 13), -- Crime and Punishment by Fyodor Dostoevsky
    (14, 14), -- The Metamorphosis by Franz Kafka
    (15, 15), -- The Old Man and the Sea by Ernest Hemingway
    (16, 16), -- Hamlet by William Shakespeare
    (17, 17), -- Beloved by Toni Morrison
    (18, 18), -- Ulysses by James Joyce
    (19, 19), -- To the Lighthouse by Virginia Woolf
    (20, 20), -- The Iliad by Homer
    (21, 21), -- I Know Why the Caged Bird Sings by Maya Angelou
    (22, 22), -- The Hound of the Baskervilles by Arthur Conan Doyle
    (23, 23), -- Slaughterhouse-Five by Kurt Vonnegut
    (24, 24), -- The Handmaid’s Tale by Margaret Atwood
    (25, 25), -- The War of the Worlds by H.G. Wells
    (26, 26), -- Do Androids Dream of Electric Sheep? by Philip K. Dick
    (27, 27), -- Fahrenheit 451 by Ray Bradbury
    (28, 28), -- The Picture of Dorian Gray by Oscar Wilde
    (29, 29), -- Things Fall Apart by Chinua Achebe
    (30, 30), -- The Stranger by Albert Camus
    (31, 31), -- Nausea by Jean-Paul Sartre
    (32, 32), -- The Call of the Wild by Jack London
    (33, 33), -- The Tell-Tale Heart by Edgar Allan Poe
    (34, 34), -- Little Women by Louisa May Alcott
    (35, 35), -- Madness and Civilization by Michel Foucault
    (36, 2),  -- The Two Towers by J.R.R. Tolkien
    (37, 2),  -- The Return of the King
    (38, 7),  -- Sense and Sensibility by Jane Austen
    (39, 16), -- Romeo and Juliet by Shakespeare
    (40, 4);  -- And Then There Were None by Agatha Christie


INSERT INTO Movies (ItemID, Language, Title, PublicationYear, NumCopies, Genre, Director, MovieType) VALUES
    (101, 'EN', 'Inception', 2010, 5, 'Sci-Fi', 'Christopher Nolan', 'Physical'),
    (102, 'EN', 'The Shawshank Redemption', 1994, 3, 'Drama', 'Frank Darabont', 'Physical'),
    (103, 'EN', 'The Dark Knight', 2008, 7, 'Action', 'Christopher Nolan', 'Physical'),
    (104, 'EN', 'Pulp Fiction', 1994, 4, 'Thriller', 'Quentin Tarantino', 'Digital'),
    (105, 'EN', 'Forrest Gump', 1994, 6, 'Drama', 'Robert Zemeckis', 'Physical'),
    (106, 'EN', 'Fight Club', 1999, 2, 'Drama', 'David Fincher', 'Physical'),
    (107, 'EN', 'The Godfather', 1972, 8, 'Crime', 'Francis Ford Coppola', 'Digital'),
    (108, 'EN', 'The Matrix', 1999, 5, 'Sci-Fi', 'The Wachowskis', 'Physical'),
    (109, 'EN', 'The Lord of the Rings: The Fellowship of the Ring', 2001, 6, 'Fantasy', 'Peter Jackson', 'Physical'),
    (110, 'EN', 'The Avengers', 2012, 10, 'Action', 'Joss Whedon', 'Physical'),
    (111, 'FR', 'Amélie', 2001, 3, 'Romance', 'Jean-Pierre Jeunet', 'Physical'),
    (112, 'FR', 'La Haine', 1995, 4, 'Drama', 'Mathieu Kassovitz', 'Physical'),
    (113, 'ES', 'Pan''s Labyrinth', 2006, 2, 'Fantasy', 'Guillermo del Toro', 'Physical'),
    (114, 'EN', 'The Silence of the Lambs', 1991, 3, 'Thriller', 'Jonathan Demme', 'Digital'),
    (115, 'EN', 'Gladiator', 2000, 5, 'Action', 'Ridley Scott', 'Physical'),
    (116, 'EN', 'The Social Network', 2010, 6, 'Biography', 'David Fincher', 'Digital'),
    (117, 'EN', 'Titanic', 1997, 8, 'Romance', 'James Cameron', 'Physical'),
    (118, 'EN', 'The Lion King', 1994, 7, 'Animation', 'Roger Allers', 'Physical'),
    (119, 'EN', 'Jurassic Park', 1993, 9, 'Adventure', 'Steven Spielberg', 'Digital'),
    (120, 'EN', 'Eternal Sunshine of the Spotless Mind', 2004, 4, 'Romance', 'Michel Gondry', 'Physical'),
    (121, 'KO', 'Parasite', 2019, 5, 'Thriller', 'Bong Joon-ho', 'Physical'),
    (122, 'IT', 'La Dolce Vita', 1960, 2, 'Drama', 'Federico Fellini', 'Physical'),
    (123, 'EN', 'The Departed', 2006, 3, 'Crime', 'Martin Scorsese', 'Physical'),
    (124, 'EN', '12 Angry Men', 1957, 4, 'Drama', 'Sidney Lumet', 'Physical'),
    (125, 'FR', 'Les Intouchables', 2011, 5, 'Comedy', 'Olivier Nakache', 'Physical'),
    (126, 'EN', 'The Shape of Water', 2017, 6, 'Fantasy', 'Guillermo del Toro', 'Digital'),
    (127, 'EN', 'No Country for Old Men', 2007, 4, 'Thriller', 'Ethan Coen', 'Physical'),
    (128, 'EN', 'The Wolf of Wall Street', 2013, 8, 'Biography', 'Martin Scorsese', 'Digital'),
    (129, 'EN', 'Deadpool', 2016, 5, 'Action', 'Tim Miller', 'Physical'),
    (130, 'EN', 'A Beautiful Mind', 2001, 6, 'Biography', 'Ron Howard', 'Digital'),
    (131, 'CH', 'Crouching Tiger, Hidden Dragon', 2000, 3, 'Action', 'Ang Lee', 'Physical'),
    (132, 'EN', 'Memento', 2000, 4, 'Thriller', 'Christopher Nolan', 'Physical'),
    (133, 'EN', 'The Big Lebowski', 1998, 5, 'Comedy', 'Joel Coen', 'Physical'),
    (134, 'EN', 'Braveheart', 1995, 6, 'History', 'Mel Gibson', 'Physical'),
    (135, 'FR', 'Blue is the Warmest Color', 2013, 2, 'Romance', 'Abdellatif Kechiche', 'Physical'),
    (136, 'EN', 'A Clockwork Orange', 1971, 4, 'Drama', 'Stanley Kubrick', 'Physical'),
    (137, 'EN', 'The Grand Budapest Hotel', 2014, 5, 'Comedy', 'Wes Anderson', 'Digital'),
    (138, 'IT', 'Cinema Paradiso', 1988, 3, 'Drama', 'Giuseppe Tornatore', 'Physical'),
    (139, 'EN', 'The Revenant', 2015, 6, 'Adventure', 'Alejandro González Iñárritu', 'Physical'),
    (140, 'EN', 'Inside Out', 2015, 7, 'Animation', 'Pete Docter', 'Digital');


INSERT INTO Reviews VALUES
    (1, 3, 1, 'An exciting continuation of the Harry Potter series! I loved it.', 5),
    (2, 7, 2, 'A timeless classic. The world-building is phenomenal.', 5),
    (3, 12, 3, 'Great start to an epic series, but a bit slow in parts.', 4),
    (4, 4, 5, 'Did not live up to the hype. Too slow and predictable.', 2),
    (5, 3, 101, 'A mind-bending journey that keeps you on the edge of your seat!', 5),
    (6, 2, 7, 'A beautiful romance with witty dialogue and social critique.', 5),
    (7, 9, 8, 'The language was outdated, and I couldn’t connect with the characters.', 2),
    (8, 15, 9, 'A gripping audiobook with a brilliant narration. Loved it!', 5),
    (9, 1, 4, 'A well-crafted mystery with plenty of twists and turns.', 5),
    (10, 10, 10, 'An emotional, nostalgic read. Full of melancholy and reflection.', 4),
    (11, 13, 11, 'A masterpiece of magical realism, but it takes effort to read.', 5),
    (12, 17, 12, 'Incredibly long, but a powerful look at human conflict.', 4),
    (13, 6, 12, 'Difficult to get through, but full of profound philosophical questions.', 3),
    (14, 20, 14, 'An interesting, surreal exploration of human isolation.', 4),
    (15, 9, 15, 'A short but powerful story. Hemingway at his best.', 5),
    (16, 16, 16, 'A classic tragedy with timeless themes of ambition and guilt.', 5),
    (17, 21, 17, 'Toni Morrison’s writing is beautiful, though emotionally heavy.', 4),
    (18, 8, 18, 'Challenging to read, but Joyce’s prose is masterful.', 3),
    (19, 5, 1, 'I couldn’t get into it. Too many plot holes and the pacing was off.', 1),
    (20, 14, 20, 'A legendary epic filled with grandeur and heroism.', 5),
    (21, 20, 114, 'A gripping psychological thriller with stellar performances, but a bit disturbing.', 4),
    (22, 11, 22, 'The mystery was weak, and the characters were uninteresting.', 2),
    (23, 21, 130, 'A brilliant biographical drama that is both inspiring and moving.', 5),
    (24, 10, 24, 'A chilling look at a dystopian future. A must-read for everyone.', 5),
    (25, 6, 116, 'A fascinating look at the rise of social media. I learned so much from it, really engaging.', 4),
    (26, 6, 26, 'A thought-provoking look at what it means to be human.', 5),
    (27, 12, 27, 'A thought-provoking commentary on censorship and conformity.', 5),
    (28, 9, 28, 'An intriguing look at vanity and morality.', 4),
    (29, 17, 9, 'A poetic and symbolic novel. Deeply impactful.', 5),
    (30, 14, 7, 'A beautiful romance filled with wit and elegance.', 4);


INSERT INTO Shelf VALUES
    (1, 1, 'A', 1),
    (2, 1, 'A', 2),
    (3, 1, 'A', 3),
    (4, 1, 'A', 4),
    (5, 1, 'A', 5),
    (6, 1, 'B', 1),
    (7, 1, 'B', 2),
    (8, 1, 'B', 3),
    (9, 1, 'B', 4),
    (10, 1, 'B', 5),
    (11, 2, 'A', 1),
    (12, 2, 'A', 2),
    (13, 2, 'A', 3),
    (14, 2, 'A', 4),
    (15, 2, 'A', 5),
    (16, 2, 'B', 1),
    (17, 2, 'B', 2),
    (18, 2, 'B', 3),
    (19, 2, 'B', 4),
    (20, 2, 'B', 5),
    (21, 3, 'A', 1),
    (22, 3, 'A', 2),
    (23, 3, 'A', 3),
    (24, 3, 'A', 4),
    (25, 3, 'A', 5),
    (26, 3, 'B', 1),
    (27, 3, 'B', 2),
    (28, 3, 'B', 3),
    (29, 3, 'B', 4),
    (30, 3, 'B', 5);


INSERT INTO Shelf_PhysicalCopy VALUES
    (1, 1),            
    (2, 1),                 
    (3, 2),                       
    (4, 2),                                  
    (6, 3),                           
    (7, 3),                      
    (8, 3),             
    (10, 4),                
    (11, 4),   
    (12, 4),                          
    (14, 5),           
    (15, 5),       
    (16, 5),                         
    (17, 6),                         
    (18, 6),                         
    (19, 7),                  
    (20, 7),
    (21, 7),
    (22, 8),
    (23, 8),
    (25, 8),
    (26, 9),
    (27, 9),
    (28, 10),
    (29, 10),
    (30, 10),
    (31, 10),
    (32, 11),
    (33, 6),
    (35, 6),
    (36, 9),
    (38, 11),
    (39, 11),
    (40, 11),
    (101, 12),
    (102, 12),
    (103, 12),
    (105, 13), 
    (106, 13),
    (108, 13), 
    (109, 14),  
    (110, 14), 
    (111, 14),
    (112, 14),
    (113, 15), 
    (115, 15),
    (117, 15), 
    (118, 15),
    (120, 16),
    (121, 16), 
    (122, 16), 
    (123, 16), 
    (124, 17), 
    (125, 17), 
    (127, 17),
    (129, 17),
    (131, 18), 
    (132, 18),
    (133, 18), 
    (134, 18), 
    (135, 19), 
    (136, 19),
    (138, 19), 
    (139, 19);

INSERT INTO CheckOutLibraryItem (ItemID, CardID, BorrowDate, ReturnByDate) VALUES
    (1, 1, '2023-09-01', '2023-09-15'),
    (2, 2, '2023-09-02', '2023-09-16'),
    (3, 3, '2023-09-03', '2023-09-17'),
    (4, 4, '2023-09-04', '2023-09-18'),
    (5, 5, '2023-09-05', '2023-09-19'),
    (6, 6, '2023-09-06', '2023-09-20'),
    (7, 7, '2023-09-07', '2023-09-21'),
    (8, 8, '2023-09-08', '2023-09-22'),
    (9, 9, '2023-09-09', '2023-09-23'),
    (10, 10, '2023-09-10', '2023-09-24'),
    (11, 11, '2023-09-11', '2023-09-25'),
    (12, 12, '2023-09-12', '2023-09-26'),
    (13, 13, '2023-09-13', '2023-09-27'),
    (14, 14, '2023-09-14', '2023-09-28'),
    (15, 15, '2023-09-15', '2023-09-29'),
    (16, 16, '2023-09-16', '2023-09-30'),
    (17, 17, '2023-09-17', '2023-10-01'),
    (18, 18, '2023-09-18', '2023-10-02'),
    (19, 19, '2023-09-19', '2023-10-03'),
    (20, 20, '2023-09-20', '2023-10-04'),
    (21, 21, '2023-09-21', '2023-10-05'),
    (22, 22, '2023-09-22', '2023-10-06'),
    (23, 23, '2023-09-23', '2023-10-07'),
    (24, 24, '2023-09-24', '2023-10-08'),
    (25, 25, '2023-09-25', '2023-10-09'),
    (26, 26, '2023-09-26', '2023-10-10'),
    (27, 27, '2023-09-27', '2023-10-11'),
    (28, 28, '2023-09-28', '2023-10-12'),
    (29, 29, '2023-09-29', '2023-10-13'),
    (30, 30, '2023-09-30', '2023-10-14'),
    (1, 1, '2023-10-01', '2023-10-15'),
    (2, 2, '2023-10-02', '2023-10-16'),
    (3, 3, '2023-10-03', '2023-10-17'),
    (4, 4, '2023-10-04', '2023-10-18'),
    (5, 5, '2023-10-05', '2023-10-19'),
    (6, 6, '2023-10-06', '2023-10-20');

INSERT INTO ReturnLibraryItem (CheckoutID, ReturnDate) VALUES
    (1, '2023-09-14'),
    (2, '2023-09-16'),
    (3, '2023-09-18'),
    (4, '2023-09-19'),
    (5, '2023-09-20'),
    (6, '2023-09-21'),
    (7, '2023-09-22'),
    (8, '2023-09-23'),
    (9, '2023-09-24'),
    (10, '2023-09-25'),
    (11, '2023-09-26'),
    (12, '2023-09-27'),
    (13, '2023-09-28'),
    (14, '2023-09-29'),
    (15, '2023-09-30'),
    (16, '2023-10-01'),
    (17, '2023-10-02'),
    (18, '2023-10-03'),
    (19, '2023-10-04'),
    (20, '2023-10-05'),
    (21, '2023-10-06'),
    (22, '2023-10-07'),
    (23, '2023-10-08'),
    (24, '2023-10-09'),
    (25, '2023-10-10'),
    (26, '2023-10-11'),
    (27, '2023-10-12'),
    (28, '2023-10-13'),
    (29, '2023-10-14'),
    (30, '2023-10-15'),
    (31, '2023-10-16'),
    (32, '2023-10-17'),
    (33, '2023-10-18');

INSERT INTO ReserveLibraryItem (ItemID, CardID, PlaceInLine) VALUES
    (1, 2, 1),
    (1, 3, 2),
    (1, 4, 3),
    (5, 5, 1),
    (5, 6, 2),
    (5, 7, 3),
    (7, 8, 1),
    (7, 9, 2),
    (7, 10, 3),
    (10, 11, 1),
    (10, 12, 2),
    (10, 13, 3),
    (15, 14, 1),
    (15, 15, 2),
    (15, 16, 3),
    (16, 17, 1),
    (16, 18, 2),
    (16, 19, 3),
    (18, 20, 1),
    (18, 21, 2),
    (18, 22, 3),
    (20, 23, 1),
    (20, 24, 2),
    (20, 25, 3),
    (22, 26, 1),
    (22, 27, 2),
    (22, 28, 3),
    (25, 29, 1),
    (25, 30, 2),
    (25, 1, 3),
    (28, 2, 1),
    (28, 3, 2),
    (28, 4, 3),
    (30, 5, 1),
    (30, 6, 2);

INSERT INTO LibraryItemState (ItemID, CopiesAvailable, ReservationCount) VALUES
    (1, 14, 3),
    (2, 10, 0),
    (3, 9, 0),
    (4, 7, 0),
    (5, 11, 3),
    (6, 8, 0),
    (7, 17, 3),
    (8, 15, 0),
    (9, 18, 0),
    (10, 11, 3),
    (11, 16, 0),
    (12, 5, 0),
    (13, 7, 0),
    (14, 10, 0),
    (15, 19, 3),
    (16, 20, 3),
    (17, 7, 0),
    (18, 5, 3),
    (19, 12, 0),
    (20, 25, 3),
    (21, 9, 0),
    (22, 13, 3),
    (23, 7, 0),
    (24, 8, 0),
    (25, 9, 3),
    (26, 9, 0),
    (27, 17, 0),
    (28, 15, 3),
    (29, 13, 0),
    (30, 12, 2),
    (31, 8, 0),
    (32, 10, 0),
    (33, 18, 0),
    (34, 20, 0),
    (35, 7, 0),
    (36, 12, 0),
    (37, 8, 0),
    (38, 6, 0),
    (39, 12, 0),
    (40, 12, 0),
    (101, 5, 0),
    (102, 3, 0),
    (103, 7, 0),
    (104, 4, 0),
    (105, 6, 0),
    (106, 2, 0),
    (107, 8, 0),
    (108, 5, 0),
    (109, 6, 0),
    (110, 10, 0),
    (111, 3, 0),
    (112, 4, 0),
    (113, 2, 0),
    (114, 3, 0),
    (115, 5, 0),
    (116, 6, 0),
    (117, 8, 0),
    (118, 7, 0),
    (119, 9, 0),
    (120, 4, 0),
    (121, 5, 0),
    (122, 2, 0),
    (123, 3, 0),
    (124, 4, 0),
    (125, 5, 0),
    (126, 6, 0),
    (127, 4, 0),
    (128, 8, 0),
    (129, 5, 0),
    (130, 6, 0),
    (131, 3, 0),
    (132, 4, 0),
    (133, 5, 0),
    (134, 6, 0),
    (135, 2, 0),
    (136, 4, 0),
    (137, 5, 0),
    (138, 3, 0),
    (139, 6, 0),
    (140, 7, 0);


-- Total number of books and movies available (Aggregate)
SELECT ItemType, SUM(CopiesAvailable) AS TotalAvailable
FROM LibraryItem
JOIN LibraryItemState ON LibraryItem.ItemID = LibraryItemState.ItemID
GROUP BY ItemType;

-- Average overdue fees (Aggregate)
SELECT AVG(OverdueFees) AS AverageOverdueFees
FROM LibraryAccount;

-- List of books and their authors (Join)
SELECT Books.Title, Authors.Name AS AuthorName
FROM Books
JOIN Book_Author ON Books.ItemID = Book_Author.ItemID
JOIN Authors ON Book_Author.AuthorID = Authors.AuthorID;

-- Top users by number of books borrowed (Join)
SELECT LibraryAccount.Name, COUNT(CheckOutLibraryItem.ItemID) AS BooksBorrowed
FROM CheckOutLibraryItem
JOIN LibraryAccount ON CheckOutLibraryItem.CardID = LibraryAccount.CardID
JOIN Books ON CheckOutLibraryItem.ItemID = Books.ItemID
GROUP BY LibraryAccount.Name
ORDER BY BooksBorrowed DESC;

-- Top 3 highest rated books (JOIN)
SELECT Title, AVG(Rating) AS AvgRating
FROM Books
JOIN Reviews ON Books.ItemID = Reviews.ItemID
GROUP BY Title
ORDER BY AvgRating DESC
LIMIT 3;

-- Total reservations for top 5 most reserved books (Subquery)
SELECT Title, ReservationCount
FROM Books
JOIN LibraryItemState ON Books.ItemID = LibraryItemState.ItemID
WHERE Books.ItemID IN (
    SELECT ItemID
    FROM LibraryItemState
    ORDER BY ReservationCount DESC
    LIMIT 5
)
ORDER BY ReservationCount DESC;


-- Total users with overdue fees (Other)
SELECT COUNT(*) AS UsersWithOverdueFees
FROM LibraryAccount
WHERE OverdueFees > 0;

-- Average copies per book genre (Aggregate)
SELECT Genre, AVG(NumCopies) AS AverageCopies
FROM Books
GROUP BY Genre;

-- Books and their shelf locations (Join)
SELECT Books.Title, Shelf.Floor, Shelf.Section, Shelf.Aisle
FROM Books
JOIN Shelf_PhysicalCopy ON Books.ItemID = Shelf_PhysicalCopy.ItemID
JOIN Shelf ON Shelf_PhysicalCopy.ShelfID = Shelf.ShelfID;

-- Users with the most reservations (Other)
SELECT Name, NumReserved
FROM LibraryAccount
ORDER BY NumReserved DESC
LIMIT 5;

-- Books with Scholastic as Publisher and have at least 1 copie available (Subquery)
SELECT b.Title, b.PublicationYear, p.Name AS PublisherName
FROM Books b
INNER JOIN Publishers p ON b.PublisherID = p.PublisherID
WHERE b.ItemID IN (
    SELECT lis.ItemID
    FROM LibraryItemState lis
    WHERE lis.CopiesAvailable > 0
) AND p.Name = 'Scholastic';

SELECT * FROM ReserveLibraryItem;