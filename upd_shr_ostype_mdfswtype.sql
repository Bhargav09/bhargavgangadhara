/*
	Copyright (c) 2008 by Cisco Systems, Inc.
	update shr_ostype_mdfswtype for Sprit 7.3 CSCsr10120 - Need to sort images by Date within a given Release
	
*/

update shr_ostype_mdfswtype set primary_sort_field='File_Name', secondary_sort_field='Publish_Date', primary_sorting_order='ASC', 
secondary_sorting_order='DESC' ;


update shr_ostype_mdfswtype set primary_sort_field='Publish_Date', secondary_sort_field='File_Name', primary_sorting_order='DESC', 
secondary_sorting_order='ASC' where os_type_id in (95, 118, 97, 104, 103,105);


commit;