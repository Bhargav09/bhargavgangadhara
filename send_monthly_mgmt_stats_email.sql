--Copyright (c) 2005-2006 by Cisco Systems, Inc.

CREATE OR REPLACE PROCEDURE Send_Monthly_Mgmt_Stats_Email ( dateofmonthyear DATE)
AS
   crlf                  CONSTANT VARCHAR2 (10)       := UTL_TCP.crlf;
   boundary              CONSTANT VARCHAR2 (256)
                                           := '-----7D81B75CCC90D2974F7A1CBD';
   first_boundary        CONSTANT VARCHAR2 (256)  := '--' || boundary || crlf;
   last_boundary         CONSTANT VARCHAR2 (256)
                                          := '--' || boundary || '--' || crlf;
   multipart_mime_type   CONSTANT VARCHAR2 (256)
                    := 'multipart/mixed;
   --boundary="' ||    boundary || '"';
   conn                           UTL_SMTP.connection;
   from_name                      VARCHAR2 (255) := 'SPRIT: SHR_RDA Database';
   from_address                   VARCHAR2 (255)      := 'cspr-eng@cisco.com';
   to_address                     VARCHAR2 (255)      := 'cspr-eng@cisco.com';
   cc_address                     VARCHAR2 (255)      := '';
   subject                        VARCHAR2 (255)
                          := 'SPRIT : Accumalated Publishing Statistics [Nov-2005 TO ' || TO_CHAR(dateofmonthyear,'Mon-YYYY') || ']';
--   mime_type                      VARCHAR2 (255)      := 'text/html';
   mime_type                      VARCHAR2 (255)      := 'text/csv; name="status.csv"';
   attachment_file_name           VARCHAR2 (2500)
                                              := 'SPRIT-Publishing-Status-' || TO_CHAR(dateofmonthyear,'Mon-YYYY') || '.csv';
   mailhost                       VARCHAR2 (255)      := '127.0.0.1';
   postrelnumber                      VARCHAR2 (256);
   repostrelnumber                      VARCHAR2 (256);
   postrelcount                   NUMBER;
   postimagecount                 NUMBER;
   repostrelcount                 NUMBER;
   repostimagecount               NUMBER;
   
   timeforpostingimage            NUMBER;
   totaltimeforpostingimage       NUMBER;
   avgtimeforpostingimage         NUMBER;
   mintimeforpostingimage         NUMBER;
   maxtimeforpostingimage         NUMBER;    

   timeforrepostingimage            NUMBER;
   totaltimeforrepostingimage       NUMBER;
   avgtimeforrepostingimage         NUMBER;
   mintimeforrepostingimage         NUMBER;
   maxtimeforrepostingimage         NUMBER;    

   
   PROCEDURE send_header (NAME IN VARCHAR2, header IN VARCHAR2)
   IS
   BEGIN
      UTL_SMTP.write_data (conn, NAME || ': ' || header || crlf);
   END;
   
BEGIN

  -- The Stored Procedure objective is to provide Posting/Reposting Statistics to the management.
  -- Its emails the repost in comma separated file. It has two types of datasets within it
  -- a. Accumulated Information for all the months since Nov 2005. 
        --Month
		--Posted Releases
		--RePosted Releases
		--Posted Images
		--RePosted Images
		--Posted-Total Time (mins)
		--Posted-Min. Time (mins)
		--Posted-Max. Time (mins)
		--Posted-Avg. Time (mins)
		--RePosted-Total Time (mins)
		--RePosted-Min. Time (mins)
		--RePosted-Max. Time (mins)
		--RePosted-Avg. Time (mins)
  
  -- b. Monthly report of the following info of the whole month for which CRON executed  
        --Software Type Name
		--Transaction Type
		--Release #
		--Total Images
		--Total Publishing Time (mins)
		--Transaction Status
		--Posted by
		--Posting Time
		--Published Time


   -- Setup SMTP for email
   conn := UTL_SMTP.open_connection (mailhost);
   UTL_SMTP.helo (conn, mailhost);
   UTL_SMTP.mail (conn, '< ' || from_address || ' >');
   UTL_SMTP.rcpt (conn, '< ' || to_address || ' >');
   UTL_SMTP.open_data (conn);
   send_header ('From', '"' || from_name || '" <' || from_address || '>');
   send_header ('To', '' || to_address || '');
   cc_address := to_address;
   send_header ('cc', '' || cc_address || '');
   send_header ('Date', TO_CHAR (SYSDATE, 'dd Mon yy hh24:mi:ss'));
   send_header ('Subject',
                subject);

   --------------------------
   -- Setup for Mime type Multipart, so that a report can be sent as a file.
   send_header('Content-Transfer-Encoding','binary');
   send_header('Content-Type','multipart/mixed; boundary="_----------=_112068030119160"');
   send_header('MIME-Version','1.0');

   utl_smtp.write_data(conn, utl_tcp.CRLF || 'This is a multi-part message in MIME format.');
   utl_smtp.write_data(conn, utl_tcp.CRLF);
   utl_smtp.write_data(conn, utl_tcp.CRLF || '--_----------=_112068030119160');
   utl_smtp.write_data(conn, utl_tcp.CRLF || 'Content-Disposition: inline');
   utl_smtp.write_data(conn, utl_tcp.CRLF || 'Content-Transfer-Encoding: binary');
   utl_smtp.write_data(conn, utl_tcp.CRLF || 'Content-Type: text/plain');
   utl_smtp.write_data(conn, utl_tcp.CRLF);
   utl_smtp.write_data(conn, utl_tcp.CRLF || 'SPRIT : Accumalated Publishing Statistics from Nov, 2005 to ' || TO_CHAR(dateofmonthyear,'Mon, YYYY') || ' in CSV format data attached as ' || attachment_file_name);
   utl_smtp.write_data(conn, utl_tcp.CRLF || '--_----------=_112068030119160');
   utl_smtp.write_data(conn, utl_tcp.CRLF || 'Content-Disposition: inline; filename="'||attachment_file_name||'"');
   utl_smtp.write_data(conn, utl_tcp.CRLF || 'Content-Transfer-Encoding: binary');
   utl_smtp.write_data(conn, utl_tcp.CRLF || 'Content-Type: text/csv; name="'||attachment_file_name||'"');
   utl_smtp.write_data(conn, utl_tcp.CRLF);

   ---------------------------

   UTL_SMTP.write_data (conn, crlf);
   UTL_SMTP.write_data( conn,'Month,Posted Releases,RePosted Releases,,Posted Images,RePosted Images,,Posted-Total Time (mins),Posted-Min. Time (mins),Posted-Max. Time (mins),Posted-Avg. Time (mins),,RePosted-Total Time (mins),RePosted-Min. Time (mins),RePosted-Max. Time (mins),RePosted-Avg. Time (mins)');
   UTL_SMTP.write_data (conn, crlf);

   -- Do query for Report A. for following info
        --Month
		--Posted Releases
		--RePosted Releases
		--Posted Images
		--RePosted Images
		--Posted-Total Time (mins)
		--Posted-Min. Time (mins)
		--Posted-Max. Time (mins)
		--Posted-Avg. Time (mins)
		--RePosted-Total Time (mins)
		--RePosted-Min. Time (mins)
		--RePosted-Max. Time (mins)
		--RePosted-Avg. Time (mins)

   FOR monthLog IN (SELECT DISTINCT TO_CHAR(adm_timestamp, 'Mon-YYYY') mont, TO_CHAR(adm_timestamp, 'YYYYMM') montno
                    FROM   cspr_ypublish_trans_log cytl
					WHERE  cytl.transaction_status = 'Success'
					AND    adm_timestamp BETWEEN TO_DATE('11-01-2005','MM-DD-YYYY') AND dateofmonthyear
				    ORDER BY montno) LOOP								
   
   postrelnumber := 'ABC';
   repostrelnumber := 'ABC';
   postrelcount := 0;
   repostrelcount := 0;
   postimagecount := 0;
   repostimagecount := 0;
   mintimeforpostingimage := 1000000;
   maxtimeforpostingimage := 0;
   totaltimeforpostingimage := 0;
   avgtimeforpostingimage := 0;
   mintimeforrepostingimage := 1000000;
   maxtimeforrepostingimage := 0;
   totaltimeforrepostingimage := 0;
   avgtimeforrepostingimage := 0;
   
   FOR transactionlog IN (SELECT RELEASE_NUMBER, 
                                 image_name,
								 cytl.transaction_type,
								 cyil.adm_timestamp, 
								 cytl.created_date
                          FROM   cspr_ypublish_image_log cyil,
                                 cspr_ypublish_trans_log cytl
                          WHERE  cytl.transaction_id = cyil.transaction_id
						  AND	 transaction_status = 'Success'
						  AND    transaction_type IN ('Post','Repost')
                          AND    TO_CHAR (cytl.adm_timestamp, 'Mon-YYYY') = monthLog.mont
						  ORDER BY RELEASE_NUMBER)
      LOOP

         IF ((postrelnumber != transactionlog.RELEASE_NUMBER) AND transactionlog.transaction_type = 'Post')
         THEN
            postrelcount := postrelcount + 1;
            postrelnumber := transactionlog.RELEASE_NUMBER;
         END IF;

         IF ((repostrelnumber != transactionlog.RELEASE_NUMBER) AND transactionlog.transaction_type = 'Repost')
         THEN
            repostrelcount := repostrelcount + 1;
            repostrelnumber := transactionlog.RELEASE_NUMBER;
         END IF;
		 
         IF (transactionlog.transaction_type = 'Post')
         THEN
            postimagecount := postimagecount + 1;
			
			timeforpostingimage :=
              (transactionlog.adm_timestamp - transactionlog.created_date
              ) * 24 * 60;
            totaltimeforpostingimage := totaltimeforpostingimage + timeforpostingimage;

            IF (mintimeforpostingimage > timeforpostingimage)
            THEN
               mintimeforpostingimage := timeforpostingimage;
            END IF;

            IF (maxtimeforpostingimage < timeforpostingimage)
            THEN
               maxtimeforpostingimage := timeforpostingimage;
            END IF;

         END IF;

         IF (transactionlog.transaction_type = 'Repost')
         THEN
            repostimagecount := repostimagecount + 1;
			
			timeforrepostingimage :=
              (transactionlog.adm_timestamp - transactionlog.created_date
              ) * 24 * 60;
            totaltimeforrepostingimage := totaltimeforrepostingimage + timeforrepostingimage;

            IF (mintimeforrepostingimage > timeforrepostingimage)
            THEN
               mintimeforrepostingimage := timeforrepostingimage;
            END IF;

            IF (maxtimeforrepostingimage < timeforrepostingimage)
            THEN
               maxtimeforrepostingimage := timeforrepostingimage;
            END IF;

         END IF;
		 
		 

      END LOOP;

      avgtimeforpostingimage := totaltimeforpostingimage / postimagecount;
      avgtimeforrepostingimage := totaltimeforrepostingimage / repostimagecount;						  
      UTL_SMTP.write_data (conn,
                           monthLog.mont
                           || ','
                           || postrelcount
                           || ','
                           || repostrelcount
                           || ',,'						   
                           || postimagecount
                           || ','
                           || repostimagecount
                           || ',,'
						   || ROUND(totaltimeforpostingimage)
                           || ','						   
						   || ROUND(mintimeforpostingimage)
                           || ','						   
						   || ROUND(maxtimeforpostingimage)
                           || ','						   
						   || ROUND(avgtimeforpostingimage)						   
                           || ',,'
						   || ROUND(totaltimeforrepostingimage)
                           || ','						   
						   || ROUND(mintimeforrepostingimage)
                           || ','						   
						   || ROUND(maxtimeforrepostingimage)
                           || ','						   
						   || ROUND(avgtimeforrepostingimage)						   
                          );						  
						  
      UTL_SMTP.write_data(conn, crlf);
   END LOOP;

   -- Do query for Report B. for following info
        --Software Type Name
		--Transaction Type
		--Release #
		--Total Images
		--Total Publishing Time (mins)
		--Transaction Status
		--Posted by
		--Posting Time
		--Published Time

   
   UTL_SMTP.write_data(conn, crlf);
   UTL_SMTP.write_data(conn, crlf);
   UTL_SMTP.write_data(conn,'Software Type Name,Transaction Type,Release #,Total Images,Total Publishing Time (mins),Transaction Status,Posted by,Posting Time,Published Time' );
   UTL_SMTP.write_data(conn, crlf);
   
   FOR x IN (
               SELECT sot.os_type_name a
                      , cytl.transaction_type b
                      , RELEASE_NUMBER c
                      , COUNT(image_name) d
                      , ROUND((MAX(cyil.adm_timestamp)-cytl.created_date)*24*60) e
                      , cytl.transaction_status f
                      , cyil.created_by g
                      , TO_CHAR(cytl.created_date, 'Dy DD-Mon-YYYY HH24:MI:SS') h
                      , TO_CHAR(MAX(cyil.adm_timestamp), 'Dy DD-Mon-YYYY HH24:MI:SS') i
               FROM   cspr_ypublish_image_log cyil
                      , cspr_ypublish_trans_log cytl
                      , SHR_OS_TYPE sot
               WHERE  sot.os_type_id = cytl.os_type_id
                      AND cytl.transaction_id = cyil.transaction_id
                      AND cytl.transaction_status = 'Success'
                      AND (TO_CHAR(cyil.adm_timestamp, 'Mon-YYYY') = TO_CHAR(dateofmonthyear, 'Mon-YYYY'))  
               GROUP BY RELEASE_NUMBER
                        , cytl.transaction_type
                        , sot.os_type_name
                        , cyil.created_by
                        , cytl.created_date
                        , cytl.transaction_status
               ORDER BY cytl.created_date DESC
            ) LOOP

       utl_smtp.write_data(conn,'"'||x.a||'"' || ',' || x.b || ','|| x.c || ',' || x.d || ','|| x.e || ','|| x.f || ',' || x.g || ',' || x.h || ',' || x.i );
       utl_smtp.write_data(conn, CRLF);

   END LOOP;

   -- Close connection
   UTL_SMTP.close_data (conn);
   UTL_SMTP.quit (conn);
   
END;
/

