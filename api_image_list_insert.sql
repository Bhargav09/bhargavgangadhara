--Copyright (c) 2003 by Cisco Systems, Inc.

CREATE OR REPLACE PROCEDURE API_IMAGE_LIST_INSERT
   ( p_RELEASE                IN    VARCHAR2
    ,p_MAINTENANCE            IN    VARCHAR2
    ,p_MRENUMBER              IN    VARCHAR2
    ,p_ED_DESIGNATOR          IN    VARCHAR2
    ,p_ED_RENUMBER            IN    VARCHAR2
    ,p_IMAGE                  IN    VARCHAR2
    ,p_PLATFORM               IN    VARCHAR2
    ,p_MINFLASH               IN    VARCHAR2
    ,p_MINDRAM                IN    VARCHAR2
    ,p_CCO                    IN    VARCHAR2
    ,p_CATEGORY               IN    VARCHAR2
    ,p_TEST                   IN    VARCHAR2
    ,p_OWNER                  IN    VARCHAR2
    ,p_src_RELEASE            IN    VARCHAR2
    ,p_src_MAINTENANCE        IN    VARCHAR2
    ,p_src_MRENUMBER          IN    VARCHAR2
    ,p_src_ED_DESIGNATOR      IN    VARCHAR2
    ,p_src_ED_RENUMBER        IN    VARCHAR2
    ,p_release_state          IN    VARCHAR2
    ,p_outrelease_state       OUT   VARCHAR2
    ,p_outmessage             OUT   VARCHAR2 )     IS

--Varibales declarations

    v_RELEASE                    IMAGE.RELEASE%TYPE;
    v_MAINTENANCE                IMAGE.MAINTENANCE%TYPE;
    v_MRENUMBER                  IMAGE.MRENUMBER%TYPE;
    v_ED_DESIGNATOR              IMAGE.ED_DESIGNATOR%TYPE;
    v_ED_RENUMBER                IMAGE.ED_RENUMBER%TYPE;
    v_IMAGE                      IMAGE.IMAGE%TYPE;
    v_PLATFORM                   IMAGE.PLATFORM%TYPE;
    v_FAMILY                     PLATFORM.FAMILY%TYPE;
    v_MINFLASH                   IMAGE.MINFLASH%TYPE;
    v_MINDRAM                    IMAGE.MINDRAM%TYPE;
    v_CCO                        IMAGE.CCO%TYPE;
    v_CATEGORY                   IMAGE.CATEGORY%TYPE;
    v_TEST                       IMAGE.TEST%TYPE;
    v_OWNER                      RELEASE_STAT.OWNER%TYPE;
    v_src_RELEASE                IMAGE.RELEASE%TYPE;
    v_src_MAINTENANCE            IMAGE.MAINTENANCE%TYPE;
    v_src_MRENUMBER              IMAGE.MRENUMBER%TYPE;
    v_src_ED_DESIGNATOR          IMAGE.ED_DESIGNATOR%TYPE;
    v_src_ED_RENUMBER            IMAGE.ED_RENUMBER%TYPE;

    v_platform_exists            NUMBER :=0;
    v_release_exists             NUMBER :=0;
    v_image_already_exists       NUMBER :=0;
    v_feature_already_exists     NUMBER :=0;
    v_family_already_exists      NUMBER :=0;

--added for UP copy
    v_release_state              NUMBER;
    v_release_state_message      VARCHAR2(400);
    v_sprit_up_create_message    VARCHAR2(400);

    not_exist_exception          EXCEPTION;
    null_param_exception         EXCEPTION;
    sprit_upgrade_planner_create EXCEPTION;

     cursor c1(l_p_platform varchar2)
     is
        SELECT count(distinct platform) cnt,family                                                                                                    FROM platform
        WHERE platform=v_PLATFORM
		group by family;

     cursor c3(l_p_release         varchar2
              ,l_p_maintenance     varchar2
              ,l_p_mrenumber       varchar2
              ,l_p_ed_designator   varchar2
              ,l_p_ed_renumber     varchar2)
      IS
      SELECT count(1) cnt2
      FROM release_stat
      WHERE release                 = p_RELEASE
      AND   maintenance             = p_MAINTENANCE
      AND   nvl(mrenumber     ,'N') = nvl(v_MRENUMBER     ,'N')
      AND   nvl(ed_designator ,'N') = nvl(v_ED_DESIGNATOR ,'N')
      AND   nvl(ed_renumber   ,'N') = nvl(v_ED_RENUMBER   ,'N')
      AND   tableid                 = 'I'
     ;
     cursor c5(l_p_release         varchar2
              ,l_p_maintenance     varchar2
              ,l_p_mrenumber       varchar2
              ,l_p_ed_designator   varchar2
              ,l_p_ed_renumber     varchar2
              ,l_p_image           varchar2
              ,l_p_platform        varchar2 )
       IS
         SELECT count(1) cnt3
         FROM image
         WHERE release                 = p_RELEASE
         AND   maintenance             = p_MAINTENANCE
         AND   nvl(mrenumber     ,'N') = nvl(v_MRENUMBER     ,'N')
         AND   nvl(ed_designator ,'N') = nvl(v_ED_DESIGNATOR ,'N')
         AND   nvl(ed_renumber   ,'N') = nvl(v_ED_RENUMBER   ,'N')
         AND   image=v_IMAGE
         AND   platform=v_PLATFORM
         AND   obsolete='N'
        ;

BEGIN
    v_RELEASE       :=trim(p_RELEASE);
    v_MAINTENANCE   :=trim(p_MAINTENANCE);
    v_MRENUMBER     :=trim(p_MRENUMBER);
    v_ED_DESIGNATOR :=trim(p_ED_DESIGNATOR);
    v_ED_RENUMBER   :=trim(p_ED_RENUMBER);
    v_IMAGE         :=trim(p_IMAGE);
    v_PLATFORM      :=trim(p_PLATFORM);
    v_MINFLASH      :=trim(p_MINFLASH);
    v_MINDRAM       :=trim(p_MINDRAM);
    v_CCO           :=trim(p_CCO);
    v_CATEGORY      :=trim(p_CATEGORY);
    v_TEST          :=trim(p_TEST);
    v_OWNER         :=trim(p_OWNER);
    v_src_RELEASE       :=trim(p_src_RELEASE);
    v_src_MAINTENANCE   :=trim(p_src_MAINTENANCE);
    v_src_MRENUMBER     :=trim(p_src_MRENUMBER);
    v_src_ED_DESIGNATOR :=trim(p_src_ED_DESIGNATOR);
    v_src_ED_RENUMBER   :=trim(p_src_ED_RENUMBER);

      p_outmessage := 'Success'; --Initialize to success
      p_outrelease_state :=p_release_state;

      IF (v_RELEASE is NULL OR v_MAINTENANCE is NULL OR
          v_IMAGE is NULL OR v_PLATFORM is NULL  OR
          v_MINFLASH is NULL OR v_MINDRAM is NULL OR
          v_CCO is NULL OR v_CATEGORY is NULL OR
          v_TEST is NULL OR v_OWNER is NULL  )  THEN
       RAISE null_param_exception;
      END IF;



     open c1(v_PLATFORM);
     loop
       fetch c1 into v_platform_exists,v_FAMILY;
         exit when c1%notfound;
     end loop;
     close c1;
    -- for c2 in c1(v_PLATFORM) LOOP
    --  v_platform_exists := c2.cnt1;
    -- END LOOP;

      IF(v_platform_exists < 1) THEN
        RAISE not_exist_exception ;
      END IF;

     open c3(v_RELEASE,v_MAINTENANCE,v_MRENUMBER,v_ED_DESIGNATOR,v_ED_RENUMBER);
      LOOP
        fetch c3 into v_release_exists;
        exit when c3%notfound;
      end loop;
     close c3;

--     FOR c4 in c3(v_RELEASE,v_MAINTENANCE,v_MRENUMBER,v_ED_DESIGNATOR,v_ED_RENUMBER) LOOP
--      v_release_exists := c4.cnt2;
--     END LOOP;

      IF(v_release_exists < 1) THEN
       INSERT INTO RELEASE_STAT(
                   TABLEID
                  ,RELEASE
                  ,MAINTENANCE
                  ,MRENUMBER
                  ,ED_DESIGNATOR
                  ,ED_RENUMBER
                  ,OWNER
                  ,STATUS
                  ,FCS_DATE
                  ,CCO_DATE
                  ,UPDT_DATE
                )
           VALUES('I'                          --tableid I-IL,U-UP,M-MM
                  ,v_RELEASE                   --p_RELEASE
                  ,v_MAINTENANCE               --p_MAINTENANCE
                  ,v_MRENUMBER                 --p_MRENUMBER
                  ,v_ED_DESIGNATOR             --p_ED_DESIGNATOR
                  ,v_ED_RENUMBER               --p_ED_RENUMBER
                  ,v_OWNER                     --p_OWNER
                  ,'SP'                        --STATUS
                  ,sysdate+7                   --FCS_DATE is by default sysdate+7 days but user can set it in UP
                  ,NULL                        --CCO_DATE
                  ,sysdate                     --p_UPDT_DATE
                );
      END IF;


      open c5(v_RELEASE,v_MAINTENANCE,v_MRENUMBER,v_ED_DESIGNATOR,v_ED_RENUMBER,v_IMAGE,v_PLATFORM);
      LOOP
        fetch c5 into v_image_already_exists;
        exit when c5%notfound;
      end loop;
     close c5;

--    FOR c6 in c5(v_RELEASE,v_MAINTENANCE,v_MRENUMBER,v_ED_DESIGNATOR,v_ED_RENUMBER,v_IMAGE,v_PLATFORM) LOOP
--      v_image_already_exists :=c6.cnt3;
--    END LOOP;

      IF(v_image_already_exists < 1) THEN
              INSERT INTO IMAGE(
                   SEQ
                  ,RELEASE
                  ,MAINTENANCE
                  ,MRENUMBER
                  ,ED_DESIGNATOR
                  ,ED_RENUMBER
                  ,IMAGE
                  ,PLATFORM
                  ,RUNSFROM
                  ,MINFLASH
                  ,MINDRAM
                  ,FLASHOPTION
                  ,SPECIALINST
                  ,MFGPARTNO
                  ,QUANTITY
                  ,COMBOID
                  ,ROMMONID
                  ,CCO
                  ,DELIVER
                  ,DEFERRAL
                  ,ORDERABLE
                  ,STATUS
                  ,CATEGORY
                  ,TEST
                  ,PARENT
                  ,PUBLISH
                  ,OBSOLETE
                  ,SWADVISE
                  ,DEFERRAL_REQUEST_ID
                  ,SOFTWARE_ADVISORY_ID
                  ,IMAGE_SIZE_PASSED
                 )
          VALUES(
                  image_seq.nextval             --IMAGE_SEQ
                  ,v_RELEASE                    --p_RELEASE
                  ,v_MAINTENANCE                --p_MAINTENANCE
                  ,v_MRENUMBER                  --p_MRENUMBER
                  ,v_ED_DESIGNATOR              --p_ED_DESIGNATOR
                  ,v_ED_RENUMBER                --p_ED_RENUMBER
                  ,v_IMAGE                      --p_IMAGE
                  ,v_PLATFORM                   --p_PLATFORM
                  ,'RAM'                        --p_RUNSFROM
                  ,v_MINFLASH                   --p_MINFLASH
                  ,v_MINDRAM                    --p_MINDRAM
                  ,'N'                          --FLASHOPTION
                  ,NULL                         --SPECIALINST
                  ,'40-0004-01'                 --MFGPARTNO
                  ,0                            --QUANTITY
                  ,NULL                         --COMBOID
                  ,NULL                         --ROMMONID
                  ,v_CCO                        --p_CCO
                  ,'Y'                          --DELIVER
                  ,'N'                          --DEFERRAL
                  ,'Y'                          --ORDERABLE
                  ,'SP'                         --STATUS
                  ,v_CATEGORY                   --p_CATEGORY
                  ,decode(v_TEST,'T','Y','N')   --p_TEST
                  ,0                            --PARENT
                  ,'V'                          --PUBLISH
                  ,'N'                          --OBSOLETE
                  ,NULL                         --SWADVISE
                  ,NULL                         --DEFERRAL_REQUEST_ID
                  ,NULL                         --SOFTWARE_ADVISORY_ID
                  ,NULL                         --IMAGE_SIZE_PASSED
                 );

              UPDATE IMAGE SET CCO           = v_CCO,
                               CATEGORY      = v_CATEGORY,
                               TEST          = decode(v_TEST,'T','Y','N')
              WHERE release                  = v_RELEASE
              AND   maintenance              = v_MAINTENANCE
              AND   nvl(mrenumber     ,'N')  = nvl(v_MRENUMBER     ,'N')
              AND   nvl(ed_designator ,'N')  = nvl(v_ED_DESIGNATOR ,'N')
              AND   nvl(ed_renumber   ,'N')  = nvl(v_ED_RENUMBER   ,'N')
              AND   image                    = v_IMAGE
              AND   obsolete                 ='N'
              ;

        IF(p_release_state = 0 ) THEN
             PROC_GET_RELEASE_STAT( v_RELEASE
                     ,v_MAINTENANCE
                     ,v_MRENUMBER
                     ,v_ED_DESIGNATOR
                     ,v_ED_RENUMBER
                     ,v_release_state
                     ,v_release_state_message
                    );

             IF(v_release_state = -1 ) THEN
                p_outmessage := 'This release does not exist in Image Or Release state table in SIIS';
                RAISE  not_exist_exception;
             ELSE
               --DBMS_OUTPUT.PUT_LINE('Release_state is inside update-delte '|| v_release_state);
               p_outrelease_state :=v_release_state;
             END IF;
        ELSE
           p_outrelease_state :=p_release_state;
        END IF;

         --Create UP/MM if the release already exist for the image being tried to add/copy into IL in SPRIT.
         IF(v_src_RELEASE IS NOT NULL AND v_src_MAINTENANCE IS NOT NULL )  THEN
                      FOR C1 IN
                      (SELECT
                              v_src_RELEASE
                             ,v_src_MAINTENANCE
                             ,v_src_MRENUMBER
                             ,v_src_ED_DESIGNATOR
                             ,v_src_ED_RENUMBER
                             ,PFXSYS
                             ,PFXSPR
                             ,PFXUPG
                             ,PRICESYS
                             ,PRICESPR
                             ,PRICEUPG
                             ,f.FAMILY
                             ,f.IMAGE
                             ,f.FEATUREDESC
                             ,f.FEATURESET
                             ,f.AVAILABLE
                             ,f.DISPLAY
                             ,f.PUBLISH
                             ,f.OBSOLETE
                             ,f.PARENT
                      FROM FEATURE f
                           ,PRODUCT p
                      WHERE f.release                 = v_src_RELEASE
                      AND   f.maintenance             = v_src_MAINTENANCE
                      AND   nvl(f.mrenumber     ,'N') = nvl(v_src_MRENUMBER     ,'N')
                      AND   nvl(f.ed_designator ,'N') = nvl(v_src_ED_DESIGNATOR ,'N')
                      AND   nvl(f.ed_renumber   ,'N') = nvl(v_src_ED_RENUMBER   ,'N')
                      AND   f.image=v_IMAGE
                      AND   f.seq=p.key(+)
                      AND   f.obsolete='N'
                      AND   f.publish='V')  LOOP

                     BEGIN
                      SELECT count(1) INTO v_feature_already_exists
                      FROM FEATURE
                      WHERE release                 = v_RELEASE
                      AND   maintenance             = v_MAINTENANCE
                      AND   nvl(mrenumber     ,'N') = nvl(v_MRENUMBER     ,'N')
                      AND   nvl(ed_designator ,'N') = nvl(v_ED_DESIGNATOR ,'N')
                      AND   nvl(ed_renumber   ,'N') = nvl(v_ED_RENUMBER   ,'N')
                      AND   image=v_IMAGE
                      AND   family=C1.family
                      AND   featuredesc=C1.featuredesc
                      AND   obsolete='N';

                      EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                       BEGIN
                           null;
                       END;
                      END;

                      If(v_feature_already_exists < 1) THEN

                          INSERT INTO FEATURE(  SEQ
                                              , RELEASE
                                              , MAINTENANCE
                                              , MRENUMBER
                                              , ED_DESIGNATOR
                                              , ED_RENUMBER
                                              , FAMILY
                                              , IMAGE
                                              , FEATUREDESC
                                              , FEATURESET
                                              , AVAILABLE
                                              , DISPLAY
                                              , PUBLISH
                                              , OBSOLETE
                                              , PARENT
                                             )
                                     VALUES (
                                              feature_seq.nextval
                                              ,v_RELEASE
                                              ,v_MAINTENANCE
                                              ,v_MRENUMBER
                                              ,v_ED_DESIGNATOR
                                              ,v_ED_RENUMBER
                                              ,C1.FAMILY
                                              ,C1.IMAGE
                                              ,C1.FEATUREDESC
                                              ,C1.FEATURESET
                                              ,C1.AVAILABLE
                                              ,C1.DISPLAY
                                              ,'V'
                                              ,C1.OBSOLETE
                                              ,C1.PARENT
                                             );
                         IF(C1.display ='Y') THEN
                          INSERT INTO PRODUCT(
                                              KEY
                                              ,MEDIAPN
                                              ,PFXSYS
                                              ,PFXSPR
                                              ,PFXUPG
                                              ,PRICESYS
                                              ,PRICESPR
                                              ,PRICEUPG
                                              ,OBSOLETE
                                              ,PCODE_SYS
                                              ,PCODE_SPR
                                              ,PCODE_UPG
                                              )
                                       VALUES (
                                               feature_seq.currval
                                               ,'40-0004-01'
                                               ,C1.PFXSYS
                                               ,C1.PFXSPR
                                               ,C1.PFXUPG
                                               ,C1.PRICESYS
                                               ,C1.PRICESPR
                                               ,C1.PRICEUPG
                                               ,C1.OBSOLETE
                                               ,NULL
                                               ,NULL
                                               ,NULL
                                               );
                           END IF;
                                      BEGIN
                                        SELECT count(1) INTO v_family_already_exists
                                        FROM family
                                        WHERE release                 = v_RELEASE
                                        AND   maintenance             = v_MAINTENANCE
                                        AND   nvl(mrenumber     ,'N') = nvl(v_MRENUMBER     ,'N')
                                        AND   nvl(ed_designator ,'N') = nvl(v_ED_DESIGNATOR ,'N')
                                        AND   nvl(ed_renumber   ,'N') = nvl(v_ED_RENUMBER   ,'N')
                                        AND   family=C1.family;

                                        EXCEPTION
                                         WHEN NO_DATA_FOUND THEN
                                         BEGIN
                                          null;
                                         END;
                                      END;

                               IF(v_family_already_exists < 1) THEN
                                 INSERT INTO family(
                                         RELEASE
                                        ,MAINTENANCE
                                        ,MRENUMBER
                                        ,ED_DESIGNATOR
                                        ,ED_RENUMBER
                                        ,FAMILY
                                        ,MEDIADISP
                                        ,ABBR
                                        ,PFDESC
                                      )
                                SELECT distinct v_RELEASE
                                        ,v_MAINTENANCE
                                        ,v_MRENUMBER
                                        ,v_ED_DESIGNATOR
                                        ,v_ED_RENUMBER
                                        ,FAMILY
                                        ,MEDIADISP
                                        ,ABBR
                                        ,PFDESC
                                FROM family
                                WHERE release                 = v_src_RELEASE
                                AND   maintenance             = v_src_MAINTENANCE
                                AND   nvl(mrenumber     ,'N') = nvl(v_src_MRENUMBER     ,'N')
                                AND   nvl(ed_designator ,'N') = nvl(v_src_ED_DESIGNATOR ,'N')
                                AND   nvl(ed_renumber   ,'N') = nvl(v_src_ED_RENUMBER   ,'N')
                                AND   family=v_FAMILY ;
                               END IF;
                           END IF; --if image does not exist in feature table already
                        END LOOP;
        END IF;--Create UP/MM
     END IF; --if image does not exist
      --commit;


     EXCEPTION

     WHEN null_param_exception THEN
     BEGIN
         p_outmessage := 'Warning: NULL parameters found check parameters value! '
                          ||' Release         =' ||v_RELEASE
                          ||' Maintenance     =' ||v_MAINTENANCE
                          ||' Mrenumber       =' ||v_MRENUMBER
                          ||' Ed_designator   =' ||v_ED_DESIGNATOR
                          ||' Ed_Renumber     =' ||v_ED_RENUMBER
                          ||' Image           =' ||v_IMAGE
                          ||' Platform        =' ||v_PLATFORM
                          ||' Minflash        =' ||v_MINFLASH
                          ||' Mindram         =' ||v_MINDRAM
                          ||' CCO             =' ||v_CCO
                          ||' Category        =' ||v_CATEGORY
                          ||' Test            =' ||v_TEST
                          ||' Owner           =' ||v_OWNER
                         ;

     --INSERT INTO test VALUES('INSERT',p_outmessage,sysdate);
     --p_outmessage :='Failed';
     END;


     WHEN not_exist_exception THEN
     BEGIN
        p_outmessage := 'Platform '||v_PLATFORM||' Does not exist in SIIS, Please add before creating Image List';
     END;

     WHEN NO_DATA_FOUND THEN
     BEGIN
         p_outmessage := substr(sqlerrm,1,512);
         null;
     END;

     WHEN sprit_upgrade_planner_create THEN
     BEGIN
        p_outmessage := v_sprit_up_create_message;
     END;

     WHEN OTHERS THEN
     BEGIN
         p_outmessage := 'OTHERS BLOCK '||substr(sqlerrm,1,512);
         --RAISE_APPLICATION_ERROR(-20001, p_outmessage);
     END;
END;
