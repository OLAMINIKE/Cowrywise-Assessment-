 -- Total deposits (Across all plans) per customer (with at least one saving and investment plan).
WITH plan_counts AS (
    SELECT 
        owner_id,
        COUNT(CASE WHEN is_regular_savings = 1 THEN 1 END) AS savings_count,
        COUNT(CASE WHEN is_a_fund = 1 THEN 1 END) AS investment_count
    FROM plans_plan
    GROUP BY owner_id
),
deposit_sums AS (
    SELECT 
        owner_id,
        ROUND(SUM(s.confirmed_amount), 2) AS total_deposits
    FROM savings_savingsaccount s
    GROUP BY owner_id
)
SELECT
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS full_name,
    pc.savings_count,
    pc.investment_count,
    COALESCE(ds.total_deposits, 0) AS total_deposits
FROM users_customuser u
JOIN plan_counts pc ON u.id = pc.owner_id
LEFT JOIN deposit_sums ds ON u.id = ds.owner_id
WHERE pc.savings_count > 0
  AND pc.investment_count > 0
ORDER BY total_deposits DESC;

-- Deposits linked only to savings/investment plans
WITH savings_plan_counts AS (
    SELECT 
        owner_id, 
        COUNT(*) AS savings_count
    FROM plans_plan
    WHERE is_regular_savings = 1
    GROUP BY owner_id
),
investment_plan_counts AS (
    SELECT 
        owner_id, 
        COUNT(*) AS investment_count
    FROM plans_plan
    WHERE is_a_fund = 1
    GROUP BY owner_id
),
total_deposits AS (
    SELECT 
        p.owner_id, 
        ROUND(SUM(s.confirmed_amount), 2) AS total_deposits
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE p.is_regular_savings = 1 OR p.is_a_fund = 1
    GROUP BY p.owner_id
)

SELECT
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    COALESCE(sp.savings_count, 0) AS savings_count,
    COALESCE(ip.investment_count, 0) AS investment_count,
    COALESCE(td.total_deposits, 0) AS total_deposits
FROM users_customuser u
LEFT JOIN savings_plan_counts sp ON u.id = sp.owner_id
LEFT JOIN investment_plan_counts ip ON u.id = ip.owner_id
LEFT JOIN total_deposits td ON u.id = td.owner_id
WHERE COALESCE(sp.savings_count, 0) > 0
  AND COALESCE(ip.investment_count, 0) > 0
ORDER BY total_deposits DESC;

