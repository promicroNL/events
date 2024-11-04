-- Step 1: Create Referees Table
CREATE TABLE Referees (
    RefereeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Nationality NVARCHAR(50),
    YearsOfExperience INT
);

-- Step 2: Alter Games Table to Add RefereeID
ALTER TABLE Games
ADD RefereeID INT;

-- Step 3:
ALTER TABLE dbo.Results
DROP COLUMN [Time];



-- Seed Referees Table
INSERT INTO Referees (FirstName, LastName, Nationality, YearsOfExperience)
VALUES
('Octavio', 'Meyran', 'Mexico', 30),       -- Referee for Muhammad Ali vs. George Foreman
('Mills', 'Lane', 'USA', 35),              -- Referee for Mike Tyson vs. Evander Holyfield
('Kenny', 'Bayless', 'USA', 25),           -- Referee for Floyd Mayweather vs. Manny Pacquiao
('Richard', 'Steele', 'USA', 40),          -- Referee for Sugar Ray Leonard vs. Marvin Hagler
('Eddie', 'Cotton', 'USA', 30),            -- Referee for Lennox Lewis vs. Mike Tyson
('Joe', 'Cortez', 'USA', 35),              -- Referee for Floyd Mayweather vs. Ricky Hatton
('Dave', 'Moretti', 'USA', 35),            -- Referee for Floyd Mayweather vs. Canelo Álvarez
('Adelaide', 'Byrd', 'USA', 25),           -- Referee for Canelo Álvarez vs. Gennady Golovkin
('Bayless', 'Kenny', 'USA', 25),           -- Referee for Manny Pacquiao vs. Miguel Cotto
('Mitch', 'Halpern', 'USA', 15);           -- Referee for Oscar De La Hoya vs. Felix Trinidad

-- Update Games Table with RefereeID
UPDATE Games SET RefereeID = 1 WHERE GameID = 1;  -- Muhammad Ali vs. George Foreman
UPDATE Games SET RefereeID = 2 WHERE GameID = 2;  -- Mike Tyson vs. Evander Holyfield
UPDATE Games SET RefereeID = 3 WHERE GameID = 3;  -- Floyd Mayweather vs. Manny Pacquiao
UPDATE Games SET RefereeID = 4 WHERE GameID = 4;  -- Sugar Ray Leonard vs. Marvin Hagler
UPDATE Games SET RefereeID = 5 WHERE GameID = 5;  -- Lennox Lewis vs. Mike Tyson
UPDATE Games SET RefereeID = 6 WHERE GameID = 6;  -- Floyd Mayweather vs. Ricky Hatton
UPDATE Games SET RefereeID = 7 WHERE GameID = 7;  -- Floyd Mayweather vs. Canelo Álvarez
UPDATE Games SET RefereeID = 8 WHERE GameID = 8;  -- Canelo Álvarez vs. Gennady Golovkin
UPDATE Games SET RefereeID = 9 WHERE GameID = 9;  -- Manny Pacquiao vs. Miguel Cotto
UPDATE Games SET RefereeID = 10 WHERE GameID = 10; -- Oscar De La Hoya vs. Felix Trinidad
