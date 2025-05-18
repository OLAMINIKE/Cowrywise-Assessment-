-- Get monthly count of successful transactions per customer
WITH customer_monthly_txns AS (
    SELECT
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month,
        COUNT(*) AS transactions_in_month
    FROM savings_savingsaccount
    WHERE transaction_status = 'success'  -- Filter only successful transactions
    GROUP BY owner_id, txn_month
),
-- Calculate each customer's average successful transactions per month
customer_avg_monthly_txns AS (
    SELECT
        owner_id,
        AVG(transactions_in_month) AS avg_txns_per_month
    FROM customer_monthly_txns
    GROUP BY owner_id
),

-- Categorize each customer by transaction frequency tier
categorized_customers AS (
    SELECT
        owner_id,
        avg_txns_per_month,
        CASE
            WHEN avg_txns_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txns_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM customer_avg_monthly_txns
)
--  Aggregate result by frequency category
SELECT
    frequency_category,
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(avg_txns_per_month), 1) AS avg_transactions_per_month
FROM categorized_customers
GROUP BY frequency_category
ORDER BY 
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'Low Frequency' THEN 3
    END;
