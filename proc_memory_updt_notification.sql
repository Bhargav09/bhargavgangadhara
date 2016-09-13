--Copyright (c) 2004 by Cisco Systems, Inc.
/*
Procedure name: PROC_MEMORY_UPDT_NOTIFICATION
Description   : This stored procedure is used to get memory update email notification content
                to send to product-release-tools-req if the image's size either flash or dram got changed
                after posted to CCO or OPUS.This populates the image_size_update table through synonym in 
                sprit@prodrtim,which is being read by manufacuring. This procedure is being invoked 
                from SPRIT,MemUpdtNotify.java when image size gets changed in Image List.

Date          : 04/09/2004
Author        : Selvaraj Aran (aselvara@cisco.com) 


*/

CREATE OR REPLACE PROCEDURE PROC_MEMORY_UPDT_NOTIFICATION
   ( p_RELEASE                          IN    VARCHAR2
    ,p_MAINTENANCE                      IN    VARCHAR2
    ,p_MRENUMBER                        IN    VARCHAR2
    ,p_ED_DESIGNATOR                    IN    VARCHAR2
    ,p_ED_RENUMBER                      IN    VARCHAR2
    ,p_RELEASE_NUMBER_ID                IN    NUMBER
    ,p_IMAGE                            IN    VARCHAR2
    ,p_new_PLATFORM                     IN    VARCHAR2
    ,p_new_MINFLASH                     IN    VARCHAR2
    ,p_old_MINFLASH                     IN    VARCHAR2
    ,p_new_MINDRAM                      IN    VARCHAR2
    ,p_old_MINDRAM                      IN    VARCHAR2
    ,p_OWNER                            IN    VARCHAR2
    ,p_pcode_state                      IN    NUMBER
    ,p_outpcode_state                   OUT   NUMBER
    ,p_outemail_notification_msg        OUT   VARCHAR2
    ,p_outmessage                       OUT   VARCHAR2 )     IS

--Parameter varibales declarations

    v_RELEASE                        SHR_MAJOR_RELEASE.MAJOR_RELEASE_NUMBER%TYPE;
    v_MAINTENANCE                    SHR_RELEASE_NUMBER.Z%TYPE;
    v_MRENUMBER                      SHR_RELEASE_NUMBER.P%TYPE;
    v_ED_DESIGNATOR                  SHR_RELEASE_NUMBER.A%TYPE;
    v_ED_RENUMBER                    SHR_RELEASE_NUMBER.O%TYPE;
    v_IMAGE                          SHR_IMAGE.IMAGE_NAME%TYPE;
    v_new_PLATFORM                   SHR_INDIVIDUAL_PLATFORM.INDIVIDUAL_PLATFORM_NAME%TYPE;
    v_new_MINFLASH                   SHR_PLATFORM_IMAGE.MIN_FLASH%TYPE;
    v_old_MINFLASH                   SHR_PLATFORM_IMAGE.MIN_FLASH%TYPE;
    v_new_MINDRAM                    SHR_PLATFORM_IMAGE.DRAM%TYPE;
    v_old_MINDRAM                    SHR_PLATFORM_IMAGE.DRAM%TYPE;
    v_OWNER                          VARCHAR(20);

--local variable declaration;

    l_is_pcode_exist           NUMBER       := -1;
    l_v_pcode                  VARCHAR2(18) :=null;

--Exception declaration;

    not_exist_exception    EXCEPTION;
    null_param_exception   EXCEPTION;


BEGIN

-- get rid of spaces in the parameters

    v_RELEASE           :=trim(p_RELEASE);
    v_MAINTENANCE       :=trim(p_MAINTENANCE);
    v_MRENUMBER         :=trim(p_MRENUMBER);
    v_ED_DESIGNATOR     :=trim(p_ED_DESIGNATOR);
    v_ED_RENUMBER       :=trim(p_ED_RENUMBER);
    v_IMAGE             :=trim(p_IMAGE);
    v_new_PLATFORM      :=trim(p_new_PLATFORM);
    v_new_MINFLASH      :=trim(p_new_MINFLASH);
    v_old_MINFLASH      :=trim(p_old_MINFLASH);
    v_new_MINDRAM       :=trim(p_new_MINDRAM);
    v_old_MINDRAM       :=trim(p_old_MINDRAM);
    v_OWNER             :=trim(p_OWNER);

    p_outemail_notification_msg  := NULL;
    p_outmessage                 := 'Success'; --Initialize to success

    IF (      v_RELEASE       IS NULL OR v_MAINTENANCE   IS NULL
          OR  v_IMAGE         IS NULL OR v_new_PLATFORM  IS NULL
          OR  v_new_MINFLASH  IS NULL OR v_old_MINFLASH  IS NULL
          OR  v_new_MINDRAM   IS NULL OR v_old_MINDRAM   IS NULL OR trim(p_RELEASE_NUMBER_ID) IS NULL )  THEN
        RAISE null_param_exception;

    END IF;

--Check if the product code exists
       IF(p_pcode_state = -1)  THEN
         BEGIN
          SELECT distinct 1 INTO l_is_pcode_exist
          FROM  shr_image               si
                ,shr_image_feature_set  sifs
                ,shr_pcode              sp
          WHERE si.release_number_id            = p_RELEASE_NUMBER_ID
          --AND   si.image_name                   =v_IMAGE
          AND   si.image_id                     = sifs.image_id
          AND   sifs.image_feature_set_id       = sp.image_feature_set_id
          AND   (sp.pcode_main IS NOT NULL OR pcode_spare IS NOT NULL)
          AND   si.is_in_image_list             = 'Y'
          AND   si.adm_flag                     = 'V'
          AND   nvl(si.is_obsolete,'N')         = 'N'
          AND   sifs.adm_flag                   = 'V'
          AND   sp.adm_flag                     = 'V'
          ;
           EXCEPTION
             WHEN  NO_DATA_FOUND THEN
              BEGIN
                 --DBMS_OUTPUT.PUT_LINE('exception release_number_id and image names are '||p_RELEASE_NUMBER_ID ||v_IMAGE);
                 NULL;
              END;
         END;
       ELSE IF(p_pcode_state >= 0 ) THEN
              p_outpcode_state := p_pcode_state;
              l_is_pcode_exist := 1;
            END IF;
       END IF;

       --DBMS_OUTPUT.PUT_LINE('control comes here 1 and l_is_pcode_exist values is '|| l_is_pcode_exist);

    IF(l_is_pcode_exist < 1) THEN
        l_is_pcode_exist := 0;
        p_outpcode_state := 0;
        DBMS_OUTPUT.PUT_LINE('before rais not exist exception  '|| l_is_pcode_exist);
        RAISE not_exist_exception ;
    ELSE
       p_outpcode_state := l_is_pcode_exist;
    END IF;

        --   DBMS_OUTPUT.PUT_LINE('control comes here 2 and l_is_pcode_exist values is '|| l_is_pcode_exist);
   BEGIN
     IF(   (v_new_MINFLASH != v_old_MINFLASH OR v_new_MINDRAM != v_old_MINDRAM)
            AND (l_is_pcode_exist > 0 )                         ) THEN

          DBMS_OUTPUT.PUT_LINE('control comes here 3 and l_is_pcode_exist values is '|| l_is_pcode_exist);

    --p_outemail_notification_msg  := 'SIIS inside prodcedure Block3';
         FOR C1 IN
          (SELECT distinct pcode_main pcode
          FROM   shr_image              si
                ,shr_image_feature_set  sifs
                ,shr_pcode              sp
          WHERE si.release_number_id            = p_RELEASE_NUMBER_ID
          AND   si.image_name                   = v_IMAGE
          AND   si.image_id                     = sifs.image_id
          AND   sifs.image_feature_set_id       = sp.image_feature_set_id
          AND   (sp.pcode_main IS NOT NULL OR pcode_spare IS NOT NULL)
          AND   si.is_in_image_list             = 'Y'
          AND   si.adm_flag                     = 'V'
          AND   nvl(si.is_obsolete,'N')         = 'N'
          AND   sifs.adm_flag                   = 'V'
          AND   sp.adm_flag                     = 'V'
          UNION
          SELECT distinct pcode_spare  pcode
          FROM   shr_image              si
                ,shr_image_feature_set  sifs
                ,shr_pcode              sp
          WHERE si.release_number_id            = p_RELEASE_NUMBER_ID
          AND   si.image_name                   = v_IMAGE
          AND   si.image_id                     = sifs.image_id
          AND   sifs.image_feature_set_id       = sp.image_feature_set_id
          AND   (sp.pcode_main IS NOT NULL OR pcode_spare IS NOT NULL)
          AND   si.is_in_image_list             = 'Y'
          AND   si.adm_flag                     = 'V'
          AND   nvl(si.is_obsolete,'N')         = 'N'
          AND   sifs.adm_flag                   = 'V'
          AND   sp.adm_flag                     = 'V'
          )
           LOOP
                 l_v_pcode :=trim(c1.pcode);
                 INSERT INTO image_size_update(IMAGE_SIZE_UPDATE_ID
                                             ,PRODUCT_NAME
                                             ,IMAGE
                                             ,PLATFORM
                                             ,NEW_DRAM
                                             ,OLD_DRAM
                                             ,NEW_FLASH
                                             ,OLD_FLASH
                                             ,STATUS
                                             ,DESCRIPTION
                                             ,VERSION
                                             ,RELEASE
                                             ,MAINTENANCE
                                             ,MRENUMBER
                                             ,ED_DESIGNATOR
                                             ,ED_RENUMBER
                                             ,CREATED_BY
                                             ,CREATED_DATE
                                             ,LAST_UPDATED_DATE)
                  VALUES                     (image_size_update_seq.nextval
                                             ,l_v_pcode
                                             ,v_IMAGE
                                             ,v_new_PLATFORM
                                             ,v_new_MINDRAM
                                             ,v_old_MINDRAM
                                             ,v_new_MINFLASH
                                             ,v_old_MINFLASH
                                             ,'unreadCPS'
                                             ,'Memory requirements have been changed in SPRIT'
                                             ,v_RELEASE
                                             ,v_RELEASE
                                             ,v_MAINTENANCE
                                             ,v_MRENUMBER
                                             ,v_ED_DESIGNATOR
                                             ,v_ED_RENUMBER
                                             ,v_OWNER
                                             ,SYSDATE
                                             ,null);
                      p_outemail_notification_msg :=p_outemail_notification_msg||chr(10)||'  '||v_IMAGE||'        '||v_new_MINFLASH||'MB  '||v_old_MINFLASH||'MB  ' ||v_new_MINDRAM||'MB  '||v_old_MINDRAM||'MB  '||v_new_PLATFORM||'    '||l_v_pcode;
               END LOOP;
       END IF;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             BEGIN
               NULL;
             END;
   END;

   EXCEPTION

     WHEN null_param_exception THEN
     BEGIN
         p_outmessage := 'Warning: NULL parameters found check parameters value! '
                          ||' Release         = ' ||v_RELEASE
                          ||' Maintenance     = ' ||v_MAINTENANCE
                          ||' Mrenumber       = ' ||v_MRENUMBER
                          ||' Ed_designator   = ' ||v_ED_DESIGNATOR
                          ||' Ed_Renumber     = ' ||v_ED_RENUMBER
                          ||' Image           = ' ||v_IMAGE
                          ||' NEW_Platform    = ' ||v_new_PLATFORM
                          ||' NEW_Minflash    = ' ||v_new_MINFLASH
                          ||' OLD_Minflash    = ' ||v_old_MINFLASH
                          ||' NEW_Mindram     = ' ||v_new_MINDRAM
                          ||' OLD_Mindram     = ' ||v_old_MINDRAM
                          ||' Owner           = ' ||v_OWNER
                         ;
         --INSERT INTO test VALUES('UPD-DEL',p_outmessage,sysdate);
         --p_outmessage :='Failed of Null param';
     END;

     WHEN not_exist_exception THEN
     BEGIN
      NULL;
     END;

     WHEN OTHERS THEN
     BEGIN
         p_outmessage := 'OTHERS BLOCK '||substr(sqlerrm,1,512);
         --RAISE_APPLICATION_ERROR(-20001, p_outmessage);
     END;
END;

