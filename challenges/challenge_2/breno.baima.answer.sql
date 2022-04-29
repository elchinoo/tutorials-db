with sales as (
select distinct s.shop_name, s.shop_city , to_char(c.cart_date, 'Day') as day_week, extract (isodow from c.cart_date) as day_week_number
     , sum((cp.cprod_value*cp.cprod_quantity)) over (partition by s.shop_id, to_char(c.cart_date, 'Day')) as t_sales_weekday_by_shop
     , sum((cp.cprod_value*cp.cprod_quantity)) over (partition by s.shop_id) as t_sales_by_shop
     , sum((cp.cprod_value*cp.cprod_quantity)) over (partition by to_char(c.cart_date, 'Day')) as t_sales_weekday_by_chain
     , sum((cp.cprod_value*cp.cprod_quantity)) over () as t_sales_by_chain
  from shop s 
  join cart c on c.shop_id = s.shop_id
  join cart_product cp on cp.cart_id = c.cart_id 
  join product p on p.prod_id = cp.prod_id
 where c.cart_is_finished
 order by 1, 2, day_week_number
)
select shop_name, shop_city, day_week
      , t_sales_weekday_by_shop
      , t_sales_by_shop
      , ((t_sales_weekday_by_shop/t_sales_by_shop) * 100)::numeric(5,2) as perc_week_x_shop
      , t_sales_weekday_by_chain
      , (t_sales_weekday_by_shop/t_sales_weekday_by_chain) as perc_shop_week_x_week_general
      , t_sales_by_chain
      , ((t_sales_by_shop/t_sales_by_chain) * 100)::numeric(5,2) as perc_store_by_total_sales
  from sales;
