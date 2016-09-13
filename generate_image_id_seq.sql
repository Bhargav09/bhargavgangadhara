--Copyright (c) 2006 by Cisco Systems, Inc. -kdharmal
--Generate image_id seq in ION_PATCH table.
--Modified Procedure ION_PATCH_POPULATE_BY_PTS added IMAGE_ID Seq.
-- Add p_headline Parameter and insert values for p_headline

 p_comment           IN VARCHAR2,
 p_patchtype         IN VARCHAR2,
 p_headline 	     IN VARCHAR2,  --- Need to add 
 p_outmessage        OUT VARCHAR2      )     IS



 INSERT INTO ION_PATCH(
 		IMAGE_ID --- Need to add 
	,ION_PATCH_SEQ_ID
        ,RELEASE_NUMBER_ID
        ,BUILDNUM
        ,PATCH_ID
        ,TARBALL_ID
        ,IMAGE_PREFIX_ID
        ,FEATURE_DESCRIPTION
        ,TARBALL_SIZE
        ,MD5CHKSUM
        ,IS_GOING_TO_CCO
        ,IS_POSTED_TO_CCO
        ,IS_CRYPTO
        ,CCO_DATE
        ,IS_DEFERRED
        ,DEFERRAL_ID
        ,IS_SOFTWARE_ADVISORY
        ,SOFTWARE_ADVISORY_ID
        ,ADM_TIMESTAMP
        ,ADM_USERID
        ,ADM_FLAG
        ,ADM_COMMENT
        ,CREATED_DATE
        ,CREATED_BY
	, PATCH_TYPE
	  )
  VALUES(
  		 
		 SHR_IMAGE_SEQ.nextval  ---- Need to add 
		 ,p_headline			 -- Image Description--FEATURE_DESCRIPTION  --- Need to add 

		

