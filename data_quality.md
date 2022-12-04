# 1.3. Качество данных:

## 1. Оценка качества данных


1. Таблица заказов является главным источником фактовых данных. Поэтому необходимо убедиться в корректности таких показателей, как:
- Количество уникальных ордеров равно общему количеству записей (UNIQE_ORDERS = TOTAL_ROWS). 
- произведение полей payment + bonus_payment равно значению cost
-  В колонках не должно быть Нулов
- количественные показатели не могут быть отрицательными
  
``` sql
SELECT 
		COUNT(*) TOTAL_ROWS
		, COUNT(DISTINCT order_id) UNIQE_ORDERS
		, COUNT(CASE WHEN (payment + bonus_payment) = "cost" THEN 1 END) COUNT_EQUALS_COST_AND_PAYMENTS
		, COUNT(CASE WHEN 
						order_id IS NULL
						OR order_ts IS NULL
						OR user_id IS NULL
						OR bonus_payment IS NULL 
						OR payment IS NULL 
						OR "cost" IS NULL 
						OR bonus_grant IS NULL 
						OR status IS NULL 
				THEN 1 END) COUNT_NULL_VALUES
		, COUNT(CASE WHEN
					bonus_payment < 0
					OR payment < 0 
					OR "cost" < 0
					OR bonus_grant < 0
				THEN 1 END) COUNT_INCORRECT_VALUES
FROM production.orders;
```
|total_rows|uniqe_orders|count_mismatched_cost_and_payments|count_null_values|count_incorrect_values|
|----------|------------|----------------------------------|-----------------|----------------------|
|10000|10000|10000|0|0|

Итог проверки:
- В таблице-источнике нет дублей и все номера ордеров уникальны, так количество уникальных ордеров = общему количеству записей в таблице
- Все значения в поле cost равны произведению полей payment + bonus_payment и равно общему количеству записей
- В таблице нет ни одного поля с Нуловым значением
- В таблице заказов нет ни одного отрицательного количественного показателя




2. Таблица статусов. Проверка может быть произведена визуально и данные в ней выглядят корректно. Также. в таблице присутствует необходимых статус Closed у которго id = 4

``` sql
SELECT id, "key"
FROM production.orderstatuses;
```
|id|key|
|--|---|
|1|Open|
|2|Cooking|
|3|Delivering|
|4|Closed|
|5|Cancelled|




3. Таблица логов статусов закзаов.

``` sql
SELECT 
		COUNT(*) COUNT_ROWS
		, COUNT(DISTINCT id) COUNT_UNIQUE_ID
		, COUNT(DISTINCT concat(order_id, '|', status_id)) COUNT_UNIQUE_KEY
		, COUNT(CASE WHEN status_id >= 1 AND status_id <=5 THEN 1 END) COUNT_CORRECT_STATUS_ID
		, COUNT(CASE WHEN id IS NULL OR order_id IS NULL OR status_id IS NULL OR dttm IS NULL THEN 1 END) COUNT_NULL_VALUES
FROM production.orderstatuslog;
```
|count_rows|count_unique_id|count_unique_key|count_correct_status_id|count_null_values|
|----------|---------------|----------------|-----------------------|-----------------|
|29982|29982|29982|29982|0|

Результат проверки:
- В таблице нет задублированных id и их ууникальное количество равно общему количеству записей в таблице
- В таблице соблюдена уникальность UNIQUE (order_id, status_id) и их количество равно общему количеству записей
- Все статусы заказов (status_id) заполнены и имеют занчение от 1-го до 5-ти (как в таблице production.orderstatuses)
- В таблице нет ни одного поля со значением поля NULL
   
---
## 2. Таблицы в схеме production и интструменты обеспечения качества данных в них

| Таблицы             | Объект                      | Инструмент      | Для чего используется |
| ------------------- | --------------------------- | --------------- | --------------------- |
| production.Products | id int NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность продукта |
| production.Products | "name" varchar(2048) NOT NULL | Не нул  | Название продукта. Всегда заполнено |
| production.Products | price numeric(19, 5) NOT NULL DEFAULT 0 CHECK ((price >= (0)::numeric)) | Проверка условия стоимости + при нулах проставляется 0 | Стоимость продукта не может быть отрицательной, а также при отстутствии цены проставляется занчение 0 |
|||||
| production.orderstatuslog | id int4 NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей лога заказов |
| production.orderstatuslog | order_id int4 NOT NULL | Не нул | Номер заказа всегда должен быть указан |
| production.orderstatuslog | status_id int4 NOT NULL | Не нул  | Статус заказа всегда заполнен |
| production.orderstatuslog | dttm timestamp NOT NULL | Не нул  | Время записи лога всегда заполнено |
| production.orderstatuslog | CONSTRAINT orderstatuslog_order_id_status_id_key UNIQUE (order_id, status_id) | Уникальность записи | Указаывает на уникальное сочетание записей в таблице |
| production.orderstatuslog | CONSTRAINT orderstatuslog_order_id_fkey FOREIGN KEY (order_id) REFERENCES production.orders(order_id) | Ключ на таблицу | В таблице production.orders должно быть аналогичное значение order_id |
| production.orderstatuslog | CONSTRAINT orderstatuslog_status_id_fkey FOREIGN KEY (status_id) REFERENCES production.orderstatuses(id) | Ключ на таблицу | Идентификатор заказа должен присутствовать в поле id таблицы production.orderstatuses |
|||||
| production.users | id int4 NOT NULL PRIMARY KEY | Первичный ключ | Обеспечивает уникальность записи пользоателя |
| production.users | login varchar(2048) NOT NULL | Не нул  | login пользователя заполнен |
|||||
| production.orderstatuses | id int4 NOT NULL PRIMARY KEY | Первичный ключ | Обеспечивает уникальность статуса заказа |
| production.orderstatuses | "key" varchar(255) NOT NULL | Не нул | Значение поля всегда заполнено |
|||||
| production.orders | order_id int4 NOT NULL PRIMARY KEY | Первичный ключ | Обеспечивает уникальность заказ |
| production.orders | product_id int4 NOT NULL | Не нул | product_id заполнен |
| production.orders | user_id int4 NOT NULL | Не нул | user_id заполнен |
| production.orders | bonus_payment numeric(19, 5) NOT NULL DEFAULT 0 | Не нул | Значение поля заполнено. В случае нула проставляется значение 0 |
| production.orders | payment numeric(19, 5) NOT NULL DEFAULT 0 | Не нул | Значение поля заполнено. В случае нула проставляется значение 0 |
| production.orders | "cost" numeric(19, 5) NOT NULL DEFAULT 0 CHECK ((cost = (payment + bonus_payment))) | Не нул | Значение поля заполнено. В случае нула проставляется значение 0. Проверка - cost должна равняться произведению: payment + bonus_payment |
| production.orders | bonus_grant numeric(19, 5) NOT NULL DEFAULT 0 | Не нул | Значение поля заполнено. В случае нула проставляется значение 0 |
| production.orders | status int4 NOT NULL | Не нул | Значение поля заполнено |
|||||
| production.orderitems | order_id int4 NOT NULL PRIMARY KEY | Первичный ключ | Обеспечивает уникальность заказов |
| production.orderitems | product_id int4 NOT NULL | Не нул | product_id заполнен |
| production.orderitems | user_id int4 NOT NULL | Не нул | user_id заполнен |
| production.orderitems | order_id int4 NOT NULL | Не нул | order_id заполнен |
| production.orderitems | "name" varchar(2048) NOT NULL | Не нул | name заполнен |
| production.orderitems | price numeric(19, 5) NOT NULL DEFAULT 0 CHECK ((price >= (0)::numeric)) | Не нул | Значение поля price заполнено. В случае нула проставляется значение 0. Проверка - price Не может быть отрицательной |
| production.orderitems | discount numeric(19, 5) NOT NULL DEFAULT 0 CHECK (((discount >= (0)::numeric) AND (discount <= price))) | Не нул | Значение поля discount заполнено. В случае нула проставляется значение 0. Проверка - discount не может быть отрицательным или больше чем price |
| production.orderitems | quantity int4 NOT NULL CHECK ((quantity > 0)) | Не нул | Значение поля заполнено. Проверка - quantity не может быть отрицательным |
| production.orderitems | CONSTRAINT orderitems_order_id_fkey FOREIGN KEY (order_id) REFERENCES production.orders(order_id) | Ключ на таблицу | В таблице production.orders должно быть аналогичное значение order_id |
| production.orderitems | CONSTRAINT orderitems_product_id_fkey FOREIGN KEY (product_id) REFERENCES production.products(id) | Ключ на таблицу | В таблице production.products должно быть аналогичное значение id впредставленное в поле orderitems.product_id |

Определение прелставленных полей:
- `Таблицы` - наименование таблицы, объект которой рассматриваете.
- `Объект` - Перечислены поля таблицы, индексы и другие ограничения и проверки, как они представлены в Базе Данных.
- `Инструмент` - тип инструмента: первичный ключ, ограничение и проверки.
- `Для чего используется` - здесь в свободной форме описано, что инструмент делает.
