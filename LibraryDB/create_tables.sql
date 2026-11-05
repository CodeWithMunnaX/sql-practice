/* =====================================================================
   LibraryDB  (SQL Server)
   3 tables, 100 rows each, 10 columns each

     members    (member_id, member_name, gender, age, city, state,
                 phone, email, join_date, membership_type)
     books      (book_id, title, author, genre, publisher, publish_year,
                 price, pages, language, stock)
     borrowings (borrow_id, member_id, book_id, borrow_date, due_date,
                 return_date, status, fine_amount, librarian, branch)

     members --< borrowings >-- books

   Notes:
     - Some members never borrowed a book, some books were never borrowed
       (good for LEFT JOIN / anti join practice)
     - email and return_date have some NULLs
   ===================================================================== */

DROP TABLE IF EXISTS borrowings;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;

CREATE TABLE members (
    member_id        INT           PRIMARY KEY,
    member_name      VARCHAR(50),
    gender           VARCHAR(10),
    age              INT,
    city             VARCHAR(30),
    state            VARCHAR(30),
    phone            VARCHAR(15),
    email            VARCHAR(100),
    join_date        DATE,
    membership_type  VARCHAR(20)
);

CREATE TABLE books (
    book_id       INT            PRIMARY KEY,
    title         VARCHAR(100),
    author        VARCHAR(50),
    genre         VARCHAR(30),
    publisher     VARCHAR(50),
    publish_year  INT,
    price         DECIMAL(10,2),
    pages         INT,
    language      VARCHAR(20),
    stock         INT
);

CREATE TABLE borrowings (
    borrow_id     INT            PRIMARY KEY,
    member_id     INT            REFERENCES members(member_id),
    book_id       INT            REFERENCES books(book_id),
    borrow_date   DATE,
    due_date      DATE,
    return_date   DATE,
    status        VARCHAR(20),
    fine_amount   DECIMAL(10,2),
    librarian     VARCHAR(30),
    branch        VARCHAR(20)
);

/* Load data from CSV (change the path if your folder is somewhere else) */
BULK INSERT members
FROM 'C:\Users\MeanderSoftware\Desktop\SQL\LibraryDB\members.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS);

BULK INSERT books
FROM 'C:\Users\MeanderSoftware\Desktop\SQL\LibraryDB\books.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS);

BULK INSERT borrowings
FROM 'C:\Users\MeanderSoftware\Desktop\SQL\LibraryDB\borrowings.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS);

SELECT COUNT(*) AS members_rows    FROM members;
SELECT COUNT(*) AS books_rows      FROM books;
SELECT COUNT(*) AS borrowings_rows FROM borrowings;
