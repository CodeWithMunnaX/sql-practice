/* =====================================================================
   SQL JOINS PRACTICE  (SQL Server)
   Dataset : LibraryDB  (3 tables, 100 rows each)
   Setup   : run create_tables.sql first

   Tables
     members    (member_id, member_name, gender, age, city, state,
                 phone, email, join_date, membership_type)
     books      (book_id, title, author, genre, publisher, publish_year,
                 price, pages, language, stock)
     borrowings (borrow_id, member_id, book_id, borrow_date, due_date,
                 return_date, status, fine_amount, librarian, branch)

     members --< borrowings >-- books

   Sections (5 questions each)
     1. LEFT JOIN          Q1  - Q5
     2. RIGHT JOIN         Q6  - Q10
     3. FULL JOIN          Q11 - Q15
     4. LEFT ANTI JOIN     Q16 - Q20
     5. RIGHT ANTI JOIN    Q21 - Q25
     6. FULL ANTI JOIN     Q26 - Q30

   Each question: question -> solution -> expected row count.
   Try writing the query yourself before looking at the solution.
   ===================================================================== */



/* =====================================================================
   1. LEFT JOIN
   All rows from the LEFT table + matching rows from the RIGHT table.
   If there is no match, the right-side columns are NULL.
   ===================================================================== */

-- Q1. List every member with their borrow_id and borrow_date.
--     Include members who have never borrowed a book.
SELECT m.member_id, m.member_name, br.borrow_id, br.borrow_date
FROM members m
LEFT JOIN borrowings br ON m.member_id = br.member_id
ORDER BY m.member_id;
-- Expected: 148 rows

-- Q2. Show how many times each book has been borrowed.
--     Books that were never borrowed should show 0.
SELECT bk.book_id, bk.title, COUNT(br.borrow_id) AS times_borrowed
FROM books bk
LEFT JOIN borrowings br ON bk.book_id = br.book_id
GROUP BY bk.book_id, bk.title
ORDER BY times_borrowed DESC, bk.book_id;
-- Expected: 100 rows

-- Q3. Show the total fine paid by each member.
--     Members with no fine or no borrowings should show 0.
SELECT m.member_id, m.member_name,
       COALESCE(SUM(br.fine_amount), 0) AS total_fine
FROM members m
LEFT JOIN borrowings br ON m.member_id = br.member_id
GROUP BY m.member_id, m.member_name
ORDER BY total_fine DESC, m.member_id;
-- Expected: 100 rows

-- Q4. Show the most recent borrow date for each book.
--     Books that were never borrowed should show NULL.
SELECT bk.book_id, bk.title, MAX(br.borrow_date) AS last_borrowed
FROM books bk
LEFT JOIN borrowings br ON bk.book_id = br.book_id
GROUP BY bk.book_id, bk.title
ORDER BY bk.book_id;
-- Expected: 100 rows

-- Q5. List all Gold and Premium members with their borrowings from the
--     'Central' branch. Include members with no Central borrowings.
--     Note: the branch filter goes in ON, not WHERE. Putting it in WHERE
--     removes the NULL rows and turns the LEFT JOIN into an INNER JOIN.
SELECT m.member_id, m.member_name, m.membership_type,
       br.borrow_id, br.branch
FROM members m
LEFT JOIN borrowings br
       ON m.member_id = br.member_id
      AND br.branch = 'Central'
WHERE m.membership_type IN ('Gold', 'Premium')
ORDER BY m.member_id;
-- Expected: 27 rows



/* =====================================================================
   2. RIGHT JOIN
   All rows from the RIGHT table + matching rows from the LEFT table.
   A LEFT JOIN B  gives the same result as  B RIGHT JOIN A.
   ===================================================================== */

-- Q6. Using RIGHT JOIN, list every book with its borrow_id and member_id.
--     Include books that have never been borrowed.
SELECT bk.book_id, bk.title, br.borrow_id, br.member_id
FROM borrowings br
RIGHT JOIN books bk ON br.book_id = bk.book_id
ORDER BY bk.book_id;
-- Expected: 144 rows

-- Q7. Using RIGHT JOIN, show the number of borrowings for every member.
SELECT m.member_id, m.member_name, COUNT(br.borrow_id) AS total_borrows
FROM borrowings br
RIGHT JOIN members m ON br.member_id = m.member_id
GROUP BY m.member_id, m.member_name
ORDER BY total_borrows DESC, m.member_id;
-- Expected: 100 rows

-- Q8. List all Hindi books with the name of each member who borrowed them.
--     Include Hindi books that have never been borrowed.
SELECT bk.book_id, bk.title, m.member_name, br.borrow_date
FROM members m
JOIN borrowings br  ON m.member_id = br.member_id
RIGHT JOIN books bk ON br.book_id = bk.book_id
WHERE bk.language = 'Hindi'
ORDER BY bk.book_id;
-- Expected: 48 rows

-- Q9. List all members from Mumbai with their 'Returned Late' borrowings.
--     Include Mumbai members who have never returned a book late.
SELECT m.member_id, m.member_name, br.borrow_id, br.status, br.fine_amount
FROM borrowings br
RIGHT JOIN members m
        ON br.member_id = m.member_id
       AND br.status = 'Returned Late'
WHERE m.city = 'Mumbai'
ORDER BY m.member_id;
-- Expected: 13 rows

-- Q10. Using RIGHT JOIN, show the total fine collected for each genre.
--      Genres with no fines should show 0.
SELECT bk.genre, COALESCE(SUM(br.fine_amount), 0) AS total_fine
FROM borrowings br
RIGHT JOIN books bk ON br.book_id = bk.book_id
GROUP BY bk.genre
ORDER BY total_fine DESC;
-- Expected: 10 rows



/* =====================================================================
   3. FULL JOIN  (FULL OUTER JOIN)
   All rows from BOTH tables. Matching rows are combined; rows without a
   match get NULL on the other side.
   ===================================================================== */

-- Q11. Show members, borrowings and books in one result so that both
--      members who never borrowed and books never borrowed appear.
SELECT m.member_id, m.member_name, br.borrow_id, bk.book_id, bk.title
FROM members m
FULL JOIN borrowings br ON m.member_id = br.member_id
FULL JOIN books bk      ON br.book_id = bk.book_id
ORDER BY br.borrow_id, m.member_id, bk.book_id;
-- Expected: 192 rows

-- Q12. Compare members who borrowed in January 2024 with members who
--      borrowed in February 2024, side by side.
SELECT jan.member_id AS jan_member, feb.member_id AS feb_member
FROM (SELECT DISTINCT member_id FROM borrowings
      WHERE borrow_date BETWEEN '2024-01-01' AND '2024-01-31') jan
FULL JOIN
     (SELECT DISTINCT member_id FROM borrowings
      WHERE borrow_date BETWEEN '2024-02-01' AND '2024-02-29') feb
  ON jan.member_id = feb.member_id
ORDER BY COALESCE(jan.member_id, feb.member_id);
-- Expected: 16 rows

-- Q13. For each genre, show the number of borrowings at the 'Central'
--      branch and at the 'North' branch. Show 0 where there are none.
SELECT COALESCE(c.genre, n.genre) AS genre,
       COALESCE(c.cnt, 0) AS central_count,
       COALESCE(n.cnt, 0) AS north_count
FROM (SELECT bk.genre, COUNT(*) AS cnt
      FROM borrowings br JOIN books bk ON br.book_id = bk.book_id
      WHERE br.branch = 'Central' GROUP BY bk.genre) c
FULL JOIN
     (SELECT bk.genre, COUNT(*) AS cnt
      FROM borrowings br JOIN books bk ON br.book_id = bk.book_id
      WHERE br.branch = 'North' GROUP BY bk.genre) n
  ON c.genre = n.genre
ORDER BY genre;
-- Expected: 9 rows

-- Q14. In one list, show books that are out of stock (stock = 0) and
--      books that are currently borrowed (status = 'Borrowed').
SELECT os.book_id AS out_of_stock_book, cb.book_id AS borrowed_book
FROM (SELECT book_id FROM books WHERE stock = 0) os
FULL JOIN
     (SELECT DISTINCT book_id FROM borrowings WHERE status = 'Borrowed') cb
  ON os.book_id = cb.book_id
ORDER BY COALESCE(os.book_id, cb.book_id);
-- Expected: 18 rows

-- Q15. In one list, show Premium members and members who have paid a fine
--      (fine_amount > 0). Label each row as 'Premium + Fine',
--      'Premium only' or 'Fine only'.
SELECT COALESCE(p.member_id, f.member_id) AS member_id,
       CASE WHEN p.member_id IS NOT NULL AND f.member_id IS NOT NULL THEN 'Premium + Fine'
            WHEN p.member_id IS NOT NULL THEN 'Premium only'
            ELSE 'Fine only'
       END AS label
FROM (SELECT member_id FROM members WHERE membership_type = 'Premium') p
FULL JOIN
     (SELECT DISTINCT member_id FROM borrowings WHERE fine_amount > 0) f
  ON p.member_id = f.member_id
ORDER BY member_id;
-- Expected: 30 rows



/* =====================================================================
   4. LEFT ANTI JOIN
   Rows from the LEFT table that have NO match in the RIGHT table.
   SQL has no ANTI JOIN keyword; write it as:
       LEFT JOIN ... WHERE right_table.key IS NULL
   ===================================================================== */

-- Q16. Find members who have never borrowed a book.
SELECT m.member_id, m.member_name
FROM members m
LEFT JOIN borrowings br ON m.member_id = br.member_id
WHERE br.borrow_id IS NULL
ORDER BY m.member_id;
-- Expected: 48 rows

-- Q17. Find books that have never been borrowed.
SELECT bk.book_id, bk.title
FROM books bk
LEFT JOIN borrowings br ON bk.book_id = br.book_id
WHERE br.borrow_id IS NULL
ORDER BY bk.book_id;
-- Expected: 44 rows

-- Q18. Find members who have never returned a book late.
SELECT m.member_id, m.member_name
FROM members m
LEFT JOIN borrowings br
       ON m.member_id = br.member_id
      AND br.status = 'Returned Late'
WHERE br.borrow_id IS NULL
ORDER BY m.member_id;
-- Expected: 81 rows

-- Q19. Find books that have never been borrowed from the 'Central' branch.
SELECT bk.book_id, bk.title
FROM books bk
LEFT JOIN borrowings br
       ON bk.book_id = br.book_id
      AND br.branch = 'Central'
WHERE br.borrow_id IS NULL
ORDER BY bk.book_id;
-- Expected: 85 rows

-- Q20. Find Gold and Premium members who borrowed nothing between
--      July and December 2024.
SELECT m.member_id, m.member_name, m.membership_type
FROM members m
LEFT JOIN borrowings br
       ON m.member_id = br.member_id
      AND br.borrow_date BETWEEN '2024-07-01' AND '2024-12-31'
WHERE m.membership_type IN ('Gold', 'Premium')
  AND br.borrow_id IS NULL
ORDER BY m.member_id;
-- Expected: 14 rows



/* =====================================================================
   5. RIGHT ANTI JOIN
   Rows from the RIGHT table that have NO match in the LEFT table:
       RIGHT JOIN ... WHERE left_table.key IS NULL
   ===================================================================== */

-- Q21. Using RIGHT JOIN, find books that have never been borrowed.
SELECT bk.book_id, bk.title
FROM borrowings br
RIGHT JOIN books bk ON br.book_id = bk.book_id
WHERE br.borrow_id IS NULL
ORDER BY bk.book_id;
-- Expected: 44 rows

-- Q22. Using RIGHT JOIN, find members who have never borrowed a book.
SELECT m.member_id, m.member_name, m.city
FROM borrowings br
RIGHT JOIN members m ON br.member_id = m.member_id
WHERE br.borrow_id IS NULL
ORDER BY m.member_id;
-- Expected: 48 rows

-- Q23. Find Fiction books that have never been borrowed by a female member.
SELECT bk.book_id, bk.title
FROM borrowings br
JOIN members m      ON br.member_id = m.member_id
                   AND m.gender = 'Female'
RIGHT JOIN books bk ON br.book_id = bk.book_id
WHERE bk.genre = 'Fiction'
  AND br.borrow_id IS NULL
ORDER BY bk.book_id;
-- Expected: 2 rows

-- Q24. Find members from Delhi who have never paid a fine.
SELECT m.member_id, m.member_name
FROM borrowings br
RIGHT JOIN members m
        ON br.member_id = m.member_id
       AND br.fine_amount > 0
WHERE m.city = 'Delhi'
  AND br.borrow_id IS NULL
ORDER BY m.member_id;
-- Expected: 4 rows

-- Q25. Find books with more than 5 copies in stock that were not borrowed
--      between January and March 2024.
SELECT bk.book_id, bk.title, bk.stock
FROM borrowings br
RIGHT JOIN books bk
        ON br.book_id = bk.book_id
       AND br.borrow_date BETWEEN '2024-01-01' AND '2024-03-31'
WHERE bk.stock > 5
  AND br.borrow_id IS NULL
ORDER BY bk.book_id;
-- Expected: 38 rows



/* =====================================================================
   6. FULL ANTI JOIN
   Rows from EITHER table that have NO match on the other side
   (the opposite of an INNER JOIN):
       FULL JOIN ... WHERE a.key IS NULL OR b.key IS NULL
   ===================================================================== */

-- Q26. Find members who borrowed in March 2024 or April 2024, but not in
--      both months.
SELECT mar.member_id AS march_only, apr.member_id AS april_only
FROM (SELECT DISTINCT member_id FROM borrowings
      WHERE borrow_date BETWEEN '2024-03-01' AND '2024-03-31') mar
FULL JOIN
     (SELECT DISTINCT member_id FROM borrowings
      WHERE borrow_date BETWEEN '2024-04-01' AND '2024-04-30') apr
  ON mar.member_id = apr.member_id
WHERE mar.member_id IS NULL OR apr.member_id IS NULL
ORDER BY COALESCE(mar.member_id, apr.member_id);
-- Expected: 12 rows

-- Q27. Find books borrowed from the 'South' branch or the 'East' branch,
--      but not from both.
SELECT s.book_id AS south_only, e.book_id AS east_only
FROM (SELECT DISTINCT book_id FROM borrowings WHERE branch = 'South') s
FULL JOIN
     (SELECT DISTINCT book_id FROM borrowings WHERE branch = 'East') e
  ON s.book_id = e.book_id
WHERE s.book_id IS NULL OR e.book_id IS NULL
ORDER BY COALESCE(s.book_id, e.book_id);
-- Expected: 28 rows

-- Q28. In a single query, list members who have never borrowed and books
--      that have never been borrowed.
SELECT m.member_id, m.member_name, bk.book_id, bk.title
FROM members m
FULL JOIN borrowings br ON m.member_id = br.member_id
FULL JOIN books bk      ON br.book_id = bk.book_id
WHERE br.borrow_id IS NULL
ORDER BY m.member_id, bk.book_id;
-- Expected: 92 rows

-- Q29. Find books that are either out of stock (stock = 0) or currently
--      borrowed (status = 'Borrowed'), but not both.
SELECT os.book_id AS out_of_stock_only, cb.book_id AS borrowed_only
FROM (SELECT book_id FROM books WHERE stock = 0) os
FULL JOIN
     (SELECT DISTINCT book_id FROM borrowings WHERE status = 'Borrowed') cb
  ON os.book_id = cb.book_id
WHERE os.book_id IS NULL OR cb.book_id IS NULL
ORDER BY COALESCE(os.book_id, cb.book_id);
-- Expected: 18 rows

-- Q30. Find members who are Premium or have paid a fine, but not both.
SELECT p.member_id AS premium_no_fine, f.member_id AS fine_not_premium
FROM (SELECT member_id FROM members WHERE membership_type = 'Premium') p
FULL JOIN
     (SELECT DISTINCT member_id FROM borrowings WHERE fine_amount > 0) f
  ON p.member_id = f.member_id
WHERE p.member_id IS NULL OR f.member_id IS NULL
ORDER BY COALESCE(p.member_id, f.member_id);
-- Expected: 29 rows
