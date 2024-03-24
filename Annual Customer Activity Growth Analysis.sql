
--- 1  Menampilkan rata-rata jumlah customer aktif bulanan (monthly active user) untuk setiap tahun

select year,round(avg(total_customer_baru),1) as rata_rata_customer_aktif from (select 
			EXTRACT(YEAR FROM CAST(od.order_purchase_timestamp AS TIMESTAMP)) AS year,
			EXTRACT(month FROM CAST(od.order_purchase_timestamp AS TIMESTAMP)) AS month,
			count (distinct cd.customer_unique_id) as total_customer_baru
			from orders_dataset od 
			join customers_dataset cd on od.customer_id  = cd.customer_id
			group by 1,2) as j

group by 1
;

--2 Menampilkan jumlah customer baru pada masing-masing tahun
select year, count(customer_unique_id) as total_customer_baru
from ( select 
		min(extract (year from cast(od.order_purchase_timestamp as timestamp))) as year,
		cd.customer_unique_id
		from orders_dataset od 
		join customers_dataset cd on od.customer_id = cd.customer_id 
		group by 2
) as f
group by 1
order by 1

--3 Menampilkan jumlah customer repeat order pada masing-masing tahun
select year,count(customer_unique_id) as jumlah_repeat_order from (
				select 
				extract(year from cast(od.order_purchase_timestamp as timestamp)) as year,
				cd.customer_unique_id, 
				count(od.order_id) as jumlah_order
				from customers_dataset cd 
				join orders_dataset od on cd.customer_id = od.customer_id 
				group by 1,2
				having count(od.order_id) > 1 ) as g
				
group by 1;

--4 Menampilkan rata-rata jumlah order yang dilakukan customer untuk masing-masing tahun
select year, round(avg(jumlah),3) as rata_jumlah_order from ( select
				extract(year from cast(od.order_purchase_timestamp as timestamp)) as year,
				cd.customer_unique_id,
				count(od.order_id) as jumlah
				from orders_dataset od 
				join customers_dataset cd on od.customer_id = cd.customer_id 
				group by 1,2)as h
				group by 1

-- 5 menggabungkan ke 4 metric diatas
with b as (select year,round(avg(total_customer_baru),1) as rata_rata_customer_aktif from (select 
			EXTRACT(YEAR FROM CAST(od.order_purchase_timestamp AS TIMESTAMP)) AS year,
			EXTRACT(month FROM CAST(od.order_purchase_timestamp AS TIMESTAMP)) AS month,
			count (distinct cd.customer_unique_id) as total_customer_baru
			from orders_dataset od 
			join customers_dataset cd on od.customer_id  = cd.customer_id
			group by 1,2) as j

group by 1
),

 k as (select year, count(customer_unique_id) as total_customer_baru
from ( select 
		min(extract (year from cast(od.order_purchase_timestamp as timestamp))) as year,
		cd.customer_unique_id
		from orders_dataset od 
		join customers_dataset cd on od.customer_id = cd.customer_id 
		group by 2
) as f
group by 1),

 s as(select year,count(customer_unique_id) as jumlah_repeat_order from (
				select 
				extract(year from cast(od.order_purchase_timestamp as timestamp)) as year,
				cd.customer_unique_id, 
				count(od.order_id) as jumlah_order
				from customers_dataset cd 
				join orders_dataset od on cd.customer_id = od.customer_id 
				group by 1,2
				having count(od.order_id) > 1 ) as g
				
group by 1
),

x as (select year, round(avg(jumlah),3) as rata_jumlah_order from ( select
				extract(year from cast(od.order_purchase_timestamp as timestamp)) as year,
				cd.customer_unique_id,
				count(od.order_id) as jumlah
				from orders_dataset od 
				join customers_dataset cd on od.customer_id = cd.customer_id 
				group by 1,2)as h
				group by 1)

SELECT 
    b.year,
    b.rata_rata_customer_aktif,
    k.total_customer_baru,
    s.jumlah_repeat_order,
    x.rata_jumlah_order
from b 
JOIN k ON b.year = k.year
JOIN s ON b.year = s.year
JOIN x ON b.year = x.year;	
				