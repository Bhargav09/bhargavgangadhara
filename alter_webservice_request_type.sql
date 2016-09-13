/************************************************************************************
 File: alter_webservice_request_type.sql
 Description: This changes is made to accommodate teh IP Central webservice name

 Auther:Selvaraj Aran(aselvara)
 Date  :08/24/2010
 Copyright (c) 2010 by Cisco Systems, Inc.
 All rights reserved.A
***************************************************************************************/

alter table webservice_request_type
modify request_type_name varchar(30);

