--Copyright (c) 2007 by Cisco Systems, Inc.
drop sequence cspr_certification_seq;

drop table cspr_certification;

create sequence cspr_certification_seq start with 1 nocache; 

create table cspr_certification (
  certification_id    number        not null  --sequence id
 ,image_id            number        not null  
 ,mdf_concept_id      number        not null  --fk shr_product_attr
 ,certification_name  varchar2(200) not null
 ,certification_url   varchar2(250) not null       
 ,created_by          varchar2(8)   not null
 ,created_date        date          not null
 ,adm_userid          varchar2(8)   not null
 ,adm_timestamp       date          not null
 ,adm_flag            char(1)       not null
 ,adm_comment         varchar2(100)
);

alter table cspr_certification
add (constraint  pk_certification_id
primary key (certification_id));

ALTER TABLE             cspr_certification
  ADD CONSTRAINT        uk_certification
  UNIQUE                (image_id,mdf_concept_id,certification_name);


grant all on cspr_certification_seq  to shr_rda_readonly;

grant all on cspr_certification  to shr_rda_readonly;

