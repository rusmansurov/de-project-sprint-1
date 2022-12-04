CREATE OR REPLACE VIEW analysis.orders AS
SELECT
		orders.order_id
		, orders.order_ts
		, orders.user_id
		, orders.bonus_payment
		, orders.payment
		, orders."cost"
		, orders.bonus_grant
		, orderstatuslog.status_id as status
FROM
		production.orders
		LEFT JOIN (
			  SELECT order_id, status_id, ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY dttm DESC) rnm
			  FROM production.orderstatuslog
		  		) orderstatuslog ON orders.order_id = orderstatuslog.order_id
WHERE
		orderstatuslog.rnm = 1
;