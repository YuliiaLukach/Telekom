--TASK 1--
--Write query which will show our customers with contacts and orders (all columns)contacts

select *
from customers cus 
join contacts con on con.customer_id = cus.customer_id
left join orders ord on ord.customer_id = cus.customer_id


--TASK 2--
-- There is  suspision that some orders were wrongly inserted more times. Check if there are any duplicated orders. If so, return unique duplicates with the following details:
-- first name, last name, email, order id and item

select distinct cus.first_name, cus.last_name, con.email, ord.order_id, ord.item, count(*) as 'The number of records'
from customers cus 
join contacts con on con.customer_id = cus.customer_id
left join orders ord on ord.customer_id = cus.customer_id
group by cus.first_name, cus.last_name, con.email, ord.order_id

--TASK 3-	
-- As you found out, there are some duplicated order which are incorrect, adjust query so it does following:
-- Show first name, last name, email, order id and item
-- Does not show duplicates
-- Order result by customer last name

select distinct cus.first_name, cus.last_name, con.email, ord.order_id, ord.item
from customers cus 
join contacts con on con.customer_id = cus.customer_id
left join orders ord on ord.customer_id = cus.customer_id
order by cus.last_name

--TASK 4--
--Our company distinguishes orders to sizes by value like so:
--order with value less or equal to 25 euro is marked as SMALL
--order with value more than 25 euro but less or equal to 100 euro is marked as MEDIUM
--order with value more than 100 euro is marked as BIG
--Write query which shows only three columns: full_name (first and last name divided by space), order_id and order_size
--Make sure the duplicated values are not shown
--Sort by order ID (ascending)

select distinct cus.first_name|| ' ' ||cus.last_name  as full_name 
		, ord.order_id
		, case when ord.order_value <= 25 then 'Small'
        		when ord.order_value > 25 and ord.order_value <= 100 then 'MEDIUM'
                when ord.order_value > 100 then 'BIG'
          end as Order_size
from customers cus 
left join orders ord on ord.customer_id = cus.customer_id
where ord.order_id is not NULL

--TASK 5--
-- Show all items from orders table which containt in their name 'ea' or start with 'Key'

select item
from orders
where item like '%ea%' or item like 'Key%'

--TASK 6--
-- Please find out if some customer was referred by already existing customer
-- Return results in following format "Customer Last name Customer First name" "Last name First name of customer who recomended the new customer"
-- Sort/Order by customer last name (ascending)

select cus.last_name|| ' ' ||cus.first_name as Current_customer
		, ref.last_name|| ' ' ||ref.first_name as Referred_by_customer
from customers cus
join customers ref on cus.referred_by_id = ref.customer_id
order by 1