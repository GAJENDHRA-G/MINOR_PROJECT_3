 -- =====================================================================
 -- RedFlag — Fraud Detection Submission 
 -- Student: Gajendhra G  |  Batch: DA-DS-1 
 -- ===================================================================== 
USE redflag; 

-- ===================================================================== 
-- PATTERN 1 · VELOCITY FRAUD 
-- What I'm looking for: users with 30+ transactions in a single day 
-- Expected suspects: ~50 
-- ===================================================================== 
SELECT user_id, DATE(txn_time) AS attack_date, COUNT(*) AS daily_txn_count 
FROM transactions 
GROUP BY user_id, DATE(txn_time) 
HAVING COUNT(*) >= 30 
ORDER BY daily_txn_count DESC; 

-- My findings: 50 suspect user-days flagged. 
-- Top 3 fraudsters by transaction count: user 14556 (60 txns on 2024-05-28), 
-- user 14569 (60 txns on 2024-04-03), user 14559 (59 txns on 2024-06-04). 
  
-- =====================================================================
-- PATTERN 2 · ROUND-AMOUNT CLUSTERING 
-- What I'm looking for: user_id with 15+ exactly-round transactions 
-- Expected suspects: 25 
-- ===================================================================== 

SELECT user_id,count(*) AS round_amount_transactions
FROM transactions
WHERE amount IN (100,200,500,1000,2000,5000,10000)
GROUP BY user_id
HAVING count(*) >= 15
ORDER BY round_amount_transactions DESC;

-- My findings: 25 suspect user-days flagged. 
-- Top 3 fraudsters by exactly-round-transactions : user 14533 (30 txns),
-- user 14534 (30 txns), user 14535 (30 txns). 
  
-- =====================================================================
-- PATTERN 3 · CARD TESTING
-- What I'm looking for: user_id with 30+ transactions under Rs.10 in a single day 
-- Expected suspects: 20
-- ===================================================================== 

SELECT user_id, DATE(txn_time) AS DATE, COUNT(*) AS small_amount_transactions
FROM transactions
WHERE amount <= 10
GROUP BY user_id, DATE
HAVING COUNT(*) >= 30
ORDER BY small_amount_transactions DESC;

-- My findings: 20 suspect user-days flagged. 
-- Top 3 fraudsters by small amount transactions: user 14569 (60 txns on 2024-04-03),
-- user 14556 (60 txns on 2024-05-28), user 14564 (59 txns on 2024-02-15). 

-- =====================================================================
-- PATTERN 4 · FAILED-THEN-SUCCEEDED 
-- What I'm looking for: user_id with 20+ transactions where status='FAILED'
-- Expected suspects: 25 
-- ===================================================================== 

SELECT user_id, count(*) AS total_failed_transactions
FROM transactions
WHERE status = 'FAILED'
GROUP BY user_id
HAVING count(*) >= 20
ORDER BY total_failed_transactions DESC;

-- My findings: 25 suspect user-days flagged. 
-- Top 3 fraudsters by failed transactions: user 14595 (35 txns),
-- user 14593 (34 txns), user 14576 (33 txns). 
  
-- =====================================================================
-- PATTERN 5 · ODD-HOUR CONCENTRATION
-- What I'm looking for: for user_id where 80% of their transactions occur between 2AM and 5AM
-- Expected suspects: 20
-- ===================================================================== 

SELECT user_id, count(*) as transactions,
SUM( CASE
		WHEN HOUR(txn_time) BETWEEN 2 AND 5 THEN 1
        ELSE 0
	END) AS odd_hour_concentration
FROM transactions
GROUP BY user_id
HAVING count(*) >= 30 AND odd_hour_concentration/count(*) >= 0.80
ORDER BY transactions DESC;

-- My findings: 20 suspect user-days flagged. 
-- Top 3 fraudsters by odd-hour transactions: user 14608 (58 txns between 2AM and 5AM),
-- user 14607 (53 txns between 2AM and 5AM), user 14606 (52 txn between 2AM and 5AM). 
  
-- =====================================================================
-- PATTERN 6 · MULE ACCOUNTS 
-- What I'm looking for: A user with 8 or more CREDIT transactions
-- Expected suspects: 30 
-- ===================================================================== 

SELECT user_id, count(*) as credit_transactions
FROM transactions
WHERE txn_type = 'CREDIT'
GROUP BY user_id
ORDER BY credit_transactions DESC;

-- My findings: 30 suspect user-days flagged.
-- Top 3 fraudsters by more than 8 credit transactions : user 14630 (15 txns),
-- user 14637 (15 txns), user 14640 (15 txns).
  
-- =====================================================================
-- PATTERN 7 · REFUND ABUSE
-- What I'm looking for: A user with 20+ total transactions and a refund ration greater than 40%
-- Expected suspects: 24-25
-- =====================================================================

SELECT user_id, count(*) AS all_transactions,
SUM(CASE WHEN txn_type = 'REFUND' THEN 1 ELSE 0 END) AS refund_amounts,
ROUND(SUM(CASE WHEN txn_type = 'REFUND' THEN 1 ELSE 0 END)*100.0/count(*),2) AS refund_ratio_percentage
FROM transactions
GROUP BY user_id
HAVING all_transactions >= 20 AND refund_amounts > all_transactions * 0.40
ORDER BY refund_ratio_percentage DESC;

-- My findings: 24 suspect user-days flagged. 
-- Top 3 fraudsters by refund ratio greater than 40% : user 14662 (25 refund txns of 39 txns (64.10 percentage) ),
-- user 14670 (32 refund txns of 50 txns (64.0 percentage) ), user 14665 (23 refund txns of 36 txns (63.89 percentage) ). 
  
-- =====================================================================
-- PATTERN 8 · MERCHANT COLLUSION 
-- What I'm looking for: A merchant where the top 5 users by volume account for more than 60% of the 
-- merchnat's total transaction value 
-- Expected suspects: 15 (exactly) 
-- ===================================================================== 

WITH user_totals AS (
    SELECT merchant_id, user_id, SUM(amount) AS user_amount
    FROM transactions
    GROUP BY merchant_id, user_id
),
ranking_user AS (
    SELECT merchant_id, user_id, user_amount,
        ROW_NUMBER() OVER (
            PARTITION BY merchant_id
            ORDER BY user_amount DESC
        ) AS roll_number
    FROM user_totals
),

merchant_totals AS (
    SELECT merchant_id, SUM(amount) AS total_amount
    FROM transactions
    GROUP BY merchant_id
)
SELECT r.merchant_id, SUM(r.user_amount) AS top5_amount, m.total_amount,
ROUND((SUM(r.user_amount) * 100.0) / m.total_amount, 2) AS top5_percentage
FROM ranking_user r
JOIN merchant_totals m
ON r.merchant_id = m.merchant_id
WHERE r.roll_number <= 5
GROUP BY r.merchant_id, m.total_amount
HAVING (SUM(r.user_amount) / m.total_amount) > 0.60
ORDER BY top5_percentage DESC;

-- My findings: 15 suspect merchants. 
-- Top 3 fraudsters by more than 60% of the merchant's total transaction value: merchant_id 12 (99.91 percentage),
-- merchant_id 8 (99.87 percentage), merchant_id 13 (99.85 percentage). 
  
-- =====================================================================
-- PATTERN 9 · JUST-UNDER-THRESHOLD (Structuring) 
-- What I'm looking for: A user with 10 or more transactions at exactly Rs.9,999.00 
-- Expected suspects: 20 
-- ===================================================================== 

SELECT user_id, count(*) as total_transactions
FROM transactions
WHERE amount = 9999
GROUP BY user_id
HAVING count(*) >= 10
ORDER BY total_transactions DESC;

-- My findings: 20 suspect user-days flagged. 
-- Top 3 fraudsters by transactions happened exactly of Rs.9,999: user 14680 (25 txns),
-- user 14690 (25 txns), user 14693 (22 txns). 
  
-- =====================================================================
-- PATTERN 10 · DORMANT THEN ACTIVE 
-- What I'm looking for: A user who has a gap of 90+ days between two consecutive transactions
-- Expected suspects: 26
-- ===================================================================== 

WITH transaction_gap AS (
    SELECT
        user_id,
        txn_time,
        LAG(txn_time) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS previous_txn
    FROM transactions
),
inactive_users AS (
    SELECT user_id, txn_time
    FROM transaction_gap
    WHERE previous_txn IS NOT NULL AND DATEDIFF(txn_time, previous_txn) >= 90
)
SELECT i.user_id, COUNT(t.txn_id) AS transactions_after_gap
FROM inactive_users i
JOIN transactions t
    ON i.user_id = t.user_id
   AND t.txn_time >= i.txn_time
GROUP BY i.user_id
HAVING COUNT(t.txn_id) >= 15
ORDER BY transactions_after_gap DESC;

-- My findings: 26 suspect user-days flagged. 
-- Top 3 fraudsters by Dormant-then-suddenly-active with more than 15 transactions : user 14526 (55 txns after gap),
-- user 14701 (28 txns after gap), user 14708 (28 txns after gap). 
  
-- =====================================================================
-- PATTERN 11 · VELOCITY SPIKE 
-- What I'm looking for: A user whose peak monthly transaction count is atleast 5x of their average
-- monthly transaction count
-- Expected suspects: 35-45 
-- ===================================================================== 

WITH per_month_transactions AS (
    SELECT user_id, DATE_FORMAT(txn_time, '%Y-%m') AS month, COUNT(*) AS monthly_count
    FROM transactions
    GROUP BY user_id, DATE_FORMAT(txn_time, '%Y-%m')
),
user_analysis AS (
    SELECT user_id, AVG(monthly_count) AS average, MAX(monthly_count) AS max_transactions
    FROM per_month_transactions
    GROUP BY user_id
)
SELECT user_id, ROUND(average,2) AS avg_transactions,
    max_transactions, ROUND(max_transactions / average,2) AS SPIKE_RATIO
FROM user_analysis
WHERE max_transactions >= 20
  AND max_transactions >= average * 5
ORDER BY SPIKE_RATIO DESC;

-- My findings: Was not able to do this pattern 
  
-- =====================================================================
-- PATTERN 12 · GEOGRAPHIC IMPOSSIBILTY
-- What I'm looking for: A user_id where atleast one pair of consecutive transactions occurs in
-- different cities within 60 minutes of each other.
-- Expected suspects: 15 
-- ===================================================================== 

WITH transaction_places AS (
    SELECT user_id, city, txn_time,
        LAG(city) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS previous_city,
        LAG(txn_time) OVER (
            PARTITION BY user_id
            ORDER BY txn_time
        ) AS previous_time
    FROM transactions
)
SELECT user_id, previous_city, city as next_city, previous_time, txn_time as next_time 
FROM transaction_places
WHERE
    previous_city IS NOT NULL
    AND city <> previous_city
    AND TIMESTAMPDIFF(MINUTE, previous_time, txn_time) <= 60
ORDER BY
    user_id, next_time;

-- My findings: 15 suspect user-days flagged. 
-- Top 3 fraudsters by Geographic Impossibilty : user 14741,
-- user 14508 , user 14515.