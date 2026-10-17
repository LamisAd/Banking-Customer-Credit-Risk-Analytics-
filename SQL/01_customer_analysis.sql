-- ============================================================
-- 01 Customer Analysis
-- ============================================================


-- Analysis 1: Total account balance by customer
-- Business question: Which customers hold the largest balances?

SELECT
    c.customer_id,
    c.customer_name,
    SUM(a.balance) AS total_balance
FROM Customers c
JOIN Accounts a
    ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_balance DESC;


-- ============================================================
-- Analysis 2: Account Balance vs Outstanding Loans
-- Business question: How much does each customer hold
-- compared with their current outstanding loan exposure?
-- ============================================================
WITH account_totals AS (
    SELECT
        customer_id,
        SUM(balance) AS total_balance
    FROM Accounts
    GROUP BY customer_id
),

loan_totals AS (
    SELECT
        customer_id,
        SUM(outstanding_balance) AS total_outstanding_loans
    FROM Loans
    WHERE status <> 'Paid'
    GROUP BY customer_id
)

SELECT
    c.customer_id,
    c.customer_name,
    at.total_balance,
    Coalesce(lt.total_outstanding_loans,0) AS total_outstanding_loans
FROM Customers c
JOIN account_totals at
    ON c.customer_id = at.customer_id
Left JOIN loan_totals lt
    ON c.customer_id = lt.customer_id;
-- ============================================================
-- Analysis 3: Loan-to-Balance Ratio
-- Business question: How large is each customer's
-- outstanding loan exposure relative to their account balance?
-- ============================================================

WITH account_totals AS (
    SELECT
        customer_id,
        SUM(balance) AS total_balance
    FROM Accounts
    GROUP BY customer_id
),

loan_totals AS (
    SELECT
        customer_id,
        SUM(outstanding_balance) AS total_outstanding_loans
    FROM Loans
    WHERE status <> 'Paid'
    GROUP BY customer_id
)

SELECT
    c.customer_id,
    c.customer_name,
    at.total_balance,
    COALESCE(lt.total_outstanding_loans, 0) AS total_outstanding_loans,
    ROUND(
        COALESCE(lt.total_outstanding_loans, 0)
        / NULLIF(at.total_balance, 0),
        2
    ) AS loan_to_balance_ratio
FROM Customers c
JOIN account_totals at
    ON c.customer_id = at.customer_id
LEFT JOIN loan_totals lt
    ON c.customer_id = lt.customer_id;
	
