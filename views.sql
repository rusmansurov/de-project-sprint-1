CREATE OR REPLACE VIEW "analysis"."orderitems" AS
SELECT 
	"id"
	, "product_id"
	, "order_id"
	, "name"
	, "price"
	, "discount"
	, "quantity" 
FROM "production"."orderitems"
;


CREATE OR REPLACE VIEW "analysis"."orders" AS
SELECT 
	"order_id"
	, "order_ts"
	, "user_id"
	, "bonus_payment"
	, "payment"
	, "cost"
	, "bonus_grant"
	, "status" 
FROM "production"."orders"
;


CREATE OR REPLACE VIEW "analysis"."orderstatuses" AS
SELECT 
	"id"
	, "key" 
FROM "production"."orderstatuses"
;


CREATE OR REPLACE VIEW "analysis"."products" AS
SELECT 
	"id"
	, "name"
	, "price" 
FROM "production"."products"
;


CREATE OR REPLACE VIEW "analysis"."users" AS
SELECT 
	"id"
	, "name"
	, "login" 
FROM "production"."users"
;


/*
-- В задаче был запрос на пять вьюшек без уточнения названий, а у нас их 6.
-- orderstatuslog используется во второй части задачи. Поэтому, эту буду считать лишней в этой задаче.
-- Но код на всякий пожаргый сохраню

CREATE OR REPLACE VIEW "analysis"."orderstatuslog" AS
SELECT 
	"id"
	, "order_id"
	, "status_id"
	, "dttm" 
FROM "production"."orderstatuslog"
;
*/