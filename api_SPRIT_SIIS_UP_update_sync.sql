--Copyright (c) 2003 by Cisco Systems, Inc.

CREATE OR REPLACE PROCEDURE SPRIT_SIIS_UP_UPDATE_SYNC_API
    (p_RELEASE                          IN    VARCHAR2
    ,p_MAINTENANCE                      IN    VARCHAR2
    ,p_MRENUMBER                        IN    VARCHAR2
    ,p_ED_DESIGNATOR                    IN    VARCHAR2
    ,p_ED_RENUMBER                      IN    VARCHAR2
    ,p_IMAGE                            IN    VARCHAR2
    ,p_FEATURE_SET_DESC                 IN    VARCHAR2
    ,p_FEATURE_SET_DESIGNATOR          IN    VARCHAR2
    ,p_ACTION                           IN    VARCHAR2
    ,p_outmessage                       OUT   VARCHAR2 ) IS

 --Varibales declarations

    v_RELEASE                   FEATURE.RELEASE%TYPE;
    v_MAINTENANCE               FEATURE.MAINTENANCE%TYPE;
    v_MRENUMBER                 FEATURE.MRENUMBER%TYPE;
    v_ED_DESIGNATOR             FEATURE.ED_DESIGNATOR%TYPE;
    v_ED_RENUMBER               FEATURE.ED_RENUMBER%TYPE;
    v_IMAGE                     FEATURE.IMAGE%TYPE;
    v_FEATURE_SET_DESC          FEATURE.FEATUREDESC%TYPE;
    v_FEATURE_SET_DESIGNATOR    FEATURE.FEATURESET%TYPE;
    v_FAMILY                    FEATURE.FAMILY%TYPE;

    v_ACTION                    VARCHAR2(20);

    not_update_exception    EXCEPTION;
    null_param_exception    EXCEPTION;

    v_feature_already_exists NUMBER;
    v_family_already_exists  NUMBER;

BEGIN
    v_RELEASE                 := trim(p_RELEASE);
    v_MAINTENANCE             := trim(p_MAINTENANCE);
    v_MRENUMBER               := trim(p_MRENUMBER);
    v_ED_DESIGNATOR           := trim(p_ED_DESIGNATOR);
    v_ED_RENUMBER             := trim(p_ED_RENUMBER);
    v_IMAGE                   := trim(p_IMAGE);
    v_FEATURE_SET_DESC        := trim(p_FEATURE_SET_DESC);
    v_FEATURE_SET_DESIGNATOR  := trim(p_FEATURE_SET_DESIGNATOR);
    v_ACTION                  := trim(p_ACTION);

    p_outmessage := 'Success'; --Initialize to success

    IF( v_RELEASE IS NULL OR   v_MAINTENANCE  IS NULL OR
        v_IMAGE IS NULL OR v_ACTION IS NULL             ) THEN
        RAISE null_param_exception;
    END IF;

    IF(p_ACTION ='delete_image') THEN
        UPDATE FEATURE set obsolete='Y'
        WHERE RELEASE                 = v_RELEASE
        AND   MAINTENANCE             = v_mAINTENANCE
        AND   NVL(MRENUMBER     ,'N') = NVL(v_MRENUMBER     ,'N')
        AND   NVL(ED_DESIGNATOR ,'N') = NVL(v_ED_DESIGNATOR ,'N')
        AND   NVL(ED_RENUMBER   ,'N') = NVL(v_ED_RENUMBER   ,'N')
        AND   IMAGE                   = v_IMAGE ;
    ELSIF(p_ACTION ='delete_fset') THEN
        UPDATE FEATURE set obsolete='Y'
        WHERE RELEASE                          = v_RELEASE
        AND   MAINTENANCE                      = v_mAINTENANCE
        AND   NVL(MRENUMBER     ,'N')          = NVL(v_MRENUMBER     ,'N')
        AND   NVL(ED_DESIGNATOR ,'N')          = NVL(v_ED_DESIGNATOR ,'N')
        AND   NVL(ED_RENUMBER   ,'N')          = NVL(v_ED_RENUMBER   ,'N')
        AND   IMAGE                            = v_IMAGE
        AND   nvl(FEATUREDESC,'N')             = nvl(v_FEATURE_SET_DESC,'N')
        AND   nvl(FEATURESET,'N')              = nvl(v_FEATURE_SET_DESIGNATOR,'N');
    ELSIF(p_ACTION ='add_fset') THEN
       BEGIN
                      SELECT count(1) INTO v_feature_already_exists
                      FROM FEATURE
                      WHERE release                          = v_RELEASE
                      AND   maintenance                      = v_MAINTENANCE
                      AND   nvl(mrenumber     ,'N')          = nvl(v_MRENUMBER     ,'N')
                      AND   nvl(ed_designator ,'N')          = nvl(v_ED_DESIGNATOR ,'N')
                      AND   nvl(ed_renumber   ,'N')          = nvl(v_ED_RENUMBER   ,'N')
                      AND   image                            = v_IMAGE
                      AND   nvl(featuredesc,'N')             = nvl(v_FEATURE_SET_DESC,'N')
                      AND   nvl(featureset,'N')              = nvl(v_FEATURE_SET_DESIGNATOR,'N')
                      AND   obsolete                         = 'N';

                      EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                       BEGIN
                           null;
                       END;
                      END;
       IF(v_feature_already_exists <1 ) THEN
          FOR record IN(SELECT distinct p.family
                        FROM image i,platform p
                        WHERE i.platform=p.platform
                        AND  release                           = v_RELEASE
                        AND   maintenance                      = v_MAINTENANCE
                        AND   nvl(mrenumber     ,'N')          = nvl(v_MRENUMBER     ,'N')
                        AND   nvl(ed_designator ,'N')          = nvl(v_ED_DESIGNATOR ,'N')
                        AND   nvl(ed_renumber   ,'N')          = nvl(v_ED_RENUMBER   ,'N')
                        AND   i.image=v_IMAGE
                        AND   i.obsolete='N'
                        AND   i.publish='V'    ) LOOP
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
                             ,record.family
                             ,v_IMAGE
                             ,v_FEATURE_SET_DESC       --FEATUREDESC
                             ,v_FEATURE_SET_DESIGNATOR --FEATURESET
                             ,NULL                     --AVAILABLE
                             ,'Y'                      --DISPLAY
                             ,'V'                      --PUBLISH
                             ,'N'                      --OBSOLETE
                             ,0                        --PARENT
                           );
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
                                               feature_seq.currval   --key
                                               ,'40-0004-01'         --mfgpartno
                                               ,'S'                  --pfxsys
                                               ,'S'                  --pfxspr
                                               ,NULL                 --pfxupg
                                               ,0                   --pricesys
                                               ,0                   --pricespr
                                               ,0                   --priceupg
                                               ,'N'                  --OBSOLETE
                                               ,NULL                 --pcode_sys
                                               ,NULL                 --pcode_spr
                                               ,NULL                 --pcode_upg
                                            );
                          BEGIN
                             SELECT count(1) INTO v_family_already_exists
                             FROM family
                             WHERE release                 = v_RELEASE
                             AND   maintenance             = v_MAINTENANCE
                             AND   nvl(mrenumber     ,'N') = nvl(v_MRENUMBER     ,'N')
                             AND   nvl(ed_designator ,'N') = nvl(v_ED_DESIGNATOR ,'N')
                             AND   nvl(ed_renumber   ,'N') = nvl(v_ED_RENUMBER   ,'N')
                             AND   family=record.family;

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
                                   VALUES( v_RELEASE
                                        ,v_MAINTENANCE
                                        ,v_MRENUMBER
                                        ,v_ED_DESIGNATOR
                                        ,v_ED_RENUMBER
                                        ,record.family
                                        ,'N'
                                        ,NULL
                                        ,NULL
                                       );
                            END IF;
                     END LOOP;
              END IF;
       ELSE
        p_outmessage :='Invalid Action has been sent to SIIS API';
       END IF;
    IF( p_ACTION ='add_fset' AND v_feature_already_exists <1 AND SQL%ROWCOUNT <1) THEN
     --DBMS_OUTPUT.PUT_LINE('Number of rows update is'|| SQL%ROWCOUNT);
       p_outmessage :='No Upgrade planner records have been Created in SIIS FEATURE table';
       RAISE not_update_exception;
    END IF;

    EXCEPTION

    WHEN null_param_exception THEN
    BEGIN
            p_outmessage := 'Warning: NULL parameters found check parameters value! '
                        ||' Release              =' || p_RELEASE
                        ||' Maintenance          =' || p_MAINTENANCE
                        ||' Image                =' || p_IMAGE
                       ;
    END;
    WHEN not_update_exception THEN
    BEGIN
      NULL;
    END;

    WHEN OTHERS THEN
    BEGIN
         p_outmessage := 'OTHERS BLOCK '||substr(sqlerrm,1,512);
         --RAISE_APPLICATION_ERROR(-20001, p_outmessage);
    END;
END;
