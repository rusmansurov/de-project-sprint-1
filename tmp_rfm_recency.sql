/*
--DROP TABLE IF EXISTS analysis.tmp_rfm_recency;

CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);
*/

INSERT INTO analysis.tmp_rfm_recency
(
"user_id"
, recency
)
WITH RANK_MAX_USER_ORDERS AS
(
    SELECT user_id, ROW_NUMBER() OVER (ORDER BY order_ts) rnm
    FROM
    (
        SELECT
            "user_id"
            , MAX("order_ts") order_ts
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
    SELECT MAX(rnm) max_rnm FROM RANK_MAX_USER_ORDERS
)

SELECT
	"user_id"
    , CASE
        WHEN rnm >= (max_rnm * 0.8) THEN 5
        WHEN rnm >= (max_rnm * 0.6) THEN 4
        WHEN rnm >= (max_rnm * 0.4) THEN 3
        WHEN rnm >= (max_rnm * 0.2) THEN 2
        ELSE 1
    END AS recency
FROM RANK_MAX_USER_ORDERS, MAX_RANK_NUMBER
;