SHOW DATABASES;
CREATE DATABASE IF NOT EXISTS BloodLink;
USE BloodLink;
SELECT DATABASE();# Just an information function, doesn't do anything
SHOW tables;

#Disable safe mode
SET SQL_SAFE_UPDATES = 0;

#Tables from Victoria
-- Create Table for explanation of Location Codes
CREATE TABLE IF NOT EXISTS Location_Codes(
LocationCode INT UNSIGNED NOT NULL,
LocationDescription ENUM('Hospital', 'DoctorsOffice', 'DonationFacility', 'TestingFacility'),
PRIMARY KEY (LocationCode)
);

-- Create Table for Location Information
CREATE TABLE IF NOT EXISTS Locations(
LocationID INT UNSIGNED NOT NULL,
LocationName VARCHAR(50),
LocationCode INT UNSIGNED,
City VARCHAR(50),
ZipCode varchar(5),
PRIMARY KEY (LocationID),
FOREIGN KEY (LocationCode) REFERENCES Location_Codes(LocationCode)
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

#Tables from Arbaaz
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

-- Create Global Inverntory table
CREATE TABLE IF NOT EXISTS Global_Inventory(
GlobalBloodBagID INT UNSIGNED NOT NULL,
LocationID INT UNSIGNED,
Available VARCHAR(1)
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

#Tables from Praneeth
#Create Table for Blood_Bags
CREATE TABLE IF NOT EXISTS Blood_Bags (
    BloodBagID INT UNSIGNED NOT NULL,
    QuantityCC INT UNSIGNED,
    BloodType ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    DonationType VARCHAR(50),
    PRIMARY KEY (BloodBagID)
);

#Create Table for Transfusion												
CREATE TABLE IF NOT EXISTS Transfusion (
    TransfusionID INT UNSIGNED NOT NULL,
    PersonalID INT UNSIGNED,  -- Assuming this refers to Patient.PersonalID
    LocationID INT UNSIGNED,  -- Assuming this refers to Locations.LocationID
    PreExamID INT UNSIGNED,   -- Assuming this refers to Pre_Exam.PreExamID
    NurseID INT UNSIGNED,     -- Assuming this refers to Nurse.PersonalID
    Amount_Received_CC INT UNSIGNED,
    PRIMARY KEY (TransfusionID),
    FOREIGN KEY (PersonalID) REFERENCES Patient(PersonalID),
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
    FOREIGN KEY (PreExamID) REFERENCES Pre_Exam(PreExamID),
    FOREIGN KEY (NurseID) REFERENCES Nurse(PersonalID)
);

# Create Table for Pre_Exam 
CREATE TABLE IF NOT EXISTS Pre_Exam (
    PreExamID INT UNSIGNED NOT NULL,
    HemoglobinGDL DECIMAL(5,2),
    TemperatureF DECIMAL(5,2),
    BloodPressure VARCHAR(10),
    PulseBPM INT UNSIGNED,
    OtherIllnesses VARCHAR(255),
    PRIMARY KEY (PreExamID)
);

#Tables from Sai
CREATE TABLE IF NOT EXISTS Donation_Types (
  Type INT PRIMARY KEY NOT NULL,
  Frequency_day INT
);

CREATE TABLE IF NOT EXISTS Donations (
  Donation_ID INT PRIMARY KEY NOT NULL,
  Donor_ID INT,
  Donation_Type INT,
  Donation_Date DATE,
  Quantity INT,
  FOREIGN KEY (Donation_Type) REFERENCES Donation_Types(Type)
);

#Tables from Sundeep
#Create Table for Nurse															
CREATE TABLE IF NOT EXISTS Nurse (
    PersonalID INT UNSIGNED NOT NULL,   -- Foreign key to Patient.PersonalID
    ExperienceYears INT UNSIGNED,
    PRIMARY KEY (PersonalID),
    FOREIGN KEY (PersonalID) REFERENCES Patient(PersonalID)
);

#Create Table for Patient																
CREATE TABLE IF NOT EXISTS Patient (
    PersonalID INT UNSIGNED NOT NULL,   -- Foreign key to Person.PersonalID
    BloodType ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    NeedStatus VARCHAR(50),
    Weight DECIMAL(5, 2),
    Reason VARCHAR(255),  -- Reason for transfusion
    PRIMARY KEY (PersonalID),
    FOREIGN KEY (PersonalID) REFERENCES Person(PersonalID)
);

#Tables from Usman
-- Create the Person table
CREATE TABLE IF NOT EXISTS Person (
    PersonalID INT UNSIGNED NOT NULL PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Age INT,
    Gender ENUM('Male', 'Female', 'Other')
);

drop table if exists Person;

-- Create the Donor table
CREATE TABLE IF NOT EXISTS Donor (
    PersonalID INT UNSIGNED NOT NULL PRIMARY KEY,
    Blood_Type ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    Weight DECIMAL(5, 2),
    Height DECIMAL(4, 2),
    NextSafeDonation DATE,
    FOREIGN KEY (PersonalID) REFERENCES Person(PersonalID) ON DELETE CASCADE
);

-- testing patient + donor via person --
show tables;
describe pre_exam;
select * from blood_bags;
select  * from locations inner join donation_records inner join blood_bags inner join transfusion_records ;
select * from patient;
select * from person inner join patient on person.PersonalID = patient.PersonalID;
select * from donations ;
select * from pre_exam;


 -- 1.Specific to donor, suppose the donor travels abroad for donation and the hospital uses different units.
 select person.PersonalID, concat(FirstName, ' ', LastName) AS 'Name', Blood_Type, Age, Gender, 
 Weight*2.2 AS 'Donor Weight lb',
 Weight AS 'Donor Weight kg',
 Height AS 'Donor Height in meter',
 Height*100 AS 'Donor Height in cm',
 format(Height*3.281, 2) AS 'Donor height in feet',
 NextSafeDonation from person inner join donor on person.PersonalID = donor.PersonalID
 ORDER BY Weight, Height;

-- 2. Fetch record of eligible donors for a patient who 
select * from donor d inner join person p on p.PersonalID = d.PersonalID;