SHOW DATABASES;
-- Create the database and select it
CREATE DATABASE IF NOT EXISTS BloodLink;
USE BloodLink;
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
    PatientID INT UNSIGNED NOT NULL,   -- Foreign key to Patient.PersonalID
    NurseID INT UNSIGNED NOT NULL,
    ExperienceYears INT UNSIGNED,
    PRIMARY KEY (PatientID),
    FOREIGN KEY (PatientID) REFERENCES Patient(PersonalID),
    FOREIGN KEY (NurseID) REFERENCES Person(PersonalID)
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
    FOREIGN KEY (NurseID) REFERENCES Nurse(NurseID)
);

-- Create Table for Donations
CREATE TABLE IF NOT EXISTS Donations (
    Donation_ID INT PRIMARY KEY NOT NULL,
    Donor_ID INT,
    Donation_Type INT,
    Donation_Date DATE,
    Quantity INT,
    FOREIGN KEY (Donation_Type) REFERENCES Donation_Types(Type),
    UNIQUE (Donor_ID)
    -- UNIQUE(Donation_ID)
);

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

# Blood_Demand_History table to track blood type demands over time
CREATE TABLE IF NOT EXISTS Blood_Demand_History (
    DemandID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    BloodType ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    LocationID INT UNSIGNED,
    DemandDate DATE,
    QuantityDemanded INT UNSIGNED
);

-- Create a new table for eligible donors
CREATE TABLE IF NOT EXISTS EligibleDonors AS
SELECT d.PersonalID, d.Blood_Type, d.Weight, d.Height, d.NextSafeDonation,
       p.FirstName, p.LastName, p.Age, p.Gender
FROM Donor d
JOIN Person p ON d.PersonalID = p.PersonalID
WHERE d.NextSafeDonation <= CURDATE() AND d.Weight >= 50;

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

 # Engagement_Records table to track frequent donors and patients
CREATE TABLE IF NOT EXISTS Engagement_Records (
    EngagementID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    PersonalID INT UNSIGNED, 
    EngagementType ENUM('Donor', 'Patient'),
    TotalEvents INT UNSIGNED,
    LastEventDate DATE,
    FOREIGN KEY (PersonalID) REFERENCES Person(PersonalID)
);

#Define which blood types are compatible for transfusions
CREATE TABLE IF NOT EXISTS Blood_Compatibility (
    DonorBloodType ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') NOT NULL,
    RecipientBloodType ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') NOT NULL,
    PRIMARY KEY (DonorBloodType, RecipientBloodType)
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
(5, 14.2, 98.7, '122/78', 70, 'None'); -- since we only want donors

INSERT INTO Donation_Types (Type, Frequency_day) VALUES
(1, 56),  -- Whole Blood
(2, 14),  -- Plasma
(3, 7);   -- Platelets

INSERT INTO Patient (PersonalID, BloodType, NeedStatus, Weight, Reason) VALUES
(6, 'O-', 'Routine', 75.8, 'Chronic Anemia'),
(7, 'B+', 'Urgent', 82.1, 'Accident Victim'),
(8, 'AB-', 'Routine', 68.5, 'Scheduled Surgery'),
(9, 'O+', 'Urgent', 79.3, 'Postpartum Hemorrhage'),
(10, 'A+', 'Routine', 71.6, 'Chemotherapy'),
(11, 'B-', 'Urgent', 66.9, 'Gastrointestinal Bleeding'),
(12, 'AB+', 'Routine', 77.2, 'Kidney Disease'); -- since we only want patients

INSERT INTO Nurse (PatientID, NurseID, ExperienceYears) VALUES
(6, 13, 8),
(7, 14, 12),
(8, 15, 6),
(9, 16, 9),
(10, 17,  20),
(11, 18,  4),
(12, 19,  11);

INSERT INTO Donor (PersonalID, Blood_Type, Weight, Height, NextSafeDonation) VALUES
(1, 'O+', 75.5, 1.75, '2024-12-15'),
(2, 'A-', 68.0, 1.63, '2024-11-30'),
(3, 'B+', 82.3, 1.80, '2025-01-10'),
(4, 'AB-', 70.1, 1.68, '2024-12-05'),
(5, 'O-', 77.8, 1.73, '2024-12-20');

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
(15, 6, 17, 1, 13, 307),
(10, 7, 2, 2, 14, 347),
(5, 8, 7, 3, 15, 272),
(16, 9, 8, 4, 16, 250),
(20, 10, 9, 5, 17, 388);

INSERT INTO Donations (Donation_ID, Donor_ID, Donation_Type, Donation_Date, Quantity) VALUES
(1, 1, 1, '2024-05-12', 315),
(2, 2, 1, '2024-12-16', 485),
(3, 3, 1, '2024-04-17', 436),
(4, 4, 1, '2024-12-15', 439),
(5, 5, 1, '2024-04-23', 353);

INSERT INTO Donor_Post_Exam_Results (PostExamID, Donor_ID, PreExamID, DiseaseDetected, EligibilityStatus, Remarks)
VALUES
(1, 1, 1, 0, 'Eligible', 'Fit for donation'),
(2, 2, 2, 0, 'Deferred', 'Mild cold, defer for a week'),
(3, 3, 3, 1, 'Disqualified', 'Detected flu symptoms'),
(4, 4, 4, 1, 'Deferred', 'Sore throat, needs rest'),
(5, 5, 5, 0, 'Eligible', 'Fit for donation');

INSERT INTO Scheduled_Donations (DonorID, NextDonationDate, IntervalDays, LocationID) VALUES
(1, '2024-11-01', 56, 3),
(2, '2024-11-15', 14, 2),
(3, '2024-12-01', 56, 1),
(4, '2024-12-10', 7, 4),
(5, '2024-11-05', 14, 5);

INSERT INTO Transfusion_Schedule (PatientID, BloodType, NextTransfusionDate, FrequencyDays, LocationID) VALUES
(6, 'A-', '2024-11-25', 14, 2),
(7, 'B+', '2024-11-12', 7, 1),
(8, 'AB-', '2024-12-03', 30, 3),
(9, 'O+', '2024-11-18', 21, 4),
(10, 'A+', '2024-12-02', 14, 5),
(11, 'A+', '2024-11-10', 30, 1),
(12, 'B-', '2024-11-15', 14, 2);

# Insert sample data into Engagement_Records
INSERT INTO Engagement_Records (PersonalID, EngagementType, TotalEvents, LastEventDate) VALUES
(1, 'Donor', 10, '2024-09-10'),
(2, 'Patient', 5, '2024-08-15'),
(3, 'Donor', 12, '2024-08-20'),
(4, 'Patient', 7, '2024-09-25'),
(5, 'Donor', 15, '2024-10-01'),
(6, 'Patient', 8, '2024-08-30'),
(7, 'Donor', 9, '2024-09-15'),
(8, 'Patient', 10, '2024-09-12'),
(9, 'Donor', 11, '2024-10-05'),
(10, 'Patient', 6, '2024-10-09'),
(11, 'Donor', 15, '2024-10-10'),
(12, 'Patient', 10, '2024-09-18'),
(13, 'Donor', 14, '2024-09-23'),
(14, 'Patient', 12, '2024-09-30'),
(15, 'Donor', 8, '2024-10-02');

# Insert sample data into Blood_Demand_History
INSERT INTO Blood_Demand_History (BloodType, LocationID, DemandDate, QuantityDemanded) VALUES 
('AB+', 4, '2023-01-08', 450),
('O+', 5, '2023-01-15', 389),
('A-', 4, '2023-01-22', 415),
('O-', 5, '2023-01-29', 372),
('B+', 2, '2023-02-05', 333),
('AB-', 1, '2023-02-12', 398),
('A+', 3, '2023-02-19', 320),
('B-', 4, '2023-02-26', 356),
('O+', 5, '2023-03-05', 285),
('A+', 1, '2024-01-15', 450),
('B+', 1, '2024-01-16', 300),
('O-', 2, '2024-01-17', 500);

#Populate blood type compatibility based on standard transfusion compatibility rules
INSERT INTO Blood_Compatibility (DonorBloodType, RecipientBloodType) VALUES
    -- Universal Donor (O-)
    ('O-', 'O-'), ('O-', 'O+'), ('O-', 'A-'), ('O-', 'A+'), ('O-', 'B-'), ('O-', 'B+'), ('O-', 'AB-'), ('O-', 'AB+'),

    -- Donor O+
    ('O+', 'O+'), ('O+', 'A+'), ('O+', 'B+'), ('O+', 'AB+'),

    -- Donor A-
    ('A-', 'A-'), ('A-', 'A+'), ('A-', 'AB-'), ('A-', 'AB+'),

    -- Donor A+
    ('A+', 'A+'), ('A+', 'AB+'),

    -- Donor B-
    ('B-', 'B-'), ('B-', 'B+'), ('B-', 'AB-'), ('B-', 'AB+'),

    -- Donor B+
    ('B+', 'B+'), ('B+', 'AB+'),

    -- Donor AB-
    ('AB-', 'AB-'), ('AB-', 'AB+'),

    -- Donor AB+ (Universal Receiver)
    ('AB+', 'AB+');
    
																	-- Complex Queries --
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

-- Complex Query 3: Displays donors with scheduled donations within the next 30 days, assisting staff with reminders and resource allocation
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

-- Complex Query 4: Identifies patients due for transfusions in the next 30 days without notification, enabling timely reminders and preparation.
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

-- Complex Query 5: The query highlights high-engagement donors and patients, helping prioritize individuals with frequent interactions in the blood donation system.
SELECT P.FirstName, 
       P.LastName, 
       ER.EngagementType,
       ER.TotalEvents, 
       ER.LastEventDate
FROM Engagement_Records ER
JOIN Person P ON ER.PersonalID = P.PersonalID
WHERE ER.TotalEvents >= 5
ORDER BY ER.EngagementType, ER.TotalEvents DESC;

-- Complex Query 6: Identify high-demand blood types per location
#Helps track and prioritize blood types with high demand for efficient inventory management.

SELECT BloodType,
    LocationID,
    SUM(QuantityDemanded) AS TotalDemand,
    MAX(DemandDate) AS MostRecentDemand
FROM 
    Blood_Demand_History
GROUP BY 
    BloodType, LocationID
HAVING 
    TotalDemand > 400
ORDER BY 
    TotalDemand DESC, MostRecentDemand DESC;
    
-- Complex Query 7: Calculate the average Hemoglobin values per blood group at time of pre-exam, determines the norm for future donations
SELECT patient.BloodType, AVG(pre_exam.HemoglobinGDL) AS AverageHemoglobin
	FROM pre_exam
JOIN Transfusion ON transfusion.PreExamID = pre_exam.PreExamID
JOIN patient ON patient.PersonalID = transfusion.PersonalID
GROUP BY patient.BloodType 
ORDER BY AverageHemoglobin DESC;

-- Complex Query 8: Inventory levels per blood type
SELECT blood_bags.BloodType, COUNT(*) AS AvailableInventory 
	FROM global_inventory
JOIN locations ON locations.LocationID = global_inventory.LocationID
JOIN transfusion_records ON transfusion_records.LocationID = global_inventory.LocationID
JOIN blood_bags ON blood_bags.BloodBagID = transfusion_records.BloodBagID
WHERE global_inventory.Available=0
GROUP BY blood_bags.BloodType 
ORDER BY AvailableInventory DESC;    

-- Complex Query 9: Retrieve the count of blood bags available in inventory that are compatible with a specific blood type for transfusion
SELECT rcpt.RecipientBloodType AS RequestedBloodType,
    COUNT(bb.BloodBagID) AS MatchingBloodBags
FROM 
    Blood_Compatibility rcpt
JOIN 
    Blood_Bags bb ON bb.BloodType = rcpt.DonorBloodType
JOIN 
    Global_Inventory gi ON gi.GlobalBloodBagID = bb.BloodBagID AND gi.Available = 'Y'
WHERE 
    rcpt.RecipientBloodType = 'A+'  -- Replace 'A+' with the desired recipient blood type
GROUP BY 
    rcpt.RecipientBloodType;
    

-- Complex Query 10: Identify locations with high demand for a specific blood type over the past year to prioritize inventory restocking
SELECT * FROM Blood_Demand_History WHERE BloodType = 'A+' AND DemandDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
SELECT LocationID, 
       SUM(QuantityDemanded) AS TotalDemand,
       COUNT(*) AS TotalRequests,
       MAX(DemandDate) AS MostRecentRequest
FROM Blood_Demand_History
WHERE DemandDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY LocationID
ORDER BY TotalDemand DESC;

-- Complex Query 11: Identify locations with substantial demand for blood type 'A+' in the past year to prioritize inventory allocation
SELECT LocationID, 
       SUM(QuantityDemanded) AS TotalDemand,
       COUNT(*) AS TotalRequests,
       MAX(DemandDate) AS MostRecentRequest
FROM Blood_Demand_History
WHERE BloodType = 'A+' AND DemandDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY LocationID
HAVING TotalDemand > 100  -- Lowered threshold for testing
ORDER BY TotalDemand DESC;

-- Complex Query 12: Specific to donor, suppose the donor travels abroad for donation and the hospital uses different units.
 select person.PersonalID, concat(FirstName, ' ', LastName) AS 'Name', Blood_Type, Age, Gender, 
 Weight*2.2 AS 'Donor Weight lb',
 Weight AS 'Donor Weight kg',
 Height AS 'Donor Height in meter',
 Height*100 AS 'Donor Height in cm',
 format(Height*3.281, 2) AS 'Donor height in feet',
 NextSafeDonation from person inner join donor on person.PersonalID = donor.PersonalID
 ORDER BY Weight, Height;
 
 -- Complex Query 13: The query identifies potential donors with the blood type 'O+' and verifies their next safe donation date to ensure they are eligible to donate soon, ordering the results by the nearest donation date. 
 -- This approach enables the hospital to make informed decisions regarding blood transfusions in emergencies, thereby maximizing patient care efficiency --
SELECT d.PersonalID, p.FirstName, p.LastName, d.NextSafeDonation 
FROM Donor d
JOIN Person p ON d.PersonalID = p.PersonalID
WHERE d.Blood_Type = 'O+' AND d.NextSafeDonation > CURDATE()
ORDER BY d.NextSafeDonation ASC;

																	-- Functions --
-- Funtion 1: The function calculates a donor's impact score to help prioritize and recognize active contributors.
DELIMITER $$
CREATE FUNCTION GetDonorImpactScore(DonorID INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE TotalDonations INT;
    DECLARE TotalQuantity INT;
    DECLARE LastDonationDate DATE;
    DECLARE DaysSinceLastDonation INT;
    DECLARE ImpactScore DECIMAL(10,2);

    -- Retrieve donor's statistics
    SELECT 
        COUNT(DON.Donation_ID),  --  Counts the total number of donations, reflecting the donor's activity level
        SUM(DON.Quantity),  --  Sums the total quantity donated to measure the donor's overall contribution
        MAX(DON.Donation_Date)  --  Finds the most recent donation date to calculate recency
    INTO 
        TotalDonations, 
        TotalQuantity, 
        LastDonationDate
    FROM 
        Donations DON
    WHERE 
        DON.Donor_ID = DonorID;  --  Filters data for the specific donor being evaluated

    -- Calculate days since the last donation
    SET DaysSinceLastDonation = DATEDIFF(CURDATE(), LastDonationDate);  --  Determines how recent the donor's last contribution was

    -- Calculate the impact score
    SET ImpactScore = (TotalDonations * 10) + (TotalQuantity / 100) - (DaysSinceLastDonation / 30);  
    --  Combines donation frequency, quantity, and recency into a single score to evaluate donor engagement

    -- Return the impact score
    RETURN ImpactScore;  -- Outputs the calculated impact score for prioritization and recognition
END$$
DELIMITER ;

SELECT GetDonorImpactScore(2) AS ImpactScore;  --  Calculates and displays the impact score for donor with ID()

-- Function 2: The function generates a personalized reminder message for a donor, indicating when they will be eligible to donate again.
DELIMITER $$
CREATE FUNCTION GetNextDonationReminder(DonorID INT) RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE DaysUntilNextDonation INT;
    DECLARE ReminderMessage VARCHAR(50);

    #Calculate days until the next donation
    SELECT DATEDIFF(NextSafeDonation, CURDATE())
    INTO DaysUntilNextDonation
    FROM Donor
    WHERE PersonalID = DonorID;

    #Generate a message based on the remaining days
    IF DaysUntilNextDonation <= 0 THEN
        SET ReminderMessage = 'Eligible to donate now';  # Encourages the donor to donate immediately if eligible
    ELSEIF DaysUntilNextDonation <= 7 THEN
        SET ReminderMessage = CONCAT('Eligible in ', DaysUntilNextDonation, ' days. Get ready!'); # Motivates the donor to prepare for an upcoming eligibility
    ELSE
        SET ReminderMessage = CONCAT('Eligible in ', DaysUntilNextDonation, ' days.');  # Provides an informational reminder for donors with eligibility beyond a week
    END IF;

    RETURN ReminderMessage;  # Outputs a personalized message tailored to the donor’s eligibility status
END$$
DELIMITER ;

SELECT GetNextDonationReminder(1) AS DonationReminder; # Retrieves a personalized reminder message for the donor with PersonalID()

-- Function 3 : User defined function to check if Patient already exists in the database. 
-- Takes PersonalID as argument and returns bool value (1 if exists else 0) --
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
 SELECT PersonExists(6);
 
																				-- Triggers --

-- Trigger 1: This trigger updates the Blood Demand History Table whenever there is a new request added to the requests table
-- This ensures we are tracking the demand statistics

delimiter //
CREATE TRIGGER UpdateBloodDemandHistory
AFTER INSERT ON Requests
FOR EACH ROW
BEGIN
    -- Insert a new record into Blood_Demand_History with details from the new request
    INSERT INTO Blood_Demand_History (BloodType, LocationID, DemandDate, QuantityDemanded)
    VALUES (NEW.BloodTypeRequested, NEW.LocationID, NEW.RequestDate, NEW.RequestedQuantityCC);
END //
DELIMITER ;

select * from requests; -- Current state of table before inserting new data
select * from blood_demand_history; -- Current state of table before running the trigger

INSERT INTO Requests (RequestID, LocationID, BloodTypeRequested, RequestDate, RequestedQuantityCC)
VALUES (21, 2, 'A+', '2024-11-20', 500);

SELECT * FROM Blood_Demand_History WHERE DemandDate = '2024-11-20' AND LocationID = 2; -- After insertion of data in requests table

-- Trigger 2: This trigger will prevent people under 18 signing up, before data is entered into tables "Person"
delimiter //
CREATE TRIGGER Restrict_SignUP_Over18
BEFORE INSERT ON Person
FOR EACH ROW
BEGIN
    IF New.Age < '18' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Age must be 18 or older to register'; 
    END IF;
END; //
DELIMITER ;

-- Testcase for Trigger Restrict_SignUP_Over18
INSERT INTO Person (PersonalID, FirstName, LastName, Age, Gender) VALUES
(100, 'Frodo', 'Rodgers', 16, 'Male');

-- Trigger 3: Automatically alert when the requested blood quantity is too low, 
-- helping to manage blood shortages.
 
DELIMITER //
CREATE TRIGGER notify_low_inventory
AFTER INSERT ON Requests
FOR EACH ROW
BEGIN
    DECLARE total_quantity INT;
    SELECT SUM(QuantityCC) INTO total_quantity
    FROM Blood_Bags
    WHERE BloodType = NEW.BloodTypeRequested;
    IF total_quantity < NEW.RequestedQuantityCC+2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Blood stock low for requested type.';
    END IF;
END //
DELIMITER ;
 
-- Test for Trigger Request
INSERT INTO Requests (RequestID, LocationID, BloodTypeRequested, RequestDate, RequestedQuantityCC) VALUES
(25, 1, 'A+', '2024-11-01', 1200);
																		-- Procedures --

-- Procedure 1 :The procedure generates a summary of a donor's details, including their name, total donations, quantity donated, last donation date, and next eligible donation date. 
 
DELIMITER $$
CREATE PROCEDURE Get_Donor_Summary(IN DonorID INT)
BEGIN
    SELECT 
        P.FirstName, # Displays the donor's first name for easy identification
        P.LastName,  # Displays the donor's last name for easy identification
        D.PersonalID, -- # Confirms the donor's unique ID for accurate tracking
        COUNT(DON.Donation_ID) AS TotalDonations,  # Counts total donations made by the donor, reflecting their engagement level
        SUM(DON.Quantity) AS TotalQuantityDonated, # Sums the total quantity donated, indicating the donor's overall contribution
        MAX(DON.Donation_Date) AS LastDonationDate, # Identifies the most recent donation, highlighting recency of engagement
        D.NextSafeDonation AS NextEligibleDonationDate # Shows the next date the donor is eligible to donate, aiding scheduling
    FROM 
        Person P
    JOIN 
        Donor D ON P.PersonalID = D.PersonalID
    JOIN 
        Donations DON ON DON.Donor_ID = D.PersonalID
    WHERE 
        D.PersonalID = DonorID  # Filters results for the specified donor
    GROUP BY 
        D.PersonalID;  #Ensures the summary is grouped correctly for the specified donor
END$$ 
DELIMITER ;

CALL Get_Donor_Summary(5);  # Generates Output of the donor's name, total donations, quantity donated, last donation date, and next eligible donation date.

-- Procedure 2 : The procedure provides a report of blood inventory status by blood type, showing available and reserved units and highlighting low inventory for efficient management.
DELIMITER $$
CREATE PROCEDURE GetBloodInventoryStatus()
BEGIN
    SELECT 
        BB.BloodType,
        COUNT(CASE WHEN GI.Available = 'Y' THEN 1 END) AS AvailableUnits,   -- Counts available blood units per blood type, helping identify stock levels
        COUNT(CASE WHEN GI.Available = 'N' THEN 1 END) AS ReservedUnits,   -- Counts reserved or unavailable blood units for operational insights
        CASE 
            WHEN COUNT(CASE WHEN GI.Available = 'Y' THEN 1 END) < 10 THEN 'Low Inventory'   -- Flags blood types with low inventory to prioritize restocking
            ELSE 'Sufficient Inventory'   -- Indicates sufficient inventory to maintain normal operations
        END AS InventoryStatus
    FROM 
        Blood_Bags BB
    JOIN 
        Global_Inventory GI ON BB.BloodBagID = GI.GlobalBloodBagID   -- Joins inventory with blood bag details for comprehensive data
    GROUP BY 
        BB.BloodType   -- Groups data by blood type to provide a detailed inventory breakdown
    ORDER BY 
        BB.BloodType;   -- Sorts the report by blood type for better readability
END$$
DELIMITER ;

CALL GetBloodInventoryStatus();   -- Generates a report to monitor and manage blood inventory levels effectively.


-- Procedure 3: The procedure inserts multiple patient records from a single string using '|' to separate records and ',' for fields. It uses SUBSTRING_INDEX() to split data, checks if a person exists with PersonExists(), and inserts into the Person table before updating the Patient table.
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