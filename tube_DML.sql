-- Simplistic stereo tube amplification system queries
-- Author: Austin Bond

-- QUERIES

-- 1) Find the most popular speaker found in discrete systems and integrated systems. List the speaker name associated with the model number and the number of times it appears in the database.
SELECT 
    SPEAKER_ID, SPEAKER_MODEL_NAME
FROM
    SPEAKER
WHERE
    SPEAKER_ID = (SELECT 
            SPEAKER_ID
        FROM
            DISCRETE_SYSTEM_OWNERSHIP
        GROUP BY SPEAKER_ID
        ORDER BY COUNT(*) DESC
        LIMIT 1);

-- 2) Select PRE/INTEGRATED amplifiers that that use similar preamp tubes. Inner join the amplifier tables.
SELECT DISTINCT
    CONCAT('PRE_ID = ',
            PREAMP_ID,
            ', ',
            'INTEGRATED_ID = ',
            INTEGRATED_AMP_ID,
            ' ') AS SIMILAR_PREAMP_TUBES
FROM
    PRE_AMPLIFIER_PARTS
        INNER JOIN
    INTEGRATED_AMPLIFIER_PARTS ON PRE_AMPLIFIER_PARTS.FRONT_PREAMP_PREAMP_TUBE_ID = INTEGRATED_AMPLIFIER_PARTS.FRONT_INTEGAMP_PREAMP_TUBE_ID
        OR PRE_AMPLIFIER_PARTS.BACK_PREAMP_PREAMP_TUBE_ID = INTEGRATED_AMPLIFIER_PARTS.FRONT_INTEGAMP_PREAMP_TUBE_ID
        OR PRE_AMPLIFIER_PARTS.FRONT_PREAMP_PREAMP_TUBE_ID = INTEGRATED_AMPLIFIER_PARTS.BACK_INTEGAMP_PREAMP_TUBE_ID
        OR PRE_AMPLIFIER_PARTS.BACK_PREAMP_PREAMP_TUBE_ID = INTEGRATED_AMPLIFIER_PARTS.BACK_INTEGAMP_PREAMP_TUBE_ID;

-- 3) List the discrete systems using vinyl as a music source medium. List the System Details. Use a subquery to find the medium.
SELECT 
    *
FROM
    DISCRETE_SYSTEM_OWNERSHIP
WHERE
    MUSIC_SOURCE_ID IN (SELECT 
            MUSIC_SOURCE_ID
        FROM
            MUSIC_SOURCE
        WHERE
            SOURCE_MEDIUM = 'VINYL');

-- 4) List all the pre_amp tubes by their name, model, and gain. Order by gain DESCENDING.
SELECT 
    PREAMP_TUBE_ID, PREAMP_TUBE_MODEL_NAME, PREAMP_TUBE_GAIN
FROM
    PREAMP_TUBE
ORDER BY PREAMP_TUBE_GAIN DESC;

-- 5) Create a trigger that automatically increments the SYSTEMS_OWNED column in the OWNER table when a new system is added to the database.
CREATE 
    TRIGGER  INTEGRATED_SYSTEMS_OWNED_TRIGGER
 AFTER INSERT ON INTEGRATED_SYSTEM_OWNERSHIP FOR EACH ROW 
    UPDATE HOBBYIST SET SYSTEMS_OWNED = SYSTEMS_OWNED + 1 WHERE
        HOB_ID = NEW.HOB_ID;

CREATE 
    TRIGGER  DISCRETE_SYSTEMS_OWNED_TRIGGER
 AFTER INSERT ON DISCRETE_SYSTEM_OWNERSHIP FOR EACH ROW 
    UPDATE HOBBYIST SET SYSTEMS_OWNED = SYSTEMS_OWNED + 1 WHERE
        HOB_ID = NEW.HOB_ID;

-- 6) Write a trigger that automatically deletes a system from the database when the cooresponding hobbyist is removed.
CREATE 
    TRIGGER  DELETE_INTEGRATED_SYSTEMS_TRIGGER
 BEFORE DELETE ON HOBBYIST FOR EACH ROW 
    DELETE FROM INTEGRATED_SYSTEM_OWNERSHIP WHERE
        HOB_ID = OLD.HOB_ID;

CREATE 
    TRIGGER  DELETE_DISCRETE_SYSTEMS_TRIGGER
 BEFORE DELETE ON HOBBYIST FOR EACH ROW 
    DELETE FROM DISCRETE_SYSTEM_OWNERSHIP WHERE
        HOB_ID = OLD.HOB_ID;