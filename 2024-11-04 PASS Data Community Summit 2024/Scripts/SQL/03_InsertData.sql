-- Seed Boxers Table
INSERT INTO Boxers (FirstName, LastName, Nationality, BirthDate, Stance, WeightClass)
VALUES 
('Muhammad', 'Ali', 'USA', '1942-01-17', 'Orthodox', 'Heavyweight'),
('Mike', 'Tyson', 'USA', '1966-06-30', 'Orthodox', 'Heavyweight'),
('Floyd', 'Mayweather', 'USA', '1977-02-24', 'Orthodox', 'Welterweight'),
('Manny', 'Pacquiao', 'Philippines', '1978-12-17', 'Southpaw', 'Welterweight'),
('Lennox', 'Lewis', 'UK', '1965-09-02', 'Orthodox', 'Heavyweight'),
('Joe', 'Frazier', 'USA', '1944-01-12', 'Orthodox', 'Heavyweight'),
('Sugar Ray', 'Leonard', 'USA', '1956-05-17', 'Orthodox', 'Welterweight'),
('Oscar', 'De La Hoya', 'USA', '1973-02-04', 'Orthodox', 'Welterweight'),
('Canelo', 'Álvarez', 'Mexico', '1990-07-18', 'Orthodox', 'Middleweight'),
('Gennady', 'Golovkin', 'Kazakhstan', '1982-04-08', 'Orthodox', 'Middleweight');

-- Seed Arenas Table
INSERT INTO Arenas (ArenaName, Location, Capacity)
VALUES 
('Stade du 20 Mai', 'Kinshasa, Zaire', 80000),
('MGM Grand Garden Arena', 'Las Vegas, USA', 17000),
('MGM Grand', 'Las Vegas, USA', 17000),
('Caesars Palace', 'Las Vegas, USA', 24000),
('The Pyramid', 'Memphis, USA', 21000),
('T-Mobile Arena', 'Las Vegas, USA', 20000),
('T-Mobile Arena', 'Las Vegas, USA', 20000),
('MGM Grand', 'Las Vegas, USA', 17000),
('Mandalay Bay Events Center', 'Las Vegas, USA', 12000),
('Staples Center', 'Los Angeles, USA', 20000);

-- Seed Games Table
INSERT INTO Games (GameDate, ArenaID, MainEvent)
VALUES 
('1974-10-30', 1, 'Muhammad Ali vs. George Foreman'),
('1997-06-28', 2, 'Mike Tyson vs. Evander Holyfield'),
('2015-05-02', 3, 'Floyd Mayweather vs. Manny Pacquiao'),
('1987-04-06', 4, 'Sugar Ray Leonard vs. Marvin Hagler'),
('2002-06-08', 5, 'Lennox Lewis vs. Mike Tyson'),
('2007-12-08', 3, 'Floyd Mayweather vs. Ricky Hatton'),
('2013-09-14', 6, 'Floyd Mayweather vs. Canelo Álvarez'),
('2017-09-16', 7, 'Canelo Álvarez vs. Gennady Golovkin'),
('2009-12-05', 8, 'Manny Pacquiao vs. Miguel Cotto'),
('1999-09-18', 9, 'Oscar De La Hoya vs. Felix Trinidad');

-- Seed Results Table
INSERT INTO Results (GameID, WinnerID, LoserID, WinningMethod, Round, Time)
VALUES 
(1, 1, 6, 'KO', 8, '02:58'),
(2, 2, 3, 'DQ', 3, '00:10'),
(3, 3, 4, 'UD', 12, '00:36:00'),
(4, 7, 6, 'SD', 12, '00:36:00'),
(5, 5, 2, 'KO', 8, '02:25:00'),
(6, 3, 4, 'TKO', 10, '01:27:00'),
(7, 3, 9, 'MD', 12, '00:45:00'),
(8, 9, 10, 'Draw', 12, '00:49:00'),
(9, 4, 2, 'TKO', 12, '02:59:00'),
(10, 8, 5, 'MD', 12, '00:41:00');