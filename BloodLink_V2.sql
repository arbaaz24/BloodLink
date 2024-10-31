SHOW DATABASES;
-- Create the database and select it
CREATE DATABASE IF NOT EXISTS BloodLink;
USE BloodLink;
/* Remove this line post-production */
-- DROP DATABASE BloodLink;


-- Disable safe mode
SET SQL_SAFE_UPDATES = 0;

-- Foundational Tables

-- Create the Person table (must be created first since many other tables reference it)
CREATE TABLE IF NOT EXISTS Person (
    PersonalID INT UNSIGNED NOT NULL PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Age INT,
    Gender VARCHAR(10)
);

-- Create Table for explanation of Location Codes
CREATE TABLE IF NOT EXISTS Location_Codes(
    LocationCode INT UNSIGNED NOT NULL,
    LocationDescription ENUM('Hospital', 'DoctorsOffice', 'DonationFacility', 'TestingFacility'),
    PRIMARY KEY (LocationCode)
);

-- Dependent Tables

-- Create Table for Location Information
CREATE TABLE IF NOT EXISTS Locations(
    LocationID INT UNSIGNED NOT NULL,
    LocationName VARCHAR(50),
    LocationCode INT UNSIGNED,
    City VARCHAR(50),
    ZipCode VARCHAR(5),
    PRIMARY KEY (LocationID),
    FOREIGN KEY (LocationCode) REFERENCES Location_Codes(LocationCode)
);

-- Create Table for Blood_Bags
CREATE TABLE IF NOT EXISTS Blood_Bags (
    BloodBagID INT UNSIGNED NOT NULL,
    QuantityCC INT UNSIGNED,
    BloodType ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    DonationType VARCHAR(50),
    PRIMARY KEY (BloodBagID)
);

-- Create Table for Pre_Exam
CREATE TABLE IF NOT EXISTS Pre_Exam (
    PreExamID INT UNSIGNED NOT NULL,
    HemoglobinGDL DECIMAL(5,2),
    TemperatureF DECIMAL(5,2),
    BloodPressure VARCHAR(10),
    PulseBPM INT UNSIGNED,
    OtherIllnesses VARCHAR(255),
    PRIMARY KEY (PreExamID)
);

-- Create Table for Donation_Types
CREATE TABLE IF NOT EXISTS Donation_Types (
    Type INT PRIMARY KEY NOT NULL,
    Frequency_day INT
);

-- Create Table for Patient
CREATE TABLE IF NOT EXISTS Patient (
    PersonalID INT UNSIGNED NOT NULL,   -- Foreign key to Person.PersonalID
    BloodType ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    NeedStatus VARCHAR(50),
    Weight DECIMAL(5, 2),
    Reason VARCHAR(255),  -- Reason for transfusion
    PRIMARY KEY (PersonalID),
    FOREIGN KEY (PersonalID) REFERENCES Person(PersonalID)
);

-- Create Table for Nurse
CREATE TABLE IF NOT EXISTS Nurse (
    PersonalID INT UNSIGNED NOT NULL,   -- Foreign key to Patient.PersonalID
    ExperienceYears INT UNSIGNED,
    PRIMARY KEY (PersonalID),
    FOREIGN KEY (PersonalID) REFERENCES Patient(PersonalID)
);

-- Create the Donor table
CREATE TABLE IF NOT EXISTS Donor (
    PersonalID INT UNSIGNED NOT NULL PRIMARY KEY,
    Blood_Type ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    Weight DECIMAL(5, 2),
    Height DECIMAL(4, 2),
    NextSafeDonation DATE,
    FOREIGN KEY (PersonalID) REFERENCES Person(PersonalID) ON DELETE CASCADE
);

-- Complex Tables

-- Create Table for Blood Request Details
CREATE TABLE IF NOT EXISTS Requests(
    RequestID INT UNSIGNED NOT NULL,
    LocationID INT UNSIGNED,
    BloodTypeRequested ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    RequestDate DATE,
    RequestedQuantityCC INT UNSIGNED,
    PRIMARY KEY (RequestID),
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID)
);

-- Create Donation records table
CREATE TABLE IF NOT EXISTS Donation_Records(
    DonationID INT UNSIGNED NOT NULL,
    LocationID INT UNSIGNED,
    DonationDate DATE,
    BloodBagID INT UNSIGNED,
    PRIMARY KEY (DonationID),
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
    FOREIGN KEY (BloodBagID) REFERENCES Blood_Bags(BloodBagID)
);

-- Create Table for Global Inventory
CREATE TABLE IF NOT EXISTS Global_Inventory(
    GlobalBloodBagID INT UNSIGNED NOT NULL,
    LocationID INT UNSIGNED,
    Available VARCHAR(1),
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID)
);

-- Create Transfusion Records table
CREATE TABLE IF NOT EXISTS Transfusion_Records(
    TransfusionID INT UNSIGNED NOT NULL,
    LocationID INT UNSIGNED,
    TransfusionDate DATE,
    BloodBagID INT UNSIGNED,
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
    FOREIGN KEY (BloodBagID) REFERENCES Blood_Bags(BloodBagID)
);

-- Create Table for Transfusion
CREATE TABLE IF NOT EXISTS Transfusion (
    TransfusionID INT UNSIGNED NOT NULL,
    PersonalID INT UNSIGNED,  -- Foreign key to Patient.PersonalID
    LocationID INT UNSIGNED,  -- Foreign key to Locations.LocationID
    PreExamID INT UNSIGNED,   -- Foreign key to Pre_Exam.PreExamID
    NurseID INT UNSIGNED,     -- Foreign key to Nurse.PersonalID
    Amount_Received_CC INT UNSIGNED,
    PRIMARY KEY (TransfusionID),
    FOREIGN KEY (PersonalID) REFERENCES Patient(PersonalID),
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
    FOREIGN KEY (PreExamID) REFERENCES Pre_Exam(PreExamID),
    FOREIGN KEY (NurseID) REFERENCES Nurse(PersonalID)
);

-- Create Table for Donations
CREATE TABLE IF NOT EXISTS Donations (
    Donation_ID INT PRIMARY KEY NOT NULL,
    Donor_ID INT,
    Donation_Type INT,
    Donation_Date DATE,
    Quantity INT,
    FOREIGN KEY (Donation_Type) REFERENCES Donation_Types(Type)
);

INSERT INTO Person (PersonalID, FirstName, LastName, Age, Gender) VALUES
(1, 'Frank', 'Rodriguez', 25, 'Male'),
(2, 'Eve', 'Moore', 39, 'Other'),
(3, 'Mallory', 'Thomas', 53, 'Male'),
(4, 'Sybil', 'Anderson', 41, 'Female'),
(5, 'Nathan', 'Garcia', 58, 'Male'),
(6, 'Diana', 'Brown', 32, 'Other'),
(7, 'Victor', 'Johnson', 61, 'Male'),
(8, 'Trent', 'Johnson', 58, 'Male'),
(9, 'Walter', 'Jackson', 34, 'Male'),
(10, 'Jane', 'Anderson', 27, 'Female'),
(11, 'Alice', 'Smith', 23, 'Female'),
(12, 'Charlie', 'Martin', 47, 'Male'),
(13, 'Heidi', 'Hernandez', 38, 'Female'),
(14, 'Alice', 'Moore', 27, 'Female'),
(15, 'Diana', 'Miller', 31, 'Female'),
(16, 'Peggy', 'Garcia', 35, 'Other'),
(17, 'Eve', 'Thomas', 50, 'Female'),
(18, 'Frank', 'Martin', 40, 'Male'),
(19, 'Jane', 'Martin', 34, 'Female'),
(20, 'Bob', 'Williams', 45, 'Male');

INSERT INTO Location_Codes (LocationCode, LocationDescription) VALUES
(1, 'Hospital'),
(2, 'DoctorsOffice'),
(3, 'DonationFacility'),
(4, 'TestingFacility');

INSERT INTO Locations (LocationID, LocationName, LocationCode, City, ZipCode) VALUES
(1, 'City Hospital', 1, 'New York', '10001'),
(2, 'Health Clinic', 2, 'Los Angeles', '90001'),
(3, 'Main Street Donation Center', 3, 'Chicago', '60601'),
(4, 'Community Testing Lab', 4, 'Houston', '77001'),
(5, 'Riverside Medical Center', 1, 'Miami', '33101'),
(6, 'Sunset Clinic', 2, 'San Francisco', '94101'),
(7, 'Downtown Donation Hub', 3, 'Boston', '02101'),
(8, 'Central Testing Facility', 4, 'Dallas', '75201'),
(9, 'Harbor Hospital', 1, 'Seattle', '98101'),
(10, 'Mountain View Health Center', 2, 'Denver', '80201'),
(11, 'Lakeshore Donation Center', 3, 'Chicago', '60602'),
(12, 'Eastside Testing Lab', 4, 'Atlanta', '30301'),
(13, 'Valley General Hospital', 1, 'Phoenix', '85001'),
(14, 'Oakwood Medical Office', 2, 'Portland', '97201'),
(15, 'Meadowbrook Donation Facility', 3, 'Austin', '78701'),
(16, 'Hillside Testing Center', 4, 'San Diego', '92101'),
(17, 'Sunnyvale Hospital', 1, 'San Jose', '95101'),
(18, 'Bayside Clinic', 2, 'Oakland', '94601'),
(19, 'Redwood Donation Center', 3, 'Sacramento', '95814'),
(20, 'Golden Gate Testing Lab', 4, 'San Francisco', '94102');

INSERT INTO Blood_Bags (BloodBagID, QuantityCC, BloodType, DonationType) VALUES
(1, 450, 'A+', 'Whole Blood'),
(2, 200, 'B-', 'Plasma'),
(3, 300, 'O+', 'Platelets'),
(4, 450, 'AB+', 'Whole Blood'),
(5, 200, 'A-', 'Plasma'),
(6, 450, 'O-', 'Whole Blood'),
(7, 200, 'A+', 'Plasma'),
(8, 300, 'B+', 'Platelets'),
(9, 450, 'AB-', 'Whole Blood'),
(10, 200, 'O+', 'Plasma'),
(11, 300, 'A-', 'Platelets'),
(12, 450, 'B-', 'Whole Blood'),
(13, 200, 'AB+', 'Plasma'),
(14, 300, 'O-', 'Platelets'),
(15, 450, 'A+', 'Whole Blood'),
(16, 200, 'B+', 'Plasma'),
(17, 300, 'AB-', 'Platelets'),
(18, 450, 'O+', 'Whole Blood'),
(19, 200, 'A-', 'Plasma'),
(20, 300, 'B-', 'Platelets');

INSERT INTO Pre_Exam (PreExamID, HemoglobinGDL, TemperatureF, BloodPressure, PulseBPM, OtherIllnesses) VALUES
(1, 14.5, 98.6, '120/80', 72, 'None'),
(2, 13.2, 99.1, '130/85', 78, 'Asthma'),
(3, 15.0, 98.4, '118/75', 68, 'None'),
(4, 12.8, 98.9, '125/82', 75, 'Diabetes'),
(5, 14.2, 98.7, '122/78', 70, 'None'),
(6, 13.8, 98.5, '119/79', 71, 'Hypertension'),
(7, 14.7, 98.8, '121/81', 73, 'None'),
(8, 13.5, 99.0, '128/84', 76, 'Allergies'),
(9, 15.2, 98.3, '117/76', 69, 'None'),
(10, 14.0, 98.9, '123/80', 74, 'Arthritis'),
(11, 13.9, 98.7, '120/78', 72, 'None'),
(12, 14.8, 98.6, '118/77', 70, 'Migraines'),
(13, 13.3, 99.2, '132/86', 79, 'None'),
(14, 15.1, 98.5, '116/75', 68, 'Thyroid disorder'),
(15, 14.3, 98.8, '124/81', 73, 'None'),
(16, 13.7, 99.0, '126/83', 75, 'Eczema'),
(17, 14.9, 98.4, '119/78', 71, 'None'),
(18, 13.6, 98.9, '127/82', 74, 'Asthma'),
(19, 15.3, 98.6, '115/74', 67, 'None'),
(20, 14.1, 98.7, '122/79', 72, 'Osteoporosis');

INSERT INTO Donation_Types (Type, Frequency_day) VALUES
(1, 56),  -- Whole Blood
(2, 14),  -- Plasma
(3, 7);   -- Platelets

INSERT INTO Patient (PersonalID, BloodType, NeedStatus, Weight, Reason) VALUES
(1, 'A+', 'Urgent', 70.5, 'Surgery'),
(2, 'B-', 'Routine', 65.2, 'Anemia'),
(3, 'O+', 'Urgent', 80.0, 'Trauma'),
(4, 'AB+', 'Routine', 72.3, 'Cancer Treatment'),
(5, 'A-', 'Urgent', 68.7, 'Blood Disorder'),
(6, 'O-', 'Routine', 75.8, 'Chronic Anemia'),
(7, 'B+', 'Urgent', 82.1, 'Accident Victim'),
(8, 'AB-', 'Routine', 68.5, 'Scheduled Surgery'),
(9, 'O+', 'Urgent', 79.3, 'Postpartum Hemorrhage'),
(10, 'A+', 'Routine', 71.6, 'Chemotherapy'),
(11, 'B-', 'Urgent', 66.9, 'Gastrointestinal Bleeding'),
(12, 'AB+', 'Routine', 77.2, 'Kidney Disease'),
(13, 'O-', 'Urgent', 73.4, 'Liver Transplant'),
(14, 'A-', 'Routine', 69.8, 'Sickle Cell Disease'),
(15, 'B+', 'Urgent', 80.5, 'Severe Burns'),
(16, 'AB-', 'Routine', 74.1, 'Thalassemia'),
(17, 'O+', 'Urgent', 76.3, 'Leukemia'),
(18, 'A+', 'Routine', 70.9, 'Hemophilia'),
(19, 'B-', 'Urgent', 83.2, 'Cardiac Surgery'),
(20, 'AB+', 'Routine', 67.8, 'Aplastic Anemia');

INSERT INTO Nurse (PersonalID, ExperienceYears) VALUES
(1, 5),
(2, 10),
(3, 3),
(4, 7),
(5, 15),
(6, 8),
(7, 12),
(8, 6),
(9, 9),
(10, 20),
(11, 4),
(12, 11),
(13, 7),
(14, 13),
(15, 2),
(16, 16),
(17, 1),
(18, 14),
(19, 5),
(20, 18);

INSERT INTO Donor (PersonalID, Blood_Type, Weight, Height, NextSafeDonation) VALUES
(1, 'O+', 75.5, 1.75, '2024-12-15'),
(2, 'A-', 68.0, 1.63, '2024-11-30'),
(3, 'B+', 82.3, 1.80, '2025-01-10'),
(4, 'AB-', 70.1, 1.68, '2024-12-05'),
(5, 'O-', 77.8, 1.73, '2024-12-20'),
(6, 'A+', 72.5, 1.70, '2024-12-25'),
(7, 'B-', 85.0, 1.86, '2025-01-05'),
(8, 'O+', 68.7, 1.60, '2024-12-10'),
(9, 'AB+', 79.2, 1.78, '2024-12-30'),
(10, 'A-', 74.6, 1.74, '2025-01-15'),
(11, 'O-', 81.3, 1.82, '2024-12-18'),
(12, 'B+', 69.8, 1.66, '2025-01-08'),
(13, 'AB-', 76.4, 1.76, '2024-12-22'),
(14, 'O+', 83.7, 1.88, '2025-01-12'),
(15, 'A+', 71.9, 1.70, '2024-12-28'),
(16, 'B-', 78.5, 1.78, '2025-01-20'),
(17, 'AB+', 73.2, 1.71, '2024-12-12'),
(18, 'O-', 80.9, 1.84, '2025-01-25'),
(19, 'A-', 67.3, 1.63, '2024-12-08'),
(20, 'B+', 84.6, 1.87, '2025-01-18');

INSERT INTO Requests (RequestID, LocationID, BloodTypeRequested, RequestDate, RequestedQuantityCC) VALUES
(1, 1, 'A+', '2024-11-01', 450),
(2, 2, 'O-', '2024-11-05', 900),
(3, 3, 'B+', '2024-11-10', 300),
(4, 4, 'AB+', '2024-11-15', 600),
(5, 5, 'A-', '2024-11-20', 450),
(6, 6, 'B-', '2024-11-25', 450),
(7, 7, 'AB+', '2024-11-30', 300),
(8, 8, 'O+', '2024-12-05', 900),
(9, 9, 'A-', '2024-12-10', 450),
(10, 10, 'B+', '2024-12-15', 600),
(11, 11, 'AB-', '2024-12-20', 300),
(12, 12, 'O-', '2024-12-25', 900),
(13, 13, 'A+', '2024-12-30', 450),
(14, 14, 'B-', '2025-01-04', 600),
(15, 15, 'AB+', '2025-01-09', 300),
(16, 16, 'O+', '2025-01-14', 900),
(17, 17, 'A-', '2025-01-19', 450),
(18, 18, 'B+', '2025-01-24', 600),
(19, 19, 'AB-', '2025-01-29', 300),
(20, 20, 'O-', '2025-02-03', 900);

INSERT INTO Donation_Records (DonationID, LocationID, DonationDate, BloodBagID) VALUES
(1, 1, '2024-10-15', 1),
(2, 1, '2024-10-16', 2),
(3, 1, '2024-10-17', 3),
(4, 2, '2024-10-18', 4),
(5, 2, '2024-10-19', 5),
(6, 2, '2024-10-20', 6),
(7, 3, '2024-10-21', 7),
(8, 3, '2024-10-22', 8),
(9, 4, '2024-10-23', 9),
(10, 4, '2024-10-24', 10),
(11, 5, '2024-10-25', 11),
(12, 5, '2024-10-26', 12),
(13, 6, '2024-10-27', 13),
(14, 6, '2024-10-28', 14),
(15, 7, '2024-10-29', 15),
(16, 7, '2024-10-30', 16),
(17, 8, '2024-10-31', 17),
(18, 8, '2024-11-01', 18),
(19, 9, '2024-11-02', 19),
(20, 9, '2024-11-03', 20);

INSERT INTO Global_Inventory (GlobalBloodBagID, LocationID, Available) VALUES
(1, 8, 'N'),
(2, 4, 'Y'),
(3, 7, 'N'),
(4, 19, 'N'),
(5, 16, 'Y'),
(6, 17, 'N'),
(7, 12, 'N'),
(8, 17, 'Y'),
(9, 6, 'N'),
(10, 6, 'Y'),
(11, 6, 'Y'),
(12, 8, 'Y'),
(13, 10, 'Y'),
(14, 14, 'N'),
(15, 5, 'Y'),
(16, 15, 'Y'),
(17, 12, 'Y'),
(18, 1, 'Y'),
(19, 12, 'Y'),
(20, 20, 'N');

INSERT INTO Transfusion_Records (TransfusionID, LocationID, TransfusionDate, BloodBagID) VALUES
(1, 15, '2024-12-21', 10),
(2, 11, '2024-10-26', 11),
(3, 3, '2024-10-19', 18),
(4, 8, '2024-10-28', 6),
(5, 7, '2024-12-03', 1),
(6, 6, '2024-12-23', 9),
(7, 7, '2024-12-04', 16),
(8, 13, '2024-12-16', 8),
(9, 12, '2024-10-05', 2),
(10, 20, '2024-11-09', 9),
(11, 17, '2024-12-28', 10),
(12, 5, '2024-11-04', 2),
(13, 12, '2024-11-12', 13),
(14, 15, '2024-10-12', 6),
(15, 15, '2024-11-09', 3),
(16, 6, '2024-11-30', 5),
(17, 8, '2024-10-06', 12),
(18, 20, '2024-10-24', 9),
(19, 8, '2024-10-29', 14),
(20, 3, '2024-10-29', 19);

INSERT INTO Transfusion (TransfusionID, PersonalID, LocationID, PreExamID, NurseID, Amount_Received_CC) VALUES
(1, 5, 6, 9, 13, 410),
(2, 6, 6, 9, 12, 221),
(3, 14, 16, 4, 7, 361),
(4, 19, 1, 1, 13, 256),
(5, 5, 7, 13, 7, 349),
(6, 15, 17, 15, 12, 307),
(7, 10, 2, 14, 17, 347),
(8, 5, 7, 8, 1, 272),
(9, 16, 8, 18, 13, 250),
(10, 20, 9, 11, 4, 388),
(11, 4, 20, 15, 4, 201),
(12, 10, 9, 15, 14, 203),
(13, 16, 7, 2, 19, 356),
(14, 6, 19, 13, 11, 383),
(15, 16, 12, 15, 5, 298),
(16, 4, 16, 20, 19, 326),
(17, 1, 14, 9, 13, 444),
(18, 8, 8, 11, 16, 283),
(19, 7, 3, 8, 20, 337),
(20, 15, 3, 13, 14, 265);

INSERT INTO Donations (Donation_ID, Donor_ID, Donation_Type, Donation_Date, Quantity) VALUES
(1, 17, 1, '2024-05-12', 315),
(2, 11, 1, '2024-12-16', 485),
(3, 6, 1, '2024-04-17', 436),
(4, 15, 1, '2024-12-15', 439),
(5, 15, 1, '2024-04-23', 353),
(6, 13, 1, '2024-06-03', 454),
(7, 1, 1, '2024-03-20', 318),
(8, 8, 2, '2024-04-26', 355),
(9, 14, 2, '2024-02-17', 416),
(10, 8, 2, '2024-12-05', 484),
(11, 1, 2, '2024-03-09', 380),
(12, 9, 2, '2024-12-02', 405),
(13, 19, 2, '2024-07-24', 321),
(14, 9, 2, '2024-11-07', 369),
(15, 19, 3, '2024-01-15', 330),
(16, 3, 3, '2024-08-06', 413),
(17, 6, 3, '2024-07-26', 466),
(18, 19, 3, '2024-06-26', 342),
(19, 17, 3, '2024-07-15', 300),
(20, 13, 3, '2024-10-06', 395);

-- Adding code with individual queries and more tables
-- -------------------------------------------------------- Arbaaz

-- Creating an index on table 'donations' for faster access and creation of child tables
CREATE INDEX idx_donations_id ON donations(Donor_ID);

-- A table to store records of Donor after going through initial tests to assess potential
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

-- Procedures, functions and triggers

-- Arbaaz
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

-- REMOVE these debuggig lines post production
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

-- Query to test if Patients with PersonalID 21,22 exist or not. When run before calling the procedure, it returns Null
select * from patient where PersonalID in ( 21,22);

-- Example query to insert details of 2 patients
CALL AddMultiplePatients(2, '21,B+,Routine,100.23,Surgery,Bhuresh,Singh,60,Male|22,B+,Routine,100.23,Surgery,Mansi,Arora,40,Female');

-- Query to test if Patients with PersonalID 21,22 exist or not
select * from patient where PersonalID in ( 21,22);

-- -------------------------------------------------------- Usman
-- Create a new table for eligible donors
CREATE TABLE IF NOT EXISTS EligibleDonors AS
SELECT d.PersonalID, d.Blood_Type, d.Weight, d.Height, d.NextSafeDonation,
       p.FirstName, p.LastName, p.Age, p.Gender
FROM Donor d
JOIN Person p ON d.PersonalID = p.PersonalID
WHERE d.NextSafeDonation <= CURDATE() AND d.Weight >= 50;

-- Complex Query 1: Find the top 5 locations with the highest blood donation volume in the last 6 months
SELECT l.LocationID, l.LocationName, l.City, 
       SUM(bb.QuantityCC) AS TotalDonationVolume
FROM Locations l
JOIN Donation_Records dr ON l.LocationID = dr.LocationID
JOIN Blood_Bags bb ON dr.BloodBagID = bb.BloodBagID
WHERE dr.DonationDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY l.LocationID, l.LocationName, l.City
ORDER BY TotalDonationVolume DESC
LIMIT 5;

-- Complex Query 2: Calculate the average donation quantity per blood type in the last 6 months
SELECT d.Blood_Type, AVG(bb.QuantityCC) AS AverageDonationQuantity, COUNT(*) AS DonationCount
FROM Donor d
JOIN Donation_Records dr ON d.PersonalID = dr.DonationID
JOIN Blood_Bags bb ON dr.BloodBagID = bb.BloodBagID
WHERE dr.DonationDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY d.Blood_Type
ORDER BY AverageDonationQuantity DESC;

-- -------------------------------------------------------- Sundeep
#Tracks upcoming donation appointments for donors, helping to manage donor schedules and locations
CREATE TABLE IF NOT EXISTS Scheduled_Donations (
    ScheduleID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    DonorID INT UNSIGNED,
    NextDonationDate DATE,
    IntervalDays INT UNSIGNED,  -- Days between scheduled donations
    LocationID INT UNSIGNED,
    FOREIGN KEY (DonorID) REFERENCES Donor(PersonalID),
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID)
);

INSERT INTO Scheduled_Donations (DonorID, NextDonationDate, IntervalDays, LocationID) VALUES
(1, '2024-11-01', 56, 3),
(2, '2024-11-15', 14, 2),
(3, '2024-12-01', 56, 1),
(4, '2024-12-10', 7, 4),
(5, '2024-11-05', 14, 5),
(6, '2024-11-12', 56, 2),
(7, '2024-11-17', 7, 3),
(8, '2024-12-08', 56, 4),
(9, '2024-11-20', 14, 1),
(10, '2024-12-02', 56, 5),
(11, '2024-11-18', 7, 2),
(12, '2024-11-25', 14, 3),
(13, '2024-12-05', 56, 4),
(14, '2024-11-30', 7, 1),
(15, '2024-11-22', 14, 2);

# Displays donors with scheduled donations within the next 30 days, assisting staff with reminders and resource allocation
SELECT D.PersonalID AS DonorID,
       P.FirstName,
       P.LastName,
       SD.NextDonationDate,
       SD.IntervalDays,
       L.LocationName
FROM Scheduled_Donations SD
JOIN Donor D ON SD.DonorID = D.PersonalID
JOIN Person P ON D.PersonalID = P.PersonalID
JOIN Locations L ON SD.LocationID = L.LocationID
WHERE SD.NextDonationDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
ORDER BY SD.NextDonationDate ASC;

# Tracks recurring transfusion schedules for patients, including blood type, interval between transfusions, and location
CREATE TABLE IF NOT EXISTS Transfusion_Schedule (
    ScheduleID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    PatientID INT UNSIGNED,
    BloodType ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    NextTransfusionDate DATE,
    FrequencyDays INT UNSIGNED,  -- Days between scheduled transfusions
    LocationID INT UNSIGNED,
    NotificationSent ENUM('Yes', 'No') DEFAULT 'No',
    FOREIGN KEY (PatientID) REFERENCES Patient(PersonalID),
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID)
);

INSERT INTO Transfusion_Schedule (PatientID, BloodType, NextTransfusionDate, FrequencyDays, LocationID) VALUES
(1, 'A+', '2024-11-10', 30, 1),
(2, 'B-', '2024-11-15', 14, 2),
(3, 'O+', '2024-12-01', 7, 3),
(4, 'AB+', '2024-12-05', 21, 4),
(5, 'O-', '2024-11-20', 30, 5),
(6, 'A-', '2024-11-25', 14, 2),
(7, 'B+', '2024-11-12', 7, 1),
(8, 'AB-', '2024-12-03', 30, 3),
(9, 'O+', '2024-11-18', 21, 4),
(10, 'A+', '2024-12-02', 14, 5);

#Identifies patients due for transfusions in the next 30 days without notification, enabling timely reminders and preparation.
SELECT P.FirstName, 
       P.LastName,
       TS.BloodType,
       TS.NextTransfusionDate,
       L.LocationName
FROM Transfusion_Schedule TS
JOIN Person P ON TS.PatientID = P.PersonalID
JOIN Locations L ON TS.LocationID = L.LocationID
WHERE TS.NextTransfusionDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
  AND TS.NotificationSent = 'No'
ORDER BY TS.NextTransfusionDate ASC;




