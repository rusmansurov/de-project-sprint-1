/*
CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);
*/

INSERT INTO analysis.tmp_rfm_frequency
(
"user_id"
 , frequency
)
WITH RANK_COUNT_ORDERS AS
(
    SELECT "user_id", ROW_NUMBER() OVER (ORDER BY order_cnt) rnm
    FROM
    (
        SELECT
            "user_id"
            , COUNT(order_id) order_cnt
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
    SELECT MAX(rnm) max_rnm FROM RANK_COUNT_ORDERS
)

SELECT 
	"user_id"
    , CASE
        WHEN rnm >= (max_rnm * 0.8) THEN 5
        WHEN rnm >= (max_rnm * 0.6) THEN 4
        WHEN rnm >= (max_rnm * 0.4) THEN 3
        WHEN rnm >= (max_rnm * 0.2) THEN 2
        ELSE 1
    END AS frequency
FROM RANK_COUNT_ORDERS, MAX_RANK_NUMBER
;