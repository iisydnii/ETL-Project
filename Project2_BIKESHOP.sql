/*
            SYDNI WARD
            PROJECT 2
            04/01/2021
*/
SET SERVEROUTPUT ON; 
/*-------------------------------------------------*/
/*                 Create Object                   */
/*-------------------------------------------------*/
CREATE OR REPLACE TYPE BIKE_OBJ AS OBJECT(
    CUSTOMERID NUMBER(38,0),
    SERIALNUMBER NUMBER(38,0)
);
/

/*-------------------------------------------------*/
/*             Create Table of Object              */
/*-------------------------------------------------*/
CREATE OR REPLACE TYPE BIKE_CSV_TABLE AS TABLE OF BIKE_OBJ;
/

/*-------------------------------------------------*/
/*                BIKESHOP PACKAGE                 */
/*-------------------------------------------------*/
CREATE OR REPLACE PACKAGE BIKESHOP AS
  PROCEDURE EXTRACT_BICYCLES(OUTPUT_TYPE CHAR);
  PROCEDURE EXTRACT_CUSTOMERS(OUTPUT_TYPE CHAR);
  FUNCTION  CUSTOMER_BIKES(CUSTOMERID NUMBER) RETURN BIKE_CSV_TABLE;
  PROCEDURE ARCHIVE_CUSTOMER_BIKES; 
END BIKESHOP;
/

/*-------------------------------------------------*/
/*            BIKESHOP PACKAGE BODY                */
/*-------------------------------------------------*/
CREATE OR REPLACE PACKAGE BODY BIKESHOP AS

/*---------------------------------------------------*/
/*          EXTRACT_BICYCLES PROCEDURE               */
/*---------------------------------------------------*/
    PROCEDURE EXTRACT_BICYCLES(OUTPUT_TYPE CHAR) IS
        CURSOR bInformation IS 
            SELECT
                "A1"."SERIALNUMBER"    "SERIALNUMBER",
                "A1"."MODELTYPE"       "MODELTYPE",
                "A1"."PAINTID"         "PAINTID",
                "A1"."FRAMESIZE"       "FRAMESIZE",
                "A1"."ORDERDATE"       "ORDERDATE",
                "A1"."STARTDATE"       "STARTDATE",
                "A1"."SHIPDATE"        "SHIPDATE",
                "A1"."CONSTRUCTION"    "CONSTRUCTION",
                "A1"."LISTPRICE"       "LISTPRICE",
                "A1"."SALEPRICE"       "SALEPRICE",
                "A1"."SALESTAX"        "SALESTAX",
                "A1"."SALESTATE"       "SALESTATE"
            FROM
                "BIKE_SHOP"."BICYCLE" "A1"
            ORDER BY A1.ORDERDATE asc;
        
        bRow bInformation%ROWTYPE; 
        Counter NUMBER := 0;
    BEGIN
        OPEN bInformation;
            IF OUTPUT_TYPE = 'D' THEN
            -- insert the data into the BICYCLES table within your own schema
            --COMMIT the transaction within the procedure. 
            --Output the number of records inserted to the console screen.
            LOOP
                FETCH bInformation INTO bRow;
                EXIT WHEN bInformation%NOTFOUND;
                    Counter := Counter + 1;
                    
                    INSERT INTO BICYCLES VALUES(bRow.SERIALNUMBER, bRow.MODELTYPE, 
                    bRow.PAINTID, bRow.FRAMESIZE, bRow.ORDERDATE, bRow.STARTDATE, 
                    bRow.SHIPDATE, bRow.CONSTRUCTION, bRow.LISTPRICE, bRow.SALEPRICE, 
                    bRow.SALESTAX, bRow.SALESTATE);
                    
                    commit;  
            END LOOP;
            
            DBMS_OUTPUT.PUT_LINE('Total Rows:   ' || Counter);
            
            ELSIF OUTPUT_TYPE = 'S' THEN
            --display the information to the screen in a well-formatted way
            --sort the records by ORDERDATE (ascending).
                LOOP
                    FETCH bInformation INTO bRow;
                    EXIT WHEN bInformation%NOTFOUND;
                        Counter := Counter + 1;
                        DBMS_OUTPUT.PUT_LINE(Counter || ').  ' ||bRow.SERIALNUMBER|| ', ' || bRow.ORDERDATE
                            || ', ' || bRow.MODELTYPE || ', ' || bRow.CONSTRUCTION );
                        DBMS_OUTPUT.PUT_LINE('  '|| bRow.PAINTID || ', ' || 
                            bRow.FRAMESIZE || ', ' || bRow.STARTDATE || ', ' ||
                            bRow.SHIPDATE || ', ' || bRow.LISTPRICE || ', ' || 
                            bRow.SALEPRICE || ', ' || bRow.SALESTAX || ', ' ||
                            bRow.SALESTATE);
                        DBMS_OUTPUT.PUT_LINE('');
                END LOOP;
            else
            DBMS_OUTPUT.PUT_LINE('');
            end if;
        CLOSE bInformation;
    END;

/*---------------------------------------------------*/
/*         EXTRACT_CUSTOMERS PROCEDURE               */
/*---------------------------------------------------*/
    PROCEDURE EXTRACT_CUSTOMERS(OUTPUT_TYPE CHAR) IS
        CURSOR cInformation IS 
            SELECT
                C1.CUSTOMERID, C1.LASTNAME, C1.FIRSTNAME, C1.PHONE, 
                C1.ADDRESS, C2.CITY, C2.STATE, C1.ZIPCODE
            FROM
                BIKE_SHOP.CUSTOMER C1
                LEFT JOIN BIKE_SHOP.CITY C2
                    ON C1.CITYID = C2.CITYID
            ORDER BY LASTNAME,
                    FIRSTNAME asc;
        
            cRow cInformation%ROWTYPE; 
            Counter NUMBER := 0;
        BEGIN
            OPEN cInformation;
                IF OUTPUT_TYPE = 'D' THEN
                -- insert the data into the CUSTOMERS table within your own schema
                --COMMIT the transaction within the procedure. 
                --Output the number of records inserted to the console screen.
                LOOP
                    FETCH cInformation INTO cRow;
                    EXIT WHEN cInformation%NOTFOUND;
                        Counter := Counter + 1;
                        
                        INSERT INTO CUSTOMERS VALUES(cRow.CUSTOMERID, cRow.LASTNAME,
                        cRow.FIRSTNAME, cRow.PHONE, cRow.ADDRESS, cRow.CITY,
                        cRow.STATE, cRow.ZIPCODE);
                        
                        commit;  
                END LOOP;
                
                DBMS_OUTPUT.PUT_LINE('Total Rows:   ' || Counter);
                
                ELSIF OUTPUT_TYPE = 'S' THEN
                --display the information to the screen in a well-formatted way
                --sort the records by ORDERDATE (ascending).
                    LOOP
                        FETCH cInformation INTO cRow;
                        EXIT WHEN cInformation%NOTFOUND;
                            DBMS_OUTPUT.PUT_LINE(cRow.CUSTOMERID || ' ' || cRow.LASTNAME 
                            || ', ' || cRow.FIRSTNAME);
                            DBMS_OUTPUT.PUT_LINE('-----------------------------------------');
                            DBMS_OUTPUT.PUT_LINE( 'Phone:   ' ||cRow.PHONE);
                            DBMS_OUTPUT.PUT_LINE( 'Address:   ' ||cRow.ADDRESS);
                            DBMS_OUTPUT.PUT_LINE( 'CITY/STATE/ZIP:   ' ||cRow.CITY || ', '||cRow.STATE || '  ' || cRow.ZIPCODE);
                            DBMS_OUTPUT.PUT_LINE('');
                    END LOOP;
                else
                DBMS_OUTPUT.PUT_LINE('');
                end if;
            CLOSE cInformation;
        END;

/*---------------------------------------------------*/
/*            CUSTOMER_BIKES FUNCTION                */
/*---------------------------------------------------*/
FUNCTION CUSTOMER_BIKES(CUSTOMERID NUMBER) RETURN BIKE_CSV_TABLE AS
    BIKE   BIKE_CSV_TABLE := BIKE_CSV_TABLE();
BEGIN
    SELECT * BULK COLLECT INTO BIKE
    FROM (SELECT BIKE_OBJ(CUSTOMERID, SERIALNUMBER) FROM BIKE_SHOP.BICYCLE)
    WHERE CUSTOMERID = CUSTOMERID;
 
    RETURN BIKE;
     
END;


/*---------------------------------------------------*/
/*          ARCHIVE_CUSTOMER_BIKES PROCEDURE         */
/*---------------------------------------------------*/  
PROCEDURE ARCHIVE_CUSTOMER_BIKES IS
    CURSOR cInformation IS
    
        SELECT CUSTOMERID 
        FROM CUSTOMERS
        WHERE CUSTOMERID = 285
        ORDER BY CUSTOMERID ASC;
     
     cRow cInformation%ROWTYPE;
     obj_table   BIKE_CSV_TABLE := BIKE_CSV_TABLE();
     obj_instance BIKE_OBJ;
     i NUMBER;
  BEGIN
  
         FOR cRow IN cInformation LOOP   
            DBMS_OUTPUT.PUT_LINE(cRow.CUSTOMERID);
            obj_table := CUSTOMER_BIKES(cRow.CUSTOMERID);  
            
           -- DBMS_OUTPUT.PUT_LINE(obj_table.CUSTOMERID, obj_table.SERIALNUMBER);
            
           -- SELECT ot.CUSTOMERID, ot.SERIALNUMBER 
              --  INTO CUSTOMER_BIKE
              --  FROM obj_table ot
               -- WHERE ot.CUSTOMERID = cRow.CUSTOMERID;
                
             --commit;   
         END LOOP;    
         
         FOR i IN obj_table.FIRST.. obj_table.LAST LOOP
           DBMS_OUTPUT.PUT_LINE('Customer:  ' || obj_table(i).CUSTOMERID || ', Bought: ' || obj_table(i).SERIALNUMBER);
           INSERT INTO CUSTOMER_BIKE VALUES ( obj_table(i).CUSTOMERID, obj_table(i).SERIALNUMBER);
           COMMIT;
         END LOOP;
         
  END;

END BIKESHOP;
/

