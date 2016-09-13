 -------------------------------------------------------------------
-- Copyright (c) 2010-2011 by cisco Systems, Inc. All rights reserved.
--
-- Funciton: grant privilege for large file publishing and gdcp
--           migration activity
-- Created by :   bhtrived 
-- Created at:    Feb 2011
-------------------------------------------------------------------
 
--Prioritization workflow
 Grant all on  cspr_sw_prioritization          to   shr_rda;
 
 Grant all on  cspr_sw_prioritization_seq      to   shr_rda;
 
 Grant all on  cspr_sw_prioritization_details   to   shr_rda;
 
 Grant all on  cspr_sw_prioritization_d_seq    to   shr_rda;
 
-- Messaging enhancement 
 Grant all on  CSPR_YPUBLISH_MESSAGE_LOG       to   shr_rda;
 Grant all on  CSPR_YPUBLISH_MESSAGE_LOG_SEQ       to   shr_rda;
 