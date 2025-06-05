-- LPL Financial - SQL Challenge Solutions by Christian Curcurato
-- Date - June 4th, 2025
-- All queries are written in T-SQL syntax

-- Query 1 Solution

--Create CTE of all customer and account information for the past 6 full months
WITH past_6_months AS (
SELECT
  C.cust_id,
  C.cust_name,
  C.cust_birth_date,
  CA.cust_role,
  A.acct_id,
  A.acct_open_date,
  A.acct_title
FROM customers AS C
INNER JOIN cust_acct AS CA
  ON C.cust_id = CA.cust_id
INNER JOIN accounts AS A
    ON CA.acct_id = A.acct_id
-- WHERE statement filters for first day of the month 6 months ago AND the first day of this month to filter for the past 6 full months
WHERE A.acct_open_date >= DATEADD(day, 1 - DAY(DATEADD(month, -6, GETDATE())), DATEADD(month, -6, GETDATE()))
  AND A.acct_open_date < DATEADD(day, 1 - DAY(GETDATE()), GETDATE())
)

-- Filter for primary customers 30 years or younger at time of account opening
SELECT 
  acct_id, 
  acct_title
FROM past_6_months
WHERE cust_role = 'primary'
-- DATEDIFF/CASE statement tries to catch exact age of a customer by accounting for them being born in the same year but different months or days
AND DATEDIFF(year, cust_birth_date, acct_open_date) - 
    CASE 
        WHEN MONTH(acct_open_date) < MONTH(cust_birth_date) 
        OR (MONTH(acct_open_date) = MONTH(cust_birth_date) AND DAY(acct_open_date) < DAY(cust_birth_date))
    THEN 1 ELSE 0 
END <= 30
;

-- Query 2 Solution

-- Select ids and names only for those customers that are primary owners of 1 or more accounts AND secondary owners of 1 or more accounts.
SELECT 
  C.cust_id, 
  C.cust_name
FROM customers AS C
INNER JOIN cust_acct AS CA
  ON C.cust_id = CA.cust_id
GROUP BY C.cust_id, C.cust_name
HAVING COUNT(DISTINCT CASE WHEN CA.cust_role = 'primary' THEN CA.acct_id END) >= 1
   AND COUNT(DISTINCT CASE WHEN CA.cust_role = 'secondary' THEN CA.acct_id END) >= 1
;

-- Query 3 Solution

-- Find largest account per state
WITH max_per_state AS (
SELECT 
  state_code, 
  MAX(acct_balance) AS largest_acct
FROM accounts
GROUP BY state_code
)

-- Join largest account to required columns
SELECT 
  A.state_code, 
  acct_id, 
  acct_title, 
  acct_balance
FROM accounts AS A
INNER JOIN max_per_state AS M
  ON A.state_code = M.state_code
  AND acct_balance = largest_acct
;

-- Query 4 Solution

-- Select Account ID & Title, then identify when an attribute matches 1,3 and 5 and take those values in respective columns. Null if not present.
SELECT 
    A.acct_id,
    A.acct_title,
    MAX(CASE WHEN AA.attr_name = 'ATTR_01' THEN AA.attr_value END) AS ATTR_01,
    MAX(CASE WHEN AA.attr_name = 'ATTR_03' THEN AA.attr_value END) AS ATTR_03,
    MAX(CASE WHEN AA.attr_name = 'ATTR_05' THEN AA.attr_value END) AS ATTR_05
FROM accounts A
LEFT JOIN account_attributes AA 
    ON A.acct_id = AA.acct_id 
    AND AA.attr_name IN ('ATTR_01', 'ATTR_03', 'ATTR_05')
GROUP BY A.acct_id, A.acct_title
;
