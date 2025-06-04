-- All queries are written in T-SQL syntax

-- Query 1
-- The CUST_ACCT table records relationships between customers and the accounts they own. The table contains a column named CUST_ROLE which has two distinct values: 'primary', 'secondary'. 
-- Each account has one, and only one, primary owner but can have zero, one, or many secondary owners. 
-- Please write a query that will return the Account ID and Account Title for all accounts opened over the past 6 full calendar months where the age of the primary customer associated with the account was 30 years or younger at the time of account opening.

--Create CTE of all customer and account information for the past 6 months
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
WHERE A.acct_open_date >= DATEADD(month, -6, GETDATE())
)

-- Filter for primary customers 30 years or younger at time of account opening
SELECT 
  acct_id, 
  acct_title
FROM past_6_months
WHERE cust_role = 'primary'
AND DATEDIFF(year, cust_birth_date, acct_open_date) - 
    CASE 
        WHEN MONTH(acct_open_date) < MONTH(cust_birth_date) 
             OR (MONTH(acct_open_date) = MONTH(cust_birth_date) AND DAY(acct_open_date) < DAY(cust_birth_date))
        THEN 1 ELSE 0 
    END <= 30
;

-- Query 2
-- Please write a query that will return the Customer ID and Name of all customers who are both primary and secondary owners of accounts. 
-- If a customer is only the primary owner of accounts, the customer should not be included in the results. 
-- Likewise, if a customer is only a secondary owner of accounts, the customer should not be included in the results.



-- Query 3
-- Please write a query that will return the State Code, Account ID, Account Title, and Account Balance for the largest account (measured by Account Balance) in each state.

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
