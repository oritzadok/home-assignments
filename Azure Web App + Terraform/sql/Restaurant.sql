CREATE TABLE Restaurant (
    Name NVARCHAR(100),
    Address NVARCHAR(255),
    Style NVARCHAR(50),
    Vegetarian BIT,
    DoesDeliveries BIT,
    OpeningHour TIME,
    ClosingHour TIME
);

INSERT INTO Restaurant (Name, Address, Style, Vegetarian, DoesDeliveries, OpeningHour, ClosingHour)
VALUES 
('Pizza Hut', 'Ben Hillel 15, Jerusalem', 'Italian', 1, 1, '09:00', '21:00'),
('Nini Hachi', 'Ben Yehuda 228, Tel Aviv', 'Japanese', 0, 1, '11:00', '23:00'),
('Sogo', 'Gaaton Jabotinski 1, Nahariya', 'Steakhouse', 0, 0, '10:00', '22:00'),
('Rak Dagim', 'Tarshish 7, Eilat', 'Seafood', 0, 0, '09:00', '21:00'),
('Cafe Cafe', 'HaHistadrut 5, Haifa', 'Cafe', 1, 1, '07:00', '22:00'),
('Falafel Gabay', 'Dizengoff 229, Tel Aviv', 'Middle Eastern', 1, 0, '10:00', '20:00'),
('M25', 'HaShomer 1, Tel Aviv', 'Steakhouse', 0, 1, '12:00', '22:00'),
('Cafe Louise', 'Merkaz Metz 28, Hod Hasharon', 'Cafe', 1, 1, '08:00', '22:00'),
('Shila', 'Ben Yehuda 182, Tel Aviv', 'Seafood', 0, 0, '12:00', '00:00'),
('Lola Martin', 'Rothschild Blvd 8, Tel Aviv', 'Mediterranean', 0, 1, '12:00', '23:00'),
('Benedict', 'Rothschild Blvd 29, Tel Aviv', 'Breakfast', 1, 1, '07:00', '15:00'),
('Claro', 'Rothschild Blvd 23, Tel Aviv', 'Mediterranean', 1, 1, '12:00', '00:00'),
('Orna & Ella', 'Sheinkin St 33, Tel Aviv', 'Cafe', 1, 0, '08:00', '22:00'),
('Tzafririm 1', 'HaTzanhanim 1, Haifa', 'Bar', 0, 1, '17:00', '02:00'),
('Ouzeria', 'Matalon St 44, Tel Aviv', 'Greek', 0, 0, '18:00', '23:00'),
('Dallal', 'Shabazi St 10, Tel Aviv', 'French', 1, 1, '12:00', '00:00'),
('Hatraklin', 'Heichal Hatalmud St 4, Tel Aviv', 'Steakhouse', 0, 0, '18:00', '23:00'),
('Santa Katarina', 'Har Sinai 2, Tel Aviv', 'Mediterranean', 1, 0, '12:00', '23:00'),
('Miznon', 'King George St 30, Tel Aviv', 'Street Food', 1, 1, '11:00', '23:00');
