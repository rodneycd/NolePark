-- NolePark seed.sql
-- Clear all data in reverse FK order
DELETE FROM PARKING_SESSION;
DELETE FROM PARKING_SPOT;
DELETE FROM LEVEL_ACCESS;
DELETE FROM "LEVEL";
DELETE FROM SURFACE_LOT;
DELETE FROM GARAGE;
DELETE FROM PARKING_LOT;
DELETE FROM VEHICLE;
DELETE FROM STUDENTS;
DELETE FROM "ADMIN";
DELETE FROM USERS;
DELETE FROM PERMIT;
 
-- Reset sequences
--ALTER SEQUENCE users_user_id_seq              RESTART WITH 1;
--ALTER SEQUENCE parking_lot_lot_id_seq         RESTART WITH 1;
--ALTER SEQUENCE level_level_id_seq             RESTART WITH 1;
--ALTER SEQUENCE parking_spot_spot_id_seq       RESTART WITH 1;
--ALTER SEQUENCE parking_session_session_id_seq RESTART WITH 1;
 
-- Permit types based on FSU permit rules
INSERT INTO PERMIT (
    permit_type, description,
    student_lot_start, student_lot_end,
    employee_lot_start, employee_lot_end,
    overnight_start, overnight_end,
    is_overnight, is_reserved, is_faculty,
    max_vehicles
) VALUES
-- Student VW: weekdays 5:45AM-Midnight student lots, 4:30PM-Midnight employee lots
(
    'Student',
    'Student VW Virtual Permit - White striped spaces. Weekdays 5:45AM-Midnight student lots, 4:30PM-Midnight employee lots.',
    '05:45', '23:59',
    '16:30', '23:59',
    NULL, NULL,
    FALSE, FALSE, FALSE,
    5
),
-- Overnight: Midnight-5:45AM overnight lots, plus all Student VW privileges
(
    'Overnight',
    'Student ON Virtual Overnight Permit - Midnight to 5:45AM overnight lots, plus full Student VW privileges.',
    '05:45', '23:59',
    '16:30', '07:30',
    '00:00', '05:45',
    TRUE, FALSE, FALSE,
    5
),
-- Reserved: 24/7 reserved spots, includes all VW and ON privileges
(
    'Reserved',
    'Student VRES Virtual Reserved Permit - 24/7 access to reserved green-striped spaces. Includes all VW and ON privileges.',
    '05:45', '23:59',
    '16:30', '07:30',
    '00:00', '05:45',
    TRUE, TRUE, FALSE,
    5
),
-- Faculty: red spaces 24/7, student spaces 4:30PM-11:59PM Mon-Fri
(
    'Faculty',
    'Faculty/Staff VR Virtual Permit - Red striped spaces 24/7. Student spaces 4:30PM-11:59PM Mon-Fri.',
    '16:30', '23:59',
    NULL, NULL,
    NULL, NULL,
    FALSE, FALSE, TRUE,
    5
);
 
-- Admins (user_id 1, 2)
INSERT INTO USERS ("name", email, "password") VALUES
    ('Sarah Thompson',  'sthompson@parking.fsu.edu', 'admin_pass_1'),
    ('Marcus Williams', 'mwilliams@parking.fsu.edu', 'admin_pass_2');
 
-- Students and faculty (user_id 3-42)
INSERT INTO USERS ("name", email, "password") VALUES
    ('Alex Johnson',      'aj22@fsu.edu',   'pass_aj22'),
    ('Maria Garcia',      'mg45@fsu.edu',   'pass_mg45'),
    ('Liam Patel',        'lp88@fsu.edu',   'pass_lp88'),
    ('Sophia Chen',       'sc12@fsu.edu',   'pass_sc12'),
    ('James Williams',    'jw67@fsu.edu',   'pass_jw67'),
    ('Emma Davis',        'ed34@fsu.edu',   'pass_ed34'),
    ('Noah Martinez',     'nm91@fsu.edu',   'pass_nm91'),
    ('Olivia Brown',      'ob55@fsu.edu',   'pass_ob55'),
    ('Tyler Scott',       'ts77@fsu.edu',   'pass_ts77'),
    ('Ava Thompson',      'at29@fsu.edu',   'pass_at29'),
    ('Ethan White',       'ew44@fsu.edu',   'pass_ew44'),
    ('Isabella Harris',   'ih63@fsu.edu',   'pass_ih63'),
    ('Mason Clark',       'mc81@fsu.edu',   'pass_mc81'),
    ('Mia Lewis',         'ml17@fsu.edu',   'pass_ml17'),
    ('Logan Robinson',    'lr39@fsu.edu',   'pass_lr39'),
    ('Charlotte Walker',  'cw52@fsu.edu',   'pass_cw52'),
    ('Aiden Hall',        'ah76@fsu.edu',   'pass_ah76'),
    ('Amelia Young',      'ay93@fsu.edu',   'pass_ay93'),
    ('Lucas King',        'lk28@fsu.edu',   'pass_lk28'),
    ('Harper Wright',     'hw61@fsu.edu',   'pass_hw61'),
    ('Jackson Lopez',     'jl47@fsu.edu',   'pass_jl47'),
    ('Evelyn Hill',       'eh84@fsu.edu',   'pass_eh84'),
    ('Sebastian Scott',   'ss36@fsu.edu',   'pass_ss36'),
    ('Abigail Green',     'ag19@fsu.edu',   'pass_ag19'),
    ('Carter Adams',      'ca72@fsu.edu',   'pass_ca72'),
    ('Emily Baker',       'eb58@fsu.edu',   'pass_eb58'),
    ('Owen Nelson',       'on14@fsu.edu',   'pass_on14'),
    ('Elizabeth Carter',  'ec87@fsu.edu',   'pass_ec87'),
    ('Julian Mitchell',   'jm33@fsu.edu',   'pass_jm33'),
    ('Scarlett Perez',    'sp69@fsu.edu',   'pass_sp69'),
    ('Wyatt Roberts',     'wr42@fsu.edu',   'pass_wr42'),
    ('Victoria Turner',   'vt25@fsu.edu',   'pass_vt25'),
    ('Elijah Phillips',   'ep96@fsu.edu',   'pass_ep96'),
    ('Grace Campbell',    'gc53@fsu.edu',   'pass_gc53'),
    ('Henry Parker',      'hp78@fsu.edu',   'pass_hp78'),
    ('Lily Evans',        'le31@fsu.edu',   'pass_le31'),
    ('Dr. Raj Kumar',     'rkumar@fsu.edu', 'pass_rkumar'),
    ('Prof. Lee Park',    'lpark@fsu.edu',  'pass_lpark'),
    ('Dr. Sandra Moore',  'smoore@fsu.edu', 'pass_smoore'),
    ('Prof. David Chen',  'dchen@fsu.edu',  'pass_dchen');
 
-- Admin rows
INSERT INTO "ADMIN" (user_id) VALUES (1), (2);
 
-- Student rows (user_id 3-42)
INSERT INTO STUDENTS (user_id, permit_type, fsuid, "role") VALUES
    (3,  'Student',   'FSU220001', 'user'),
    (4,  'Student',   'FSU220002', 'user'),
    (5,  'Overnight', 'FSU220003', 'user'),
    (6,  'Student',   'FSU220004', 'user'),
    (7,  'Student',   'FSU220005', 'user'),
    (8,  'Overnight', 'FSU220006', 'user'),
    (9,  'Student',   'FSU220007', 'user'),
    (10, 'Student',   'FSU220008', 'user'),
    (11, 'Student',   'FSU220009', 'user'),
    (12, 'Student',   'FSU220010', 'user'),
    (13, 'Student',   'FSU220011', 'user'),
    (14, 'Student',   'FSU220012', 'user'),
    (15, 'Reserved',  'FSU220013', 'user'),
    (16, 'Student',   'FSU220014', 'user'),
    (17, 'Student',   'FSU220015', 'user'),
    (18, 'Overnight', 'FSU220016', 'user'),
    (19, 'Student',   'FSU220017', 'user'),
    (20, 'Student',   'FSU220018', 'user'),
    (21, 'Student',   'FSU220019', 'user'),
    (22, 'Student',   'FSU220020', 'user'),
    (23, 'Reserved',  'FSU220021', 'user'),
    (24, 'Student',   'FSU220022', 'user'),
    (25, 'Student',   'FSU220023', 'user'),
    (26, 'Overnight', 'FSU220024', 'user'),
    (27, 'Student',   'FSU220025', 'user'),
    (28, 'Student',   'FSU220026', 'user'),
    (29, 'Student',   'FSU220027', 'user'),
    (30, 'Student',   'FSU220028', 'user'),
    (31, 'Overnight', 'FSU220029', 'user'),
    (32, 'Student',   'FSU220030', 'user'),
    (33, 'Student',   'FSU220031', 'user'),
    (34, 'Reserved',  'FSU220032', 'user'),
    (35, 'Student',   'FSU220033', 'user'),
    (36, 'Student',   'FSU220034', 'user'),
    (37, 'Student',   'FSU220035', 'user'),
    (38, 'Student',   'FSU220036', 'user'),
    (39, 'Faculty',   'FSU180001', 'user'),
    (40, 'Faculty',   'FSU180002', 'user'),
    (41, 'Faculty',   'FSU180003', 'user'),
    (42, 'Faculty',   'FSU180004', 'user');
 
-- Vehicles (multiple per user, up to 5 per FSU rules)
INSERT INTO VEHICLE (license_plate, make, model, color, "year", owner_id) VALUES
    ('FSU-001A', 'Toyota',    'Camry',     'Blue',   2019, 3),
    ('FSU-001B', 'Honda',     'CBR500',    'Black',  2021, 3),
    ('FSU-002A', 'Honda',     'Civic',     'Silver', 2021, 4),
    ('FSU-003A', 'Ford',      'F-150',     'Black',  2020, 5),
    ('FSU-003B', 'Ford',      'Mustang',   'Red',    2018, 5),
    ('FSU-004A', 'Hyundai',   'Elantra',   'White',  2022, 6),
    ('FSU-005A', 'Chevrolet', 'Malibu',    'Red',    2018, 7),
    ('FSU-005B', 'Chevrolet', 'Spark',     'Orange', 2020, 7),
    ('FSU-006A', 'Kia',       'Forte',     'Gray',   2021, 8),
    ('FSU-007A', 'Nissan',    'Altima',    'Blue',   2020, 9),
    ('FSU-008A', 'Toyota',    'Corolla',   'Green',  2023, 10),
    ('FSU-009A', 'Mazda',     'Mazda3',    'Orange', 2020, 11),
    ('FSU-010A', 'Subaru',    'Impreza',   'White',  2021, 12),
    ('FSU-011A', 'Volkswagen','Jetta',     'Black',  2019, 13),
    ('FSU-012A', 'Toyota',    'RAV4',      'Silver', 2022, 14),
    ('RSV-001A', 'Tesla',     'Model 3',   'Red',    2023, 15),
    ('RSV-001B', 'Tesla',     'Model Y',   'White',  2022, 15),
    ('FSU-014A', 'Honda',     'Accord',    'Blue',   2020, 16),
    ('FSU-015A', 'Jeep',      'Wrangler',  'Green',  2021, 17),
    ('FSU-016A', 'BMW',       'Mini',      'Yellow', 2020, 18),
    ('FSU-017A', 'Dodge',     'Charger',   'Black',  2019, 19),
    ('FSU-018A', 'Kia',       'Soul',      'Orange', 2021, 20),
    ('FSU-019A', 'Honda',     'CR-V',      'Gray',   2022, 21),
    ('FSU-020A', 'Toyota',    'Highlander','Blue',   2020, 22),
    ('RSV-002A', 'Audi',      'A4',        'Black',  2022, 23),
    ('FSU-022A', 'Ford',      'Escape',    'White',  2021, 24),
    ('FSU-023A', 'Nissan',    'Rogue',     'Silver', 2020, 25),
    ('FSU-024A', 'Hyundai',   'Tucson',    'Red',    2022, 26),
    ('FSU-025A', 'Toyota',    'Tacoma',    'Blue',   2019, 27),
    ('FSU-026A', 'Honda',     'Pilot',     'Gray',   2021, 28),
    ('FSU-027A', 'Chevrolet', 'Equinox',   'Black',  2020, 29),
    ('FSU-028A', 'Ford',      'Explorer',  'White',  2022, 30),
    ('FSU-029A', 'Subaru',    'Outback',   'Green',  2021, 31),
    ('FSU-029B', 'Yamaha',    'YZF-R3',    'Blue',   2020, 31),
    ('FSU-030A', 'Mazda',     'CX-5',      'Red',    2022, 32),
    ('FSU-031A', 'Jeep',      'Cherokee',  'Gray',   2020, 33),
    ('RSV-003A', 'Mercedes',  'C-Class',   'Silver', 2023, 34),
    ('FSU-033A', 'Nissan',    'Sentra',    'White',  2021, 35),
    ('FSU-034A', 'Honda',     'HR-V',      'Orange', 2022, 36),
    ('FSU-035A', 'Toyota',    'Prius',     'Silver', 2020, 37),
    ('FSU-036A', 'Volkswagen','Passat',    'Blue',   2021, 38),
    ('FAC-001A', 'BMW',       '330i',      'Black',  2022, 39),
    ('FAC-001B', 'BMW',       'X3',        'White',  2020, 39),
    ('FAC-002A', 'Audi',      'Q5',        'Gray',   2021, 40),
    ('FAC-003A', 'Lexus',     'ES350',     'Silver', 2022, 41),
    ('FAC-004A', 'Mercedes',  'E-Class',   'Black',  2023, 42),
    ('FAC-004B', 'Honda',     'Goldwing',  'Red',    2021, 42);
 
-- Parking lots (2 garages, 3 surface lots)
INSERT INTO PARKING_LOT (lot_name, admin_id, address) VALUES
    ('Traditions Garage',    1, 'Spirit Way, Tallahassee FL 32304'),       -- lot_id = 1
    ('Innovation Garage',    1, 'Innovation Way, Tallahassee FL 32306'),   -- lot_id = 2
    ('Stadium Drive Lot',    2, 'Stadium Drive, Tallahassee FL 32304'),    -- lot_id = 3
    ('Pensacola Street Lot', 2, 'Pensacola Street, Tallahassee FL 32304'), -- lot_id = 4
    ('Call Street Lot',      2, 'Call Street, Tallahassee FL 32304');      -- lot_id = 5
 
INSERT INTO GARAGE (lot_id) VALUES (1), (2);
 
INSERT INTO SURFACE_LOT (lot_id, total_spots) VALUES
    (3, 120),
    (4, 85),
    (5, 60);
 
-- Levels: Traditions = 5, Innovation = 4, surface lots = 1 each
-- Color: white=student, red=faculty, green=reserved, blue=overnight
INSERT INTO "LEVEL" (lot_id, level_number, allowed_permit_type) VALUES
    (1, 1, 'Student'),   -- level_id 1
    (1, 2, 'Student'),   -- level_id 2
    (1, 3, 'Overnight'), -- level_id 3
    (1, 4, 'Faculty'),   -- level_id 4
    (1, 5, 'Reserved'),  -- level_id 5
    (2, 1, 'Student'),   -- level_id 6
    (2, 2, 'Student'),   -- level_id 7
    (2, 3, 'Faculty'),   -- level_id 8
    (2, 4, 'Reserved'),  -- level_id 9
    (3, 1, 'Student'),   -- level_id 10
    (4, 1, 'Faculty'),   -- level_id 11
    (5, 1, 'Reserved');  -- level_id 12
 
-- Time-based access rules per level per permit
-- Traditions Level 1 (student white)
INSERT INTO LEVEL_ACCESS VALUES (1, 1, 'Student',   'weekday', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (1, 1, 'Student',   'weekend', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (1, 1, 'Faculty',   'weekday', '16:30', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (1, 1, 'Faculty',   'weekend', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (1, 1, 'Overnight', 'weekday', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (1, 1, 'Reserved',  'any',     '00:00', '23:59');
 
-- Traditions Level 2 (student white)
INSERT INTO LEVEL_ACCESS VALUES (1, 2, 'Student',   'weekday', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (1, 2, 'Student',   'weekend', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (1, 2, 'Faculty',   'weekday', '16:30', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (1, 2, 'Faculty',   'weekend', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (1, 2, 'Overnight', 'weekday', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (1, 2, 'Reserved',  'any',     '00:00', '23:59');
 
-- Traditions Level 3 (overnight blue)
INSERT INTO LEVEL_ACCESS VALUES (1, 3, 'Overnight', 'any',     '00:00', '05:45');
INSERT INTO LEVEL_ACCESS VALUES (1, 3, 'Overnight', 'weekday', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (1, 3, 'Reserved',  'any',     '00:00', '23:59');
 
-- Traditions Level 4 (faculty red)
INSERT INTO LEVEL_ACCESS VALUES (1, 4, 'Faculty',   'any',     '00:00', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (1, 4, 'Student',   'weekday', '16:30', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (1, 4, 'Overnight', 'weekday', '16:30', '07:30');
INSERT INTO LEVEL_ACCESS VALUES (1, 4, 'Reserved',  'any',     '00:00', '23:59');
 
-- Traditions Level 5 (reserved green)
INSERT INTO LEVEL_ACCESS VALUES (1, 5, 'Reserved',  'any',     '00:00', '23:59');
 
-- Innovation Level 1 (student white)
INSERT INTO LEVEL_ACCESS VALUES (2, 6, 'Student',   'weekday', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (2, 6, 'Student',   'weekend', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (2, 6, 'Faculty',   'weekday', '16:30', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (2, 6, 'Overnight', 'weekday', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (2, 6, 'Reserved',  'any',     '00:00', '23:59');
 
-- Innovation Level 2 (student white)
INSERT INTO LEVEL_ACCESS VALUES (2, 7, 'Student',   'weekday', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (2, 7, 'Student',   'weekend', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (2, 7, 'Faculty',   'weekday', '16:30', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (2, 7, 'Overnight', 'weekday', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (2, 7, 'Reserved',  'any',     '00:00', '23:59');
 
-- Innovation Level 3 (faculty red)
INSERT INTO LEVEL_ACCESS VALUES (2, 8, 'Faculty',   'any',     '00:00', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (2, 8, 'Student',   'weekday', '16:30', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (2, 8, 'Overnight', 'weekday', '16:30', '07:30');
INSERT INTO LEVEL_ACCESS VALUES (2, 8, 'Reserved',  'any',     '00:00', '23:59');
 
-- Innovation Level 4 (reserved green)
INSERT INTO LEVEL_ACCESS VALUES (2, 9, 'Reserved',  'any',     '00:00', '23:59');
 
-- Stadium Drive (student lot)
INSERT INTO LEVEL_ACCESS VALUES (3, 10, 'Student',   'weekday', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (3, 10, 'Student',   'weekend', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (3, 10, 'Faculty',   'weekday', '16:30', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (3, 10, 'Overnight', 'weekday', '05:45', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (3, 10, 'Reserved',  'any',     '00:00', '23:59');
 
-- Pensacola (faculty lot)
INSERT INTO LEVEL_ACCESS VALUES (4, 11, 'Faculty',   'any',     '00:00', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (4, 11, 'Student',   'weekday', '16:30', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (4, 11, 'Overnight', 'weekday', '16:30', '07:30');
INSERT INTO LEVEL_ACCESS VALUES (4, 11, 'Reserved',  'any',     '00:00', '23:59');
 
-- Call Street (reserved/overnight lot)
INSERT INTO LEVEL_ACCESS VALUES (5, 12, 'Reserved',  'any',     '00:00', '23:59');
INSERT INTO LEVEL_ACCESS VALUES (5, 12, 'Overnight', 'any',     '00:00', '05:45');
 
-- Parking spots
-- Traditions Level 1 (level_id=1): 28 standard, 3 handicap, 2 motorcycle
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT 1, 1, 'available', 'white', 'standard', 'T1-' || generate_series
FROM generate_series(1, 28);
 
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number) VALUES
    (1, 1, 'available', 'white', 'handicap',   'T1-HC1'),
    (1, 1, 'available', 'white', 'handicap',   'T1-HC2'),
    (1, 1, 'available', 'white', 'handicap',   'T1-HC3'),
    (1, 1, 'available', 'white', 'motorcycle', 'T1-MC1'),
    (1, 1, 'available', 'white', 'motorcycle', 'T1-MC2');
 
-- Traditions Level 2 (level_id=2): 27 standard, 3 handicap, 2 motorcycle
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT 1, 2, 'available', 'white', 'standard', 'T2-' || generate_series
FROM generate_series(1, 27);
 
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number) VALUES
    (1, 2, 'available', 'white', 'handicap',   'T2-HC1'),
    (1, 2, 'available', 'white', 'handicap',   'T2-HC2'),
    (1, 2, 'available', 'white', 'handicap',   'T2-HC3'),
    (1, 2, 'available', 'white', 'motorcycle', 'T2-MC1'),
    (1, 2, 'available', 'white', 'motorcycle', 'T2-MC2');
 
-- Traditions Level 3 (level_id=3): 23 standard, 2 handicap, 2 motorcycle
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT 1, 3, 'available', 'blue', 'standard', 'T3-' || generate_series
FROM generate_series(1, 23);
 
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number) VALUES
    (1, 3, 'available', 'blue', 'handicap',   'T3-HC1'),
    (1, 3, 'available', 'blue', 'handicap',   'T3-HC2'),
    (1, 3, 'available', 'blue', 'motorcycle', 'T3-MC1'),
    (1, 3, 'available', 'blue', 'motorcycle', 'T3-MC2');
 
-- Traditions Level 4 (level_id=4): 20 standard, 3 handicap, 1 motorcycle
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT 1, 4, 'available', 'red', 'standard', 'T4-' || generate_series
FROM generate_series(1, 20);
 
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number) VALUES
    (1, 4, 'available', 'red', 'handicap',   'T4-HC1'),
    (1, 4, 'available', 'red', 'handicap',   'T4-HC2'),
    (1, 4, 'available', 'red', 'handicap',   'T4-HC3'),
    (1, 4, 'available', 'red', 'motorcycle', 'T4-MC1');
 
-- Traditions Level 5 (level_id=5): 15 standard, 2 handicap, 1 motorcycle
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT 1, 5, 'available', 'green', 'standard', 'T5-' || generate_series
FROM generate_series(1, 15);
 
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number) VALUES
    (1, 5, 'available', 'green', 'handicap',   'T5-HC1'),
    (1, 5, 'available', 'green', 'handicap',   'T5-HC2'),
    (1, 5, 'available', 'green', 'motorcycle', 'T5-MC1');
 
-- Innovation Level 1 (level_id=6): 22 standard, 2 handicap, 2 motorcycle
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT 2, 6, 'available', 'white', 'standard', 'I1-' || generate_series
FROM generate_series(1, 22);
 
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number) VALUES
    (2, 6, 'available', 'white', 'handicap',   'I1-HC1'),
    (2, 6, 'available', 'white', 'handicap',   'I1-HC2'),
    (2, 6, 'available', 'white', 'motorcycle', 'I1-MC1'),
    (2, 6, 'available', 'white', 'motorcycle', 'I1-MC2');
 
-- Innovation Level 2 (level_id=7): 22 standard, 2 handicap, 2 motorcycle
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT 2, 7, 'available', 'white', 'standard', 'I2-' || generate_series
FROM generate_series(1, 22);
 
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number) VALUES
    (2, 7, 'available', 'white', 'handicap',   'I2-HC1'),
    (2, 7, 'available', 'white', 'handicap',   'I2-HC2'),
    (2, 7, 'available', 'white', 'motorcycle', 'I2-MC1'),
    (2, 7, 'available', 'white', 'motorcycle', 'I2-MC2');
 
-- Innovation Level 3 (level_id=8): 18 standard, 2 handicap, 1 motorcycle
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT 2, 8, 'available', 'red', 'standard', 'I3-' || generate_series
FROM generate_series(1, 18);
 
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number) VALUES
    (2, 8, 'available', 'red', 'handicap',   'I3-HC1'),
    (2, 8, 'available', 'red', 'handicap',   'I3-HC2'),
    (2, 8, 'available', 'red', 'motorcycle', 'I3-MC1');
 
-- Innovation Level 4 (level_id=9): 12 standard, 1 handicap, 1 motorcycle
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT 2, 9, 'available', 'green', 'standard', 'I4-' || generate_series
FROM generate_series(1, 12);
 
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number) VALUES
    (2, 9, 'available', 'green', 'handicap',   'I4-HC1'),
    (2, 9, 'available', 'green', 'motorcycle', 'I4-MC1');
 
-- Stadium Drive Lot (lot_id=3, level_id=10): 108 standard, 8 handicap, 4 motorcycle
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT 3, 10, 'available', 'white', 'standard', 'SD-' || generate_series
FROM generate_series(1, 108);
 
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number) VALUES
    (3, 10, 'available', 'white', 'handicap',   'SD-HC1'),
    (3, 10, 'available', 'white', 'handicap',   'SD-HC2'),
    (3, 10, 'available', 'white', 'handicap',   'SD-HC3'),
    (3, 10, 'available', 'white', 'handicap',   'SD-HC4'),
    (3, 10, 'available', 'white', 'handicap',   'SD-HC5'),
    (3, 10, 'available', 'white', 'handicap',   'SD-HC6'),
    (3, 10, 'available', 'white', 'handicap',   'SD-HC7'),
    (3, 10, 'available', 'white', 'handicap',   'SD-HC8'),
    (3, 10, 'available', 'white', 'motorcycle', 'SD-MC1'),
    (3, 10, 'available', 'white', 'motorcycle', 'SD-MC2'),
    (3, 10, 'available', 'white', 'motorcycle', 'SD-MC3'),
    (3, 10, 'available', 'white', 'motorcycle', 'SD-MC4');
 
-- Pensacola Lot (lot_id=4, level_id=11): 77 standard, 6 handicap, 2 motorcycle
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT 4, 11, 'available', 'red', 'standard', 'PEN-' || generate_series
FROM generate_series(1, 77);
 
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number) VALUES
    (4, 11, 'available', 'red', 'handicap',   'PEN-HC1'),
    (4, 11, 'available', 'red', 'handicap',   'PEN-HC2'),
    (4, 11, 'available', 'red', 'handicap',   'PEN-HC3'),
    (4, 11, 'available', 'red', 'handicap',   'PEN-HC4'),
    (4, 11, 'available', 'red', 'handicap',   'PEN-HC5'),
    (4, 11, 'available', 'red', 'handicap',   'PEN-HC6'),
    (4, 11, 'available', 'red', 'motorcycle', 'PEN-MC1'),
    (4, 11, 'available', 'red', 'motorcycle', 'PEN-MC2');
 
-- Call Street Lot (lot_id=5, level_id=12): 54 standard, 4 handicap, 2 motorcycle
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT 5, 12, 'available', 'green', 'standard', 'CS-' || generate_series
FROM generate_series(1, 54);
 
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number) VALUES
    (5, 12, 'available', 'green', 'handicap',   'CS-HC1'),
    (5, 12, 'available', 'green', 'handicap',   'CS-HC2'),
    (5, 12, 'available', 'green', 'handicap',   'CS-HC3'),
    (5, 12, 'available', 'green', 'handicap',   'CS-HC4'),
    (5, 12, 'available', 'green', 'motorcycle', 'CS-MC1'),
    (5, 12, 'available', 'green', 'motorcycle', 'CS-MC2');
 
-- Simulate ~30% occupancy
UPDATE PARKING_SPOT SET "status" = 'occupied'
WHERE lot_id = 1 AND spot_number IN (
    'T1-1','T1-3','T1-5','T1-8','T1-11','T1-14','T1-17','T1-20',
    'T2-2','T2-6','T2-9','T2-13','T2-18',
    'T3-1','T3-4','T3-7',
    'T4-1','T4-3','T4-5','T4-8',
    'T5-1','T5-3'
);
 
UPDATE PARKING_SPOT SET "status" = 'occupied'
WHERE lot_id = 2 AND spot_number IN (
    'I1-1','I1-4','I1-7','I1-10','I1-15','I1-20',
    'I2-2','I2-5','I2-8','I2-12',
    'I3-1','I3-4','I3-7',
    'I4-1','I4-3'
);
 
UPDATE PARKING_SPOT SET "status" = 'occupied'
WHERE lot_id = 3 AND spot_number IN (
    'SD-1','SD-5','SD-10','SD-15','SD-20','SD-25','SD-30','SD-35',
    'SD-40','SD-45','SD-50','SD-55','SD-60','SD-65','SD-70',
    'SD-75','SD-80','SD-85','SD-90','SD-95','SD-100','SD-105',
    'SD-HC1','SD-HC3','SD-MC1'
);
 
UPDATE PARKING_SPOT SET "status" = 'occupied'
WHERE lot_id = 4 AND spot_number IN (
    'PEN-1','PEN-5','PEN-10','PEN-15','PEN-20','PEN-25','PEN-30',
    'PEN-35','PEN-40','PEN-45','PEN-50','PEN-55','PEN-HC1','PEN-HC2'
);
 
UPDATE PARKING_SPOT SET "status" = 'occupied'
WHERE lot_id = 5 AND spot_number IN (
    'CS-1','CS-5','CS-10','CS-15','CS-20','CS-25','CS-HC1'
);
 
-- Historical sessions (March 2026)
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-10', '08:15', '10:30', 'FSU-001A', 1,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=1 AND spot_number='T1-1');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-10', '09:00', '11:45', 'FSU-002A', 1,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=1 AND spot_number='T1-3');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-10', '07:30', '17:00', 'FAC-001A', 1,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=1 AND spot_number='T4-1');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-11', '13:00', '15:00', 'FSU-003A', 2,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=2 AND spot_number='I1-1');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-11', '08:00', '09:30', 'FAC-002A', 4,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=4 AND spot_number='PEN-1');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-12', '10:00', '12:30', 'FSU-004A', 3,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=3 AND spot_number='SD-1');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-12', '14:00', '16:30', 'RSV-001A', 5,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=5 AND spot_number='CS-1');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-13', '08:30', '10:00', 'FSU-005A', 1,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=1 AND spot_number='T1-5');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-13', '09:15', '12:00', 'FAC-003A', 2,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=2 AND spot_number='I3-1');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-14', '11:00', '13:30', 'FSU-006A', 3,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=3 AND spot_number='SD-5');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-17', '08:00', '17:00', 'FAC-001A', 4,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=4 AND spot_number='PEN-5');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-17', '13:00', '15:00', 'RSV-002A', 5,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=5 AND spot_number='CS-5');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-18', '09:00', '11:00', 'FSU-007A', 1,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=1 AND spot_number='T2-2');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-18', '10:00', '12:00', 'FSU-008A', 3,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=3 AND spot_number='SD-10');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-19', '08:15', '09:30', 'FAC-004A', 2,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=2 AND spot_number='I3-4');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-19', '14:00', '17:30', 'FSU-009A', 1,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=1 AND spot_number='T1-8');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-20', '08:00', '10:00', 'FSU-010A', 3,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=3 AND spot_number='SD-15');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-20', '09:30', '11:30', 'RSV-003A', 5,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=5 AND spot_number='CS-10');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-24', '07:45', '09:00', 'FAC-002A', 4,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=4 AND spot_number='PEN-10');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-24', '10:00', '14:00', 'FSU-011A', 2,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=2 AND spot_number='I2-2');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-25', '08:30', '11:00', 'FSU-012A', 3,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=3 AND spot_number='SD-20');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-25', '13:00', '15:30', 'FSU-001B', 1,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=1 AND spot_number='T1-MC1');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-26', '09:00', '10:30', 'FSU-029B', 1,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=1 AND spot_number='T1-MC2');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-26', '14:30', '17:00', 'FSU-014A', 1,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=1 AND spot_number='T2-6');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT '2026-03-27', '08:00', '09:30', 'FSU-015A', 3,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=3 AND spot_number='SD-25');
 
-- Active sessions (no end_time = currently parked)
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT CURRENT_DATE, '08:00', NULL, 'FSU-001A', 1,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=1 AND spot_number='T1-11');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT CURRENT_DATE, '09:30', NULL, 'FSU-004A', 2,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=2 AND spot_number='I1-4');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT CURRENT_DATE, '10:15', NULL, 'FAC-001A', 1,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=1 AND spot_number='T4-3');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT CURRENT_DATE, '07:45', NULL, 'RSV-001A', 5,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=5 AND spot_number='CS-15');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT CURRENT_DATE, '08:30', NULL, 'FSU-003A', 3,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=3 AND spot_number='SD-30');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT CURRENT_DATE, '11:00', NULL, 'FAC-003A', 4,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=4 AND spot_number='PEN-15');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT CURRENT_DATE, '09:00', NULL, 'FSU-006A', 1,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=1 AND spot_number='T2-9');
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT CURRENT_DATE, '10:00', NULL, 'RSV-002A', 5,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id=5 AND spot_number='CS-20');
 