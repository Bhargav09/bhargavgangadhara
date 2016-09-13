--Copyright (c) 2004 by Cisco Systems, Inc.

CREATE TABLE SHR_PLATFORM_OS_TYPE ( 
  PLATFORM_OS_TYPE_ID      NUMBER        NOT NULL, 
  INDIVIDUAL_PLATFORM_ID   NUMBER        NOT NULL, 
  OS_TYPE_ID               NUMBER        NOT NULL, 
  ADM_TIMESTAMP            DATE          NOT NULL, 
  ADM_USERID               VARCHAR2 (20)  NOT NULL, 
  ADM_FLAG                 CHAR (1)      NOT NULL, 
  ADM_COMMENT              VARCHAR2 (50), 
  CREATED_BY               VARCHAR2 (20)  NOT NULL, 
  CREATED_DATE             DATE          NOT NULL)
  
CREATE SEQUENCE SHR_PLATFORM_OS_TYPE_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;
  
ALTER TABLE shr_platform_os_type
ADD CONSTRAINT UK_SHR_PLATFORM_OS_TYPE
UNIQUE(INDIVIDUAL_PLATFORM_ID,OS_TYPE_ID)

ALTER TABLE shr_platform_os_type
ADD CONSTRAINT PK_SHR_PLATFORM_OS_TYPE_ID
PRIMARY KEY(PLATFORM_OS_TYPE_ID)

ALTER TABLE shr_platform_os_type
ADD CONSTRAINT FK_SHR_PLATFORM_OS_TYPE_PLT_ID
FOREIGN KEY(INDIVIDUAL_PLATFORM_ID)
REFERENCES SHR_INDIVIDUAL_PLATFORM(INDIVIDUAL_PLATFORM_ID)

ALTER TABLE shr_platform_os_type
ADD CONSTRAINT  FK_SHR_PLATFORM_OS_TYPE_ID
FOREIGN KEY(OS_TYPE_ID)
REFERENCES SHR_OS_TYPE(OS_TYPE_ID)

INSERT INTO SHR_PLATFORM_OS_TYPE
   (PLATFORM_OS_TYPE_ID 
    ,INDIVIDUAL_PLATFORM_ID 
    ,OS_TYPE_ID 
    ,ADM_TIMESTAMP 
    ,ADM_USERID 
    ,ADM_FLAG 
    ,ADM_COMMENT 
    ,CREATED_BY 
    ,CREATED_DATE
	)
SELECT SHR_PLATFORM_OS_TYPE_SEQ.NEXTVAL
          ,INDIVIDUAL_PLATFORM_ID
		  ,1
		  ,SYSDATE
		  ,'MIGRATED'
		  , 'V'
		  ,'POPULATED FROM SHR_INDIVIDUAL_PLATFORM TABLE'
		  ,'MIGRATED'
		  ,SYSDATE
FROM SHR_INDIVIDUAL_PLATFORM

update shr_pcode_group set pcode_group_name='IOS_ALL'
where pcode_group_name like 'ALL'




