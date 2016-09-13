--Copyright (c) 2003 by Cisco Systems, Inc.

CREATE OR REPLACE PROCEDURE API_IMAGE_LIST_UPDATE_DELETE
   ( p_RELEASE                          IN    VARCHAR2
    ,p_MAINTENANCE                      IN    VARCHAR2
    ,p_MRENUMBER                        IN    VARCHAR2
    ,p_ED_DESIGNATOR                    IN    VARCHAR2
    ,p_ED_RENUMBER                      IN    VARCHAR2
    ,p_IMAGE                            IN    VARCHAR2
    ,p_new_PLATFORM                     IN    VARCHAR2
    ,p_old_PLATFORM                     IN    VARCHAR2
    ,p_new_MINFLASH                     IN    VARCHAR2
    ,p_old_MINFLASH                     IN    VARCHAR2
    ,p_new_MINDRAM                      IN    VARCHAR2
    ,p_old_MINDRAM                      IN    VARCHAR2
    ,p_new_CCO                          IN    VARCHAR2
    ,p_old_CCO                          IN    VARCHAR2
    ,p_new_CATEGORY                     IN    VARCHAR2
    ,p_old_CATEGORY                     IN    VARCHAR2
    ,p_new_TEST                         IN    VARCHAR2
    ,p_old_TEST                         IN    VARCHAR2
    ,p_new_OBSOLETE                     IN    VARCHAR2
    ,p_OWNER                            IN    VARCHAR2
    ,p_release_state                    IN    NUMBER
    ,p_outrelease_state                 OUT   NUMBER
    ,p_outemail_notification_msg        OUT   VARCHAR2
    ,p_outmessage                       OUT   VARCHAR2 )     IS

--Varibales declarations

    v_RELEASE                        IMAGE.RELEASE%TYPE;
    v_MAINTENANCE                    IMAGE.MAINTENANCE%TYPE;
    v_MRENUMBER                      varchar2(10);
    --v_MRENUMBER                      IMAGE.MRENUMBER%TYPE;
    v_ED_DESIGNATOR                  IMAGE.ED_DESIGNATOR%TYPE;
    v_ED_RENUMBER                    IMAGE.ED_RENUMBER%TYPE;
    v_IMAGE                          IMAGE.IMAGE%TYPE;
    v_new_PLATFORM                   IMAGE.PLATFORM%TYPE;
    v_old_PLATFORM                   IMAGE.PLATFORM%TYPE;
    v_new_MINFLASH                   IMAGE.MINFLASH%TYPE;
    v_old_MINFLASH                   IMAGE.MINFLASH%TYPE;
    v_new_MINDRAM                    IMAGE.MINDRAM%TYPE;
    v_old_MINDRAM                    IMAGE.MINDRAM%TYPE;
    v_new_CCO                        IMAGE.CCO%TYPE;
    v_old_CCO                        IMAGE.CCO%TYPE;
    v_new_CATEGORY                   IMAGE.CATEGORY%TYPE;
    v_old_CATEGORY                   IMAGE.CATEGORY%TYPE;
    v_new_TEST                       IMAGE.TEST%TYPE;
    v_old_TEST                       IMAGE.TEST%TYPE;
    v_new_OBSOLETE                   IMAGE.OBSOLETE%TYPE;
    v_OWNER                          RELEASE_STAT.OWNER%TYPE;

    l_v_platform_exists        NUMBER;
    l_v_release_exists         NUMBER;
    l_v_pcode_sys              VARCHAR2(18) :=null;
    v_release_state            NUMBER;
    v_release_state_message    VARCHAR2(400);
    v_is_obsolete_UP_record    NUMBER;


    not_exist_exception    EXCEPTION;
    not_update_exception    EXCEPTION;
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
    v_old_PLATFORM      :=trim(p_old_PLATFORM);
    v_new_MINFLASH      :=trim(p_new_MINFLASH);
    v_old_MINFLASH      :=trim(p_old_MINFLASH);
    v_new_MINDRAM       :=trim(p_new_MINDRAM);
    v_old_MINDRAM       :=trim(p_old_MINDRAM);
    v_new_CCO           :=trim(p_new_CCO);
    v_old_CCO           :=trim(p_old_CCO);
    v_new_CATEGORY      :=trim(p_new_CATEGORY);
    v_old_CATEGORY      :=trim(p_old_CATEGORY);
    v_new_TEST          :=trim(p_new_TEST);
    v_old_TEST          :=trim(p_old_TEST);
    v_new_OBSOLETE      :=trim(p_new_OBSOLETE);
    v_OWNER             :=trim(p_OWNER);

    p_outemail_notification_msg  :=NULL;
    p_outmessage                 := 'Success'; --Initialize to success

/*
    p_outmessage := 'debugging: '
                          ||' Release         = ' ||v_RELEASE
                          ||' Maintenance     = ' ||v_MAINTENANCE
                          ||' Mrenumber       = ' ||v_MRENUMBER
                          ||' Ed_designator   = ' ||v_ED_DESIGNATOR
                          ||' Ed_Renumber     = ' ||v_ED_RENUMBER
                          ||' Image           = ' ||v_IMAGE
                          ||' NEW_Platform    = ' ||v_new_PLATFORM
                          ||' OLD_Platform    = ' ||v_old_PLATFORM
                          ||' NEW_Minflash    = ' ||v_new_MINFLASH
                          ||' OLD_Minflash    = ' ||v_old_MINFLASH
                          ||' NEW_Mindram     = ' ||v_new_MINDRAM
                          ||' OLD_Mindram     = ' ||v_old_MINDRAM
                          ||' New CCO         = ' ||v_new_CCO
                          ||' Old CCO         = ' ||v_old_CCO
                          ||' New Category    = ' ||v_new_CATEGORY
                          ||' Old Category    = ' ||v_old_CATEGORY
                          ||' New Test        = ' ||v_new_TEST
                          ||' Old Test        = ' ||v_old_TEST
                          ||' Owner           = ' ||v_OWNER
                          ||' Release_stat     = ' ||p_release_state
                         ;

*/

    IF (   v_RELEASE       IS NULL OR v_MAINTENANCE  IS NULL
          OR v_IMAGE         IS NULL OR v_new_PLATFORM IS NULL
          OR v_old_PLATFORM  IS NULL OR v_new_MINFLASH IS NULL
          OR v_old_MINFLASH  IS NULL OR v_new_MINDRAM  IS NULL
          OR v_old_MINDRAM   IS NULL OR v_new_CCO      IS NULL
          OR v_old_CCO       IS NULL OR v_new_CATEGORY IS NULL
          OR v_old_CATEGORY  IS NULL OR v_new_TEST     IS NULL
          OR v_old_TEST      IS NULL OR v_OWNER        IS NULL )  THEN
        RAISE null_param_exception;

    END IF;

      IF(p_release_state = 0 ) THEN
          PROC_GET_RELEASE_STAT( v_RELEASE
                     ,v_MAINTENANCE
                     ,v_MRENUMBER
                     ,v_ED_DESIGNATOR
                     ,v_ED_RENUMBER
                     ,v_release_state
                     ,v_release_state_message
                    );

          IF(v_release_state = -1) THEN
             p_outmessage := 'This release does not exist in Image Or Release state table in SIIS';
             RAISE  not_exist_exception;
          ELSE
            --DBMS_OUTPUT.PUT_LINE('Release_state is inside update-delte '|| v_release_state);
            p_outrelease_state :=v_release_state;
          END IF;
      ELSE
          p_outrelease_state :=p_release_state;
      END IF;



    BEGIN
          SELECT count(1) into l_v_platform_exists
          FROM platform
          WHERE platform=v_new_PLATFORM
          ;

           EXCEPTION
             WHEN  NO_DATA_FOUND THEN
              BEGIN
                 NULL;
              END;
    END;

    IF(l_v_platform_exists < 1) THEN
        p_outmessage := 'Platform '||v_new_PLATFORM||' Does not exist in SIIS, Please add before creating Image List';
        RAISE not_exist_exception ;
    END IF;

    IF(v_new_OBSOLETE !='Y') THEN
     IF((v_new_CCO != v_old_CCO
             OR v_new_CATEGORY != v_old_CATEGORY
             OR v_new_TEST != v_old_TEST )AND v_new_OBSOLETE != 'Y' )  THEN
              UPDATE IMAGE SET CCO           = v_new_CCO,
                               CATEGORY      = v_new_CATEGORY,
                               TEST          = decode(v_new_TEST,'T','Y','N')
              WHERE release                  = v_RELEASE
              AND   maintenance              = v_MAINTENANCE
              AND   nvl(mrenumber     ,'N')  = nvl(v_MRENUMBER     ,'N')
              AND   nvl(ed_designator ,'N')  = nvl(v_ED_DESIGNATOR ,'N')
              AND   nvl(ed_renumber   ,'N')  = nvl(v_ED_RENUMBER   ,'N')
              AND   image                    = v_IMAGE
              AND   obsolete                 ='N'
              ;
      END IF;

      IF(v_new_PLATFORM    != v_old_PLATFORM
       OR v_new_MINFLASH != v_old_MINFLASH
       OR v_new_MINDRAM  != v_old_MINDRAM
       OR v_new_OBSOLETE IS NOT NULL ) THEN
              UPDATE IMAGE SET PLATFORM      = v_new_PLATFORM,
                               MINFLASH      = v_new_MINFLASH,
                               MINDRAM       = v_new_MINDRAM,
                               OBSOLETE      = v_new_OBSOLETE
              WHERE release                  = v_RELEASE
              AND   maintenance              = v_MAINTENANCE
              AND   nvl(mrenumber     ,'N')  = nvl(v_MRENUMBER     ,'N')
              AND   nvl(ed_designator ,'N')  = nvl(v_ED_DESIGNATOR ,'N')
              AND   nvl(ed_renumber   ,'N')  = nvl(v_ED_RENUMBER   ,'N')
              AND   image                    = v_IMAGE
              AND   platform                 = v_old_PLATFORM
              AND   obsolete                 ='N'
              ;
              UPDATE IMAGE SET CCO           = v_new_CCO,
                               CATEGORY      = v_new_CATEGORY,
                               TEST          = decode(v_new_TEST,'T','Y','N')
              WHERE release                  = v_RELEASE
              AND   maintenance              = v_MAINTENANCE
              AND   nvl(mrenumber     ,'N')  = nvl(v_MRENUMBER     ,'N')
              AND   nvl(ed_designator ,'N')  = nvl(v_ED_DESIGNATOR ,'N')
              AND   nvl(ed_renumber   ,'N')  = nvl(v_ED_RENUMBER   ,'N')
              AND   image                    = v_IMAGE
              AND   obsolete                 ='N'
              ;

       IF(SQL%ROWCOUNT < 1) THEN
         --DBMS_OUTPUT.PUT_LINE('Number of rows update is'|| SQL%ROWCOUNT);
         p_outmessage := 'No image records have been updated in SIIS';
         RAISE not_update_exception;
       END IF;
     END IF;
    ELSE
              UPDATE IMAGE SET OBSOLETE      = v_new_OBSOLETE
              WHERE release                  = v_RELEASE
              AND   maintenance              = v_MAINTENANCE
              AND   nvl(mrenumber     ,'N')  = nvl(v_MRENUMBER     ,'N')
              AND   nvl(ed_designator ,'N')  = nvl(v_ED_DESIGNATOR ,'N')
              AND   nvl(ed_renumber   ,'N')  = nvl(v_ED_RENUMBER   ,'N')
              AND   image                    = v_IMAGE
              AND   platform                 = v_old_PLATFORM
              ;
            BEGIN
              SELECT count(1) INTO v_is_obsolete_UP_record
              FROM  image 
              WHERE release                  = v_RELEASE
              AND   maintenance              = v_MAINTENANCE
              AND   nvl(mrenumber     ,'N')  = nvl(v_MRENUMBER     ,'N')
              AND   nvl(ed_designator ,'N')  = nvl(v_ED_DESIGNATOR ,'N')
              AND   nvl(ed_renumber   ,'N')  = nvl(v_ED_RENUMBER   ,'N')
              AND   image                    = v_IMAGE
              AND   OBSOLETE                 = 'N'
              ;
             EXCEPTION
              WHEN NO_DATA_FOUND THEN
               BEGIN
                NULL;
               END;
             END; 
              IF (v_is_obsolete_UP_record < 1) THEN
                 UPDATE FEATURE SET OBSOLETE    = v_new_OBSOLETE
                 WHERE release                  = v_RELEASE
                 AND   maintenance              = v_MAINTENANCE
                 AND   nvl(mrenumber     ,'N')  = nvl(v_MRENUMBER     ,'N')
                 AND   nvl(ed_designator ,'N')  = nvl(v_ED_DESIGNATOR ,'N')
                 AND   nvl(ed_renumber   ,'N')  = nvl(v_ED_RENUMBER   ,'N')
                 AND   image                    = v_IMAGE
                 ;
              END IF;
    END IF;


              UPDATE RELEASE_STAT SET UPDT_DATE=SYSDATE
              WHERE release                  = v_RELEASE
              AND   maintenance              = v_MAINTENANCE
              AND   nvl(mrenumber     ,'N')  = nvl(v_MRENUMBER     ,'N')
              AND   nvl(ed_designator ,'N')  = nvl(v_ED_DESIGNATOR ,'N')
              AND   nvl(ed_renumber   ,'N')  = nvl(v_ED_RENUMBER   ,'N')
              AND   tableid                 ='I'
              ;

    IF(SQL%ROWCOUNT < 1) THEN
       p_outmessage := 'Release_stat table has not been updated in SIIS';
       RAISE not_update_exception;
    END IF;

   BEGIN
     IF(   (v_new_MINFLASH != v_old_MINFLASH OR v_new_MINDRAM != v_old_MINDRAM)
        AND (p_outrelease_state > 10 )                         ) THEN

    --p_outemail_notification_msg  := 'SIIS inside prodcedure Block3';
              FOR C1 IN
              (SELECT distinct pcode_sys pcode_sys
              FROM product
              WHERE key in( SELECT seq FROM feature
                            WHERE release                  = v_RELEASE
                            AND   maintenance              = v_MAINTENANCE
                            AND   nvl(mrenumber     ,'N')  = nvl(v_MRENUMBER     ,'N')
                            AND   nvl(ed_designator ,'N')  = nvl(v_ED_DESIGNATOR ,'N')
                            AND   nvl(ed_renumber   ,'N')  = nvl(v_ED_RENUMBER   ,'N')
                            AND   image                    = v_IMAGE
                            AND   family                   = (SELECT family FROM platform
                                                              WHERE platform=v_new_PLATFORM))
               AND pcode_sys is not null
               UNION
               SELECT DISTINCT product_name pcode_sys
               FROM mfg_cache_opus
               WHERE rel             = v_RELEASE
               AND   maint           = v_MAINTENANCE
               AND   nvl(mren,'N')   = nvl(v_MRENUMBER     ,'N')
               AND   nvl(ed ,'N')    = nvl(v_ED_DESIGNATOR ,'N')
               AND   nvl(edr,'N')    = nvl(v_ED_RENUMBER   ,'N')
               AND   image     like      v_IMAGE||'%'
               AND   product_name not    like      '%='
               )
               LOOP
                  l_v_pcode_sys :=trim(c1.pcode_sys);
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
                                       VALUES(image_size_update_seq.nextval
                                             ,l_v_pcode_sys
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
                      p_outemail_notification_msg :=p_outemail_notification_msg||chr(10)||'  '||v_IMAGE||'        '||v_new_MINFLASH||'MB  '||v_old_MINFLASH||'MB  ' ||v_new_MINDRAM||'MB  '||v_old_MINDRAM||'MB  '||v_new_PLATFORM||'    '||l_v_pcode_sys;
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
                          ||' OLD_Platform    = ' ||v_old_PLATFORM
                          ||' NEW_Minflash    = ' ||v_new_MINFLASH
                          ||' OLD_Minflash    = ' ||v_old_MINFLASH
                          ||' NEW_Mindram     = ' ||v_new_MINDRAM
                          ||' OLD_Mindram     = ' ||v_old_MINDRAM
                          ||' New CCO         = ' ||v_new_CCO
                          ||' Old CCO         = ' ||v_old_CCO
                          ||' New Category    = ' ||v_new_CATEGORY
                          ||' Old Category    = ' ||v_old_CATEGORY
                          ||' New Test        = ' ||v_new_TEST
                          ||' Old Test        = ' ||v_old_TEST
                          ||' Owner           = ' ||v_OWNER
                         ;
         --INSERT INTO test VALUES('UPD-DEL',p_outmessage,sysdate);
         --p_outmessage :='Failed of Null param';
     END;

     WHEN not_exist_exception THEN
     BEGIN
      NULL;
     END;

     WHEN not_update_exception THEN
     BEGIN
      NULL;
     END;

     WHEN NO_DATA_FOUND THEN
     BEGIN
         p_outmessage := substr(sqlerrm,1,512);
     END;

     WHEN OTHERS THEN
     BEGIN
         p_outmessage := 'OTHERS BLOCK '||substr(sqlerrm,1,512);
         --RAISE_APPLICATION_ERROR(-20001, p_outmessage);
     END;
END;
