Banking Customer \& Credit Risk Analytics



\- Overview:



This project analyzes a sample banking dataset to evaluate customer financial value, account balances, loan exposure, transaction behavior, and payment delinquency.



Using SQL and Power BI, I developed a banking analytics workflow that transforms relational data into business-focused metrics and interactive dashboards. The project demonstrates data preparation and validation, SQL-based financial analysis, relational data modeling, and DAX calculations.



\- Objectives:



The project addresses the following business questions:



1\. Which customers hold the largest account balances and outstanding loan exposures?

2\. How does outstanding loan exposure compare with customer account balances?

3\. Which loan types contribute most to total outstanding exposure?

4\. Which customers have recorded payment delays?

5\. How are customers classified under the project's rule-based financial risk framework?

6\. How does transaction activity vary by channel, branch, account type, and customer segment?

7\. What financial indicators should management monitor when assessing customer exposure and potential credit risk?



\- Dataset:



The project uses a manually constructed sample banking dataset stored in SQLite and exported to CSV for Power BI.



Dataset       Records 



Customers     10 

Accounts      20 

Transactions  37 

Loans         15 

Payments      37 



The source database also contains country and branch reference data.



The dataset is illustrative and was created for analytical practice. It does not contain real customer information or represent an actual financial institution.



\- Tools and Software:



* SQLite / SQL: Data validation, joins, aggregations, common table expressions (CTE's), window functions, financial metrics, and credit-risk analysis.
* Power BI: Relational data modeling, DAX measures, calculated columns, KPI cards, and interactive visualizations.
* CSV: Data transfer from the SQLite database to Power BI.


- Analytical Methodology:



Customer and Account Analysis



* Aggregated account balances by customer.
* Compared account balances with outstanding loan exposure.
* Calculated loan-to-balance ratios.
* Examined account activity, balance concentration, and customer financial activity.



Loan and Credit Risk Analysis



* Aggregated outstanding loan exposure by customer and loan type.
* Analyzed loan status and exposure.
* Examined payment delays and changes in recorded delays over time.
* Developed a rule-based customer risk classification.
* Compared customer balances, loan exposure, and payment delinquency.



Transaction Analysis



* Analyzed transaction activity by channel, branch, transaction type, account type, and customer segment.
* Examined monthly transaction activity and customer transaction frequency.
* Used ranking, running totals, and window functions to investigate customer transaction behavior.
* Compared transaction activity with account balances and other customer financial indicators.



Data Validation



The source database was checked for issues including duplicate primary keys, orphaned foreign keys, negative financial values, invalid payment arithmetic, outstanding loan balances exceeding original principal, and inconsistencies involving paid loans.



Key analytical results were cross-checked between SQLite and Power BI.


- Power BI Dashboards:



Executive Banking Overview



The executive dashboard presents:



* Total customer account balance
* Total outstanding loan exposure
* Total recorded transaction amount
* Number of customers
* Number of active loans
* Outstanding loan exposure by loan type
* Customer risk profile
* Transaction amount by channel
* Customer balance compared with loan exposure



Credit Risk Analysis



The credit-risk dashboard presents:



* Outstanding loan exposure by customer
* Maximum recorded payment delay by loan
* Outstanding loan exposure by customer risk category
* Defaulted loan count
* Loans with at least one recorded payment delay
* Loan status distribution


- Key Findings:



The following findings were verified against the project's sample data.



Metric                                          Result 



Total customer account balance                  484,100 

Total outstanding loan exposure                 857,400 

Total recorded transaction amount               129,270 

Number of customers                              10 

Number of loans                                  15 

Active loans                                     13 

Paid loans                                       1 

Defaulted loans                                  1 

Loans with at least one recorded payment delay   13 



Outstanding Loan Exposure by Loan Type



Loan type     Outstanding exposure 


 Mortgage           608,000 

&#x20;Business           118,000 
 Personal           72,900 

&#x20;Auto               58,500 

&#x20;Total              857,400



Mortgage loans account for the largest share of outstanding exposure in this sample.



Customer Risk Classification



The rule-based classification produced the following distribution:



Risk category  Customers  Share 



&#x20;High Risk        5        50% 

&#x20;Medium Risk      3        30% 

&#x20;Lower Risk       2        20% 

&#x20;Total            10       100%



These categories are based on the project's defined rules, not a validated or externally calibrated credit-scoring model.


- Risk Classification Rules:



Customers were classified using two indicators:



* Whether outstanding loan exposure exceeded the customer's active account balance.
* Whether the customer had at least one loan with a recorded payment delay.



The rules were:



* High Risk: Loan exposure exceeds active account balance, and at least one loan has a recorded payment delay.
* Medium Risk: Exactly one of those two conditions is met.
* Lower Risk: Neither condition is met.



The classifications are intended to demonstrate rule-based analytical logic and should not be interpreted as predictions of default probability.


- Limitations:



* Small sample size: The dataset contains only 10 customers and 15 loans. The results cannot be generalized to a real banking portfolio.
* Manually created data: The records are illustrative rather than sourced from a real bank or representative customer population.
* Rule-based risk classification: The categories are based on selected financial indicators. They have not been statistically validated against actual repayment outcomes.
* Limited predictive capability: The project describes observed financial indicators and payment delays. It does not predict future defaults or estimate credit losses.
* Payment-delay interpretation: A loan is counted as having payment delays when at least one recorded payment has a positive `days\_late` value. This count does not measure the probability of future default.
* Limited time coverage: The transaction and payment dates cover a small illustrative period, so the observed patterns should not be treated as reliable long-term trends.
* Simplified financial indicators: Account balance is used as a comparison point for outstanding loan exposure. It is not equivalent to disposable income, total wealth, collateral value, or verified debt-servicing capacity.


- Project Deliverables:



* SQLite database and CSV data exports.
* SQL scripts covering customer, account, transaction, loan, and credit-risk analyses.
* Power BI report containing executive and credit-risk dashboards.
* DAX measures and customer risk classification.
* Data validation and documented analytical findings.


- Business Value:



This project demonstrates how SQL and Power BI can be used to structure banking data, calculate financial indicators, investigate customer behavior, and communicate portfolio-level findings through dashboards.



It provides a foundation for further work in financial analysis, business intelligence, credit-risk analytics, and banking reporting.


