/************************************************************************************
 File: alter_sprit_properties.sql
 Description: The is altered to accommodate property name for IP Central UserId
 Auther:Selvaraj Aran(aselvara)
 Date  :08/31/2010
 Copyright (c) 2010 by Cisco Systems, Inc.
 All rights reserved.A
*************************************************************/
alter table sprit_properties
modify PROPERTY_NAME varchar2(30);

