--- 1 Membuat tabel yang berisi informasi pendapatan/revenue perusahaan total untuk masing-masing tahun 
--(Hint: Revenue adalah harga barang dan juga biaya kirim. 
--Pastikan juga melakukan filtering terhadap order status yang tepat untuk menghitung pendapatan)

 create table total_revenue_per_year as select 
	extract(year from cast(od.order_purchase_timestamp as timestamp)) as year,
	sum(oid2.price + oid2.freight_value ) as revenue
	from orders_dataset od 
	join order_items_dataset oid2 on od.order_id = oid2.order_id 
	where od.order_status = 'delivered'
	group by 1
	order by 1
	

-- 2 Membuat tabel yang berisi informasi jumlah cancel order total untuk masing-masing tahun 
--(Hint: Perhatikan filtering terhadap order status yang tepat untuk menghitung jumlah cancel order)
create table total_cancel_order1 as	select 
	extract(year from cast(od.order_purchase_timestamp as timestamp)) as year,
	count(od.order_status) as total_canceled_order
	from orders_dataset od 
	join order_items_dataset oid2 on od.order_id = oid2.order_id 
	where od.order_status = 'canceled'
	group by 1
	order by 1

--3) Membuat tabel yang berisi nama kategori produk yang memberikan pendapatan total tertinggi untuk masing-masing tahun
create table most_revenue_product1 as SELECT *
FROM (
    SELECT
        product_category_name,
        SUM(oid2.price + oid2.freight_value) AS revenue_product,
        EXTRACT(YEAR FROM CAST(od.order_purchase_timestamp AS TIMESTAMP)) AS year,
        RANK() OVER (PARTITION BY EXTRACT(YEAR FROM CAST(od.order_purchase_timestamp AS TIMESTAMP)) ORDER BY SUM(oid2.price + oid2.freight_value) DESC) AS ranking
    FROM
        order_items_dataset oid2
        JOIN orders_dataset od ON oid2.order_id = od.order_id
        JOIN product_dataset pd2 ON oid2.product_id = pd2.product_id
    WHERE
        od.order_status = 'delivered'
    GROUP BY
        1, 3
) AS sub
where ranking = 1

---4 Membuat tabel yang berisi nama kategori produk yang memiliki jumlah cancel order terbanyak untuk masing-masing tahun
create table highest_canceled_product_per_year1 as
SELECT *
FROM (
    SELECT
        product_category_name as product_canceled,
        count(od.order_id) as total_canceled_product,
        EXTRACT(YEAR FROM CAST(od.order_purchase_timestamp AS TIMESTAMP)) AS year,
        RANK() OVER (PARTITION BY EXTRACT(YEAR FROM CAST(od.order_purchase_timestamp AS TIMESTAMP)) ORDER BY count(od.order_id) DESC) AS ranking
    FROM
        order_items_dataset oid2
        JOIN orders_dataset od ON oid2.order_id = od.order_id
        JOIN product_dataset pd2 ON oid2.product_id = pd2.product_id
    WHERE
        od.order_status = 'canceled'
    GROUP BY
        1, 3
) AS sub
where ranking = 1

--- 5 menggabungkan semua tabel

select 
	tr.year,
	tr.revenue,
	tc.total_canceled_order,
	mr.product_category_name,
	mr.revenue_product,
	hc.product_canceled,
	hc.total_canceled_product
	from total_revenue_per_year tr 
	join total_cancel_order1 tc on tr.year = tc.year
	join most_revenue_product1 mr on tr.year = mr.year
	join highest_canceled_product_per_year1 hc on tr.year = hc.year
	
	