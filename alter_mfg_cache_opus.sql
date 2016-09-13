/************************************************************************************
 File: alter_egenie_changes.sql
 Description: These tables are altered to accommodate the changes that eGenie requires
 Auther:Selvaraj Aran(aselvara)
 Date  :08/24/2010
 Copyright (c) 2010 by Cisco Systems, Inc.
 All rights reserved.A
*************************************************************/
alter table mfg_cache_opus
add (PARENT_PRODUCT_NAME     VARCHAR2(18 BYTE) );

alter table mfg_cache_opus
add (PLATFORM_MANAGER_LIST     VARCHAR2(100 BYTE) );


alter table mfg_cache_opus
add release_manager_id varchar2(8) null;

