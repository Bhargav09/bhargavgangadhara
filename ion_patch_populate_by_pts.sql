-- --Copyright (c) 2006-2008 by Cisco Systems, Inc. -- kdharmal

CREATE OR REPLACE PROCEDURE SHR_RDA.ION_PATCH_POPULATE_BY_PTS
   (p_buildnum          IN ION_PATCH.BUILDNUM%TYPE,
    p_patch_id          IN ION_PATCH.PATCH_ID%TYPE,
    p_tarball_id        IN ION_PATCH.TARBALL_ID%TYPE,
    p_platform_prefix   IN SHR_IMAGE_PREFIX.IMAGE_PREFIX_NAME%TYPE,
    p_tarball_size      IN ION_PATCH.TARBALL_SIZE%TYPE,
    p_is_crypto         IN ION_PATCH.IS_CRYPTO%TYPE,
    p_release_number    IN VARCHAR2,
    p_user_id           IN ION_PATCH.CREATED_BY%TYPE,
    p_comment           IN VARCHAR2,
    p_patchtype         IN VARCHAR2,
    p_headline             IN VARCHAR2,
    p_image_src_location IN VARCHAR2,
    p_prod_type         IN ION_PATCH.PROD_TYPE%TYPE,
    p_outmessage        OUT VARCHAR2      )     IS

    v_release_number_id NUMBER;
    v_image_prefix_id   NUMBER;
 BEGIN

    SELECT release_number_id INTO v_release_number_id
    FROM shr_release_number a
        ,shr_major_release  b
    WHERE b.major_release_id     = a.major_release_id
    AND   b.major_release_number||'('||a.z||a.p||')'||a.a||a.o =p_release_number
    AND   a.release_type_id in(1,5);

    SELECT image_prefix_id INTO v_image_prefix_id
    FROM shr_image_prefix
    WHERE image_prefix_name=p_platform_prefix;

--'12.2(8)T2'

 INSERT INTO ION_PATCH(
         IMAGE_ID
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
        , IMAGE_SOURCE_LOCATION
        , PROD_TYPE
      )
  VALUES(
           SHR_IMAGE_SEQ.nextval
        ,SHR_ION_PATCH_ID_SEQ.nextval
        ,v_release_number_id
        ,p_buildnum
        ,p_patch_id
        ,p_tarball_id
        ,v_image_prefix_id   -- Image prefix name is called as platform_prefix in PTS.
        ,p_headline             -- Image Description--FEATURE_DESCRIPTION
        ,p_tarball_size        --TARBALL_SIZE
        ,NULL                   --MD5CHKSUM
        ,'Y'                    --IS_GOING_TO_CCO
        ,'N'                    --IS_POSTED_TO_CCO
        ,p_is_crypto            --IS_CRYPTO
        ,NULL                   --CCO_DATE
        ,'N'                    --IS_DEFERRED
        ,NULL                   --DEFERRAL_ID
        ,'N'                    --IS_SOFTWARE_ADVISORY
        ,NULL                   --SOFTWARE_ADVISORY_ID
        ,SYSDATE                --ADM_TIMESTAMP
        ,p_user_id               --ADM_USERID
        ,'V'                    --ADM_FLAG
        ,p_comment              --ADM_COMMENT
        ,SYSDATE                --CREATED_DATE
        ,p_user_id               --CREATED_BY
        , p_patchtype            -- PATCH_TYPE
        ,p_image_src_location     -- IMAGE_SOURCE_LOCATION
        ,p_prod_type            -- IMAGE type PROD|DEMO
);

     p_outmessage := 'Success';

     EXCEPTION

     WHEN NO_DATA_FOUND THEN
      BEGIN
         p_outmessage := substr(sqlerrm,1,512);
         --RAISE_APPLICATION_ERROR(-20001, p_outmessage);
      END;

     WHEN OTHERS THEN
      BEGIN
         p_outmessage := substr(sqlerrm,1,512);
         --RAISE_APPLICATION_ERROR(-20001, p_outmessage);
      END;

END;
/