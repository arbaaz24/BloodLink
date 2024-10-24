/* User defined function to check if Patient already exists in the database.
 Takes PersonalID as argument and returns bool value (1 if exists else 0)
*/
DELIMITER $$
CREATE FUNCTION PersonExists( p INT) RETURNS BOOL
DETERMINISTIC
BEGIN
DECLARE result BOOL;
SELECT 1 INTO result FROM Person WHERE PersonalID = p;
IF result IS NULL THEN RETURN 0;
END IF;
RETURN result;
 END $$
 DELIMITER ;
 
 -- Example expression to test PersonExists function
 SELECT PersonExists(21);


/* Procedure to insert details of mutiple patients using pipe character '|' as a delimiter between records and ',' as a delimiter between 
each field. SUBSTRING_INDEX() used to process multiple patient data passed as a single string to the procedure.
 Since Patient references Person table on PernoalID, procedure utilises branching statement and user defined funtion PersonExists() to make sure data is 
 first added to Person table followed by updating Patient table.
*/

-- REMOVE these debuggig lines before integration
/*
SELECT * FROM person;
select * from Person where PersonalID in ( 21,22);
select * from patient where PersonalID in ( 21,22);
delete from patient where PersonalID in (21,22);
delete from person where PersonalID in (21,22);
drop procedure AddMultiplePatients;
drop function PersonExists;
*/


DELIMITER $$

CREATE PROCEDURE AddMultiplePatients(
    IN patientCount INT,
    IN patientDetails TEXT
)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE patientData TEXT;
    DECLARE PersonalID INT UNSIGNED ;
    DECLARE BloodType ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-');
    DECLARE NeedStatus VARCHAR(50);
    DECLARE Weight DECIMAL(5, 2);
    DECLARE Reason VARCHAR(255);
    DECLARE FirstName VARCHAR(50);
    DECLARE LastName VARCHAR(50);
    DECLARE Age INT;
    DECLARE Gender ENUM('Male', 'Female', 'Other');
    
    -- Loop through the number of patients
    WHILE i <= patientCount DO
        -- Extract individual patient details from the provided string
        SET patientData = SUBSTRING_INDEX(patientDetails, '|', -i);
        
        -- Assuming the data is pipe-separated, split into fields using ','
        SET PersonalID = SUBSTRING_INDEX(SUBSTRING_INDEX(patientData, ',', 1), ',', -1);
        SET BloodType = SUBSTRING_INDEX(SUBSTRING_INDEX(patientData, ',', 2), ',', -1);
        SET NeedStatus = SUBSTRING_INDEX(SUBSTRING_INDEX(patientData, ',', 3), ',', -1);
        SET Weight = SUBSTRING_INDEX(SUBSTRING_INDEX(patientData, ',', 4), ',', -1);
        SET Reason = SUBSTRING_INDEX(SUBSTRING_INDEX(patientData, ',', 5), ',', -1);
		SET FirstName = SUBSTRING_INDEX(SUBSTRING_INDEX(patientData, ',', 6), ',', -1);
        SET LastName = SUBSTRING_INDEX(SUBSTRING_INDEX(patientData, ',', 7), ',', -1);
        SET Age = SUBSTRING_INDEX(SUBSTRING_INDEX(patientData, ',', 8), ',', -1);
        SET Gender = SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(patientData, ',', 9), ',', -1), '|',1);
        
		IF  NOT PersonExists(PersonalID) THEN
            -- Insert into the Person table if not exists
            INSERT INTO person (PersonalID, FirstName, LastName, Age, Gender)
            VALUES (PersonalID, FirstName, LastName, Age, Gender);
        END IF;
        
        -- Insert each patient's data into the table
        INSERT INTO Patient (PersonalID, BloodType, NeedStatus, Weight, Reason)
        VALUES (PersonalID, BloodType, NeedStatus, Weight, Reason);

        -- Increment the loop counter
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- Example query to insert details of 2 patients
CALL AddMultiplePatients(2, '21,B+,Routine,100.23,Surgery,Bhuresh,Singh,60,Male|22,B+,Routine,100.23,Surgery,Mansi,Arora,40,Female');



