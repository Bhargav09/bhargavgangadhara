--Copyright (c) 2003 by Cisco Systems, Inc.
Declare

CURSOR c1 is
Select release||'('||maintenance||mrenumber||')'||ed_designator||ed_renumber Rel,
   --rs.status,
   sds.deployment_status_id DSID
   --sds.deployment_status_name,
   --sds.deployment_status_Description
From release_stat rs,
     shr_deployment_status sds
Where tableid='U'
AND nvl(rs.status,'UNK')=sds.deployment_status_name;

Begin
   FOR c2 IN c1  LOOP
         UPDATE shr_release_number set deployment_status_id=c2.DSID
         WHERE release_number_id=(SELECT release_number_id
                                  FROM shr_release_number r
				       ,shr_major_release m
				  WHERE m.major_release_id = r.major_release_id
			          AND m.major_release_number||'('||r.zabp||')'||r.a||r.o=c2.Rel);
   END LOOP;
End;
