#6月份2ms销售绩效计算

17、公司需要计算6月份的销售绩效，需要求出所有销售的职务、小组、分行、入职日期、离职日期、6月份在职情况、
满标月份、成交额（别名amount）、绩效成交额（别名amount_2ms）、以及2ms绩效，按最终绩效降序排序

select
2msjx.销售ID
,2msjx.职务
,2msjx.小组
,2msjx.分行
,2msjx.入职日期
,2msjx.离职日期
,2msjx.6月份在职情况

,2msjx.满标月份
,sum(2msjx.amount) amount
,sum(2msjx.amount_2ms) amount_2ms

,sum(case when 2msjx.产品期限 = 1  then 0*2msjx.amount_2ms
	      when 2msjx.产品期限 = 3  then 0.005*2msjx.amount_2ms
	      when 2msjx.产品期限 = 6  then 0.015*2msjx.amount_2ms
	      when 2msjx.产品期限 = 9  then 0.018*2msjx.amount_2ms
	      when 2msjx.产品期限 = 12 then 0.02*2msjx.amount_2ms
	      when 2msjx.产品期限 = 18 then 0.02*2msjx.amount_2ms
		  else -1 end
	) 2ms绩效

from
(
	select
	midw.listing_id   标ID
	,midw.user_id     用户ID
	,midw.bid_sale_id 销售ID

	,sif.job_name     职务
	,sif.team         小组
	,sif.branch       分行

	,cast(sif.reg_time as date)         入职日期
	,cast(sif.leave_time as date)       离职日期

	,case 	when cast(sif.reg_time as date) < '2020-06-01' and (cast(sif.leave_time as date) > '2020-06-01' or cast(sif.leave_time as date) is null)
		  	then '在职'
		  	when cast(sif.reg_time as date) < '2020-06-01'and cast(sif.leave_time as date) < '2020-06-01'
		  	then '离职'
			when cast(sif.reg_time as date) between '2020-06-01' and '2020-06-30'
			then '在职'
			when cast(sif.reg_time as date) > '2020-06-30'
			then '未入职'
			else '未知' end 6月份在职情况

    ,substring(midw.fullbid_date,1,7)   满标月份
    ,midw.amount       					amount
	,case when cast(midw.cre_dt as date) <= date_add(cast(uif.cmdat_mmv_suc_ft as date),interval 2 month) then midw.amount
	  	  else 0 end  amount_2ms

    ,midw.months       					产品期限

	from edw.dsx_listing_info midw
	left join edw_s.dsx_user_info_daily uif
	on midw.user_id = uif.user_id
	left join edw_s.dsx_saler_info sif
	on midw.bid_sale_id = sif.sale_id #发标销售信息

	where midw.fullbid_date != 'null'
	and substring(midw.fullbid_date,1,7) = '2020-06'
	and uif.cmdat_mmv_suc_ft != 'null'
    and cast(uif.cmdat_mmv_suc_ft as date) <= '2020-06-30'
	#order by midw.fullbid_date
) 2msjx
group by 1,2,3,4,5,6,7,8
order by 10 desc