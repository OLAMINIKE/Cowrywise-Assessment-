# Cowrywise Assessment
## 📋 Table of Contents

1. [High-Value Customers with Multiple Products](#1-high-value-customers-with-multiple-products)  
   - [Objective](#objective)  
   - [Context](#context)  
   - [Approach](#approach)  
     - [Query 1: All Deposits per Customer](#query-1-all-deposits-per-customer)  
     - [Query 2: Deposits Linked to Savings or Investment Plans](#query-2-deposits-linked-to-savings-or-investment-plans)  
   - [Strategy](#strategy)  
   - [Challenge & Resolution](#challenge--resolution)  
     - [Challenge](#challenge)  
     - [Resolution](#resolution)  
   - [Deliverables](#deliverables)  

2. [Transaction Frequency Analysis](#2-transaction-frequency-analysis)  
   - [Objective](#objective-1)  
   - [Approach](#approach-1)  
     - [Step 1: Monthly Successful Transaction Count](#step-1-monthly-successful-transaction-count)  
     - [Step 2: Calculate Monthly Averages](#step-2-calculate-monthly-averages)  
     - [Step 3: Frequency Segmentation](#step-3-frequency-segmentation)  
     - [Step 4: Summary Output](#step-4-summary-output)  
   - [Challenge & Resolution](#challenge--resolution-1)  
     - [Challenge](#challenge-1)  
     - [Resolution](#resolution-1)  
   - [Note](#note)  

3. [Account Inactivity Alert](#3-account-inactivity-alert)  
   - [Objective](#objective-2)  
   - [Approach](#approach-2)  
     - [Step-by-Step Strategy](#step-by-step-strategy)  
   - [Observations](#observations)  

4. [Customer Lifetime Value (CLV) Estimation](#4-customer-lifetime-value-clv-estimation)  
   - [Objective](#objective-3)  
   - [Approach](#approach-3)  

## 1. High-Value Customers with Multiple Products

### Objective


To identify customers who have **both a savings plan and an investment plan**, highlighting cross-selling opportunities and showing the **total amount they have deposited**.


### Context

* **users_customuser**: Contains customer demographic and contact information. 

* **plans_plan**: Stores customer financial plans, with: 

    * is_regular_savings indicating savings plans. 

    * is_a_fund indicating investment plans. 

* **savings_savingsaccount**: Records deposit transactions, including a plan_id to link each deposit to a specific plan. 


### Approach

There are two possible interpretations based on business requirements. To ensure flexibility and clarity, I implemented **two separate queries** using **CTEs (Common Table Expressions)** for readability and modularity.

**Query 1: All Deposits per Customer**

This version filters for customers that have at least one investment or savings plan. However, the **deposit sums include deposits from all plans irrespective of it being savings or investment.**

 **Use Case**: For businesses interested in the customers’ (customers in saving and investment plans) total monetary deposit activity across all plans.


**Query 2: Deposits Linked to Savings or Investment Plans**

Here, I use the plan_id in savings_savingsaccount to join deposits to plans_plan table, allowing us to **filter and sum only deposits tied to valid savings or investment plans**. 
 
**Use Case**: For more accurate insights into how much customers have committed to actual financial products(saving and investment plan),  excluding unrelated deposits.

### Strategy

1. **Identify customers** with at least one savings **and** one investment plan. 

2. Use **aggregations grouped by owner_id** to get counts of each plan type. 

3. Use **joins and CTEs** to compute total deposits: 

    * **All deposits** (Query 1).

    * **Filtered deposits** tied to specific plans (Query 2). 

4. Ensure only users with **both product types** are included in the result.

5. Round the total deposit  up to 2 decimal point for better alignment with the expected output

6. **Sort by total deposits** to surface high-value customers.


### Challenge & Resolution


#### Challenge

Initially, it was unclear whether to sum **all customer deposits** or only those **tied to specific plans**. Including irrelevant deposits could misrepresent customer value and reduce the precision of business insights.


#### Resolution

After examining the schema, I identified that the savings_savingsaccount table includes a plan_id, allowing deposits to be accurately linked to their corresponding plans. By joining this with plans_plan, I was able to **filter deposits based on whether the plan is a savings or investment product**, ensuring **data accuracy**.

However, I still provided a query that sums up all deposits irrespective of their plans (Query 1).


### Deliverables

Two sql queries have been included in the **Assessment_Q1.sql** 

* **Query 1**: Total deposits per customer, regardless of plan type for all customers with at least one saving and investment plan.
* **Query 2**: Deposits linked only to savings/investment plans.


## 2. Transaction Frequency Analysis

### Objective

To analyze how frequently each customer performs **successful transactions**, then segment them into engagement categories:

* **High Frequency**: ≥ 10 successful transactions per month 

* **Medium Frequency**: 3–9 per month 

* **Low Frequency**: ≤ 2 per month 

This segmentation enables the finance team to **better understand customer behavior**, improve targeting strategies, and enhance customer support.


### Approach


**Step 1: Monthly Successful Transaction Count**

* Extracted the count of **successful transactions** per customer **per month**. 

* Ensured only transactions with transaction_status = 'success' were included. 

* This step filters out incomplete or failed transactions to maintain data quality. 

**Step 2: Calculate Monthly Averages**

* Computed the **average number of successful transactions per customer per month**. 

* This gives a normalized view of user activity over time, especially for long-term customers. 

**Step 3: Frequency Segmentation**

* Based on the calculated monthly averages, customers were categorized with the criteria provided in the question 

**Step 4: Summary Output**

Finally, I grouped and counted customers in each segment and computed their average transactions per month.

Note: I used **CTEs** to enhance readability and maintainability. The same logic can be achieved with nested subqueries depending on your SQL environment.

### Challenge & Resolution


#### Challenge

Initially, I included **all transaction types**, which led to inflated and misleading frequency numbers. After further investigation and understanding that the **finance team only tracks successful transactions**, I realized this would not align with the reporting metrics for the **finance team**

#### Resolution

* Added a condition to only include records where transaction_status = 'success’. 

* This ensures results reflect **actual user behavior** and align with **financial reporting standards**. 

* As a result, insights are more accurate, actionable, and aligned with the team’s expectations.



#### Note

Although failed transactions were excluded from this analysis, they **represent an opportunity** for further investigation:

* **Why do they fail?** (e.g., tech issues, payment failures, user errors) 

* **Which users experience more failures?**

* Insights here could help: 

    * **Engineering** improves reliability. 

    * **Customer Support** proactively assists users.

    * **Product Teams** streamline the transaction flow.


## 3. Account Inactivity Alert

### Objective

To assist the **Operations Team** in identifying **active customer plans** either savings or investment that  have **not received any deposit in the last 365 days**.

### Approach

The analysis is based on two tables:

* **plans_plan**: Contains metadata about customer financial plans. 

* **savings_savingsaccount**: Contains deposit records, including timestamps and associated plan IDs. 

### Step-by-Step Strategy

**1. Identify Plan Type**

From the plans_plan table:

* **Savings Plan** → is_regular_savings = 1 

* **Investment Plan** → is_a_fund = 1 

This classification helps label each plan appropriately for reporting.


**2. Join with Deposit Records**

* Join plans_plan with savings_savingsaccount using plan_id. 

* This links each plan to its corresponding deposit activity. 

**3. Determine Last Deposit Date**

* Use the MAX(savings_savingsaccount.transaction_date) to extract the **most recent deposit date** for each plan. 
* Apply the confirmed amount filter to be greater than zero

**4. Calculate Inactivity**

*  to find the number of days since the last deposit. 

**5. Filter Inactive Plans**

* Only include plans where: 

    * No deposit has been made in ***the last 365 days (**cases where the difference between the max(transaction_date) and the current date is within 365)


#### Observations

I observed that some plans have never been activated; these are plans that exist in the plans_plan table but have no deposit records at all in the savings_savingsaccount table, resulting in a NULL value for their last_tran_date.

These users can be segmented to  Analyze their demographics, sign up channels, and confirm if their onboarding steps were completed


## 4. Customer Lifetime Value (CLV) Estimation


### Objective

Estimate the **Customer Lifetime Value (CLV)** for each customer to help the business understand the **long-term value** generated by individual users based on their transaction activity and tenure. 


### Approach


**1. Calculate Customer Tenure**

* Use the difference between the current date and the customer's account creation date (date_joined) in **months** to measure how long the customer has been active.

* This is calculated using the MySQL PERIOD_DIFF function with year-month formatted dates. This helps to get the tenure in months. 

**2. Aggregate Successful Transactions**

* Count the total number of **successful** transactions (transaction_status = 'success') performed by each customer. 

* This count represents the customer’s transactional engagement over their lifetime.

**3. Estimate Average Profit Per Transaction**

* Calculate the average transaction amount for successful transactions.

* Multiply the average amount by a fixed profit margin factor (0.001 in this case) to estimate average profit per transaction 

**4. Calculate Estimated CLV**

* This formula annualizes the customer's transaction frequency and applies average profit to estimate yearly lifetime value. 

* Use NULLIF to replace NULL tenure in month with zero when calculating the CLV. 

**5. Filter & Sort**

* exclude customers with zero transactions. 

* Sort customers by estimated CLV in descending order to prioritize high-value customers. 

