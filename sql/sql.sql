-- ============================
-- CTE for account metrics
-- ============================
WITH account_dataset AS (
    SELECT
        s.date,
        sp.country,
        aa.send_interval,
        aa.is_verified,
        aa.is_unsubscribed,
        COUNT(DISTINCT acs.account_id) AS account_cnt
    FROM `DA.account` aa
    JOIN `DA.account_session` acs
        ON aa.id = acs.account_id
    JOIN `DA.session` s
        ON acs.ga_session_id = s.ga_session_id
    JOIN `DA.session_params` sp
        ON sp.ga_session_id = s.ga_session_id
    GROUP BY s.date, sp.country, aa.send_interval, aa.is_verified, aa.is_unsubscribed
),

-- ============================
-- CTE for email metrics
-- ============================
email_dataset AS (
    SELECT
        DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date,
        sp.country,
        aa.send_interval,
        aa.is_verified,
        aa.is_unsubscribed,
        COUNT(DISTINCT es.id_message) AS sent_msg,
        COUNT(DISTINCT eo.id_message) AS open_msg,
        COUNT(DISTINCT ev.id_message) AS visit_msg
    FROM `data-analytics-mate.DA.email_sent` es
    LEFT JOIN `data-analytics-mate.DA.email_open` eo
        ON es.id_message = eo.id_message
    LEFT JOIN `data-analytics-mate.DA.email_visit` ev
        ON es.id_message = ev.id_message
    JOIN `data-analytics-mate.DA.account_session` acs
        ON es.id_account = acs.account_id
    JOIN `data-analytics-mate.DA.session_params` sp
        ON acs.ga_session_id = sp.ga_session_id
    JOIN `DA.session` s
        ON acs.ga_session_id = s.ga_session_id
    JOIN `DA.account` aa
        ON aa.id = es.id_account
    GROUP BY date, sp.country, aa.send_interval, aa.is_verified, aa.is_unsubscribed
),

-- ============================
-- CTE to merge account and email data
-- ============================
union_dataset AS (
    SELECT
        date,
        country,
        send_interval,
        is_verified,
        is_unsubscribed,
        account_cnt,
        0 AS sent_msg,
        0 AS open_msg,
        0 AS visit_msg
    FROM account_dataset
    UNION ALL
    SELECT
        date,
        country,
        send_interval,
        is_verified,
        is_unsubscribed,
        0 AS account_cnt,
        sent_msg,
        open_msg,
        visit_msg
    FROM email_dataset
),

-- ============================
-- CTE to aggregate all metrics
-- ============================
union_final AS (
    SELECT
        date,
        country,
        send_interval,
        is_verified,
        is_unsubscribed,
        SUM(account_cnt) AS account_cnt,
        SUM(sent_msg) AS sent_msg,
        SUM(open_msg) AS open_msg,
        SUM(visit_msg) AS visit_msg
    FROM union_dataset
    GROUP BY date, country, send_interval, is_verified, is_unsubscribed
)

-- ============================
-- Final query with country ranking
-- ============================
SELECT *
FROM (
    -- Subquery to rank countries
    SELECT
        date,
        country,
        send_interval,
        is_verified,
        is_unsubscribed,
        account_cnt,
        sent_msg,
        open_msg,
        visit_msg,
        total_country_sent_cnt,
        total_country_account_cnt,
        DENSE_RANK() OVER (ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
        DENSE_RANK() OVER (ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt
    FROM (
        -- Subquery to calculate total accounts and sent emails by country
        SELECT
            date,
            country,
            send_interval,
            is_verified,
            is_unsubscribed,
            account_cnt,
            SUM(account_cnt) OVER(PARTITION BY country) AS total_country_account_cnt,
            sent_msg,
            open_msg,
            visit_msg,
            SUM(sent_msg) OVER(PARTITION BY country) AS total_country_sent_cnt
        FROM union_final
    )
)

-- Filter for top 10 countries by accounts or sent emails
WHERE rank_total_country_account_cnt <= 10
   OR rank_total_country_sent_cnt <= 10;