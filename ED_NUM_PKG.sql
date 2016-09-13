/**************************************************
Copyright (c) 2005-2007 by Cisco Systems, Inc.

Created for ED Renumber Sorting

Author: Qingbo Kong (qkong)
Date  : 06/13/2007
**************************************************/

CREATE OR REPLACE Package ED_NUM_PKG
IS

FUNCTION ED_NUM_GEN(p_str VARCHAR2) RETURN VARCHAR2;

FUNCTION ED_NUM_GEN_PAD(p_str VARCHAR2, p_pad NUMBER) RETURN VARCHAR2;

FUNCTION WHAT_IS(i_char VARCHAR2) RETURN VARCHAR2;

END ED_NUM_PKG;
/



CREATE OR REPLACE PACKAGE BODY ED_NUM_PKG
IS

  FUNCTION ED_NUM_GEN( p_str IN VARCHAR2 )
	RETURN VARCHAR2
  AS
  BEGIN
	RETURN ED_NUM_GEN_PAD(p_str, 5);
  END ED_NUM_GEN;

  FUNCTION ED_NUM_GEN_PAD( p_str IN VARCHAR2, p_pad IN NUMBER )
	RETURN VARCHAR2
  AS
	   v_str   VARCHAR2(10);
	   v_char  VARCHAR2(1);
	   v_stat  VARCHAR2(1);
	   v_len   NUMBER;
	   v_cnt   NUMBER;
	   v_stg   NUMBER := 1;
	   v_p1    VARCHAR2(100) := NULL;
	   v_p2    VARCHAR2(100) := NULL;
	   v_p4    VARCHAR2(100) := NULL;
	   v_p5    VARCHAR2(100) := NULL;
	   v_p7    VARCHAR2(100) := NULL;
	   v_out   VARCHAR2(1000) := NULL;
	   pad_len NUMBER := p_pad;

  BEGIN

	IF (p_str IS NULL) THEN
		 v_out := lpad('0',pad_len,'0')||lpad('0',pad_len,'0')||lpad('0',pad_len,'0')||
				 lpad('0',pad_len,'0')||lpad('0',pad_len,'0');
	  --DBMS_OUTPUT.PUT_LINE('Input String is NULL');
	  return v_out;
	END IF;

	v_str := p_str;
	v_len := length(p_str);
	--DBMS_OUTPUT.PUT_LINE('Input String is '||p_str);
	--DBMS_OUTPUT.PUT_LINE('STR_LEN= '||v_len);

	FOR i IN 1..v_len
	LOOP
	  v_char := substr(v_str,i,1);
		v_stat := WHAT_IS(v_char);
		-- DBMS_OUTPUT.PUT_LINE(v_char ||' == '||v_stat);

		IF (v_stat = 'E') THEN
		  v_out := lpad('ERROR',pad_len,'0')||lpad('ERROR',pad_len,'0')||lpad('ERROR',pad_len,'0')||
					 lpad('ERROR',pad_len,'0')||lpad('ERROR',pad_len,'0');
		  RETURN v_out;
		END IF;

		-- determine which group we are handling
		LOOP
		  EXIT WHEN (v_stg=1 AND v_stat='N');
			EXIT WHEN (v_stg=2 AND v_stat='A');
			EXIT WHEN (v_stg=3 AND v_stat='O');
			EXIT WHEN (v_stg=4 AND v_stat='N');
			EXIT WHEN (v_stg=5 AND v_stat='A');
			EXIT WHEN (v_stg=6 AND v_stat='C');
			EXIT WHEN (v_stg=7 AND v_stat='A');

		  IF (v_stg=1 AND v_stat != 'N') THEN
			  v_stg := 2;
			ELSIF (v_stg=2 AND v_stat != 'A') THEN
			  v_stg := 3;
			ELSIF (v_stg=3 AND v_stat != 'O') THEN
			  v_stg := 4;
			ELSIF (v_stg=4 AND v_stat != 'N') THEN
			  v_stg := 5;
			ELSIF (v_stg=5 AND v_stat != 'A') THEN
			  v_stg := 6;
			ELSIF (v_stg=6 AND v_stat != 'C') THEN
			  v_stg := 7;
			END IF;
		END LOOP;

		-- processing character based on their group
		IF (v_stg=1 AND v_stat='N') THEN
		  v_p1 := v_p1||v_char;
			GOTO NEXT_ONE;
		END IF;

		IF (v_stg=2 AND v_stat='A') THEN
		  v_p2 := v_p2||v_char;
			GOTO NEXT_ONE;
		END IF;

		IF (v_stg=4 AND v_stat='N') THEN
		  v_p4 := v_p4||v_char;
			GOTO NEXT_ONE;
		END IF;

		IF (v_stg=5 AND v_stat='A') THEN
		  v_p5 := v_p5||v_char;
			GOTO NEXT_ONE;
		END IF;

		IF (v_stg=7 AND v_stat='A') THEN
		  v_p7 := v_p7||v_char;
			GOTO NEXT_ONE;
		END IF;

		<<NEXT_ONE>> NULL;

	  END LOOP;

	  -- fill the rest, if their value is missing or not long enough
	  IF (v_p1 IS NULL) THEN
		v_p1 := lpad('0',pad_len,'0');
	  ELSE
		v_p1 := lpad(v_p1,pad_len,'0');
	  END IF;

	  IF (v_p2 IS NULL) THEN
		v_p2 := lpad('0',pad_len,'0');
	  ELSE
		v_p2 := rpad(v_p2,pad_len,'0');
	  END IF;

	  IF (v_p4 IS NULL) THEN
		v_p4 := lpad('0',pad_len,'0');
	  ELSE
		v_p4 := lpad(v_p4,pad_len,'0');
	  END IF;

	  IF (v_p5 IS NULL) THEN
		v_p5 := lpad('0',pad_len,'0');
	  ELSE
		v_p5 := rpad(v_p5,pad_len,'0');
	  END IF;

	  IF (v_p7 IS NULL) THEN
		v_p7 := lpad('0',pad_len,'0');
	  ELSE
		v_p7 := rpad(v_p7,pad_len,'0');
	  END IF;

	v_out := v_p1||v_p2||v_p4||v_p5||v_p7;
	--DBMS_OUTPUT.PUT_LINE(v_out);
	RETURN v_out;
  END ED_NUM_GEN_PAD;

  --
  -- WHAT_IS returns following:
  --	A -- Alpha
  --	N -- Numeric
  --	C -- close parenthesis
  --	O -- open parenthesis
  --
  FUNCTION WHAT_IS(i_char IN VARCHAR2)
	RETURN VARCHAR2
  AS
	v_out VARCHAR2(1);
	  v_val NUMBER;
  BEGIN
	v_val:= ASCII(i_char);

	  IF (v_val>=65 AND v_val<=90 OR v_val>=97 AND v_val<=122) THEN
	  RETURN 'A';
	  ELSIF (v_val>=48 AND v_val<=57) THEN
	  RETURN 'N';
	  ELSIF (v_val=40) THEN
		RETURN 'O';
	  ELSIF (v_val=41) THEN
		RETURN 'C';
	  END IF;
	  RETURN 'E';

	EXCEPTION WHEN VALUE_ERROR THEN
	RETURN 'E';
  END WHAT_IS;

END ED_NUM_PKG;
/

