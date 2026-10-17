-- ============================================================
-- Analysis 4: Outstanding Loan Exposure by Loan Type
-- Business question: How much outstanding loan exposure
-- does the bank have by loan type?
-- ============================================================
SELECT
Loan_type,
Sum(Outstanding_balance) AS Total_outstanding_balance
From Loans
Where Status <> 'Paid'
Group By Loan_type
Order By Total_outstanding_balance DESC;

-- ============================================================
-- Analysis 5: Outstanding Loan Exposure by Customer
-- Business question: Which customers have the highest
-- outstanding loan exposure?
-- ============================================================
SELECT
    c.customer_id,
    c.customer_name,
    SUM(l.outstanding_balance) AS total_outstanding_balance
FROM Customers c
JOIN Loans l
    ON c.customer_id = l.customer_id
WHERE l.status <> 'Paid'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_outstanding_balance DESC;