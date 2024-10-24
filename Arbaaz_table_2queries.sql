-- New table added by arbaaz
CREATE INDEX idx_donations_id ON donations(Donor_ID);
CREATE TABLE Donor_Post_Exam_Results (
    PostExamID INT PRIMARY KEY,   -- Unique identifier for each test result
    Donor_ID INT,                          -- Foreign key to donations table
    PreExamID INT UNSIGNED ,                        -- Foreign key to PreExam table
    DiseaseDetected BOOLEAN,                       -- Indicates if a disqualifying disease is detected (1 for Yes, 0 for No)
    EligibilityStatus ENUM('Eligible', 'Deferred', 'Disqualified'),  -- Status of donor based on the test results
    Remarks TEXT,                                  -- Any additional comments or notes about the test results
    FOREIGN KEY (Donor_ID) REFERENCES donations(Donor_ID),  -- Foreign key constraint to the donations table
    FOREIGN KEY (PreExamID) REFERENCES pre_exam(PreExamID)  -- Foreign key constraint to the PreExam table
);

INSERT INTO Donor_Post_Exam_Results (PostExamID, Donor_ID, PreExamID, DiseaseDetected, EligibilityStatus, Remarks)
VALUES
(1, 1, 1, 0, 'Eligible', 'Fit for donation'),
(2, 3, 2, 0, 'Deferred', 'Mild cold, defer for a week'),
(3, 6, 4, 1, 'Disqualified', 'Detected flu symptoms'),
(4, 8, 8, 1, 'Deferred', 'Sore throat, needs rest'),
(5, 9, 9, 0, 'Eligible', 'Fit for donation'),
(6, 11, 11, 1, 'Disqualified', 'Hypertension detected'),
(7, 13, 13, 0, 'Eligible', 'Fit for donation'),
(8, 14, 14, 0, 'Eligible', 'Healthy and fit'),
(9, 15, 15, 0, 'Deferred', 'Minor headache, rest advised'),
(10, 17, 17, 0, 'Eligible', 'Good health condition'),
(11, 19, 19, 0, 'Eligible', 'Healthy and ready');

 -- 1.Specific to donor, suppose the donor travels abroad for donation and the hospital uses different units.
 select person.PersonalID, concat(FirstName, ' ', LastName) AS 'Name', Blood_Type, Age, Gender, 
 Weight*2.2 AS 'Donor Weight lb',
 Weight AS 'Donor Weight kg',
 Height AS 'Donor Height in meter',
 Height*100 AS 'Donor Height in cm',
 format(Height*3.281, 2) AS 'Donor height in feet',
 NextSafeDonation from person inner join donor on person.PersonalID = donor.PersonalID
 ORDER BY Weight, Height;
 
 -- 2. The query identifies potential donors with the blood type 'O+' and verifies their next safe donation date to ensure they are eligible to donate soon, ordering the results by the nearest donation date. 
 -- This approach enables the hospital to make informed decisions regarding blood transfusions in emergencies, thereby maximizing patient care efficiency.

SELECT d.PersonalID, p.FirstName, p.LastName, d.NextSafeDonation 
FROM Donor d
JOIN Person p ON d.PersonalID = p.PersonalID
WHERE d.Blood_Type = 'O+' AND d.NextSafeDonation > CURDATE()
ORDER BY d.NextSafeDonation ASC;

