 -------------------------------------------------------------------
-- Copyright (c) 2010-2011 by cisco Systems, Inc. All rights reserved.
--
-- Funciton: grant privilege for large file publishing and gdcp
--           migration activity
-- Created by :   bhtrived 
-- Created at:    Feb 2011
-------------------------------------------------------------------
 
 --Prioritization workflow
 create or replace synonym  cspr_sw_prioritization           for sprit.cspr_sw_prioritization;
 
 create or replace synonym  cspr_sw_prioritization_seq    	 for sprit.cspr_sw_prioritization_seq;
 
 create or replace synonym  cspr_sw_prioritization_details    for sprit.cspr_sw_prioritization_details;
 
 create or replace synonym  cspr_sw_prioritization_d_seq      for sprit.cspr_sw_prioritization_d_seq;

-- Messaging enhancement
 create or replace synonym  CSPR_YPUBLISH_MESSAGE_LOG      for sprit.CSPR_YPUBLISH_MESSAGE_LOG;
 create or replace synonym  CSPR_YPUBLISH_MESSAGE_LOG_SEQ  for sprit.CSPR_YPUBLISH_MESSAGE_LOG_SEQ;
