select  distinct shop.shop_id, shop_name, 
	shop_city,
	CASE 
      WHEN extract(dow from cart_date)=0 THEN 'Sunday'
         WHEN extract(dow from cart_date) =1 THEN 'Monday'
         WHEN extract(dow from cart_date)=2 THEN 'Tuesday'
         WHEN extract(dow from cart_date)=3 THEN 'Wednesday'
         WHEN extract(dow from cart_date)=4 THEN 'Thursday'
         WHEN extract(dow from cart_date)=5 THEN 'Friday'
         WHEN extract(dow from cart_date)=6 THEN 'Saturday'
        end as d_week,
        sum(cprod_value*cprod_quantity) over (partition by extract(dow from cart_date), shop_name order by extract(dow from cart_date) ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as t_weekly_by_shop,
	sum(cprod_value*cprod_quantity) over (partition by shop_name order by extract(dow from cart_date) ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as t_shop,
	round((sum(cprod_value*cprod_quantity) over (partition by extract(dow from cart_date), shop_name order by extract(dow from cart_date) ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)*100) / sum(cprod_value*cprod_quantity) over (partition by shop_name order by extract(dow from cart_date) ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),2) as perc_week_x_hop,
	sum(cprod_value*cprod_quantity) over (partition by extract(dow from cart_date) order by extract(dow from cart_date) ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as t_weekly_geral,
	sum(cprod_value*cprod_quantity) over() as t_geral ,	
	round((sum(cprod_value*cprod_quantity) over (partition by extract(dow from cart_date), shop_name order by extract(dow from cart_date) ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) *100) / sum(cprod_value*cprod_quantity) over(),2) as perc_shop_week_x_week_geral,
	round((sum(cprod_value*cprod_quantity) over (partition by shop_name order by extract(dow from cart_date) ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)*100) / sum(cprod_value*cprod_quantity) over(),2) as perc_shop_x_geral	

  from shop,
	cart,
	cart_product 
 where shop.shop_id = cart.shop_id	
   and cart_product.cart_id = cart.cart_id
   and cart_is_finished = true
order by shop.shop_id 