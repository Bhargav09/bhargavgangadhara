-------------------------------------------------------------------
-- Copyright (c) 2006-2007 by cisco Systems, Inc. All rights reserved.
--
-- Funciton: create shr_issu_image table for SPRIT-ISSU implementation.
--
-- Created by :   nadialee 
-- Created at:    Aug 2006  
-------------------------------------------------------------------

drop table shr_issu_image;

drop sequence shr_issu_image_seq; 

create sequence shr_issu_image_seq increment by 1 start with 1 nocycle nocache;

create table shr_issu_image (
    issu_image_id       number,
    issu_image_name     varchar2(84) not null,
    os_type_id          number       not null,
    adm_created_date    date         not null,
    adm_created_by      varchar2(20) not null,
    adm_timestamp       date         not null,
    adm_userid          varchar2(20) not null,
    adm_flag            varchar2(1)  not null,
    adm_comment         varchar2(50) );

alter table shr_issu_image add constraint pk_shr_issu_image primary key (issu_image_id);

alter table shr_issu_image add constraint fk_shr_issu_image_os_type_id foreign key( os_type_id ) references shr_os_type( os_type_id );

create unique index uk_shr_issu_image on shr_issu_image (issu_image_name, os_type_id );

