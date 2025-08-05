select
    midw.listing_id   标ID
    ,midw.user_id     用户ID
    ,midw.bid_sale_id 销售ID

    ,sif.job_name     职务
    ,sif.team         小组
    ,sif.branch       分行

    ,cast(sif.reg_time as date)         入职日期
    ,cast(sif.leave_time as date)       离职日期

    ,case   when cast(sif.reg_time as date) < '2020-06-01' and (cast(sif.leave_time as date) > '2020-06-01' or cast(sif.leave_time as date) is null)
            then '在职'
            when cast(sif.reg_time as date) < '2020-06-01'and cast(sif.leave_time as date) < '2020-06-01'
            then '离职'
            when cast(sif.reg_time as date) between '2020-06-01' and '2020-06-30'
            then '在职'
            when cast(sif.reg_time as date) > '2020-06-30'
            then '未入职'
            else '未知' end 6月份在职情况
    ,substring(midw.fullbid_date,1,10)   满标日期
    ,substring(midw.fullbid_date,1,7)   满标月份
    ,midw.amount                        amount
    ,case when cast(midw.cre_dt as date) <= date_add(cast(uif.cmdat_mmv_suc_ft as date),interval 2 month) then midw.amount
          else 0 end  amount_2ms

    ,midw.months                        产品期限

    from edw.dsx_listing_info midw
    left join edw_s.dsx_user_info_daily uif
    on midw.user_id = uif.user_id
    left join edw_s.dsx_saler_info sif
    on midw.bid_sale_id = sif.sale_id #发标销售信息

    where midw.fullbid_date != 'null'
    and substring(midw.fullbid_date,1,7) = '2020-06'
    and uif.cmdat_mmv_suc_ft != 'null'
    and cast(uif.cmdat_mmv_suc_ft as date) <= '2020-06-30'
    and sif.branch not in ('测试分行','null')
    and midw.bid_sale_id != 0
    #order by midw.fullbid_date



    #注册流量
    # 注册流量统计
select
    uif.user_id 用户ID,
    1 注册用户数,
    uif.cmdnum_bind_sale_id_ft 销售ID,
    sif.job_name 职务,
    sif.team 小组,
    sif.branch 分行
from edw.s_dsx_user_info_daily uif
left join edw.s_dsx_saler_info sif 
    on uif.cmdnum_bind_sale_id_ft = sif.sale_id  # 发标销售信息
where substring(uif.cmdat_reg,1,7) = '2020-06'
    and uif.cmdnum_bind_sale_id_ft != 0
    and sif.branch not in ('测试分行', null);