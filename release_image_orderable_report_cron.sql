/*******************************************************************
-- Copyright (c) 2006-2007 by cisco Systems, Inc. All rights reserved.
-- This sql script is created for CSCsi25260 sprit Enhance Product code orderable report performance
-- Created by :   Selvaraj Aran(aselvara@cisco.com)
-- Created on:    April 5 2007
*******************************************************************/

CREATE INDEX IDX_REL_ORDERABLE_REPORT
ON RELEASE_ORDERABLE_REPORT(RELEASE_NUMBER);

drop table local_cmf_pt_group_types;

create  table local_cmf_pt_group_types
as select * from cmf_pt_group_types@sj;

CREATE INDEX IDX_local_cmf_group
ON local_cmf_pt_group_types(group_id);

drop table local_cmf_pt_items;

create table local_cmf_pt_items
as select * from cmf_pt_items@sj ;

CREATE INDEX IDX_local_cmf_group_items
ON local_cmf_pt_items(group_id);

CREATE INDEX IDX_local_cmf_group_version
ON local_cmf_pt_items(image_version);

CREATE INDEX IDX_local_cmf_pt_item_invent
ON local_cmf_pt_items(inventory_item_id);

CREATE INDEX IDX_local_cmf_pt_item_name
ON local_cmf_pt_items(item_name);


drop table local_mtl_pending_item_status;

create table local_mtl_pending_item_status
as select *  from mtl_pending_item_status@sj;

CREATE INDEX IDX_local_mtl_pending_item
ON local_mtl_pending_item_status(inventory_item_id);

drop table local_mtl_system_items_b ;

create table local_mtl_system_items_b
as select segment1 ,inventory_item_status_code , organization_id,inventory_item_id from mtl_system_items_b@sj  

CREATE INDEX IDX_local_mtl_system_items_b
ON local_mtl_system_items_b(inventory_item_id);

CREATE INDEX IDX_local_mtl_system_items_b
ON local_mtl_system_items_b(segment1);


Insert into RELEASE_ORDERABLE_REPORT (
  RELEASE_NUMBER_ID 
 ,RELEASE_NUMBER 
 ,RELEASE_PM 
 ,OPUS_SUBMISSION_DATE 
 ,OPUS_APPROVAL_DATE 
 ,CCO_DATE 
 ,ECO_WRITEBACK 
 ,FINANCE_APPROVAL_DATE 
 ,READY_FOR_ORDERABILITY_DATE 
 ,ORDERABLE_PERCENTAGE 
 ,DATE_100PERCENT_PDT_ORDERABLE 
 ,PERCENTAGE_PRICE_TOOL_VISIBLE 
 ,DATE_100PERCENT_PRICE_TOOL_VIS
 ,CREATED_BY 
 ,CREATED_DATE 
 ,ADM_USERID 
 ,ADM_TIMESTAMP 
 ,ADM_FLAG 
 ,ADM_COMMENT 
  )
select  release_number_id
       ,Release_Number
       ,Release_PM
       ,opus_submission_date
       ,opus_approval_date
       ,cco_date
       ,eco_writeback
       ,finance_approval_date
       ,least(nvl(cco_date,sysdate),nvl(eco_writeback,sysdate),nvl(finance_approval_date,sysdate)) ready_for_orderability_date
       ,orderable_percentage
       ,DATE_100PERCENT_PDT_ORDERABLE 
       ,PERCENTAGE_PRICE_TOOL_VISIBLE 
       ,DATE_100PERCENT_PRICE_TOOL_VIS
       ,CREATED_BY 
       ,CREATED_DATE 
       ,ADM_USERID 
       ,ADM_TIMESTAMP 
       ,ADM_FLAG 
       ,ADM_COMMENT 
from(
select distinct srn.release_number_id                                    Release_number_id
         ,smr.major_release_number||'('||srn.z||srn.p||')'||srn.a||srn.o Release_Number
         ,m.userid                                                       Release_PM
        ,(select srm.actual_date
            from shr_rel_ms srm,
                shr_rel_ms_member srmm,
                shr_ms_const ms
            where srm.rel_ms_id=srmm.rel_ms_id
            and srm.ms_const_id= ms.ms_const_id
            and ms_name='OPUS'
            and rel_id=srn.release_number_id
		  )                                                      opus_submission_date
        ,(select min(process_date)
           from mfg_cache_opus
           where version=smr.major_release_number||'('||srn.z||srn.p||')'||srn.a||srn.o
           and process_date is not null
		  )                                                      opus_approval_Date
        ,(select srm.actual_date
            from shr_rel_ms          srm,
                shr_rel_ms_member   srmm,
                shr_ms_const         ms
            where srm.rel_ms_id=srmm.rel_ms_id
            and srm.ms_const_id= ms.ms_const_id
            and ms_name='CCO FCS'
            and rel_id=srn.release_number_id
		  )                                                      CCO_DATE
         ,(select srm.actual_date
            from  shr_rel_ms             srm,
                  shr_rel_ms_member     srmm,
                  shr_ms_const            ms
            where srm.rel_ms_id=srmm.rel_ms_id
            and srm.ms_const_id= ms.ms_const_id
            and ms_name='ECO Writeback'
            and rel_id=srn.release_number_id
	   )                                                             eco_writeback
          ,null                                                      finance_approval_date
          ,round(r.orderable_percentage,2)                           orderable_percentage
          ,null                                                      DATE_100PERCENT_PDT_ORDERABLE 
          ,null                                                      PERCENTAGE_PRICE_TOOL_VISIBLE 
          ,null                                                      DATE_100PERCENT_PRICE_TOOL_VIS
          ,'cron'                                                    CREATED_BY 
	  ,sysdate                                                       CREATED_DATE 
	  ,'cron'                                                        ADM_USERID 
	  ,sysdate                                                       ADM_TIMESTAMP 
	  ,'V'                                                           ADM_FLAG 
          ,'Inserted by cron job'                                    ADM_COMMENT 
from      shr_major_release   smr
         ,shr_release_number  srn
         ,release_member       rm
         ,member                m
         ,shr_image            si
         ,release               r
where smr.major_release_id=srn.major_release_id
and   srn.release_number_id= rm.release_id(+)
and   r.release_id=srn.release_number_id
and   rm.member_id =m.member_id
and   rm.owner_flag='Y'
and   srn.release_number_id = si.release_number_id
and   si.adm_flag='V'
and   smr.adm_flag='V'
and   srn.adm_flag='V'
and   srn.release_number_id not in(select release_number_id from RELEASE_ORDERABLE_REPORT)
)
where  cco_date is not null;

commit;


Begin
  Declare
  noOfPcodeVisibleInPriceList     Number;
  pcodeToBeVisibleInPriceList     Number;
  vpercentage_price_tool_visible  Number;
  vdate_100percent_price_tool_vi  date;
  noOfPcodeOrderableInPDT         Number;
  noOfPcodeToBeOrderableInPDT     Number;
  vpercentage_PDT_orderable       Number;
  vdate_100percent_PDT_orderable  date;

Begin
--Finance approval date
For record in ( select distinct image_version,min(cpgt.last_update_date) v_finance_approval_date
                            from  local_cmf_pt_group_types cpgt
                                 ,local_cmf_pt_items      cpi
                                 ,release_orderable_report ror
                            where cpi.group_id=cpgt.group_id
                            and image_version=ror.release_number
                            and cpgt.last_update_date is not null
                            group by image_version    )
  loop
     update release_orderable_report
     set finance_approval_date=record.v_finance_approval_date
     where release_number=record.image_version;
     commit;
  end loop;

-----Percentage in PDT
 For pdtrecord in ( select release_number from release_orderable_report
                           --where release_number= '12.4(11)T'
                          )
   loop

      select count(distinct pcode)
              INTO noOfPcodeToBeOrderableInPDT
              from (select pcode_main pcode
                           from shr_pcode          sp
                           ,shr_image_feature_set       sifs
                           ,shr_image                   si
                           ,shr_release_number          srn
                           ,shr_major_release           smr
                       where smr.major_release_id=srn.major_release_id
                       and srn.release_number_id =si.release_number_id
                       and si.image_id           = sifs.image_id
                       and sifs.image_feature_set_id = sp.image_feature_set_id
                       and pcode_main_price_source in ('EPR','OPUS')
                       and (PCODE_MAIN_ORDERABLE_INSTR_ID =1 or PCODE_MAIN_ORDERABLE_INSTR_ID is null)
                       and nvl(is_deferred,'N')='N'
                      --and release_number= '12.4(11)T1'
                       and release_number=pdtrecord.release_number
                      UNION
                      select pcode_spare pcode from shr_pcode              sp
                            ,shr_image_feature_set       sifs
                            ,shr_image                   si
                            ,shr_release_number          srn
                            ,shr_major_release           smr
                      where smr.major_release_id=srn.major_release_id
                      and srn.release_number_id =si.release_number_id
                      and si.image_id           = sifs.image_id
                      and sifs.image_feature_set_id = sp.image_feature_set_id
                      and pcode_spare_price_source in ('EPR','OPUS')
                      and (PCODE_SPARE_ORDERABLE_INSTR_ID =1 or PCODE_MAIN_ORDERABLE_INSTR_ID is null)
                      and nvl(is_deferred,'N')='N'
                      --and release_number= '12.4(11)T1'
                      and release_number=pdtrecord.release_number
                      );
               
               select count(distinct segment1) INTO noOfPcodeOrderableInPDT
               from local_mtl_system_items_b msib,local_cmf_pt_items cpi
               where msib.inventory_item_id=cpi.inventory_item_id
               and segment1=item_name
               and status_code='I'
               and organization_id=1
               and inventory_item_status_code like 'ENABLE%'
               and segment1 in( select pcode_main pcode from shr_pcode    sp
                            ,shr_image_feature_set       sifs
                            ,shr_image                   si
                            ,shr_release_number          srn
                            ,shr_major_release           smr
               where smr.major_release_id=srn.major_release_id
               and srn.release_number_id =si.release_number_id
               and si.image_id           = sifs.image_id
               and sifs.image_feature_set_id = sp.image_feature_set_id
               and pcode_main_price_source in ('EPR','OPUS')
               and (PCODE_MAIN_ORDERABLE_INSTR_ID =1 or PCODE_MAIN_ORDERABLE_INSTR_ID is null)
               and nvl(is_deferred,'N')='N'
               and release_number=pdtrecord.release_number
               --and release_number= '12.4(11)T1'
               UNION
               select pcode_spare pcode from shr_pcode              sp
                            ,shr_image_feature_set       sifs
                            ,shr_image                   si
                            ,shr_release_number          srn
                            ,shr_major_release           smr
               where smr.major_release_id=srn.major_release_id
               and srn.release_number_id =si.release_number_id
               and si.image_id           = sifs.image_id
               and sifs.image_feature_set_id = sp.image_feature_set_id
               and pcode_spare_price_source in ('EPR','OPUS')
               and (PCODE_spare_ORDERABLE_INSTR_ID =1 or PCODE_spare_ORDERABLE_INSTR_ID is null)
               and nvl(is_deferred,'N')='N'
               and release_number=pdtrecord.release_number
               --and release_number= '12.4(11)T1'
        );

        if(noOfPcodeOrderableInPDT > 0 AND noOfPcodeToBeOrderableInPDT > 0) THEN
            select round((noOfPcodeOrderableInPDT/noOfPcodeToBeOrderableInPDT)*100,2)
            INTO vpercentage_PDT_orderable
            from dual;
         else
            vpercentage_PDT_orderable:=0;
         end if;

         update release_orderable_report
         set orderable_percentage=vpercentage_PDT_orderable
         where release_number=pdtrecord.release_number;

         commit;
     end loop;

--Date 100 percent PDT orderable
 For daterecord in ( select release_number, max(mpis.last_update_date) v_date100percentpdtorderable
                from  local_mtl_pending_item_status mpis
                     ,local_mtl_system_items_b      msib 
	                 ,local_cmf_pt_items            cpi
                     ,release_orderable_report     ror
                where mpis.inventory_item_id=msib.inventory_item_id
                and msib.inventory_item_id=cpi.inventory_item_id
                and cpi.image_version=ror.release_number
                and orderable_percentage>=100
                group by release_number    )
  loop
     update release_orderable_report
     set date_100percent_pdt_orderable=daterecord.v_date100percentpdtorderable
     where release_number=daterecord.release_number;
     commit;
  end loop;

--Percentage Pricing tool visible
  
  For pricelistrecord in ( select release_number from release_orderable_report
                           --where release_number= '12.4(11)T'
                          )
   loop
   
    Select count(distinct product_id) 
    INTO  noOfPcodeVisibleInPriceList
    from xxcpd_web_prod_maps_report
    where product_id in(select pcode_main from shr_pcode          sp
                            ,shr_image_feature_set       sifs
                            ,shr_image                   si
                            ,shr_release_number          srn
                            ,shr_major_release           smr
               where smr.major_release_id=srn.major_release_id
               and srn.release_number_id =si.release_number_id
               and si.image_id           = sifs.image_id
               and sifs.image_feature_set_id = sp.image_feature_set_id
               and pcode_main_price_source in ('EPR','OPUS')
               and nvl(is_deferred,'N')='N'
               --and release_number= '12.4(11)T' 
               and release_number=pricelistrecord.release_number
               UNION
               select pcode_spare from shr_pcode              sp
                            ,shr_image_feature_set       sifs
                            ,shr_image                   si
                            ,shr_release_number          srn
                            ,shr_major_release           smr
               where smr.major_release_id=srn.major_release_id
               and srn.release_number_id =si.release_number_id
               and si.image_id           = sifs.image_id
               and sifs.image_feature_set_id = sp.image_feature_set_id
               and pcode_spare_price_source in ('EPR','OPUS')
               and nvl(is_deferred,'N')='N'
               --and release_number= '12.4(11)T' 
               and release_number=pricelistrecord.release_number
               );
        SELECT count(*) 
        INTO pcodeToBeVisibleInPriceList 
        from(
               select pcode_main from shr_pcode          sp
                            ,shr_image_feature_set       sifs
                            ,shr_image                   si
                            ,shr_release_number          srn
                            ,shr_major_release           smr
               where smr.major_release_id=srn.major_release_id
               and srn.release_number_id =si.release_number_id
               and si.image_id           = sifs.image_id
               and sifs.image_feature_set_id = sp.image_feature_set_id
               and pcode_main_price_source in ('EPR','OPUS')
               and (PCODE_MAIN_ORDERABLE_INSTR_ID =1 or PCODE_MAIN_ORDERABLE_INSTR_ID is null)
               and nvl(is_deferred,'N')='N'
               and release_number=pricelistrecord.release_number
               --and release_number= '12.4(11)T' 
               UNION
               select pcode_spare from shr_pcode              sp
                            ,shr_image_feature_set       sifs
                            ,shr_image                   si
                            ,shr_release_number          srn
                            ,shr_major_release           smr
               where smr.major_release_id=srn.major_release_id
               and srn.release_number_id =si.release_number_id
               and si.image_id           = sifs.image_id
               and sifs.image_feature_set_id = sp.image_feature_set_id
               and pcode_spare_price_source in ('EPR','OPUS')
               and (PCODE_spare_ORDERABLE_INSTR_ID =1 or PCODE_spare_ORDERABLE_INSTR_ID is null)
               and nvl(is_deferred,'N')='N'
               and release_number=pricelistrecord.release_number
               --and release_number= '12.4(11)T'  
        );
        
       
         if(noOfPcodeVisibleInPriceList > 0 AND pcodeToBeVisibleInPriceList > 0) THEN
            select round((noOfPcodeVisibleInPriceList/pcodeToBeVisibleInPriceList)*100,2) 
            INTO vpercentage_price_tool_visible
            from dual;
         else
            vpercentage_price_tool_visible:=0;
         end if;
           
         update release_orderable_report
         set percentage_price_tool_visible=vpercentage_price_tool_visible
         where release_number=pricelistrecord.release_number;
       commit;
      end loop;
      
      For d100pptvrecord in (select release_number from release_orderable_report
                       where percentage_price_tool_visible >= 100
                       )
  Loop
            select max(cre_date) INTO vdate_100percent_price_tool_vi
             FROM xxcpd_web_prod_maps_report
                  where product_id in(
                  select pcode_main from shr_pcode          sp
                            ,shr_image_feature_set       sifs
                            ,shr_image                   si
                            ,shr_release_number          srn
                            ,shr_major_release           smr
                 where smr.major_release_id=srn.major_release_id
                 and srn.release_number_id =si.release_number_id
                 and si.image_id           = sifs.image_id
                 and sifs.image_feature_set_id = sp.image_feature_set_id
                 and pcode_main_price_source in ('EPR','OPUS')
                 and (PCODE_MAIN_ORDERABLE_INSTR_ID =1 or PCODE_MAIN_ORDERABLE_INSTR_ID is null)
                 and nvl(is_deferred,'N')='N'
                 and release_number= d100pptvrecord.release_number
                 --and release_number= '12.4(11)T' 
                 UNION
                 select pcode_spare from shr_pcode              sp
                            ,shr_image_feature_set       sifs
                            ,shr_image                   si
                            ,shr_release_number          srn
                            ,shr_major_release           smr
                 where smr.major_release_id=srn.major_release_id
                 and srn.release_number_id =si.release_number_id
                 and si.image_id           = sifs.image_id
                 and sifs.image_feature_set_id = sp.image_feature_set_id
                 and pcode_spare_price_source in ('EPR','OPUS')
                 and (PCODE_spare_ORDERABLE_INSTR_ID =1 or PCODE_spare_ORDERABLE_INSTR_ID is null)
                 and nvl(is_deferred,'N')='N'
                 and release_number= d100pptvrecord.release_number
                 --and release_number= '12.4(11)T'
               );
     update release_orderable_report
     set date_100percent_price_tool_vis=vdate_100percent_price_tool_vi
     where release_number=d100pptvrecord.release_number;
     commit;
  end loop;

 commit;


 End;
END;



--this is for ImageOrderable Report cron job script

drop table xxcpd_web_prod_maps_report;


create table xxcpd_web_prod_maps_report as
SELECT * --cre_date
FROM xxcpd_web_prod_maps@sjoe;

create index indx_PCODE_CREATE_DATE_QTC
on xxcpd_web_prod_maps_report(product_id);

create table local_xxcpd_orderable_products
as select * from xxcpd_orderable_products@sjoe

create index idx_local_xxcpd_orderable_prod
on local_xxcpd_orderable_products(segment1);



 Insert into pcode_orderable(
 Select --pcode_id,
        pcode,
		null,
		null
  from(
       select distinct --max(pcode_id) pcode_id,
	    pcode_main pcode 
       from shr_pcode
       where pcode_main is not null
	   --group by pcode_main
       union
       select distinct  --max(pcode_id) pcode_id,
	   pcode_spare pcode
       from shr_pcode
       where pcode_spare is not null
	   --group by pcode_spare
      )
 );

commit;


Begin
For record in (select pcode_name 
               from pcode_orderable     )
  loop			   
     update pcode_orderable 
     set in_orderable_tool =(
                         SELECT decode(count(*),0,'N','Y')
                         FROM local_xxcpd_orderable_products
                         WHERE segment1 = record.pcode_name)
	 where pcode_name=record.pcode_name;
	 commit;
     update pcode_orderable 
     set pricing_tool_visible_date = (SELECT min(cre_date)
                                   FROM xxcpd_web_prod_maps_report
                                   WHERE product_id = record.pcode_name
								   --and rownum<2
                                   )
	 where pcode_name=record.pcode_name;
	 
  commit;
  end loop;							   
End;								   	

---this is for ImageOrderable Report cron job script end here
