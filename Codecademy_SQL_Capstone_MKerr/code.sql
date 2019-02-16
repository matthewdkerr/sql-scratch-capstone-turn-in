-- Matt Kerr
-- Learn SQL from Scratch
-- Cohort 2018/12/03



-- Question_1

SELECT *
FROM subscriptions
LIMIT 100;

-- confirm there are no additional unique segments besides 87 and 30
SELECT DISTINCT segment
FROM subscriptions;


--------------------------------------------------


-- Question_2

SELECT MIN(subscription_start) AS 'sub_start_min',
    MAX(subscription_start) AS 'sub_start_max',
    MIN(subscription_end) AS 'sub_end_min',
    MAX(subscription_end) AS 'sub_end_max'
FROM subscriptions;


--------------------------------------------------


-- Question_3

WITH months AS (
    SELECT '2017-01-01' AS first_day,
        '2017-01-31' AS last_day
    UNION
    SELECT '2017-02-01',
        '2017-02-28'
    UNION
    SELECT '2017-03-01',
        '2017-03-31')
SELECT *
FROM months;


--------------------------------------------------


-- Question_4

WITH months AS (
    SELECT '2017-01-01' AS first_day,
        '2017-01-31' AS last_day
    UNION
    SELECT '2017-02-01',
        '2017-02-28'
    UNION
    SELECT '2017-03-01',
        '2017-03-31'),
cross_join AS (
    SELECT *
    FROM subscriptions
    CROSS JOIN months)
SELECT *
FROM cross_join
LIMIT 50;


--------------------------------------------------


-- Question_5

WITH months AS (
    SELECT '2017-01-01' AS first_day,
        '2017-01-31' AS last_day
    UNION
    SELECT '2017-02-01',
        '2017-02-28'
    UNION
    SELECT '2017-03-01',
        '2017-03-31'),
cross_join AS (
    SELECT *
    FROM subscriptions
    CROSS JOIN months),

status AS (
    SELECT id,
        first_day AS month,
        CASE
            WHEN ((segment == 87)
                AND (subscription_start < first_day)
                AND (subscription_end >= first_day
                OR subscription_end IS NULL))
                THEN 1
            ELSE 0
        END AS is_active_87,
        CASE
            WHEN ((segment == 30)
                AND (subscription_start < first_day)
                AND (subscription_end >= first_day
                OR subscription_end IS NULL))
                THEN 1
            ELSE 0
        END AS is_active_30
    FROM cross_join)

SELECT *
FROM status
LIMIT 50;


--------------------------------------------------


-- Question_6

WITH months AS (
    SELECT '2017-01-01' AS first_day,
        '2017-01-31' AS last_day
    UNION
    SELECT '2017-02-01',
        '2017-02-28'
    UNION
    SELECT '2017-03-01',
        '2017-03-31'),
cross_join AS (
    SELECT *
    FROM subscriptions
    CROSS JOIN months),

status AS (
    SELECT id,
        first_day AS month,
        CASE
            WHEN segment == 87
                AND subscription_start < first_day
                AND (subscription_end >= first_day
                OR subscription_end IS NULL)
                THEN 1
            ELSE 0
        END AS is_active_87,
        CASE
            WHEN segment == 30
                AND subscription_start < first_day
                AND (subscription_end >= first_day
                OR subscription_end IS NULL)
                THEN 1
            ELSE 0
        END AS is_active_30,
        CASE
            WHEN segment == 87
                AND subscription_end >= first_day
                AND subscription_end <= last_day
                THEN 1
            ELSE 0
        END AS is_canceled_87,
        CASE
            WHEN segment == 30
                AND subscription_end >= first_day
                AND subscription_end <= last_day
                THEN 1
            ELSE 0
        END AS is_canceled_30
    FROM cross_join)

SELECT *
FROM status
LIMIT 50;


--------------------------------------------------


-- Question_7

WITH months AS (
    SELECT '2017-01-01' AS first_day,
        '2017-01-31' AS last_day
    UNION
    SELECT '2017-02-01',
        '2017-02-28'
    UNION
    SELECT '2017-03-01',
        '2017-03-31'),
cross_join AS (
    SELECT *
    FROM subscriptions
    CROSS JOIN months),

status AS (
    SELECT id,
        first_day AS month,
  
        CASE
            WHEN segment == 87
                AND subscription_start < first_day
                AND (subscription_end >= first_day
                OR subscription_end IS NULL)
                THEN 1
            ELSE 0
        END AS is_active_87,
  
        CASE
            WHEN segment == 30
                AND subscription_start < first_day
                AND (subscription_end >= first_day
                OR subscription_end IS NULL)
                THEN 1
            ELSE 0
        END AS is_active_30,
  
        CASE
            WHEN segment == 87
                AND subscription_end >= first_day
                AND subscription_end <= last_day
                THEN 1
            ELSE 0
        END AS is_canceled_87,

        CASE
            WHEN segment == 30
                AND subscription_end >= first_day
                AND subscription_end <= last_day
                THEN 1
            ELSE 0
        END AS is_canceled_30
    FROM cross_join),

status_aggregate AS (
    SELECT month,
        SUM(is_active_87) AS sum_active_87,
        SUM(is_active_30) AS sum_active_30,
        SUM(is_canceled_87) AS sum_canceled_87,
        SUM(is_canceled_30) AS sum_canceled_30
    FROM status
    GROUP BY 1)

SELECT *
FROM status_aggregate;


--------------------------------------------------


-- Question_8

WITH months AS (
    SELECT '2017-01-01' AS first_day,
        '2017-01-31' AS last_day
    UNION
    SELECT '2017-02-01',
        '2017-02-28'
    UNION
    SELECT '2017-03-01',
        '2017-03-31'),
cross_join AS (
    SELECT *
    FROM subscriptions
    CROSS JOIN months),

status AS (
    SELECT id,
        first_day AS month,
        CASE
            WHEN segment == 87
                AND subscription_start < first_day
                AND (subscription_end >= first_day
                OR subscription_end IS NULL)
                THEN 1
            ELSE 0
        END AS is_active_87,
        CASE
            WHEN segment == 30
                AND subscription_start < first_day
                AND (subscription_end >= first_day
                OR subscription_end IS NULL)
                THEN 1
            ELSE 0
        END AS is_active_30,
        CASE
            WHEN segment == 87
                AND subscription_end >= first_day
                AND subscription_end <= last_day
                THEN 1
            ELSE 0
        END AS is_canceled_87,
        CASE
            WHEN segment == 30
                AND subscription_end >= first_day
                AND subscription_end <= last_day
                THEN 1
            ELSE 0
        END AS is_canceled_30
    FROM cross_join),

status_aggregate AS (
    SELECT month,
        SUM(is_active_87) AS sum_active_87,
        SUM(is_active_30) AS sum_active_30,
        SUM(is_canceled_87) AS sum_canceled_87,
        SUM(is_canceled_30) AS sum_canceled_30
    FROM status
    GROUP BY 1)

SELECT month,
    (1.0 * sum_canceled_87 / sum_active_87) AS churn_87,
    (1.0 * sum_canceled_30 / sum_active_30) AS churn_30
FROM status_aggregate
GROUP BY 1;


--------------------------------------------------


-- Question_9  BONUS

WITH months AS (
    SELECT '2017-01-01' AS first_day,
        '2017-01-31' AS last_day
    UNION
    SELECT '2017-02-01',
        '2017-02-28'
    UNION
    SELECT '2017-03-01',
        '2017-03-31'),
cross_join AS (
    SELECT *
    FROM subscriptions
    CROSS JOIN months),

status AS (
    SELECT id,
        first_day AS month,
        segment,
        CASE
            WHEN subscription_start < first_day
                AND (subscription_end >= first_day
                OR subscription_end IS NULL)
                THEN 1
            ELSE 0
        END AS is_active,
        CASE
            WHEN subscription_end >= first_day
                AND subscription_end <= last_day
                THEN 1
            ELSE 0
        END AS is_canceled
    FROM cross_join)

/*status_aggregate AS (
    SELECT segment,
        month,
        SUM(is_active) AS sum_active,
        SUM(is_canceled) AS sum_canceled
    FROM status
    GROUP BY 1, 2)

SELECT segment,
    month,
    (1.0 * sum_canceled / sum_active) AS churn
FROM status_aggregate
GROUP BY 1, 2;*/


-- I replaced the commented out code above with the more
-- concise, but still very readable code below.

SELECT segment,
    month,
    (1.0 * SUM(is_canceled) / SUM(is_active)) AS churn
FROM status
GROUP BY 1, 2;