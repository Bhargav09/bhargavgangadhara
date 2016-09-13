--Copyright (c) 2004 by Cisco Systems, Inc.
CREATE OR REPLACE VIEW MFG_RELEASE_OWNER ( RELEASE, 
OWNER ) AS select release||'('||maintenance||mrenumber||')'||ed_designator||ed_renumber Release,owner
from release_stat  
where tableid='I';
