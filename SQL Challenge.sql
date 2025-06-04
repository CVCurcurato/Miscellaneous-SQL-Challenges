-- All queries are written in T-SQL syntax

-- Query 1
-- The CUST_ACCT table records relationships between customers and the accounts they own. The table contains a column named CUST_ROLE which has two distinct values: 'primary', 'secondary'. Each account has one, and only one, primary owner but can have zero, one, or many secondary owners. 
-- Please write a query that will return the Account ID and Account Title for all accounts opened over the past 6 full calendar months where the age of the primary customer associated with the account was 30 years or younger at the time of account opening.

--Create CTE of all customer and account information for the past 6 months (including duplicate columns like cust_id and acct_id)
WITH past_6_months AS (
SELECT *
FROM customers AS C
INNER JOIN cust_acct AS CA
  ON C.cust_id = CA.cust_id
INNER JOIN accounts AS A
    ON CA.acct_id = A.acct_id
WHERE DATEDIFF(month, acct_open_date, TODAY()) = 6
)

-- Filter for primary customers 30 years or younger at time of account opening
SELECT CA.acct_id, acct_title
FROM past_6_months
WHERE DATEDIFF(year, cust_birth_date, acct_open_date) <= 30
AND cust_role = 'primary'
