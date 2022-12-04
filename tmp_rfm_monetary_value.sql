/*
CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);
*/

INSERT INTO analysis.tmp_rfm_monetary_value
(
"user_id"
, monetary_value
)
WITH RANK_SUM_ORDERS AS
(
    SELECT "user_id", ROW_NUMBER() OVER (ORDER BY sum_payment) rnm
    FROM
    (
        SELECT 
            "user_id"
            , SUM(payment) sum_payment
        FROM "analysis"."orders"
        WHERE
            "status" = 4
            AND EXTRACT(YEAR FROM "order_ts") >= 2022
        GROUP BY "user_id"
    ) T
)
,
MAX_RANK_NUMBER AS
(
    SELECT MAX(rnm) max_rnm FROM RANK_SUM_ORDERS
)

SELECT 
	"user_id"
    , CASE
        WHEN rnm >= (max_rnm * 0.8) THEN 5
        WHEN rnm >= (max_rnm * 0.6) THEN 4
        WHEN rnm >= (max_rnm * 0.4) THEN 3
        WHEN rnm >= (max_rnm * 0.2) THEN 2
        ELSE 1
    END AS monetary_value
FROM RANK_SUM_ORDERS, MAX_RANK_NUMBER
;