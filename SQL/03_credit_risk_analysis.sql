-- ============================================================
-- Analysis 6: Payment Delinquency by Loan
-- Business question: Which loans show the most problematic
-- payment behavior based on late payments?
-- ============================================================
SELECT
Loan_id,
Count(*) As Number_of_payments,
Sum(
case 
When Days_late >0 Then 1
Else 0
END) AS Number_of_late_payments,
Sum(Days_late) AS Total_days_late
From PAyments 
Group by Loan_id
Order By Total_days_late DESC;

-- ============================================================
-- Analysis 7: Customer Payment Delinquency
-- Business question: Which customers have the highest
-- payment delinquency based on their loan payment history?
-- ============================================================
SELECT
c.Customer_id,
c.Customer_name,
Count(p.Payment_id) As Number_of_payments,
Sum(
case 
When p.Days_late >0 Then 1
Else 0
END) AS Number_of_late_payments,
Sum(p.Days_late) AS Total_days_late
From Payments p
Join Loans l
On p.Loan_id = l.Loan_id
Join Customers c
On C.customer_id = l.Customer_id
Group by c.Customer_id,
c.Customer_name
Order By Total_days_late DESC;

-- ============================================================
-- Analysis 8: Repeated Worsening Payment Delays
-- Business question: Which loans show repeated increases
-- in payment delays over time?
-- ============================================================
With PaymentChanges AS
(
SELECT
Loan_id,
Payment_date,
Days_late,
LAG(Days_late) OVER (Partition by Loan_id Order By Payment_date ASC) AS Previous_Days_Late
From Payments
),
DelayChanges AS
(
SELECT
Loan_id,
Payment_date,
Days_late,
Previous_Days_Late,
Days_late - Previous_Days_Late AS Delay_change
From PaymentChanges
)
SELECT
Loan_id,
Count(*) as Number_of_payments,
Sum(
   CASE
   When Delay_change >0 then 1
   Else 0
   END) AS Number_of_delay_increase,
Sum(
   CASE
   When Delay_Change >0 then Delay_change
   Else 0
   END) AS Total_positive_delay_change
FROM DelayChanges
Group by Loan_id;


-- Analysis 9: Customer Exposure to Worsening Loans
-- Business Question:
-- Which customers have loans showing repeated increases in payment delays?
-- This analysis identifies customers whose loans show worsening payment delinquency
-- by measuring repeated increases in days late across payment history.

WITH PaymentChanges AS
(
SELECT
loan_id,
payment_date,
days_late,
LAG(days_late) OVER (PARTITION BY loan_id ORDER BY payment_date ASC) AS previous_days_late
FROM Payments
),
DelayChanges AS
(
SELECT
loan_id,
payment_date,
days_late,
previous_days_late,
days_late - previous_days_late AS delay_change
FROM PaymentChanges
),
LoanDelinquency AS
(
SELECT
loan_id,
COUNT(*) AS number_of_payments,
SUM(
CASE
WHEN delay_change > 0 THEN 1
ELSE 0
END
) AS number_of_delay_increases,
SUM(
CASE
WHEN delay_change > 0 THEN delay_change
ELSE 0
END
) AS total_positive_delay_change
FROM DelayChanges
GROUP BY loan_id
)
SELECT
c.customer_id,
c.customer_name,
COUNT(ld.loan_id) AS number_of_loans,
SUM(
CASE
WHEN ld.number_of_delay_increases > 0 THEN 1
ELSE 0
END
) AS loans_with_delay_increases,
SUM(ld.total_positive_delay_change) AS total_positive_delay_change
FROM LoanDelinquency ld
JOIN Loans l
ON ld.loan_id = l.loan_id
JOIN Customers c
ON l.customer_id = c.customer_id
GROUP BY
c.customer_id,
c.customer_name;

-- Analysis 10
-- Customer Risk Classification — Classifies customers into Low,
-- Medium, or High risk based on loan-to-balance ratio,
-- cumulative payment delays, and the number of loans
-- showing increasing payment delays.

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
),

Ratios AS (
    SELECT
        c.customer_id,
        c.customer_name,
        ROUND(
            COALESCE(lt.total_outstanding_loans, 0)
            / NULLIF(at.total_balance, 0),
            2
        ) AS loan_to_balance_ratio
    FROM Customers c
    JOIN account_totals at
        ON c.customer_id = at.customer_id
    LEFT JOIN loan_totals lt
        ON c.customer_id = lt.customer_id
),

PaymentChanges AS (
    SELECT
        loan_id,
        payment_date,
        days_late,
        LAG(days_late) OVER (
            PARTITION BY loan_id
            ORDER BY payment_date
        ) AS previous_days_late
    FROM Payments
),

DelayChanges AS (
    SELECT
        loan_id,
        payment_date,
        days_late,
        previous_days_late,
        days_late - previous_days_late AS delay_change
    FROM PaymentChanges
),

LoanDelinquency AS (
    SELECT
        loan_id,
        COUNT(*) AS number_of_payments,
        SUM(days_late) AS total_days_late,

        SUM(
            CASE
                WHEN delay_change > 0 THEN 1
                ELSE 0
            END
        ) AS number_of_delay_increases,

        SUM(
            CASE
                WHEN delay_change > 0 THEN delay_change
                ELSE 0
            END
        ) AS total_positive_delay_change

    FROM DelayChanges
    GROUP BY loan_id
),

LoanDelays AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COUNT(ld.loan_id) AS number_of_loans,

        SUM(
            CASE
                WHEN ld.number_of_delay_increases > 0 THEN 1
                ELSE 0
            END
        ) AS loans_with_delay_increases,

        SUM(ld.total_days_late) AS total_days_late

    FROM LoanDelinquency ld

    JOIN Loans l
        ON ld.loan_id = l.loan_id

    JOIN Customers c
        ON l.customer_id = c.customer_id

    GROUP BY
        c.customer_id,
        c.customer_name
)

SELECT
    r.customer_id,
    r.customer_name,
    r.loan_to_balance_ratio,
    ld.total_days_late,
    ld.loans_with_delay_increases,

    CASE
        WHEN r.loan_to_balance_ratio > 3
             OR ld.total_days_late >= 20
             OR ld.loans_with_delay_increases >= 2
        THEN 'High Risk'

        WHEN r.loan_to_balance_ratio > 1
             OR ld.total_days_late > 0
             OR ld.loans_with_delay_increases = 1
        THEN 'Medium Risk'

        ELSE 'Low Risk'
    END AS risk_category

FROM Ratios r

JOIN LoanDelays ld
    ON r.customer_id = ld.customer_id;

-- Analysis 11
-- High-Exposure Customers — Measures outstanding loan
-- exposure relative to annual income and classifies customers
-- into Low, Medium, or High exposure categories.

With TotalLoans AS
(
SELECT
Customer_id,
Sum(Outstanding_balance) AS Total_outstanding_loans
From Loans
Where Status <> 'Paid'
Group By Customer_id
),
Ratios AS
(
SELECT
c.Customer_id,
c.Customer_name,
c.Annual_income,
tl.Total_outstanding_loans,
Round(tl.Total_outstanding_loans / c.Annual_income,2) AS Loan_to_income_ratio
From Customers c
Join TotalLoans tl
ON c.Customer_id = tl.Customer_id
)
SELECT
Customer_id,
Customer_name,
Annual_income,
Total_outstanding_loans,
Loan_to_income_ratio,
CASE
When Loan_to_income_ratio >=3 Then 'High Exposure'
When Loan_to_income_ratio >=1 Then 'Medium Exposure'
Else 'Low Exposure'
End AS Exposure_category
From Ratios;

-- ============================================================
-- Analysis 35: Customer Financial Risk Profile
-- ============================================================
With AccountMetrics AS
(
SELECT
Customer_id,
Sum(balance) AS total_balance
From Accounts
Where Status = 'Active'
Group by Customer_id
),
LoanMetrics AS
(
SELECT
customer_id,
sum(Outstanding_balance) AS outstanding_loan
From Loans
where status <> 'Paid'
group by Customer_id
),
TransactionMetrics AS
(
SELECT
a.Customer_id,
count(t.transaction_id) AS total_transactions,
sum(t.amount) AS total_transaction_amount
from Accounts a
Join transactions t
ON a.account_id = t.Account_id
Group by a.Customer_id
),
DelinquencyMetrics AS
(
    SELECT
        l.customer_id,
        COUNT(DISTINCT p.loan_id) AS loans_with_delays
    FROM Loans l
    JOIN Payments p
        ON l.loan_id = p.loan_id
    WHERE p.days_late > 0
    GROUP BY l.customer_id
)
SELECT
c.Customer_id,
c.Customer_name,
am.total_balance,
coalesce(lm.outstanding_loan,0) AS outstanding_loan,
tm.total_transactions,
tm.total_transaction_amount,
coalesce(dm.loans_with_delays,0) AS loans_with_delays,
CASE
WHEN coalesce(lm.outstanding_loan,0) > am.total_balance
AND coalesce(dm.loans_with_delays,0) >=1 THEN 'High Risk'
WHEN coalesce(lm.outstanding_loan,0) > am.total_balance 
OR coalesce(dm.loans_with_delays,0) >=1 THEN 'Medium Risk'
ELSE 'Lower Risk'
END AS financial_risk_profile
from Customers c
join AccountMetrics am
ON c.Customer_id = am.Customer_id
left join LoanMEtrics lm
ON c.Customer_id = lm.Customer_id
join transactionMetrics tm
ON c.Customer_id = tm.Customer_id
left join DelinquencyMetrics dm
On c.Customer_id = dm.Customer_id;