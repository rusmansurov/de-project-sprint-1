INSERT INTO analysis.dm_rfm_segments
(
"user_id"
, recency
, frequency
, monetary_value
)
SELECT
	tmp_rfm_recency."user_id"
	, tmp_rfm_recency.recency
	, tmp_rfm_frequency.frequency
	, tmp_rfm_monetary_value.monetary_value
FROM analysis.tmp_rfm_recency
	JOIN analysis.tmp_rfm_frequency ON tmp_rfm_recency."user_id" = tmp_rfm_frequency."user_id"
	JOIN analysis.tmp_rfm_monetary_value ON tmp_rfm_recency."user_id" = tmp_rfm_monetary_value."user_id"
;

--Получаем первые десять строк из полученной таблицы, отсортированные по user_id, запрошенные в задаче
/*
SELECT *
FROM analysis.dm_rfm_segments
ORDER BY "user_id"
LIMIT 10
*/
|user_id|recency|frequency|monetary_value|
|-------|-------|---------|--------------|
|0      |1      |3        |4             |
|1      |4      |3        |3             |
|2      |2      |3        |5             |
|3      |2      |3        |3             |
|4      |4      |3        |3             |
|5      |5      |5        |5             |
|6      |1      |3        |5             |
|7      |4      |3        |2             |
|8      |1      |1        |3             |
|9      |1      |2        |2             |