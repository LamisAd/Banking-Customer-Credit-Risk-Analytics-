	-- ============================================================
-- Analysis 12
-- Branch Performance — Compares branches based on
-- customer count, total account balances, and transaction activity.
-- ============================================================
With AccountMetrics AS
(
SELECT
Branch_id,
Count(distinct customer_id) AS number_of_customers,
sum(Balance) AS total_account_balance
From Accounts
Group by Branch_id
),
TransactionMetrics AS
(
SELECT
a.branch_id,
count(t.transaction_id) AS number_of_transactions
From Accounts a
Join Transactions t
ON a.Account_id = t.Account_id
Group by a.branch_id
)
SELECT
b.Branch_id,
b.Branch_Name,
c.Country_Name,
am.number_of_customers,
am.total_account_balance,
tm.number_of_transactions
From Countries c
Join Branches b
On c.Country_id = b.country_id
Join AccountMetrics am
On b.branch_id = am.branch_id
Join TransactionMetrics tm
On b.branch_id = tm.branch_id;

-- ============================================================
-- Analysis 13
-- Transaction Activity by Channel — Measures transaction
-- frequency, total transaction value, and average transaction
-- size across banking channels.
-- ============================================================

SELECT
channel,
count(*) AS number_of_transactions,
sum(Amount) AS total_transaction_amount,
avg(amount) AS average_transaction_amount
From Transactions
Group By Channel
Order By number_of_transactions DESC;

-- ============================================================
-- Analysis 14
-- Transaction Type Analysis — Compares banking transaction
-- types by transaction volume, total monetary value, and
-- average transaction size..
-- ============================================================
SELECT
Transaction_type,
count(*) AS number_of_transactions,
Sum(amount) AS total_transaction_amount,
Round(avg(amount),2) AS average_transaction_amount
From Transactions
group by Transaction_type
Order by number_of_transactions DESC,
total_transaction_amount DESC;

-- ============================================================
-- Analysis 15
-- Transaction Type Analysis —identifies customers with the highest
-- transaction activity and monetary transaction volume, including
-- average transaction size.
-- ============================================================
SELECT
c.customer_id,
c.Customer_name,
count(t.transaction_id) AS number_of_transactions,
sum(t.amount) AS total_transaction_amount,
Round(avg(t.amount),2) AS average_transaction_amount
From Customers c
Join Accounts a 
ON c.Customer_id = a.Customer_id
Join Transactions t
ON a.Account_id = t.Account_id
Group By c.customer_id,
c.Customer_name
ORDER By total_transaction_amount DESC;

-- ============================================================
-- Analysis 16
-- Customer Segment Transaction Activity
-- ============================================================
SELECT
c.Customer_segment,
count(DISTINCT c.customer_id) as number_of_customers,
count(t.transaction_id) as number_of_transactions,
sum(t.amount) as total_transaction_amount,
Round(avg(t.amount),2) as average_transaction_amount
From customers c
Join Accounts a
On c.Customer_id = a.Customer_id
Join Transactions t
On a.account_id = t.Account_id
Group by c.Customer_segment
Order by total_transaction_amount DESC;

-- ============================================================
-- Analysis 17
-- Monthly transaction activity
-- ============================================================
SELECT
strftime('%Y-%m',transaction_date) AS transaction_month,
count(*) AS number_of_transactions,
sum(amount) AS total_transaction_amount,
avg(amount) average_transaction_amount
From Transactions
Group by transaction_month
Order by  transaction_month;

-- ============================================================
-- Analysis 18
-- Transaction Activity by Account Type
-- ============================================================
SELECT
a.Account_type,
Count(Distinct a.Account_id) AS number_of_accounts,
Count(t.Transaction_id) AS number_of_transactions,
Sum(t.Amount) AS total_transaction_amount,
Round(avg(t.amount),2) AS average_transaction_amount
From Accounts a
Join Transactions t
On a.Account_id = t.Account_id
Where a.Status = 'Active'
Group by a.Account_type
Order by total_transaction_amount DESC;

-- ============================================================
-- Analysis 19
-- Transaction Activity by Branch
-- ============================================================
SELECT
b.branch_id,
b.branch_name,
c.Country_name,
count(t.Transaction_id) AS number_of_transactions,
sum(t.Amount) AS total_transaction_amount,
Round(avg(t.Amount),2) AS average_transaction_amount
From Branches b
Join Countries c
ON b.country_id = c.country_id
Join Accounts a
On b.branch_id = a.branch_id
Join Transactions t
On a.Account_id = t.Account_id
Group by b.branch_id,
b.branch_name,
c.country_name
Order by total_transaction_amount DESC;

-- ============================================================
-- Analysis 20
-- Customer Segment × Channel Usage
-- ============================================================
SELECT
c.Customer_segment,
t.Channel,
count(t.transaction_id) AS number_of_transactions,
sum(t.amount) AS total_transaction_amount,
round(avg(t.amount),2) AS average_transaction_amount
From Customers c
Join Accounts a
ON c.Customer_id = a.Customer_id
Join Transactions t
ON a.Account_id = t.Account_id
Group By c.Customer_segment,
t.Channel
Order by total_transaction_amount desc;

-- ============================================================
-- Analysis 21
-- Customer Transaction Frequency
-- ============================================================
SELECT
c.Customer_id,
c.Customer_name,
Count(t.Transaction_id) AS number_of_transactions,
sum(t.amount) AS total_transaction_amount,
round(avg(t.amount),2) AS average_transaction_amount
from customers c
Join Accounts a
on c.customer_id = a.Customer_id
join Transactions t
on a.Account_id = t.Account_id
group by c.Customer_id,
c.Customer_name
order by number_of_transactions DESC,
total_transaction_amount DESC;

-- ============================================================
-- Analysis 22
-- Customer Ranking Within Segment
-- ============================================================
With Totals AS
(
SELECT
c.Customer_segment,
c.Customer_id,
c.Customer_name,
Sum(t.Amount) AS total_transaction_amount
From Customers c
Join Accounts a
On c.Customer_id = a.Customer_id
Join Transactions t
On a.Account_id = t.Account_id
Group By c.Customer_segment,
c.Customer_id,
c.Customer_name
)
SELECT
Customer_segment,
Customer_id,
Customer_name,
total_transaction_amount,
Rank() OVER (partition by Customer_segment Order By total_transaction_amount DESC) AS Customer_rank
From Totals;

-- ============================================================
-- Analysis 23
-- Customer Transaction running total
-- ============================================================
SELECT
c.Customer_id,
c.Customer_name,
t.Transaction_date,
t.Transaction_id,
t.Amount,
Sum(t.amount) Over(partition by c.Customer_id ORDER by t.Transaction_date, t.Transaction_id) AS running_transaction_amount
From customers c
join Accounts a
On c.customer_id = a.Customer_id
join transactions t
On a.account_id = t.Account_id;

-- ============================================================
-- Analysis 24
-- Transaction Amount Change From Previous Transaction
-- ============================================================
With PreviousAmount AS
(
SELECT
c.customer_id,
c.Customer_name,
t.transaction_date,
t.transaction_id,
t.Amount,
Lag(t.amount) Over(partition by c.customer_id Order by t.transaction_date, t.transaction_id) AS Previous_transaction_amount
From Customers c
Join Accounts a
On c.customer_id = a.Customer_id
Join Transactions t
On a.account_id = t.Account_id
)
SELECT
customer_id,
Customer_name,
transaction_date,
transaction_id,
Amount,
Previous_transaction_amount,
Amount - Previous_transaction_amount AS transaction_amount_change 
From PreviousAmount;

-- ============================================================
-- Analysis 25
-- Customer Transaction Volatility
-- ============================================================
With PreviousAmount AS
(
SELECT
c.customer_id,
c.Customer_name,
t.transaction_date,
t.transaction_id,
t.Amount,
Lag(t.amount) Over(partition by c.customer_id Order by t.transaction_date, t.transaction_id) AS Previous_transaction_amount
From Customers c
Join Accounts a
On c.customer_id = a.Customer_id
Join Transactions t
On a.account_id = t.Account_id
),
Transaction_change AS
(
SELECT
customer_id,
Customer_name,
transaction_date,
transaction_id,
Amount,
Previous_transaction_amount,
Amount - Previous_transaction_amount AS transaction_amount_change 
From PreviousAmount
)
Select 
customer_id,
Customer_name,
count(transaction_id) as number_of_transactions,
Round(AVG(transaction_amount_change),2) AS average_transaction_change,
MAX(transaction_amount_change) AS largest_transaction_increase,
MIN(transaction_amount_change) AS largest_transaction_decrease
From Transaction_change
Group by customer_id,
Customer_name;