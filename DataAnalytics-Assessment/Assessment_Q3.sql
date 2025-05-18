WITH plan_with_last_tran AS (
    SELECT
        p.id AS plan_id,
        p.owner_id,
        CASE
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Other'
        END AS plan_type,
        MAX(s.transaction_date) AS last_tran_date
    FROM plans_plan p
    LEFT JOIN savings_savingsaccount s 
        ON p.id = s.plan_id AND s.confirmed_amount > 0
    WHERE p.is_regular_savings = 1 OR p.is_a_fund = 1
    GROUP BY p.id, p.owner_id, plan_type
)

SELECT
    plan_id,
    owner_id,
    plan_type,
    last_tran_date,
    DATEDIFF(CURDATE(), last_tran_date) AS days_inactive
FROM plan_with_last_tran
WHERE 
     DATEDIFF(CURDATE(), last_tran_date) <= 365
ORDER BY days_inactive DESC;
