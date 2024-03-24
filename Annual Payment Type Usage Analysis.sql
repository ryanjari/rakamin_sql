--1. Menampilkan jumlah penggunaan masing-masing tipe pembayaran secara all time diurutkan dari yang terfavorit
select payment_type, count(*) as total_user from order_payments_dataset opd 
group by 1
order by 2 desc;


--2 .Menampilkan detail informasi jumlah penggunaan masing-masing tipe pembayaran untuk setiap tahun

select payment_type,
    sum(case when year = 2016 then total_user else 0 end) as "2016",
    sum(case when year = 2017 then total_user else 0 end) as "2017",
    sum(case when year = 2018 then total_user else 0 end) as "2018",
    sum(total_user) as total_payment_user
from (
    select 
        extract(year from cast(od.order_purchase_timestamp as timestamp)) as year,
        opd.payment_type,
        count(*) as total_user
    from order_payments_dataset opd 
    join orders_dataset od on opd.order_id = od.order_id
    group by 1, 2
) as g
group by 1;
