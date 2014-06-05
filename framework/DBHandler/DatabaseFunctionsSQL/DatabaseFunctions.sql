/* 
  All functions functions which have been added to database.
  Last update 01.06.2014
*/

1)
CREATE OR REPLACE FUNCTION photomultiplierInformationFunction()
RETURNS TABLE
(
  runid integer,
  setupid integer,
  hvpmconnid integer,
  isrightside boolean,
  slot_id integer,
  photomid integer
) AS
$BODY$
BEGIN
  FOR runid, setupid, hvpmconnid, isrightside, slot_id, photomid IN
    SELECT 
      "Run".id AS runid, 
      "Setup".id AS setupid, 
      "HVPMConnection".id AS hvpmconnid, 
      "HVPMConnection".isrightside, 
      "HVPMConnection".slot_id AS slot_id, 
      "PhotoMultiplier".id AS photomid 
    FROM "Run" 
      INNER JOIN "Setup" ON "Run".setup_id = "Setup".id 
      INNER JOIN "HVPMConnection" ON "Setup".id = "HVPMConnection".setup_id 
      INNER JOIN "PhotoMultiplier" ON "HVPMConnection".photomultiplier_id = "PhotoMultiplier".id 
    ORDER BY "HVPMConnection".slot_id
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM photomultiplierInformationFunction();

1.1)
CREATE OR REPLACE FUNCTION photomultiplierInformationFunction(IN p_run_id INTEGER)
RETURNS TABLE
(
  runid integer,
  setupid integer,
  hvpmconnid integer,
  isrightside boolean,
  slot_id integer,
  photomid integer
) AS
$BODY$
BEGIN
  FOR runid, setupid, hvpmconnid, isrightside, slot_id, photomid IN
    SELECT 
      "Run".id AS runid, 
      "Setup".id AS setupid, 
      "HVPMConnection".id AS hvpmconnid, 
      "HVPMConnection".isrightside, 
      "HVPMConnection".slot_id AS slot_id, 
      "PhotoMultiplier".id AS photomid 
    FROM "Run" 
      INNER JOIN "Setup" ON "Run".setup_id = "Setup".id 
      INNER JOIN "HVPMConnection" ON "Setup".id = "HVPMConnection".setup_id 
      INNER JOIN "PhotoMultiplier" ON "HVPMConnection".photomultiplier_id = "PhotoMultiplier".id 
    WHERE "Run".id = p_run_id
    ORDER BY "HVPMConnection".slot_id
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM photomultiplierInformationFunction(1);

2)
CREATE OR REPLACE FUNCTION runDataFunction()
RETURNS TABLE
(
  run_id integer,
  runstart timestamp without time zone,
  filepath character varying(255),
  rundescription character varying(255),
  information character varying(255)
) AS
$BODY$
BEGIN
  FOR run_id, runstart, filepath, rundescription, information IN
    SELECT 
      "Run".id AS run_id, 
      "Run".runstart AS runstart, 
      "Run".filepath AS filepath, 
      "Run".rundescription AS rundescription, 
      "Run".informations AS information 
    FROM "Run"
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM runDataFunction();

3)
CREATE OR REPLACE FUNCTION runDataFunction(IN p_run_id INTEGER)
RETURNS TABLE
(
  run_id integer,
  runstart timestamp without time zone,
  filepath character varying(255),
  rundescription character varying(255),
  information character varying(255)
) AS
$BODY$
BEGIN
  FOR run_id, runstart, filepath, rundescription, information IN
    SELECT 
      "Run".id AS run_id, 
      "Run".runstart AS runstart, 
      "Run".filepath AS filepath, 
      "Run".rundescription AS rundescription, 
      "Run".informations AS information 
    FROM "Run"
    WHERE "Run".id = p_run_id
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM runDataFunction(1);

4)
CREATE OR REPLACE FUNCTION sizeOfTableFunction
(
  p_tableName varchar(100)
)
RETURNS integer 
AS $$
DECLARE
  p_tableSize integer;
BEGIN
  execute 'SELECT count(*) from '||quote_ident(p_tableName) into p_tablesize;
  return p_tableSize;
END;
$$ LANGUAGE plpgsql STRICT;

SELECT * FROM sizeOfTableFunction('Run');

5)
CREATE OR REPLACE FUNCTION thresholdFromTRBConfigEntryBasedOnTOMBInputIdFunction(IN p_run_id INTEGER)
RETURNS TABLE
(
  tombinput_id INTEGER,
  trbtombconnection_id INTEGER,
  trboutput_id INTEGER,
  trbinput_id INTEGER,
  kbtrbconnection_id INTEGER,
  trbconfigentry_id INTEGER,
  trbconfigentry_threshold REAL,
  setup_id INTEGER,
  run_id INTEGER
) AS
$BODY$
BEGIN
  FOR tombinput_id, trbtombconnection_id, trboutput_id, trbinput_id, kbtrbconnection_id, trbconfigentry_id, trbconfigentry_threshold, setup_id, run_id IN
    SELECT 
      "TOMBInput".id AS tombinput_id,
      "TRBTOMBConnection".id AS trbtombconnection_id,
      "TRBOutput".id AS trboutput_id,
      "TRBInput".id AS trbinput_id,
      "KBTRBConnection".id AS kbtrbconnection_id,
      "TRBConfigEntry".id AS trbconfigentry_id,
      "TRBConfigEntry".threshold AS trbconfigentry_threshold,
      "Setup".id AS setup_id,
      "Run".id AS run_id      
    FROM "TOMBInput" 
      INNER JOIN "TRBTOMBConnection" ON "TOMBInput".id = "TRBTOMBConnection".tombinput_id 
      INNER JOIN "TRBOutput" ON "TRBTOMBConnection".trboutput_id = "TRBOutput".id
      INNER JOIN "TRBInput" ON "TRBOutput".trbinput_id = "TRBInput".id
      INNER JOIN "KBTRBConnection" ON "TRBInput".id = "KBTRBConnection".trbinput_id
      INNER JOIN "TRBConfigEntry" ON "KBTRBConnection".id = "TRBConfigEntry".id
      INNER JOIN "Setup" ON "TRBTOMBConnection".setup_id = "Setup".id
      INNER JOIN "Run" ON "Setup".id = "Run".id
    AND
      "Run".id = p_run_id
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM thresholdFromTRBConfigEntryBasedOnTOMBInputIdFunction(1);

6)
CREATE OR REPLACE FUNCTION photomultiplierIdBasedOnTOMBInputIdFunction(IN p_run_id INTEGER)
RETURNS TABLE
(
  tombinput_id INTEGER,
  trbtombconnection_id INTEGER,
  trboutput_id INTEGER,
  trbinput_id INTEGER,
  kbtrbconnection_id INTEGER,
  konradboardoutput_id INTEGER,
  konradboardinput_id INTEGER,
  pmkbconnection_id INTEGER,
  photomultiplier_id INTEGER,
  setup_id INTEGER,
  run_id INTEGER  
) AS
$BODY$
BEGIN
  FOR tombinput_id, trbtombconnection_id, trboutput_id, trbinput_id, kbtrbconnection_id, konradboardoutput_id, konradboardinput_id, pmkbconnection_id, photomultiplier_id, setup_id, run_id IN
    SELECT 
      "TOMBInput".id AS tombinput_id,
      "TRBTOMBConnection".id AS trbtombconnection_id,
      "TRBOutput".id AS trboutput_id,
      "TRBInput".id AS trbinput_id,
      "KBTRBConnection".id AS kbtrbconnection_id,
      "KonradBoardOutput".id AS konradboardoutput_id,
      "KonradBoardInput".id AS konradboardinput_id,
      "PMKBConnection".id AS pmkbconnection_id,
      "PhotoMultiplier".id AS photomultiplier_id,
      "Setup".id AS setup_id,
      "Run".id AS run_id
    FROM "TOMBInput" 
      INNER JOIN "TRBTOMBConnection" ON "TOMBInput".id = "TRBTOMBConnection".tombinput_id 
      INNER JOIN "TRBOutput" ON "TRBTOMBConnection".trboutput_id = "TRBOutput".id
      INNER JOIN "TRBInput" ON "TRBOutput".trbinput_id = "TRBInput".id
      INNER JOIN "KBTRBConnection" ON "TRBInput".id = "KBTRBConnection".trbinput_id
      INNER JOIN "KonradBoardOutput" ON "KBTRBConnection".konradboardoutput_id = "KonradBoardOutput".id
      INNER JOIN "KonradBoardInput" ON "KonradBoardOutput".konradboardinput_id = "KonradBoardInput".id
      INNER JOIN "PMKBConnection" ON "KonradBoardInput".id = "PMKBConnection".konradboardinput_id
      INNER JOIN "PhotoMultiplier" ON "PMKBConnection".photomultiplier_id = "PhotoMultiplier".id
      INNER JOIN "Setup" ON "TRBTOMBConnection".setup_id = "Setup".id
      INNER JOIN "Run" ON "Setup".id = "Run".id
    AND
      "Run".id = p_run_id
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM photomultiplierIdBasedOnTOMBInputIdFunction(1);

7)
CREATE OR REPLACE FUNCTION tombinputIdBasedOnTRBIdAndTRBoutputIdFunction(IN p_run_id INTEGER)
RETURNS TABLE
(
  trb_id INTEGER,
  trboutput_id INTEGER,
  trbtombconnection_id INTEGER,
  tombinput_id INTEGER,
  setup_id INTEGER,
  run_id INTEGER  
) AS
$BODY$
BEGIN
  FOR trb_id, trboutput_id, trbtombconnection_id, tombinput_id, setup_id, run_id IN
    SELECT
      "TRB".id AS trb_id,
      "TRBOutput".id AS trboutput_id,
      "TRBTOMBConnection".id AS trbtombconnection_id,
      "TOMBInput".id AS tombinput_id,
      "Setup".id AS setup_id,
      "Run".id AS run_id
    FROM "TRB"
      INNER JOIN "TRBOutput" ON "TRB".id = "TRBOutput".trb_id
      INNER JOIN "TRBTOMBConnection" ON "TRBOutput".id = "TRBTOMBConnection".trboutput_id
      INNER JOIN "TOMBInput" ON "TRBTOMBConnection".tombinput_id = "TOMBInput".id
      INNER JOIN "Setup" ON "TRBTOMBConnection".setup_id = "Setup".id
      INNER JOIN "Run" ON "Setup".id = "Run".id
    AND
      "Run".id = p_run_id
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM tombinputIdBasedOnTRBIdAndTRBoutputIdFunction(1);

8)
CREATE OR REPLACE FUNCTION passedInformationIsTimeBasedOnTOMBInputIdFunction(IN p_run_id INTEGER)
RETURNS TABLE
(
  tombinput_id INTEGER,
  trbtombconnection_id INTEGER,
  trboutput_id INTEGER,
  trbinput_id INTEGER,
  kbtrbconnection_id INTEGER,
  konradboardoutput_id INTEGER,
  konradBoardOutput_passedinformationistime BOOLEAN,
  setup_id INTEGER,
  run_id INTEGER  
) AS
$BODY$
BEGIN
  FOR tombinput_id, trbtombconnection_id, trboutput_id, trbinput_id, kbtrbconnection_id, konradboardoutput_id, konradBoardOutput_passedinformationistime, setup_id, run_id IN
    SELECT
      "TOMBInput".id AS tombinput_id,
      "TRBTOMBConnection".id AS trbtombconnection_id,
      "TRBOutput".id AS trboutput_id,
      "TRBInput".id AS trbinput_id,
      "KBTRBConnection".id AS kbtrbconnection_id,
      "KonradBoardOutput".id AS konradboardoutput_id,
      "KonradBoardOutput".passedinformationistime AS konradBoardOutput_passedinformationistime,
      "Setup".id AS setup_id,
      "Run".id AS run_id
    FROM "TOMBInput" 
      INNER JOIN "TRBTOMBConnection" ON "TOMBInput".id = "TRBTOMBConnection".tombinput_id 
      INNER JOIN "TRBOutput" ON "TRBTOMBConnection".trboutput_id = "TRBOutput".id
      INNER JOIN "TRBInput" ON "TRBOutput".trbinput_id = "TRBInput".id
      INNER JOIN "KBTRBConnection" ON "TRBInput".id = "KBTRBConnection".trbinput_id
      INNER JOIN "KonradBoardOutput" ON "KBTRBConnection".konradboardoutput_id = "KonradBoardOutput".id
      INNER JOIN "Setup" ON "TRBTOMBConnection".setup_id = "Setup".id
      INNER JOIN "Run" ON "Setup".id = "Run".id
    AND
      "Run".id = p_run_id      
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM passedInformationIsTimeBasedOnTOMBInputIdFunction(1);



/**! PONIZSZE FUNKCJE TRZEBA POPRAWIC !**/


***********Scintillators************


CREATE OR REPLACE FUNCTION getScintillatorsData(IN p_run_id INTEGER)
RETURNS TABLE
(
  scintillator_id INTEGER,
  scintillator_isactive BOOLEAN,
  scintillator_status CHARACTER VARYING(255),

  scintillator_length DOUBLE PRECISION,
  scintillator_width DOUBLE PRECISION,
  scintillator_height DOUBLE PRECISION,
  scintillator_description CHARACTER VARYING(255),

  scintillatortype_id INTEGER,
  scintillatortype_name CHARACTER VARYING(255),
  scintillatortype_description CHARACTER VARYING(255),

  scintillatorcalibration_id INTEGER,
  scintillatorcalibration_name CHARACTER VARYING(255),
  scintillatorcalibration_attlength REAL,

  user_id INTEGER,
  user_name CHARACTER VARYING(255),
  user_lastname CHARACTER VARYING(255),
  user_login CHARACTER VARYING(255),
  user_password  CHARACTER VARYING(255),
  user_isroot BOOLEAN,
  user_creationdate TIMESTAMP,
  user_lastlogindate TIMESTAMP,

  setup_id INTEGER,
  run_id INTEGER  
) AS
$BODY$
BEGIN
  FOR 
    scintillator_id,
    scintillator_isactive,
    scintillator_status,

    scintillator_length,
    scintillator_width,
    scintillator_height,
    scintillator_description,

    scintillatortype_id,
    scintillatortype_name,
    scintillatortype_description,

    scintillatorcalibration_id,
    scintillatorcalibration_name,
    scintillatorcalibration_attlength,

    user_id,
    user_name,
    user_lastname,
    user_login,
    user_password,
    user_isroot,
    user_creationdate,
    user_lastlogindate,

    setup_id,
    run_id

  IN

      SELECT
	"Scintillator".id AS scintillator_id,
	"Scintillator".isactive AS scintillator_isactive,
	"Scintillator".status AS scintillator_status,
	"Scintillator".length AS scintillator_length,
	"Scintillator".width AS scintillator_width,
	"Scintillator".height AS scintillator_height,
	"Scintillator".description AS scintillator_description,

	"ScintillatorType".id AS scintillatortype_id,
	"ScintillatorType".name AS scintillatortype_name,
	"ScintillatorType".description AS scintillatortype_description,

	"ScintillatorCalibration".id AS scintillatorcalibration_id,
	"ScintillatorCalibration".name AS scintillatorcalibration_name,
	"ScintillatorCalibration".attlength AS scintillatorcalibration_attlength,

	"PETUser".id AS user_id,
	"PETUser".name AS user_name,
	"PETUser".lastname AS user_lastname,
	"PETUser".login AS user_login,
	"PETUser".password AS user_password,
	"PETUser".isroot AS user_isroot,
	"PETUser".creationdate AS user_creationdate,
	"PETUser".lastlogindate AS user_lastlogindate,
	
	"Setup".id AS setup_id,
	"Run".id AS run_id

      FROM "ScintillatorCalibration", "Scintillator", "ScintillatorType", "SLSCConnection", "PETUser", "Run", "Setup"
	WHERE
	  "Scintillator".scintillatorcalibration_id = "ScintillatorCalibration".id
	  AND
	  "Scintillator".scintillatortype_id = "ScintillatorType".id
	  AND
	  "SLSCConnection".scintillator_id = "Scintillator".id
	  AND
	  "SLSCConnection".setup_id = "Setup".id
	  AND
	  "Run".setup_id = "Setup".id
	  AND
	  "Scintillator".creator_id = "PETUser".id
	  AND
	  "Run".id = p_run_id
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM getScintillatorsData(1);


***********PhotoMultipliers************


CREATE OR REPLACE FUNCTION getPhotoMultipliersData(IN p_run_id INTEGER)
RETURNS TABLE
(
  hvpmconnection_id INTEGER,
  hvpmconnection_isrightside BOOLEAN,

  photomultiplier_id INTEGER,
  photomultiplier_isactive BOOLEAN,
  photomultiplier_status CHARACTER VARYING(255),
  photomultiplier_name CHARACTER VARYING(255),
  photomultiplier_maxhv DOUBLE PRECISION,
  photomultiplier_description CHARACTER VARYING(255),
  photomultiplier_producer CHARACTER VARYING(255),
  photomultiplier_boughtdate TIMESTAMP,
  photomultiplier_serialnumber CHARACTER VARYING(255),
  photomultiplier_takespositivevoltage BOOLEAN,

  pmmodel_id INTEGER,
  pmmodel_name CHARACTER VARYING(255),

  pmcalibration_id INTEGER,
  pmcalibration_name CHARACTER VARYING(255),
  pmcalibration_opthv REAL,
  pmcalibration_c2e_1 REAL,
  pmcalibration_c2e_2 REAL,
  pmcalibration_gainalpha REAL,
  pmcalibration_gainbeta REAL,

  user_id INTEGER,
  user_name CHARACTER VARYING(255),
  user_lastname CHARACTER VARYING(255),
  user_login CHARACTER VARYING(255),
  user_password  CHARACTER VARYING(255),
  user_isroot BOOLEAN,
  user_creationdate TIMESTAMP,
  user_lastlogindate TIMESTAMP,

  setup_id INTEGER,
  run_id INTEGER
) AS
$BODY$
BEGIN
  FOR 
    hvpmconnection_id,
    hvpmconnection_isrightside,

    photomultiplier_id,
    photomultiplier_isactive,
    photomultiplier_status,
    photomultiplier_name,
    photomultiplier_maxhv,
    photomultiplier_description,
    photomultiplier_producer,
    photomultiplier_boughtdate,
    photomultiplier_serialnumber,
    photomultiplier_takespositivevoltage,

    pmmodel_id,
    pmmodel_name,

    pmcalibration_id,
    pmcalibration_name,
    pmcalibration_opthv,
    pmcalibration_c2e_1,
    pmcalibration_c2e_2,
    pmcalibration_gainalpha,
    pmcalibration_gainbeta,

    user_id,
    user_name,
    user_lastname,
    user_login,
    user_password,
    user_isroot,
    user_creationdate,
    user_lastlogindate,

    setup_id,
    run_id

  IN

      SELECT
	"HVPMConnection".id AS hvpmconnection_id,
	"HVPMConnection".isrightside AS hvpmconnection_isrightside,

	"PhotoMultiplier".id AS photomultiplier_id,
	"PhotoMultiplier".isactive AS photomultiplier_isactive,
	"PhotoMultiplier".status AS photomultiplier_status,
	"PhotoMultiplier".name AS photomultiplier_name,
	"PhotoMultiplier".maxhv AS photomultiplier_maxhv,
	"PhotoMultiplier".description AS photomultiplier_description,
	"PhotoMultiplier".producer AS photomultiplier_producer,
	"PhotoMultiplier".boughtdate AS photomultiplier_boughtdate,
	"PhotoMultiplier".serialnumber AS photomultiplier_serialnumber,
	"PhotoMultiplier".takespositivevoltage AS photomultiplier_takespositivevoltage,

	"PhotoMultiplier".pmmodel_id AS pmmodel_id,
	"PMModel".name AS pmmodel_name,

	"PhotoMultiplier".pmcalibration_id AS pmcalibration_id,
	"PMCalibration".name AS pmcalibration_name,
	"PMCalibration".opthv AS pmcalibration_opthv,
	"PMCalibration".c2e_1 AS pmcalibration_c2e_1,
	"PMCalibration".c2e_2 AS pmcalibration_c2e_2,
	"PMCalibration".gainalpha AS pmcalibration_gainalpha,
	"PMCalibration".gainbeta AS pmcalibration_gainbeta,

	"PETUser".id AS user_id,
	"PETUser".name AS user_name,
	"PETUser".lastname AS user_lastname,
	"PETUser".login AS user_login,
	"PETUser".password AS user_password,
	"PETUser".isroot AS user_isroot,
	"PETUser".creationdate AS user_creationdate,
	"PETUser".lastlogindate AS user_lastlogindate,
	
	"Setup".id AS setup_id,
	"Run".id AS run_id

      FROM "HVPMConnection", "PhotoMultiplier", "PMModel", "PMCalibration", "PETUser", "Run", "Setup"
	WHERE
	  "PhotoMultiplier".pmcalibration_id = "PMCalibration".id
	  AND
	  "HVPMConnection".photomultiplier_id = "PhotoMultiplier".id
	  AND
	  "HVPMConnection".setup_id = "Setup".id
	  AND
	  "Run".setup_id = "Setup".id
	  AND
	  "PhotoMultiplier".creator_id = "PETUser".id
	  AND
	  "Run".id = p_run_id
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM getPhotoMultipliersData(1);


***********KBs************


Wczesniej stworzylem funkcje "getKonradBoardsData" i dodalem do bazy danych rowniez na kozie
teraz funkcje zmienilem (dodalem PETUser oraz z inner join na where) trzeba to poprawic bo daje
zle wyniki za duzo rows. Na kozie jeszcze nie zmienilem tej funkcji.

CREATE OR REPLACE FUNCTION getKonradBoardsData(IN p_run_id INTEGER)
RETURNS TABLE
(
  konradboard_id INTEGER,
  konradboard_isactive BOOLEAN,
  konradboard_status CHARACTER VARYING(255),
  konradboard_description CHARACTER VARYING(255),
  konradboard_version INTEGER,
  konradboard_creator_id INTEGER,

  konradboardinput_id INTEGER,
  konradboardinput_isactive BOOLEAN,
  konradboardinput_status CHARACTER VARYING(255),
  konradboardinput_portnumber INTEGER,
  konradboardinput_description CHARACTER VARYING(255),
  konradboardinput_konradboard_id INTEGER,
    
  konradboardoutput_id INTEGER,
  konradboardoutput_isactive BOOLEAN,
  konradboardoutput_status CHARACTER VARYING(255),
  konradboardoutput_portnumber INTEGER,
  konradboardoutput_description CHARACTER VARYING(255),
  konradboardoutput_passedinformationistime BOOLEAN,
  konradboardoutput_konradboard_id INTEGER,
  konradboardoutput_input_id INTEGER,
  konradboardoutput_konradboardinput_id INTEGER,

  user_id INTEGER,
  user_name CHARACTER VARYING(255),
  user_lastname CHARACTER VARYING(255),
  user_login CHARACTER VARYING(255),
  user_password  CHARACTER VARYING(255),
  user_isroot BOOLEAN,
  user_creationdate TIMESTAMP,
  user_lastlogindate TIMESTAMP,

  setup_id INTEGER,
  run_id INTEGER  
) AS
$BODY$
BEGIN
  FOR 
    konradboard_id,
    konradboard_isactive,
    konradboard_status,
    konradboard_description,
    konradboard_version,
    konradboard_creator_id,

    konradboardinput_id,
    konradboardinput_isactive,
    konradboardinput_status,
    konradboardinput_portnumber,
    konradboardinput_description,
    konradboardinput_konradboard_id,
      
    konradboardoutput_id,
    konradboardoutput_isactive,
    konradboardoutput_status,
    konradboardoutput_portnumber,
    konradboardoutput_description,
    konradboardoutput_passedinformationistime,
    konradboardoutput_konradboard_id,
    konradboardoutput_input_id,
    konradboardoutput_konradboardinput_id,

    user_id,
    user_name,
    user_lastname,
    user_login,
    user_password,
    user_isroot,
    user_creationdate,
    user_lastlogindate,

    setup_id,
    run_id

  IN

      SELECT
	"KonradBoard".id AS konradboard_id,
	"KonradBoard".isactive AS konradboard_isactive,
	"KonradBoard".status AS konradboard_status,
	"KonradBoard".description AS konradboard_description,
	"KonradBoard".version AS konradboard_version,
	"KonradBoard".creator_id AS konradboard_creator_id,

	"KonradBoardInput".id AS konradboardinput_id,
	"KonradBoardInput".isactive AS konradboardinput_isactive,
	"KonradBoardInput".status AS konradboardinput_status,
	"KonradBoardInput".portnumber AS konradboardinput_portnumber,
	"KonradBoardInput".description AS konradboardinput_description,
	"KonradBoardInput".konradboard_id AS konradboardinput_konradboard_id,
	
	"KonradBoardOutput".id AS konradboardoutput_id,
	"KonradBoardOutput".isactive AS konradboardoutput_isactive,
	"KonradBoardOutput".status AS konradboardoutput_status,
	"KonradBoardOutput".portnumber AS konradboardoutput_portnumber,
	"KonradBoardOutput".description AS konradboardoutput_description,
	"KonradBoardOutput".passedinformationistime AS konradboardoutput_passedinformationistime,
	"KonradBoardOutput".konradboard_id AS konradboardoutput_konradboard_id,
	"KonradBoardOutput".input_id AS konradboardoutput_input_id,
	"KonradBoardOutput".input_id AS konradboardoutput_konradboardinput_id,
	
	"PETUser".id AS user_id,
	"PETUser".name AS user_name,
	"PETUser".lastname AS user_lastname,
	"PETUser".login AS user_login,
	"PETUser".password AS user_password,
	"PETUser".isroot AS user_isroot,
	"PETUser".creationdate AS user_creationdate,
	"PETUser".lastlogindate AS user_lastlogindate,
	
	"Setup".id AS setup_id,
	"Run".id AS run_id
	
      FROM "KonradBoard", "KonradBoardInput", "KonradBoardOutput", "KBTRBConnection", "PETUser", "Setup", "Run"
	WHERE
	  "KonradBoardInput".konradboard_id = "KonradBoard".id
	  AND
	  "KonradBoardOutput".konradboard_id = "KonradBoard".id
	  AND
	  "KBTRBConnection".konradboardoutput_id = "KonradBoardOutput".id
	  AND
	  "KBTRBConnection".setup_id = "Setup".id
	  AND
	  "Run".setup_id = "Setup".id
	  AND
	  "KonradBoard".creator_id = "PETUser".id
	  AND
	  "Run".id = p_run_id     
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM getKonradBoardsData(1);


***********TRBs************


CREATE OR REPLACE FUNCTION getTRBsData(IN p_run_id INTEGER)
RETURNS TABLE
(
  TRB_id INTEGER,
  TRB_isactive BOOLEAN,
  TRB_status CHARACTER VARYING(255),
  TRB_maxch INTEGER,
  TRB_name CHARACTER VARYING(255),
  TRB_description CHARACTER VARYING(255),
  TRB_version INTEGER,

  user_id INTEGER,
  user_name CHARACTER VARYING(255),
  user_lastname CHARACTER VARYING(255),
  user_login CHARACTER VARYING(255),
  user_password  CHARACTER VARYING(255),
  user_isroot BOOLEAN,
  user_creationdate TIMESTAMP,
  user_lastlogindate TIMESTAMP,

  setup_id INTEGER,
  run_id INTEGER  
) AS
$BODY$
BEGIN
  FOR 
    TRB_id,
    TRB_isactive,
    TRB_status,
    TRB_maxch,
    TRB_name,
    TRB_description,
    TRB_version,

    user_id,
    user_name,
    user_lastname,
    user_login,
    user_password,
    user_isroot,
    user_creationdate,
    user_lastlogindate,

    setup_id,
    run_id

  IN

      SELECT
	"TRB".id AS TRB_id,
	"TRB".isactive AS TRB_isactive,
	"TRB".status AS TRB_status,
	"TRB".maxch AS TRB_maxch,
	"TRB".name AS TRB_name,
	"TRB".description AS TRB_description,
	"TRB".version AS TRB_version,

	"PETUser".id AS user_id,
	"PETUser".name AS user_name,
	"PETUser".lastname AS user_lastname,
	"PETUser".login AS user_login,
	"PETUser".password AS user_password,
	"PETUser".isroot AS user_isroot,
	"PETUser".creationdate AS user_creationdate,
	"PETUser".lastlogindate AS user_lastlogindate,
	
	"Setup".id AS setup_id,
	"Run".id AS run_id

      FROM "TRB", "TRBOutput", "TRBTOMBConnection", "PETUser", "Run", "Setup"
	WHERE
	  "TRBOutput".trb_id = "TRB".id
	  AND
	  "TRBTOMBConnection".trboutput_id = "TRBOutput".id
	  AND
	  "TRBTOMBConnection".setup_id = "Setup".id
	  AND
	  "Run".setup_id = "Setup".id
	  AND
	  "TRB".creator_id = "PETUser".id
	  AND
	  "Run".id = p_run_id
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM getTRBsData(1);


***********TOMB************


CREATE OR REPLACE FUNCTION getTOMBData(IN p_run_id INTEGER)
RETURNS TABLE
(
  TOMB_id INTEGER,
  TOMB_description CHARACTER VARYING(255),
  TOMB_setup_id INTEGER,

  setup_id INTEGER,
  run_id INTEGER  
) AS
$BODY$
BEGIN
  FOR 
    TOMB_id,
    TOMB_description,
    TOMB_setup_id,

    setup_id,
    run_id

  IN

      SELECT
	"TRBOffsetMappingBoard".id AS TOMB_id,
	"TRBOffsetMappingBoard".description AS TOMB_description,
	"TRBOffsetMappingBoard".setup_id AS TOMB_setup_id,
	
	"Setup".id AS setup_id,
	"Run".id AS run_id

      FROM "TRBOffsetMappingBoard", "Run", "Setup"
	WHERE
	  "TRBOffsetMappingBoard".setup_id = "Setup".id
	  AND
	  "Run".setup_id = "Setup".id
	  AND
	  "Run".id = p_run_id
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM getTOMBData(1);


****************************************************************************************

*********************************FUNCTION to fill TRefs*********************************

************************************Scintillators***************************************


CREATE OR REPLACE FUNCTION getPhotoMultipliersForScintillator(IN p_scintillator_id INTEGER)
RETURNS TABLE
(
  SLSCConnection_id INTEGER,
  Slot_id INTEGER,
  HVPMConnection_id INTEGER,
  PhotoMultiplier_id INTEGER
) AS
$BODY$
BEGIN
  FOR 
    SLSCConnection_id,
    Slot_id,
    HVPMConnection_id,
    PhotoMultiplier_id

  IN

      SELECT
	"SLSCConnection".id AS SLSCConnection_id,
	"Slot".id AS Slot_id,
	"HVPMConnection".id AS HVPMConnection_id,
	"PhotoMultiplier".id AS PhotoMultiplier_id

      FROM "SLSCConnection", "Slot", "HVPMConnection", "PhotoMultiplier"
	WHERE
	  "PhotoMultiplier".id = "HVPMConnection".photomultiplier_id
	  AND
	  "HVPMConnection".slot_id = "Slot".id
	  AND
	  "SLSCConnection".slot_id = "Slot".id
	  AND
	  "SLSCConnection".scintillator_id = p_scintillator_id
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM getPhotoMultipliersForScintillator(1);


****************************************************************************************

************************************PhotoMultipliers***************************************

// dobra funkcja
CREATE OR REPLACE FUNCTION getKonradBoardsForPhotoMultiplier(IN p_photoMultiplier_id INTEGER)
RETURNS TABLE
(
  PMKBConnection_id INTEGER,
  KonradBoardInput_id INTEGER,
  KonradBoard_id INTEGER
) AS
$BODY$
BEGIN
  FOR 
    PMKBConnection_id,
	KonradBoardInput_id,
	KonradBoard_id
  IN
	SELECT
		"PMKBConnection".id AS PMKBConnection_id,
		"KonradBoardInput".id AS KonradBoardInput_id,
		"KonradBoard".id AS KonradBoard_id

	FROM "PMKBConnection", "KonradBoardInput", "KonradBoard"
		WHERE
		  "KonradBoard".id = "KonradBoardInput".konradboard_id
		  AND
		  "KonradBoardInput".id = "PMKBConnection".konradboardinput_id
		  AND
		  "PMKBConnection".photomultiplier_id = p_photoMultiplier_id
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM getKonradBoardsForPhotoMultiplier(57);


*********************************************************************

************************************KonradBoards***************************************

// trzeba poprawic ta funckje
CREATE OR REPLACE FUNCTION getTRBsForKonradBoard(IN p_konradBoard_id INTEGER)
RETURNS TABLE
(
	KonradBoardOutput_id INTEGER,
	KBTRBConnection_id INTEGER,
	TRBInput_id INTEGER,
	TRB_id INTEGER
) AS
$BODY$
BEGIN
  FOR 
	KonradBoardOutput_id,
	KBTRBConnection_id,
	TRBInput_id,
	TRB_id
  IN
      SELECT
		"KonradBoardOutput".id AS KonradBoardOutput_id,
		"KBTRBConnection".id AS KBTRBConnection_id,
		"TRBInput".id AS TRBInput_id,
		"TRB".id AS TRB_id

      FROM "KonradBoardOutput", "KBTRBConnection", "TRBInput", "TRB"
		WHERE
		  "TRB".id = "TRBInput".trb_id
		  AND
		  "TRBInput".id = "KBTRBConnection".trbinput_id
		  AND
		  "KBTRBConnection".konradboardoutput_id = "KonradBoardOutput".id
		  AND
		  "KonradBoardOutput".konradboard_id = p_konradBoard_id
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM getTRBsForKonradBoard(1);


*********************************************************************

************************************TRBs***************************************

// trzeba poprawic ta funckje
CREATE OR REPLACE FUNCTION getTOMBForTRB(IN p_TRBOutput INTEGER)
RETURNS TABLE
(
	TRBOutput_id INTEGER,
	TRBTOMBConnection_id INTEGER,
	TOMBInput_id INTEGER,
	TOMB_id INTEGER
) AS
$BODY$
BEGIN
  FOR 
	TRBOutput_id,
	TRBTOMBConnection_id,
	TOMBInput_id,
	TOMB_id
  IN
      SELECT
		"TRBOutput".id AS TRBOutput_id,
		"TRBTOMBConnection".id AS TRBTOMBConnection_id,
		"TOMBInput".id AS TOMBInput_id,
		"TRBOffsetMappingBoard".id AS TOMB_id

      FROM "TRBOutput", "TRBTOMBConnection", "TOMBInput", "TRBOffsetMappingBoard"
		WHERE
		  "TRBOffsetMappingBoard".id = "TOMBInput".trboffsetmappingboard_id
		  AND
		  "TOMBInput".id = "TRBTOMBConnection".tombinput_id
		  AND
		  "TRBTOMBConnection".trboutput_id = "TRBOutput".id
		  AND
		  "TRBOutput".trb_id = p_TRBOutput
  LOOP
    RETURN NEXT;
  END LOOP;
END
$BODY$ LANGUAGE plpgsql STABLE;

SELECT * FROM getTOMBForTRB(1);
