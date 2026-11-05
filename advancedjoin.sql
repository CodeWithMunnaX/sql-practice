/* =====================================================================
   ADVANCED JOINS PRACTICE  (SQL Server)
   Dataset : CompanyDB  (4 tables, 10 rows each)
   5 questions per join -> question first, then the solution
                           (expected result written below each query)

   Joins:
     1. LEFT  ANTI JOIN : rows in LEFT table  with NO match on the right
     2. RIGHT ANTI JOIN : rows in RIGHT table with NO match on the left
     3. FULL  ANTI JOIN : unmatched rows from BOTH sides
     4. CROSS JOIN      : every row of A paired with every row of B

   Tables:
     departments       (dept_id, dept_name, city, budget)
     employees         (emp_id, emp_name, gender, dept_id, manager_id, salary, join_date)
     projects          (project_id, project_name, dept_id, start_date, end_date, budget)
     employee_projects (emp_id, project_id, role, hours_worked)

     departments --< employees --< employee_projects >-- projects
     departments --< projects
     employees.manager_id -> employees.emp_id   (self join)
   ===================================================================== */


/* ---------------------------------------------------------------------
   STEP 0 : Create the tables and load data from the CSV files
   --------------------------------------------------------------------- */
DROP TABLE IF EXISTS employee_projects;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    dept_id     INT          PRIMARY KEY,
    dept_name   VARCHAR(30),
    city        VARCHAR(30),
    budget      INT
);

CREATE TABLE employees (
    emp_id      INT          PRIMARY KEY,
    emp_name    VARCHAR(50),
    gender      VARCHAR(10),
    dept_id     INT,                       -- NULL = no department yet
    manager_id  INT,                       -- NULL = top boss
    salary      INT,
    join_date   DATE
);

CREATE TABLE projects (
    project_id   VARCHAR(10)  PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id      INT,
    start_date   DATE,
    end_date     DATE,
    budget       INT
);

CREATE TABLE employee_projects (
    emp_id       INT,
    project_id   VARCHAR(10),
    role         VARCHAR(20),
    hours_worked INT,
    PRIMARY KEY (emp_id, project_id)
);

-- Change the folder path below if your CompanyDB folder is somewhere else
BULK INSERT departments
FROM 'C:\Users\MeanderSoftware\Desktop\SQL\CompanyDB\departments.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS);

BULK INSERT employees
FROM 'C:\Users\MeanderSoftware\Desktop\SQL\CompanyDB\employees.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS);

BULK INSERT projects
FROM 'C:\Users\MeanderSoftware\Desktop\SQL\CompanyDB\projects.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS);

BULK INSERT employee_projects
FROM 'C:\Users\MeanderSoftware\Desktop\SQL\CompanyDB\employee_projects.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', KEEPNULLS);

-- Check: each table should have 10 rows
SELECT * FROM departments;
SELECT * FROM employees;
SELECT * FROM projects;
SELECT * FROM employee_projects;



/* =====================================================================
   1. LEFT ANTI JOIN
   ---------------------------------------------------------------------
   Meaning : "Give me rows from the LEFT table that have NO match
              in the RIGHT table."

   SQL has no ANTI JOIN keyword. We build it with:
       LEFT JOIN  +  WHERE right_table.key IS NULL

        LEFT       RIGHT
       ( ####(    )      )      #### = result
       ( ####(    )      )      (only the left part, not the overlap)

   Why it works: LEFT JOIN keeps every left row. If a left row has no
   match, all right-side columns come back as NULL -> we keep only those.

   Tip: in the IS NULL check, use the right table's join/primary key
        column (a column that is never NULL when a match exists).
   ===================================================================== */

-- Q1. Find employees who are NOT working on any project.
SELECT e.emp_id, e.emp_name
FROM employees e
LEFT JOIN employee_projects ep ON e.emp_id = ep.emp_id
WHERE ep.emp_id IS NULL;
-- Result: 8 Ananya Das, 10 Pooja Nair

-- Q2. Find departments that have NO employees.
SELECT d.dept_id, d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
WHERE e.emp_id IS NULL;
-- Result: 50 Finance, 70 Design, 80 Legal, 90 Research, 100 Operations

-- Q3. Find projects that have NO employee working on them.
SELECT p.project_id, p.project_name
FROM projects p
LEFT JOIN employee_projects ep ON p.project_id = ep.project_id
WHERE ep.project_id IS NULL;
-- Result: P102 Website Redesign, P106 Hiring Drive,
--         P109 Compliance Audit, P110 Data Warehouse

-- Q4. Find departments that have NO projects.
SELECT d.dept_id, d.dept_name
FROM departments d
LEFT JOIN projects p ON d.dept_id = p.dept_id
WHERE p.project_id IS NULL;
-- Result: 50 Finance, 100 Operations

-- Q5. (Self join) Find employees who are NOT a manager of anyone.
--     -> join employees to itself: e = the person, r = people reporting to e
SELECT e.emp_id, e.emp_name
FROM employees e
LEFT JOIN employees r ON r.manager_id = e.emp_id
WHERE r.emp_id IS NULL;
-- Result: 5 Karan, 6 Neha, 7 Vikram, 8 Ananya, 9 Rohan, 10 Pooja
--         (1 Rahul, 2 Priya, 3 Amit, 4 Sneha are managers)

-- Bonus: the same Q1 using NOT EXISTS (another common way to write anti join)
SELECT e.emp_id, e.emp_name
FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM employee_projects ep WHERE ep.emp_id = e.emp_id);



/* =====================================================================
   2. RIGHT ANTI JOIN
   ---------------------------------------------------------------------
   Meaning : "Give me rows from the RIGHT table that have NO match
              in the LEFT table."

   Built with:
       RIGHT JOIN  +  WHERE left_table.key IS NULL

        LEFT       RIGHT
       (     (    )####  )      #### = result
       (     (    )####  )      (only the right part, not the overlap)

   Note: A RIGHT ANTI JOIN B  =  B LEFT ANTI JOIN A  (just tables swapped).
         Most people write LEFT, but you should be able to read both.
   ===================================================================== */

-- Q1. Find projects that have NO employee working on them.
SELECT p.project_id, p.project_name
FROM employee_projects ep
RIGHT JOIN projects p ON ep.project_id = p.project_id
WHERE ep.project_id IS NULL;
-- Result: P102 Website Redesign, P106 Hiring Drive,
--         P109 Compliance Audit, P110 Data Warehouse
--         (same answer as LEFT ANTI Q3, tables just swapped)

-- Q2. Find departments that have NO employees.
SELECT d.dept_id, d.dept_name, d.city
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;
-- Result: 50 Finance, 70 Design, 80 Legal, 90 Research, 100 Operations

-- Q3. Find departments that have NO projects.
SELECT d.dept_id, d.dept_name
FROM projects p
RIGHT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.project_id IS NULL;
-- Result: 50 Finance, 100 Operations

-- Q4. Find employees who are NOT working on any project.
SELECT e.emp_id, e.emp_name, e.salary
FROM employee_projects ep
RIGHT JOIN employees e ON ep.emp_id = e.emp_id
WHERE ep.emp_id IS NULL;
-- Result: 8 Ananya Das, 10 Pooja Nair

-- Q5. Find projects whose department has NO employees
--     (nobody in that department can run the project).
SELECT p.project_id, p.project_name, p.dept_id
FROM employees e
RIGHT JOIN projects p ON e.dept_id = p.dept_id
WHERE e.emp_id IS NULL;
-- Result: P102 Website Redesign (70), P109 Compliance Audit (80),
--         P110 Data Warehouse (90)



/* =====================================================================
   3. FULL ANTI JOIN
   ---------------------------------------------------------------------
   Meaning : "Give me the unmatched rows from BOTH tables"
             = LEFT ANTI result + RIGHT ANTI result together.

   Built with:
       FULL OUTER JOIN  +  WHERE left.key IS NULL OR right.key IS NULL

        LEFT       RIGHT
       ( ####(    )####  )      #### = result
       ( ####(    )####  )      (everything except the overlap)

   Use it to find "orphan" data on both sides in one query.
   ===================================================================== */

-- Q1. Show employees without a department AND departments without employees.
SELECT e.emp_id, e.emp_name, d.dept_id, d.dept_name
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;
-- Result (6 rows):
--   10 Pooja Nair | NULL NULL        <- employee with no department
--   NULL NULL     | 50 Finance       <- departments with no employees
--   NULL NULL     | 70 Design
--   NULL NULL     | 80 Legal
--   NULL NULL     | 90 Research
--   NULL NULL     | 100 Operations

-- Q2. Same as Q1, but add a label so the result is easy to read.
SELECT
    COALESCE(e.emp_name, d.dept_name) AS name,
    CASE
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        WHEN e.emp_id  IS NULL THEN 'Department without employees'
    END AS problem
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

-- Q3. Count how many unmatched rows come from each side.
SELECT
    CASE
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Department without employees'
    END AS problem,
    COUNT(*) AS total
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL
GROUP BY
    CASE
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Department without employees'
    END;
-- Result: Employee without department = 1, Department without employees = 5

-- Q4. Show departments without projects AND projects without departments.
SELECT d.dept_id, d.dept_name, p.project_id, p.project_name
FROM departments d
FULL OUTER JOIN projects p ON d.dept_id = p.dept_id
WHERE d.dept_id IS NULL OR p.project_id IS NULL;
-- Result: 50 Finance, 100 Operations
-- Note: every project has a valid department, so the right side gives
--       nothing. A full anti join can return rows from only one side.

-- Q5. (3 tables) In ONE query, find employees with no project
--     AND projects with no employee.
SELECT e.emp_name, p.project_name
FROM employees e
FULL OUTER JOIN employee_projects ep ON e.emp_id = ep.emp_id
FULL OUTER JOIN projects p          ON ep.project_id = p.project_id
WHERE ep.emp_id IS NULL;
-- Result (6 rows):
--   Ananya Das | NULL                 <- employees with no project
--   Pooja Nair | NULL
--   NULL       | Website Redesign     <- projects with no employee
--   NULL       | Hiring Drive
--   NULL       | Compliance Audit
--   NULL       | Data Warehouse



/* =====================================================================
   4. CROSS JOIN
   ---------------------------------------------------------------------
   Meaning : pair EVERY row of table A with EVERY row of table B.
             No ON condition.

             rows in result = rows in A  x  rows in B
             10 employees x 10 projects = 100 rows

       A        B          A x B
       1        x          1-x  1-y
       2        y          2-x  2-y

   Careful: on big tables this explodes (1000 x 1000 = 1,000,000 rows).
   Real use: build all combinations, then LEFT JOIN real data onto them
             to find missing combinations or fill zeros in reports.
   ===================================================================== */

-- Q1. Pair every employee with every project.
SELECT e.emp_name, p.project_name
FROM employees e
CROSS JOIN projects p;
-- Result: 100 rows (10 x 10)

-- Q2. Prove the row count: departments x projects.
SELECT COUNT(*) AS total_rows
FROM departments d
CROSS JOIN projects p;
-- Result: 100

-- Q3. Make a list of every department with both genders
--     (a small 2-row list made with VALUES).
SELECT d.dept_name, g.gender
FROM departments d
CROSS JOIN (VALUES ('Male'), ('Female')) AS g(gender)
ORDER BY d.dept_name, g.gender;
-- Result: 20 rows (10 departments x 2 genders)

-- Q4. Count employees in every department by gender, showing 0 where
--     there is nobody.  CROSS JOIN builds all pairs, LEFT JOIN fills counts.
SELECT d.dept_name, g.gender, COUNT(e.emp_id) AS total_employees
FROM departments d
CROSS JOIN (VALUES ('Male'), ('Female')) AS g(gender)
LEFT JOIN employees e
       ON e.dept_id = d.dept_id
      AND e.gender  = g.gender
GROUP BY d.dept_name, g.gender
ORDER BY d.dept_name, g.gender;
-- Result: 20 rows, e.g. Engineering Male = 2, Engineering Female = 1,
--         Finance Male = 0, Finance Female = 0 ...

-- Q5. (CROSS JOIN + LEFT ANTI JOIN) Engineering employees who are NOT yet
--     on an Engineering project -> who could be added to which project?
SELECT e.emp_name, p.project_name
FROM employees e
CROSS JOIN projects p
LEFT JOIN employee_projects ep
       ON ep.emp_id     = e.emp_id
      AND ep.project_id = p.project_id
WHERE e.dept_id = 10
  AND p.dept_id = 10
  AND ep.emp_id IS NULL;
-- Result: Rahul Sharma -> Mobile App, Priya Verma -> AI Chatbot


/* =========================== END OF FILE ============================= */
