-- ============================================================
-- NolePark extra synthetic demo data
-- Run after your original seed.sql.
-- Adds 4 admins, more users/vehicles, 2 garages, 3 surface lots,
-- more levels, spots, access rules, current occupancy, and many sessions.
-- ============================================================

-- ---------- More admins ----------
INSERT INTO USERS ("name", email, "password") VALUES
    ('Nina Rodriguez', 'nrodriguez@parking.fsu.edu', 'admin_pass_3'),
    ('Caleb Brooks',   'cbrooks@parking.fsu.edu',   'admin_pass_4'),
    ('Priya Shah',     'pshah@parking.fsu.edu',     'admin_pass_5'),
    ('Andre Thomas',   'athomas@parking.fsu.edu',   'admin_pass_6');

INSERT INTO "ADMIN" (user_id)
SELECT user_id FROM USERS
WHERE email IN (
    'nrodriguez@parking.fsu.edu',
    'cbrooks@parking.fsu.edu',
    'pshah@parking.fsu.edu',
    'athomas@parking.fsu.edu'
);

-- ---------- More users ----------
INSERT INTO USERS ("name", email, "password") VALUES
    ('Daniel Nguyen',        'dn101@fsu.edu', 'pass_dn101'),
    ('Sofia Ramirez',        'sr102@fsu.edu', 'pass_sr102'),
    ('Miles Anderson',       'ma103@fsu.edu', 'pass_ma103'),
    ('Zoe Foster',           'zf104@fsu.edu', 'pass_zf104'),
    ('Nathan Brooks',        'nb105@fsu.edu', 'pass_nb105'),
    ('Ella Morgan',          'em106@fsu.edu', 'pass_em106'),
    ('Jayden Rivera',        'jr107@fsu.edu', 'pass_jr107'),
    ('Chloe Sanders',        'cs108@fsu.edu', 'pass_cs108'),
    ('Aaron Bell',           'ab109@fsu.edu', 'pass_ab109'),
    ('Layla Reed',           'lr110@fsu.edu', 'pass_lr110'),
    ('Connor Price',         'cp111@fsu.edu', 'pass_cp111'),
    ('Nora Bennett',         'nb112@fsu.edu', 'pass_nb112'),
    ('Isaac Ward',           'iw113@fsu.edu', 'pass_iw113'),
    ('Hannah Torres',        'ht114@fsu.edu', 'pass_ht114'),
    ('Gavin Murphy',         'gm115@fsu.edu', 'pass_gm115'),
    ('Aria Cooper',          'ac116@fsu.edu', 'pass_ac116'),
    ('Leo Richardson',       'lr117@fsu.edu', 'pass_lr117'),
    ('Aubrey Cox',           'ac118@fsu.edu', 'pass_ac118'),
    ('Samuel Howard',        'sh119@fsu.edu', 'pass_sh119'),
    ('Penelope Flores',      'pf120@fsu.edu', 'pass_pf120'),
    ('Dr. Karen Alvarez',    'kalvarez@fsu.edu', 'pass_kalvarez'),
    ('Prof. Michael Stone',  'mstone@fsu.edu',   'pass_mstone'),
    ('Dr. Lisa Bennett',     'lbennett@fsu.edu', 'pass_lbennett'),
    ('Prof. Omar Haddad',    'ohaddad@fsu.edu',  'pass_ohaddad');

INSERT INTO STUDENTS (user_id, permit_type, fsuid)
SELECT user_id,
       CASE
           WHEN email IN ('dn101@fsu.edu','sr102@fsu.edu','ma103@fsu.edu','zf104@fsu.edu','nb105@fsu.edu','em106@fsu.edu','jr107@fsu.edu','cs108@fsu.edu','ab109@fsu.edu','lr110@fsu.edu','cp111@fsu.edu','nb112@fsu.edu') THEN 'Student'
           WHEN email IN ('iw113@fsu.edu','ht114@fsu.edu','gm115@fsu.edu','ac116@fsu.edu') THEN 'Overnight'
           WHEN email IN ('lr117@fsu.edu','ac118@fsu.edu','sh119@fsu.edu','pf120@fsu.edu') THEN 'Reserved'
           ELSE 'Faculty'
       END AS permit_type,
       'FSU23' || LPAD((ROW_NUMBER() OVER (ORDER BY user_id))::TEXT, 4, '0') AS fsuid
FROM USERS
WHERE email IN (
    'dn101@fsu.edu','sr102@fsu.edu','ma103@fsu.edu','zf104@fsu.edu','nb105@fsu.edu','em106@fsu.edu',
    'jr107@fsu.edu','cs108@fsu.edu','ab109@fsu.edu','lr110@fsu.edu','cp111@fsu.edu','nb112@fsu.edu',
    'iw113@fsu.edu','ht114@fsu.edu','gm115@fsu.edu','ac116@fsu.edu','lr117@fsu.edu','ac118@fsu.edu',
    'sh119@fsu.edu','pf120@fsu.edu','kalvarez@fsu.edu','mstone@fsu.edu','lbennett@fsu.edu','ohaddad@fsu.edu'
);

-- ---------- More vehicles ----------
INSERT INTO VEHICLE (license_plate, make, model, color, "year", owner_id)
SELECT plate, make, model, color, yr, u.user_id
FROM (VALUES
    ('FSU-101A','Toyota','Camry','White',2021,'dn101@fsu.edu'),
    ('FSU-102A','Honda','Civic','Blue',2020,'sr102@fsu.edu'),
    ('FSU-103A','Ford','Bronco','Black',2022,'ma103@fsu.edu'),
    ('FSU-104A','Kia','K5','Silver',2023,'zf104@fsu.edu'),
    ('FSU-105A','Nissan','Altima','Gray',2021,'nb105@fsu.edu'),
    ('FSU-106A','Hyundai','Sonata','Red',2022,'em106@fsu.edu'),
    ('FSU-107A','Mazda','CX-30','Blue',2020,'jr107@fsu.edu'),
    ('FSU-108A','Subaru','Crosstrek','Green',2021,'cs108@fsu.edu'),
    ('FSU-109A','Toyota','Corolla','Black',2022,'ab109@fsu.edu'),
    ('FSU-110A','Honda','Accord','White',2021,'lr110@fsu.edu'),
    ('FSU-111A','Volkswagen','Jetta','Silver',2019,'cp111@fsu.edu'),
    ('FSU-112A','Chevrolet','Trailblazer','Orange',2023,'nb112@fsu.edu'),
    ('ON-113A','Jeep','Compass','Gray',2022,'iw113@fsu.edu'),
    ('ON-114A','Toyota','Prius','Silver',2020,'ht114@fsu.edu'),
    ('ON-115A','Honda','CR-V','Black',2021,'gm115@fsu.edu'),
    ('ON-116A','Nissan','Rogue','White',2022,'ac116@fsu.edu'),
    ('RSV-117A','Tesla','Model 3','Red',2023,'lr117@fsu.edu'),
    ('RSV-118A','Audi','A3','Blue',2022,'ac118@fsu.edu'),
    ('RSV-119A','BMW','X1','Black',2021,'sh119@fsu.edu'),
    ('RSV-120A','Lexus','IS300','White',2023,'pf120@fsu.edu'),
    ('FAC-005A','Volvo','XC60','Gray',2022,'kalvarez@fsu.edu'),
    ('FAC-006A','Acura','TLX','Black',2021,'mstone@fsu.edu'),
    ('FAC-007A','Lexus','RX350','Silver',2023,'lbennett@fsu.edu'),
    ('FAC-008A','Tesla','Model Y','White',2022,'ohaddad@fsu.edu')
) AS v(plate, make, model, color, yr, email)
JOIN USERS u ON u.email = v.email;

-- ---------- 2 more garages + 3 more surface lots ----------
INSERT INTO PARKING_LOT (lot_name, admin_id, address)
SELECT lot_name, a.user_id, address
FROM (VALUES
    ('Woodward Garage',      'nrodriguez@parking.fsu.edu', 'Woodward Avenue, Tallahassee FL 32304'),
    ('Spirit Way Garage',    'cbrooks@parking.fsu.edu',    'Spirit Way, Tallahassee FL 32306'),
    ('Student Union Lot',    'pshah@parking.fsu.edu',      'Student Union, Tallahassee FL 32306'),
    ('Leach Center Lot',     'athomas@parking.fsu.edu',    'Leach Center, Tallahassee FL 32306'),
    ('West Campus Lot',      'nrodriguez@parking.fsu.edu', 'West Campus, Tallahassee FL 32304')
) AS x(lot_name, admin_email, address)
JOIN USERS a ON a.email = x.admin_email;

INSERT INTO GARAGE (lot_id)
SELECT lot_id FROM PARKING_LOT
WHERE lot_name IN ('Woodward Garage', 'Spirit Way Garage');

INSERT INTO SURFACE_LOT (lot_id, total_spots)
SELECT lot_id,
       CASE lot_name
           WHEN 'Student Union Lot' THEN 95
           WHEN 'Leach Center Lot' THEN 70
           WHEN 'West Campus Lot' THEN 110
       END
FROM PARKING_LOT
WHERE lot_name IN ('Student Union Lot', 'Leach Center Lot', 'West Campus Lot');

-- ---------- Levels for new lots ----------
INSERT INTO "LEVEL" (lot_id, level_number, allowed_permit_type)
SELECT pl.lot_id, x.level_number, x.permit_type
FROM PARKING_LOT pl
JOIN (VALUES
    ('Woodward Garage',   1, 'Student'),
    ('Woodward Garage',   2, 'Student'),
    ('Woodward Garage',   3, 'Faculty'),
    ('Woodward Garage',   4, 'Overnight'),
    ('Woodward Garage',   5, 'Reserved'),
    ('Spirit Way Garage', 1, 'Student'),
    ('Spirit Way Garage', 2, 'Student'),
    ('Spirit Way Garage', 3, 'Faculty'),
    ('Spirit Way Garage', 4, 'Reserved'),
    ('Student Union Lot', 1, 'Student'),
    ('Leach Center Lot',  1, 'Faculty'),
    ('West Campus Lot',   1, 'Student')
) AS x(lot_name, level_number, permit_type)
ON pl.lot_name = x.lot_name;

-- ---------- Level access rules for new levels ----------
-- Student levels
INSERT INTO LEVEL_ACCESS (lot_id, level_id, permit_type, day_type, start_time, end_time)
SELECT l.lot_id, l.level_id, 'Student', 'weekday', '05:45', '23:59'
FROM "LEVEL" l
JOIN PARKING_LOT pl ON pl.lot_id = l.lot_id
WHERE pl.lot_name IN ('Woodward Garage','Spirit Way Garage','Student Union Lot','West Campus Lot')
  AND l.allowed_permit_type = 'Student';

INSERT INTO LEVEL_ACCESS (lot_id, level_id, permit_type, day_type, start_time, end_time)
SELECT l.lot_id, l.level_id, 'Student', 'weekend', '05:45', '23:59'
FROM "LEVEL" l
JOIN PARKING_LOT pl ON pl.lot_id = l.lot_id
WHERE pl.lot_name IN ('Woodward Garage','Spirit Way Garage','Student Union Lot','West Campus Lot')
  AND l.allowed_permit_type = 'Student';

-- Faculty can use student areas later in the day
INSERT INTO LEVEL_ACCESS (lot_id, level_id, permit_type, day_type, start_time, end_time)
SELECT l.lot_id, l.level_id, 'Faculty', 'weekday', '16:30', '23:59'
FROM "LEVEL" l
JOIN PARKING_LOT pl ON pl.lot_id = l.lot_id
WHERE pl.lot_name IN ('Woodward Garage','Spirit Way Garage','Student Union Lot','West Campus Lot')
  AND l.allowed_permit_type = 'Student';

-- Overnight permit inherits student daytime access on student areas
INSERT INTO LEVEL_ACCESS (lot_id, level_id, permit_type, day_type, start_time, end_time)
SELECT l.lot_id, l.level_id, 'Overnight', 'weekday', '05:45', '23:59'
FROM "LEVEL" l
JOIN PARKING_LOT pl ON pl.lot_id = l.lot_id
WHERE pl.lot_name IN ('Woodward Garage','Spirit Way Garage','Student Union Lot','West Campus Lot')
  AND l.allowed_permit_type = 'Student';

-- Faculty levels/lots
INSERT INTO LEVEL_ACCESS (lot_id, level_id, permit_type, day_type, start_time, end_time)
SELECT l.lot_id, l.level_id, 'Faculty', 'any', '00:00', '23:59'
FROM "LEVEL" l
JOIN PARKING_LOT pl ON pl.lot_id = l.lot_id
WHERE pl.lot_name IN ('Woodward Garage','Spirit Way Garage','Leach Center Lot')
  AND l.allowed_permit_type = 'Faculty';

INSERT INTO LEVEL_ACCESS (lot_id, level_id, permit_type, day_type, start_time, end_time)
SELECT l.lot_id, l.level_id, 'Student', 'weekday', '16:30', '23:59'
FROM "LEVEL" l
JOIN PARKING_LOT pl ON pl.lot_id = l.lot_id
WHERE pl.lot_name IN ('Woodward Garage','Spirit Way Garage','Leach Center Lot')
  AND l.allowed_permit_type = 'Faculty';

-- Overnight levels
INSERT INTO LEVEL_ACCESS (lot_id, level_id, permit_type, day_type, start_time, end_time)
SELECT l.lot_id, l.level_id, 'Overnight', 'any', '00:00', '05:45'
FROM "LEVEL" l
JOIN PARKING_LOT pl ON pl.lot_id = l.lot_id
WHERE pl.lot_name IN ('Woodward Garage')
  AND l.allowed_permit_type = 'Overnight';

-- Reserved levels and reserved permit access everywhere
INSERT INTO LEVEL_ACCESS (lot_id, level_id, permit_type, day_type, start_time, end_time)
SELECT l.lot_id, l.level_id, 'Reserved', 'any', '00:00', '23:59'
FROM "LEVEL" l
JOIN PARKING_LOT pl ON pl.lot_id = l.lot_id
WHERE pl.lot_name IN ('Woodward Garage','Spirit Way Garage','Student Union Lot','Leach Center Lot','West Campus Lot');

-- ---------- Parking spots for new lots ----------
WITH specs(lot_name, level_number, prefix, color, standard_count, handicap_count, motorcycle_count) AS (
    VALUES
    ('Woodward Garage',   1, 'W1',  'white', 45, 4, 3),
    ('Woodward Garage',   2, 'W2',  'white', 42, 4, 3),
    ('Woodward Garage',   3, 'W3',  'red',   32, 3, 2),
    ('Woodward Garage',   4, 'W4',  'blue',  25, 2, 2),
    ('Woodward Garage',   5, 'W5',  'green', 16, 2, 1),
    ('Spirit Way Garage', 1, 'SW1', 'white', 38, 3, 2),
    ('Spirit Way Garage', 2, 'SW2', 'white', 36, 3, 2),
    ('Spirit Way Garage', 3, 'SW3', 'red',   28, 3, 1),
    ('Spirit Way Garage', 4, 'SW4', 'green', 18, 2, 1),
    ('Student Union Lot', 1, 'SU',  'white', 86, 6, 3),
    ('Leach Center Lot',  1, 'LC',  'red',   63, 5, 2),
    ('West Campus Lot',   1, 'WC',  'white', 98, 8, 4)
)
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT pl.lot_id, l.level_id, 'available', s.color, 'standard', s.prefix || '-' || gs
FROM specs s
JOIN PARKING_LOT pl ON pl.lot_name = s.lot_name
JOIN "LEVEL" l ON l.lot_id = pl.lot_id AND l.level_number = s.level_number
CROSS JOIN LATERAL generate_series(1, s.standard_count) AS gs;

WITH specs(lot_name, level_number, prefix, color, handicap_count) AS (
    VALUES
    ('Woodward Garage',1,'W1','white',4),('Woodward Garage',2,'W2','white',4),('Woodward Garage',3,'W3','red',3),('Woodward Garage',4,'W4','blue',2),('Woodward Garage',5,'W5','green',2),
    ('Spirit Way Garage',1,'SW1','white',3),('Spirit Way Garage',2,'SW2','white',3),('Spirit Way Garage',3,'SW3','red',3),('Spirit Way Garage',4,'SW4','green',2),
    ('Student Union Lot',1,'SU','white',6),('Leach Center Lot',1,'LC','red',5),('West Campus Lot',1,'WC','white',8)
)
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT pl.lot_id, l.level_id, 'available', s.color, 'handicap', s.prefix || '-HC' || gs
FROM specs s
JOIN PARKING_LOT pl ON pl.lot_name = s.lot_name
JOIN "LEVEL" l ON l.lot_id = pl.lot_id AND l.level_number = s.level_number
CROSS JOIN LATERAL generate_series(1, s.handicap_count) AS gs;

WITH specs(lot_name, level_number, prefix, color, motorcycle_count) AS (
    VALUES
    ('Woodward Garage',1,'W1','white',3),('Woodward Garage',2,'W2','white',3),('Woodward Garage',3,'W3','red',2),('Woodward Garage',4,'W4','blue',2),('Woodward Garage',5,'W5','green',1),
    ('Spirit Way Garage',1,'SW1','white',2),('Spirit Way Garage',2,'SW2','white',2),('Spirit Way Garage',3,'SW3','red',1),('Spirit Way Garage',4,'SW4','green',1),
    ('Student Union Lot',1,'SU','white',3),('Leach Center Lot',1,'LC','red',2),('West Campus Lot',1,'WC','white',4)
)
INSERT INTO PARKING_SPOT (lot_id, level_id, "status", color, spot_type, spot_number)
SELECT pl.lot_id, l.level_id, 'available', s.color, 'motorcycle', s.prefix || '-MC' || gs
FROM specs s
JOIN PARKING_LOT pl ON pl.lot_name = s.lot_name
JOIN "LEVEL" l ON l.lot_id = pl.lot_id AND l.level_number = s.level_number
CROSS JOIN LATERAL generate_series(1, s.motorcycle_count) AS gs;

-- ---------- Make current occupancy look realistic on new lots ----------
WITH ranked AS (
    SELECT
        ps.lot_id,
        ps.level_id,
        ps.spot_id,
        ROW_NUMBER() OVER (PARTITION BY ps.lot_id, ps.level_id ORDER BY ps.spot_id) AS rn,
        COUNT(*) OVER (PARTITION BY ps.lot_id, ps.level_id) AS total,
        l.allowed_permit_type
    FROM PARKING_SPOT ps
    JOIN "LEVEL" l ON l.lot_id = ps.lot_id AND l.level_id = ps.level_id
    JOIN PARKING_LOT pl ON pl.lot_id = ps.lot_id
    WHERE pl.lot_name IN ('Woodward Garage','Spirit Way Garage','Student Union Lot','Leach Center Lot','West Campus Lot')
)
UPDATE PARKING_SPOT ps
SET "status" = 'occupied'
FROM ranked r
WHERE ps.lot_id = r.lot_id
  AND ps.spot_id = r.spot_id
  AND r.rn <= CEIL(r.total *
      CASE r.allowed_permit_type
          WHEN 'Student' THEN 0.58
          WHEN 'Faculty' THEN 0.44
          WHEN 'Overnight' THEN 0.28
          WHEN 'Reserved' THEN 0.35
          ELSE 0.30
      END
  );

-- ---------- Many historical sessions for prediction demo ----------
-- This creates broad weekday/weekend + hour coverage across all lots.
WITH vehicle_pool AS (
    SELECT license_plate,
           ROW_NUMBER() OVER (ORDER BY license_plate) AS v_rn,
           COUNT(*) OVER () AS v_total
    FROM VEHICLE
),
spot_pool AS (
    SELECT ps.lot_id,
           ps.spot_id,
           l.level_id,
           l.allowed_permit_type,
           ROW_NUMBER() OVER (ORDER BY ps.lot_id, ps.spot_id) AS s_rn
    FROM PARKING_SPOT ps
    JOIN "LEVEL" l ON l.lot_id = ps.lot_id AND l.level_id = ps.level_id
    WHERE ps.spot_type = 'standard'
),
demo_days AS (
    SELECT generate_series('2026-03-30'::date, '2026-04-26'::date, interval '1 day')::date AS session_date
),
demo_hours(hour_of_day, per_level_sessions) AS (
    VALUES
        (0, 1),   -- midnight / overnight
        (7, 2),
        (8, 4),
        (9, 6),
        (10, 7),
        (11, 6),
        (12, 5),  -- noon
        (13, 5),
        (14, 4),
        (16, 3),
        (17, 3),
        (18, 2),
        (21, 1)   -- 9 PM
),
level_spots AS (
    SELECT
        sp.*,
        ROW_NUMBER() OVER (PARTITION BY sp.lot_id, sp.level_id ORDER BY sp.spot_id) AS rn_in_level
    FROM spot_pool sp
),
sessions_to_insert AS (
    SELECT
        d.session_date,
        make_time(h.hour_of_day, ((ls.rn_in_level * 7) % 50)::INT, 0) AS start_time,
        (make_time(h.hour_of_day, ((ls.rn_in_level * 7) % 50)::INT, 0) + interval '2 hours')::time AS end_time,
        vp.license_plate,
        ls.lot_id,
        ls.spot_id,
        ROW_NUMBER() OVER () AS seq
    FROM demo_days d
    JOIN demo_hours h ON TRUE
    JOIN level_spots ls ON ls.rn_in_level <= h.per_level_sessions
    JOIN vehicle_pool vp ON vp.v_rn = ((ls.s_rn + EXTRACT(DOY FROM d.session_date)::INT + h.hour_of_day) % vp.v_total) + 1
    WHERE
        -- Make student areas busier on weekdays during class hours.
        NOT (EXTRACT(DOW FROM d.session_date) IN (0,6) AND h.hour_of_day IN (7,8))
)
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT session_date, start_time, end_time, license_plate, lot_id, spot_id
FROM sessions_to_insert;

-- ---------- Active sessions for live monitor on new lots ----------
WITH occupied_new_spots AS (
    SELECT ps.lot_id, ps.spot_id,
           ROW_NUMBER() OVER (ORDER BY ps.lot_id, ps.spot_id) AS rn
    FROM PARKING_SPOT ps
    JOIN PARKING_LOT pl ON pl.lot_id = ps.lot_id
    WHERE pl.lot_name IN ('Woodward Garage','Spirit Way Garage','Student Union Lot','Leach Center Lot','West Campus Lot')
      AND ps."status" = 'occupied'
      AND ps.spot_type = 'standard'
    LIMIT 24
),
vehicle_pool AS (
    SELECT license_plate,
           ROW_NUMBER() OVER (ORDER BY license_plate) AS rn
    FROM VEHICLE
    WHERE license_plate LIKE 'FSU-%' OR license_plate LIKE 'FAC-%' OR license_plate LIKE 'RSV-%' OR license_plate LIKE 'ON-%'
)
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT CURRENT_DATE,
       CASE
           WHEN os.rn % 4 = 0 THEN '07:45'::time
           WHEN os.rn % 4 = 1 THEN '08:30'::time
           WHEN os.rn % 4 = 2 THEN '10:15'::time
           ELSE '12:05'::time
       END,
       NULL,
       vp.license_plate,
       os.lot_id,
       os.spot_id
FROM occupied_new_spots os
JOIN vehicle_pool vp ON vp.rn = os.rn;

-- ---------- Quick sanity counts ----------
-- SELECT COUNT(*) AS lots FROM PARKING_LOT;
-- SELECT COUNT(*) AS users FROM USERS;
-- SELECT COUNT(*) AS spots FROM PARKING_SPOT;
-- SELECT COUNT(*) AS sessions FROM PARKING_SESSION;
