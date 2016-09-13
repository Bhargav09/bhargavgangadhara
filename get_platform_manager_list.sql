/************************************************************************************
   This procedure is created to get list of platform managers based on the image and platforms for
   eGenie/OPUS submission from SPRIT. Along with the image and PIDs this data is also submitted to eGenie/OPUS
  
   Auther:Selvaraj Aran(aselvara)

   LastUpdateddate:September 23,2010
   Modification History:

    Copyright (c) 2007-2010 by Cisco Systems, Inc.
****************************************************************************************/
CREATE OR REPLACE FUNCTION SHR_RDA.GET_PLATFORM_MANAGER_LIST ( p_image_id in NUMBER )
RETURN VARCHAR2
is
v_platform_manager_list varchar2(100) :=null;
BEGIN
    FOR record IN
        (select   distinct      platform_role_userid
                  from           shr_platform_role        spr
                                ,shr_individual_platform sip
                                ,shr_platform_image      spi
                                ,shr_image                si
                  where spr.individual_platform_id=sip.individual_platform_id
                  and   sip.individual_platform_id=spi.individual_platform_id
                  and   spi.image_id=si.image_id
                  and   spi.image_id = p_image_id
                  and spr.adm_flag='V'            
                  and spr.role_id=1
        )
    LOOP
         if(v_platform_manager_list is not null) then
         begin
         v_platform_manager_list:=v_platform_manager_list||','||record.platform_role_userid;
         end;
         else
         begin
         v_platform_manager_list:=record.platform_role_userid;
         end;
         end if;
    END LOOP;
    return v_platform_manager_list;
END GET_PLATFORM_MANAGER_LIST;
