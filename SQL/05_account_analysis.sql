-- ============================================================
-- Analysis 26: Customer Account Activity
-- ============================================================
SELECT
c.customer_id,
c.Customer_name,
count(a.account_id) AS number_of_accounts,
Sum(
CASE
When a.Status = 'Active' Then 1
Else 0
End) AS Active_accounts,
Sum(a.Balance) total_balance
From Customers c
Join Accounts a
On c.Customer_id = a.Customer_id
Group by c.customer_id,
c.Customer_name
Order By total_balance DESC;

-- ============================================================
-- Analysis 27: Account Balance vs Transaction Activity
-- ============================================================
With TransactionsMetrics as
(
SELECT
Account_id,
count(transaction_id) AS number_of_transactions,
Sum(amount) as total_transaction_amount
from Transactions
group by Account_id
)
SELECT
tm.Account_id,
a.Customer_id,
a.Account_type,
a.Balance,
tm.number_of_transactions,
tm.total_transaction_amount
From Accounts a
Left Join TransactionsMetrics tm
ON a.Account_id = tm.Account_id
where a.status = 'Active'
Order by a.Balance DESC;

-- ============================================================
-- Analysis 28: Transaction Activity Relative to Account Balance
-- ============================================================
With TransactionsMetrics as
(
SELECT
Account_id,
Sum(amount) as total_transaction_amount
from Transactions
group by Account_id
)
SELECT
tm.Account_id,
a.Customer_id,
a.Account_type,
a.Balance,
tm.total_transaction_amount,
Round(tm.total_transaction_amount / nullif(a.balance,0),2) AS transaction_to_balance_ratio
From Accounts a
Left Join TransactionsMetrics tm
ON a.Account_id = tm.Account_id
where a.status = 'Active'
Order by transaction_to_balance_ratio DESC;

-- ============================================================
-- Analysis 29: Account Balance Concentration
-- ============================================================
With Customer_metrics AS
(
SELECT
customer_id,
sum(balance) total_balance
From Accounts
Where status = 'Active'
Group by Customer_id
),
BankMetrics AS
(
SELECT
customer_id,
total_balance,
sum(total_balance)Over() as bank_total_balance
From customer_metrics
)
Select 
c.customer_id,
c.Customer_name,
bm.total_balance,
bm.bank_total_balance,
Round((bm.total_balance/bm.bank_total_balance*100),2) AS balance_share_pct 
From BankMetrics bm
Join Customers c
ON c.Customer_id = bm.Customer_id
Order By balance_share_pct DESC;

-- ============================================================
-- Analysis 30: Customer Balance vs. Bank Average
-- ============================================================
With Customer_metrics AS
(
SELECT
customer_id,
sum(balance) total_balance
From Accounts
Where status = 'Active'
Group by Customer_id
),
BankMetrics AS
(
SELECT
customer_id,
total_balance,
avg(total_balance)Over() as average_customer_balance
From customer_metrics
)
Select 
c.customer_id,
c.Customer_name,
bm.total_balance,
bm.average_customer_balance,
bm.total_balance - bm.average_customer_balance AS balance_difference,
round((bm.total_balance / bm.average_customer_balance) * 100,2) AS balance_vs_average
From BankMetrics bm
Join Customers c
ON c.Customer_id = bm.Customer_id
Order By balance_vs_average DESC;

-- ============================================================
-- Analysis 31: Customer Account Utilization
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
)
SELECT
c.Customer_id,
c.Customer_name,
am.total_balance,
tm.total_transactions,
tm.total_transaction_amount,
Round(tm.total_transaction_amount / nullif(am.total_balance,0),2) AS transaction_amount_to_balance_ratio
From Customers c
Join AccountMetrics am
On c.Customer_id = am.Customer_id
Join transactionMetrics tm
ON c.Customer_id = tm.Customer_id
Order by transaction_amount_to_balance_ratio DESC;

-- ============================================================
-- Analysis 32: Customer Balance vs. Transaction Frequency
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
TransactionMetrics AS
(
SELECT
a.Customer_id,
count(t.transaction_id) AS total_transactions
from Accounts a
Join transactions t
ON a.account_id = t.Account_id
Group by a.Customer_id
)
SELECT
c.Customer_id,
c.Customer_name,
am.total_balance,
tm.total_transactions,
Round(tm.total_transactions / nullif(am.total_balance,0)*1000,2) AS transactions_per_1000_balance
From Customers c
Join AccountMetrics am
On c.Customer_id = am.Customer_id
Join transactionMetrics tm
ON c.Customer_id = tm.Customer_id
Order by transactions_per_1000_balance DESC;

-- ============================================================
-- Analysis 33: Customer Financial Activity Classification
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
)
SELECT
c.Customer_id,
c.Customer_name,
am.total_balance,
tm.total_transactions,
tm.total_transaction_amount,
CASE
WHEN tm.total_transactions >=5 THEN 'High Activity'
WHEN tm.total_transactions >=3 THEN 'Medium Activity'
Else 'Low Activity'
END AS activity_level
From Customers c
Join AccountMetrics am
On c.Customer_id = am.Customer_id
Join transactionMetrics tm
ON c.Customer_id = tm.Customer_id
Order by tm.total_transactions DESC,
tm.total_transaction_amount DESC;

-- ============================================================
-- Analysis 34: Customer Balance vs. Loan Exposure
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
)
Select 
c.customer_id,
c.customer_name,
am.total_balance,
coalesce(lm.outstanding_loan,0) AS outstanding_loan,
am.total_balance - coalesce(lm.outstanding_loan,0) AS net_financial_position,
CASE
WHEN (am.total_balance - coalesce(lm.outstanding_loan,0)) >0 THEN 'Balance Exceeds Loan Exposure'
WHEN (am.total_balance - coalesce(lm.outstanding_loan,0)) = 0 THEN 'Balanced'
Else 'Loan Exposure Exceeds Balance'
END AS exposure_position
FROM Customers c
JOIN AccountMetrics am
    ON c.customer_id = am.customer_id
LEFT JOIN LoanMetrics lm
    ON c.customer_id = lm.customer_id
ORDER BY
    net_financial_position ASC;