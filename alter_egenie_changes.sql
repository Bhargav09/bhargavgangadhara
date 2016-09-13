/************************************************************************************
 File: alter_egenie_changes.sql
 Description: These tables are altered to accommodate the changes that eGenie requires
 Auther:Selvaraj Aran(aselvara)
 Date  :08/24/2010
 Copyright (c) 2010 by Cisco Systems, Inc.
 All rights reserved.A
*************************************************************/
alter table shr_pcode
add (PARENT_PCODE_MAIN     VARCHAR2(18 BYTE),
    PARENT_PCODE_SPARE     VARCHAR2(18 BYTE));
