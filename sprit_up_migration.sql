--Copyright (c) 2003 by Cisco Systems, Inc.

BEGIN

Insert Into shr_feature_set_desc
            (feature_set_desc_id,
             feature_set_desc,
             adm_timestamp,
             adm_userid,
             adm_flag,
             adm_comment
            )
Select          shr_feature_set_desc_seq.nextval,
                feature_set_desc,
                adm_timestamp,
                adm_userid,
                adm_flag,
                adm_comment
From   
    (Select distinct  featuredesc                            feature_set_desc
		     ,sysdate                                adm_timestamp
                     ,'MIGRATED'                             adm_userid
                     ,'V'                                    adm_flag
                     ,'Migrated from SIIS feature table'     adm_comment
        From siis_test.feature f 
	Where f.obsolete='N'
        AND featuredesc is not null
        AND featuredesc != '?');

--*************************************************************************************

Insert Into shr_feature_set_designator
            (feature_set_designator_id,
             feature_set_designator,
             adm_timestamp,
             adm_userid,
             adm_flag,
             adm_comment
            )
Select          shr_feature_set_designator_seq.nextval,
                feature_set_designator,
                adm_timestamp,
                adm_userid,
                adm_flag,
                adm_comment
From   
       (Select distinct  featureset                          feature_set_designator
                     ,sysdate                                adm_timestamp
                     ,'MIGRATED'                             adm_userid
                     ,'V'                                    adm_flag
                     ,'Migrated from SIIS feature table'     adm_comment
        From siis_test.feature f
        Where f.obsolete='N'
        AND featureset is not null
       );

--**************************************************************************************

Insert INTO shr_feature_set
          (feature_set_id
		   ,image_prefix_id
		   ,feature_set_name_id
		   ,feature_set_desc_id
		   ,feature_set_designator_id
		   ,adm_timestamp
		   ,adm_userid
		   ,adm_flag
		   ,adm_comment
		   )
select shr_feature_set_seq.nextval
        ,image_prefix_id
		,feature_set_name_id
		,feature_set_desc_id
		,feature_set_designator_id
		,adm_timestamp
		,adm_userid
		,adm_flag
		,adm_comment
From( select distinct sip.image_prefix_id    image_prefix_id
      ,sfn.feature_set_name_id               feature_set_name_id
      ,sfd.feature_set_desc_id               feature_set_desc_id
	  ,sfdr.feature_set_designator_id        feature_set_designator_id
	  ,sysdate                               adm_timestamp
	  ,'MIGRATED'                            adm_userid
	  ,'V'                                   adm_flag
	  ,'Migrated from SIIS feature table'    adm_comment
      /*,sfd.feature_set_desc
      ,sfdr.feature_set_designator
      ,sfn.feature_set_name
	  ,sip.image_prefix_name
	  ,f.image
	  ,f.featuredesc
	  ,f.featureset
	  */
from
     shr_feature_set_desc        sfd,
	 shr_feature_set_designator  sfdr,
	 shr_feature_set_name        sfn,
	 shr_image_prefix            sip,
	 siis_test.feature            f
where
     f.featuredesc = sfd.feature_set_desc
and  f.obsolete='N'
and	 f.featureset  = sfdr.feature_set_designator(+)
and  substr(f.image,1,decode(instr(f.image,'-',1,1),0,decode(instr(f.image,'_',1,1),0,length(f.image)+1
                                                                                                    ,instr(f.image,'_',1,1))
                                                                 ,instr(f.image,'-',1,1) )-1) = sip.image_prefix_name
and  decode(substr(f.image,instr(f.image,'-',1,1)+1,instr(f.image,'-',1,2)-(instr(f.image,'-',1,1)+1) ),null,'No Fset'
                        ,substr(f.image,instr(f.image,'-',1,1)+1,instr(f.image,'-',1,2)-(instr(f.image,'-',1,1)+1) ))=sfn.feature_set_name
);

--**************************************************************************************************************

DECLARE
    CURSOR siis_fcur IS
    SELECT distinct release||'('||maintenance||mrenumber||')'||ed_designator||ed_renumber relstring
                   ,image
                   ,i.image_id
                   ,featuredesc
                   ,featureset
    FROM
          shr_release_number r
         ,shr_major_release m
         ,shr_image i
         ,siis_test.feature f
         ,shr_platform_image spi
    WHERE f.obsolete='N'
    AND   m.major_release_id = r.major_release_id
    AND   i.release_number_id=r.release_number_id
    AND   i.image_id         =spi.image_id
    AND   i.is_obsolete='N'
    AND   i.adm_flag='V'
    AND   spi.adm_flag='V'
    AND   m.major_release_number||'('||r.zabp||')'||r.a||r.o = f.release||'('||f.maintenance||f.mrenumber||')'||f.ed_designator||f.ed_renumber
    AND   i.image_name                                       =f.image
    AND   featuredesc is not null
    ORDER BY 1,2,3,4
    ;


   CURSOR shr_rda_fsetcur (l_image_name             varchar2
                          ,l_feature_set_desc       varchar2
                          ,l_feature_set_designator varchar2 ) IS
   SELECT feature_set_id
   FROM
         shr_feature_set             sfs,
         shr_feature_set_name        sfn,
         shr_image_prefix            sip,
         shr_feature_set_desc        sfsd,
         shr_feature_set_designator  sfsdr
   WHERE
           sfs.image_prefix_id= sip.image_prefix_id
   AND      sfs.feature_set_name_id =sfn.feature_set_name_id
   AND      sfs.feature_set_desc_id =sfsd.feature_set_desc_id
   AND      sfs.feature_set_designator_id = sfsdr.feature_set_designator_id(+)
   AND      sfn.feature_set_name =decode(substr(l_image_name,instr(l_image_name,'-',1,1)+1,instr(l_image_name,'-',1,2)-(instr(l_image_name,'-',1,1)+1) ),null, 'No Fset' ,substr(l_image_name,instr(l_image_name,'-',1,1)+1,instr(l_image_name,'-',1,2)-(instr(l_image_name,'-',1,1)+1) ))
   AND      sip.image_prefix_name =substr(l_image_name,1,decode(instr(l_image_name,'-',1,1),0,decode(instr(l_image_name,'_',1,1),0,length(l_image_name)+1 ,instr(l_image_name,'_',1,1)) ,instr(l_image_name,'-',1,1) )-1) 
   AND      sfsd.feature_set_desc =l_feature_set_desc
   AND      nvl(sfsdr.feature_set_designator,'X') = nvl(l_feature_set_designator,'X')
   ; 

  BEGIN

    FOR c1 in siis_fcur  LOOP
     FOR c2 in shr_rda_fsetcur(c1.image,c1.featuredesc,c1.featureset)LOOP
      INSERT INTO shr_image_feature_set
               ( image_feature_set_id
                ,image_id
                ,feature_set_id
                ,adm_timestamp
                ,adm_userid
                ,adm_flag
                ,adm_comment
               )
            VALUES(
                   shr_image_feature_set_seq.nextval
                   ,c1.image_id
                   ,c2.feature_set_id
                   ,sysdate
                   ,'MIGRATED'
                   ,'V'
                   ,'Migrated from SIIS'
                  );
     END LOOP;
    END LOOP;
   END;

END;
