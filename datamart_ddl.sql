DROP TABLE IF EXISTS analysis.dm_rfm_segments;

CREATE TABLE analysis.dm_rfm_segments
(
user_id integer NOT NULL PRIMARY KEY
, recency integer NOT NULL CHECK (recency BETWEEN 1 AND 5)
, frequency integer NOT NULL CHECK (frequency BETWEEN 1 AND 5)
, monetary_value integer NOT NULL CHECK (monetary_value BETWEEN 1 AND 5)
)
;