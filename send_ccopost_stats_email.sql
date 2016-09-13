--Copyright (c) 2005 by Cisco Systems, Inc.

CREATE OR REPLACE Procedure send_stats_email as

   CRLF CONSTANT                 varchar2(10)  := utl_tcp.CRLF;
   BOUNDARY CONSTANT             varchar2(256) := '-----7D81B75CCC90D2974F7A1CBD';
   FIRST_BOUNDARY CONSTANT       varchar2(256) := '--'||BOUNDARY||CRLF;
   LAST_BOUNDARY CONSTANT        varchar2(256) := '--'||BOUNDARY||'--'||CRLF;
   MULTIPART_MIME_TYPE CONSTANT  varchar2(256) := 'multipart/mixed;
   --boundary="'||BOUNDARY||'"';

   conn utl_smtp.connection;
   from_name                     varchar2(255) := 'SPRIT: SHR_RDA Database';
   from_address                  varchar2(255) := 'cspr-eng@cisco.com';
   to_address                    varchar2(255) := 'cspr-eng@cisco.com';
   cc_address                    varchar2(255) := '';
   subject                       varchar2(255) := 'SPRIT-YPublish : Posting Publishing Statistics';
   mime_type                     varchar2(255) := 'text/html'; --'xls/csv';
   attachment_file_name          varchar2(2500) := 'c:\extracts\hosp\stats.htm';
   mailhost                      varchar2(255) := '127.0.0.1';

   Procedure send_header(name   in varchar2,
                         header in varchar2) is

   begin
      utl_smtp.write_data(conn, name||': '||header||CRLF);
   End;

BEGIN

   conn := utl_smtp.open_connection(mailhost);
   utl_smtp.helo(conn,mailhost);
   utl_smtp.mail(conn,'< '||from_address||' >');
   utl_smtp.rcpt(conn,'< '||to_address||' >');
   utl_smtp.open_data(conn);
   send_header('From','"'||from_name||'" <'||from_address||'>');
   send_header('To',''||to_address||'');
   cc_address := to_address;
   send_header('cc',''||cc_address||'');
   send_header('Date',to_char (sysdate, 'dd Mon yy hh24:mi:ss'));
   send_header('Subject',subject || ' [' || to_char (sysdate, 'Dy dd-Mon-yy') || ']');
   -- send_header('Content-Type',MULTIPART_MIME_TYPE);
   send_header('Content-Type',mime_type);
   -- Close header section by a crlf on its own
   utl_smtp.write_data(conn,CRLF);
   -- utl_smtp.write_data(conn,'This is a multi-part message in MIME format.'||CRLF);

   ----------------------------------------
   -- Send the main message text
   ----------------------------------------
   -- mime header
   -- utl_smtp.write_data(conn, FIRST_BOUNDARY);
   -- send_header('Content-Type',mime_type);
   utl_smtp.write_data(conn, CRLF);
   utl_smtp.write_data(conn,'<html><HEAD><TITLE>SPRIT-YPublish : Posting Publishing Statistics</TITLE><style type="text/css">');
   utl_smtp.write_data(conn,'.adminline {');
   utl_smtp.write_data(conn,'font: 4px verdana, arial, sans-serif;');
   utl_smtp.write_data(conn,'width: 200px;');
   utl_smtp.write_data(conn,'}');
   utl_smtp.write_data(conn,'</style></head>');
   utl_smtp.write_data(conn,'<body><BR><b><H2>SPRIT-YPublish : Posting Publishing Statistics</H2></b>');
   utl_smtp.write_data(conn,'<H6><FONT FACE="arial" SIZE="1">');
   utl_smtp.write_data(conn,'<TABLE BORDER=1 CELLSPACING=0 CELLPADDING=5 frame="border" rules="all"><B><TR><TH> Software Type Name </TH><TH> Transaction Type </TH><TH>Release #</TH><TH> Total Images </TH><TH>Total Publishing Time (mins)</TH><TH> Transaction Status </TH><TH>Posted by</TH><TH>Posting Time</TH><TH>Published Time</TH></TH>' );

   for x in (
               select sot.os_type_name a
                      , cytl.transaction_type b
                      , release_number c
                      , count(image_name) d
                      , round((max(cyil.adm_timestamp)-cytl.created_date)*24*60) e
					  , cytl.transaction_status f
                      , cyil.created_by g
                      , to_char(cytl.created_date, 'Dy DD-Mon-YYYY HH24:MI:SS') h
                      , to_char(max(cyil.adm_timestamp), 'Dy DD-Mon-YYYY HH24:MI:SS') i
               from   cspr_ypublish_image_log cyil
                      , cspr_ypublish_trans_log cytl
                      , shr_os_type sot
               where  sot.os_type_id = cytl.os_type_id
                      and cytl.transaction_id = cyil.transaction_id
--                      and cytl.transaction_status = 'Success'
                      and (   to_char(cyil.adm_timestamp, 'DD-Mon-YYYY') = to_char(sysdate, 'DD-Mon-YYYY') 
					       OR to_char(cytl.created_date, 'DD-Mon-YYYY') = to_char(sysdate, 'DD-Mon-YYYY')
						  )  
               group by release_number
                        , cytl.transaction_type
                        , sot.os_type_name
                        , cyil.created_by
                        , cytl.created_date
						, cytl.transaction_status
               order by cytl.created_date desc

            ) loop

       utl_smtp.write_data(conn, '<TR><TD>' || x.a || '</TD><TD>' || x.b || '</TD><TD>'|| x.c || '</TD><TD>' || x.d || '</TD><TD>'|| x.e || '</TD><TD>'|| x.f || '</TD><TD>' || x.g || '</TD><TD>' || x.h || '</TD><TD>' || x.i || '</TD></TR>' );
       utl_smtp.write_data(conn, CRLF);

  end loop;
  utl_smtp.write_data(conn,'</TABLE>');
  utl_smtp.write_data(conn,'</FONT></H6>');
  utl_smtp.write_data(conn, '</body></html>');
  utl_smtp.write_data(conn, CRLF);

  -- Close connection
  utl_smtp.close_data(conn);
  utl_smtp.quit(conn);

end;
/
