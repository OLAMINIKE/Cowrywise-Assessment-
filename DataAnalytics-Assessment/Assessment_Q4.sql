-- Customer Lifetime Value (CLV) Estimation
SELECT u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS full_name,
-- Calculate tenure in months since account signup
    PERIOD_DIFF(DATE_FORMAT(CURDATE(), '%Y%m'), DATE_FORMAT(u.date_joined, '%Y%m')) AS tenure_months,
-- Count all successful transactions made by the user
    COUNT(s.id) AS total_transactions,
-- Calculate Estimated CLV using the formula:
    ROUND((COUNT(s.id) / NULLIF(PERIOD_DIFF(DATE_FORMAT(CURDATE(), '%Y%m'), 
    DATE_FORMAT(u.date_joined, '%Y%m')), 0)) * 12 * (0.001 * AVG(s.amount)), 2
    ) AS estimated_clv
FROM users_customuser u
LEFT JOIN savings_savingsaccount s 
    ON u.id = s.owner_id AND s.transaction_status = 'success'  -- Only include successful transactions
GROUP BY u.id, name
HAVING total_transactions > 0  --  Exclude customers with zero transactions
ORDER BY estimated_clv DESC;
