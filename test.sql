-- NolePark tests.sql
-- Testing schema and entires work and appearing as expected.
-- Run this file in psql after loading the schema and data to verify everything is correct.
 
-- ── SECTION 1: VERIFY TABLES LOADED ──────────────────────────────────────────
 
-- List all tables in the public schema
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
 
-- Row counts per table
SELECT 'PERMIT'          AS tbl, COUNT(*) AS rows FROM PERMIT
UNION ALL
SELECT 'USERS',                  COUNT(*) FROM USERS
UNION ALL
SELECT 'STUDENTS',               COUNT(*) FROM STUDENTS
UNION ALL
SELECT 'ADMIN',                  COUNT(*) FROM "ADMIN"
UNION ALL
SELECT 'VEHICLE',                COUNT(*) FROM VEHICLE
UNION ALL
SELECT 'PARKING_LOT',            COUNT(*) FROM PARKING_LOT
UNION ALL
SELECT 'GARAGE',                 COUNT(*) FROM GARAGE
UNION ALL
SELECT 'SURFACE_LOT',            COUNT(*) FROM SURFACE_LOT
UNION ALL
SELECT 'LEVEL',                  COUNT(*) FROM "LEVEL"
UNION ALL
SELECT 'LEVEL_ACCESS',           COUNT(*) FROM LEVEL_ACCESS
UNION ALL
SELECT 'PARKING_SPOT',           COUNT(*) FROM PARKING_SPOT
UNION ALL
SELECT 'PARKING_SESSION',        COUNT(*) FROM PARKING_SESSION
ORDER BY tbl;
 
 
-- ── SECTION 2: BASIC SELECTS ──────────────────────────────────────────────────
 
-- All permit types and their time rules
SELECT
    permit_type, description,
    student_lot_start, student_lot_end,
    employee_lot_start, employee_lot_end,
    overnight_start, overnight_end,
    is_overnight, is_reserved, is_faculty,
    max_vehicles
FROM PERMIT;
 
-- All users with role and account type
SELECT
    u.user_id,
    u."name",
    u.email,
    s.permit_type,
    s.fsuid,
    s."role",
    CASE WHEN a.user_id IS NOT NULL THEN 'Admin' ELSE 'User' END AS account_type
FROM USERS u
LEFT JOIN STUDENTS s ON s.user_id = u.user_id
LEFT JOIN "ADMIN"  a ON a.user_id = u.user_id
ORDER BY u.user_id;
 
-- All parking lots with type and spot count
SELECT
    pl.lot_id,
    pl.lot_name,
    pl.address,
    CASE
        WHEN g.lot_id  IS NOT NULL THEN 'Garage'
        WHEN sl.lot_id IS NOT NULL THEN 'Surface Lot'
    END AS lot_type,
    sl.total_spots
FROM PARKING_LOT pl
LEFT JOIN GARAGE      g  ON  g.lot_id = pl.lot_id
LEFT JOIN SURFACE_LOT sl ON sl.lot_id = pl.lot_id
ORDER BY pl.lot_id;
 
-- Level access rules: who can park where and when
SELECT
    pl.lot_name,
    l.level_number,
    l.allowed_permit_type,
    la.permit_type AS accessible_to,
    la.day_type,
    la.start_time,
    la.end_time
FROM LEVEL_ACCESS la
JOIN "LEVEL"     l  ON  l.lot_id = la.lot_id AND  l.level_id = la.level_id
JOIN PARKING_LOT pl ON pl.lot_id = la.lot_id
ORDER BY pl.lot_name, l.level_number, la.permit_type;
 
-- Spot type breakdown per lot
SELECT
    pl.lot_name,
    ps.spot_type,
    COUNT(*) AS total_spots,
    COUNT(*) FILTER (WHERE ps."status" = 'available') AS available,
    COUNT(*) FILTER (WHERE ps."status" = 'occupied')  AS occupied
FROM PARKING_SPOT ps
JOIN PARKING_LOT pl ON pl.lot_id = ps.lot_id
GROUP BY pl.lot_name, ps.spot_type
ORDER BY pl.lot_name, ps.spot_type;
 
 
-- ── SECTION 3: SEARCH QUERIES ─────────────────────────────────────────────────
 
-- Available spots for Student permit (via view)
SELECT * FROM v_available_spots
WHERE allowed_permit_type = 'Student'
ORDER BY lot_name, level_number;
 
-- All available handicap spots
SELECT
    pl.lot_name,
    l.level_number,
    ps.spot_number,
    ps.color,
    l.allowed_permit_type,
    ps."status"
FROM PARKING_SPOT ps
JOIN "LEVEL"     l  ON  l.lot_id = ps.lot_id AND l.level_id = ps.level_id
JOIN PARKING_LOT pl ON pl.lot_id = ps.lot_id
WHERE ps.spot_type = 'handicap'
AND   ps."status"  = 'available'
ORDER BY pl.lot_name, l.level_number;
 
-- All available motorcycle spots
SELECT
    pl.lot_name,
    l.level_number,
    ps.spot_number,
    ps."status"
FROM PARKING_SPOT ps
JOIN "LEVEL"     l  ON  l.lot_id = ps.lot_id AND l.level_id = ps.level_id
JOIN PARKING_LOT pl ON pl.lot_id = ps.lot_id
WHERE ps.spot_type = 'motorcycle'
AND   ps."status"  = 'available'
ORDER BY pl.lot_name;
 
-- Where Faculty permit can park (all locations and times)
SELECT DISTINCT
    pl.lot_name,
    l.level_number,
    l.allowed_permit_type,
    la.start_time,
    la.end_time,
    la.day_type
FROM LEVEL_ACCESS la
JOIN "LEVEL"     l  ON  l.lot_id = la.lot_id AND l.level_id = la.level_id
JOIN PARKING_LOT pl ON pl.lot_id = la.lot_id
WHERE la.permit_type = 'Faculty'
ORDER BY pl.lot_name, l.level_number;
 
-- Where Overnight permit can park
SELECT DISTINCT
    pl.lot_name,
    l.level_number,
    l.allowed_permit_type,
    la.start_time,
    la.end_time,
    la.day_type
FROM LEVEL_ACCESS la
JOIN "LEVEL"     l  ON  l.lot_id = la.lot_id AND l.level_id = la.level_id
JOIN PARKING_LOT pl ON pl.lot_id = la.lot_id
WHERE la.permit_type = 'Overnight'
ORDER BY pl.lot_name, l.level_number;
 
-- Find student by email
SELECT
    u.user_id, u."name", u.email,
    s.permit_type, s.fsuid, s."role"
FROM USERS u
JOIN STUDENTS s ON s.user_id = u.user_id
WHERE u.email = 'aj22@fsu.edu';
 
-- All vehicles for a specific user
SELECT
    u."name", u.email,
    v.license_plate, v.make, v.model, v.color, v."year"
FROM VEHICLE v
JOIN USERS u ON u.user_id = v.owner_id
WHERE u.email = 'aj22@fsu.edu';
 
-- All active sessions
SELECT * FROM v_active_sessions;
 
 
-- ── SECTION 4: JOIN QUERIES ───────────────────────────────────────────────────
 
-- Join 1: Students and all their vehicles (3 tables)
SELECT
    u."name",
    u.email,
    s.permit_type,
    v.license_plate,
    v.make || ' ' || v.model AS vehicle,
    v.color,
    v."year"
FROM STUDENTS s
JOIN USERS   u ON u.user_id  = s.user_id
JOIN VEHICLE v ON v.owner_id = s.user_id
ORDER BY u."name", v.license_plate;
 
-- Join 2: Every spot with location, permit rules, and status (4 tables)
SELECT
    pl.lot_name,
    l.level_number,
    l.allowed_permit_type,
    ps.spot_number,
    ps.color,
    ps.spot_type,
    ps."status"
FROM PARKING_SPOT ps
JOIN PARKING_LOT pl ON pl.lot_id  = ps.lot_id
JOIN "LEVEL"      l ON  l.lot_id  = ps.lot_id AND l.level_id = ps.level_id
ORDER BY pl.lot_name, l.level_number, ps.spot_number;
 
-- Join 3: Full session history with student, permit, and spot info (6 tables)
SELECT
    sess.session_id,
    u."name"              AS student_name,
    s.permit_type,
    v.license_plate,
    v.make || ' ' || v.model AS vehicle,
    pl.lot_name,
    l.level_number,
    ps.spot_number,
    ps.spot_type,
    sess.session_date,
    sess.start_time,
    sess.end_time,
    CASE WHEN sess.end_time IS NULL THEN 'Active'
         ELSE 'Completed' END AS session_status,
    CASE WHEN sess.end_time IS NOT NULL
         THEN ROUND(EXTRACT(EPOCH FROM (sess.end_time - sess.start_time))/60, 1)
    END                       AS duration_minutes
FROM PARKING_SESSION sess
JOIN VEHICLE      v   ON v.license_plate = sess.license_plate
JOIN USERS        u   ON u.user_id       = v.owner_id
JOIN STUDENTS     s   ON s.user_id       = v.owner_id
JOIN PARKING_LOT  pl  ON pl.lot_id       = sess.lot_id
JOIN PARKING_SPOT ps  ON ps.lot_id       = sess.lot_id AND ps.spot_id = sess.spot_id
JOIN "LEVEL"      l   ON  l.lot_id       = ps.lot_id   AND  l.level_id = ps.level_id
ORDER BY sess.session_date DESC, sess.start_time DESC;
 
-- Join 4: Parking history for a specific student
SELECT
    pl.lot_name,
    l.level_number,
    ps.spot_number,
    ps.spot_type,
    sess.session_date,
    sess.start_time,
    sess.end_time,
    CASE WHEN sess.end_time IS NULL THEN 'Active' ELSE 'Completed' END AS session_status
FROM PARKING_SESSION sess
JOIN VEHICLE      v   ON v.license_plate = sess.license_plate
JOIN USERS        u   ON u.user_id       = v.owner_id
JOIN PARKING_SPOT ps  ON ps.lot_id       = sess.lot_id AND ps.spot_id = sess.spot_id
JOIN "LEVEL"      l   ON  l.lot_id       = ps.lot_id   AND  l.level_id = ps.level_id
JOIN PARKING_LOT  pl  ON pl.lot_id       = sess.lot_id
WHERE u.email = 'aj22@fsu.edu'
ORDER BY sess.session_date DESC;
 
-- Join 5: Spots accessible to Student permit on a weekday at 10 AM
SELECT DISTINCT
    pl.lot_name,
    l.level_number,
    l.allowed_permit_type,
    COUNT(ps.spot_id) FILTER (WHERE ps."status" = 'available') AS available_spots
FROM LEVEL_ACCESS la
JOIN "LEVEL"     l  ON  l.lot_id = la.lot_id AND l.level_id = la.level_id
JOIN PARKING_LOT pl ON pl.lot_id = la.lot_id
JOIN PARKING_SPOT ps ON ps.lot_id = la.lot_id AND ps.level_id = la.level_id
WHERE la.permit_type = 'Student'
AND   la.day_type    IN ('weekday', 'any')
AND   '10:00'::TIME  BETWEEN la.start_time AND la.end_time
GROUP BY pl.lot_name, l.level_number, l.allowed_permit_type
ORDER BY pl.lot_name;
 
 
-- ── SECTION 5: AGGREGATE QUERIES ─────────────────────────────────────────────
 
-- Occupancy summary per lot and level (via view)
SELECT * FROM v_occupancy_summary ORDER BY lot_name, level_number;
 
-- Total spots per lot broken down by type
SELECT
    pl.lot_name,
    COUNT(*)                                              AS total,
    COUNT(*) FILTER (WHERE ps.spot_type = 'standard')    AS standard,
    COUNT(*) FILTER (WHERE ps.spot_type = 'handicap')    AS handicap,
    COUNT(*) FILTER (WHERE ps.spot_type = 'motorcycle')  AS motorcycle,
    COUNT(*) FILTER (WHERE ps."status"  = 'occupied')    AS occupied,
    COUNT(*) FILTER (WHERE ps."status"  = 'available')   AS available,
    ROUND(COUNT(*) FILTER (WHERE ps."status"='occupied') * 100.0 / COUNT(*), 1) AS pct_full
FROM PARKING_SPOT ps
JOIN PARKING_LOT pl ON pl.lot_id = ps.lot_id
GROUP BY pl.lot_name
ORDER BY pct_full DESC;
 
-- Students per permit type
SELECT
    p.permit_type,
    COUNT(s.user_id) AS students_enrolled
FROM PERMIT p
LEFT JOIN STUDENTS s ON s.permit_type = p.permit_type
GROUP BY p.permit_type
ORDER BY students_enrolled DESC;
 
-- Total sessions per lot (busiest lots)
SELECT
    pl.lot_name,
    COUNT(sess.session_id) AS total_sessions,
    COUNT(sess.session_id) FILTER (WHERE sess.end_time IS NULL)     AS active_now,
    COUNT(sess.session_id) FILTER (WHERE sess.end_time IS NOT NULL) AS completed
FROM PARKING_SESSION sess
JOIN PARKING_LOT pl ON pl.lot_id = sess.lot_id
GROUP BY pl.lot_name
ORDER BY total_sessions DESC;
 
-- Average parking duration per lot
SELECT
    pl.lot_name,
    ROUND(AVG(
        EXTRACT(EPOCH FROM (sess.end_time - sess.start_time)) / 60
    ), 1)           AS avg_minutes,
    MIN(sess.end_time - sess.start_time) AS shortest,
    MAX(sess.end_time - sess.start_time) AS longest,
    COUNT(*)        AS completed_sessions
FROM PARKING_SESSION sess
JOIN PARKING_LOT pl ON pl.lot_id = sess.lot_id
WHERE sess.end_time IS NOT NULL
GROUP BY pl.lot_name
ORDER BY avg_minutes DESC;
 
-- Sessions per spot type
SELECT
    ps.spot_type,
    COUNT(sess.session_id) AS total_uses
FROM PARKING_SESSION sess
JOIN PARKING_SPOT ps ON ps.lot_id = sess.lot_id AND ps.spot_id = sess.spot_id
GROUP BY ps.spot_type
ORDER BY total_uses DESC;
 
-- Users with multiple vehicles
SELECT
    u."name",
    u.email,
    s.permit_type,
    COUNT(v.license_plate) AS vehicle_count
FROM USERS u
JOIN STUDENTS s ON s.user_id  = u.user_id
JOIN VEHICLE  v ON v.owner_id = u.user_id
GROUP BY u."name", u.email, s.permit_type
ORDER BY vehicle_count DESC;
 
 
-- ── SECTION 6: INSERT ─────────────────────────────────────────────────────────
 
-- Add a new user
INSERT INTO USERS ("name", email, "password")
VALUES ('Test Student', 'testdemo@fsu.edu', 'demo_pass');
 
-- Add as student
INSERT INTO STUDENTS (user_id, permit_type, fsuid, "role")
VALUES (
    (SELECT user_id FROM USERS WHERE email = 'testdemo@fsu.edu'),
    'Student', 'FSU999001', 'user'
);
 
-- Register their vehicle
INSERT INTO VEHICLE (license_plate, make, model, color, "year", owner_id)
VALUES (
    'DEMO-001', 'Honda', 'Accord', 'Blue', 2022,
    (SELECT user_id FROM USERS WHERE email = 'testdemo@fsu.edu')
);
 
-- Mark spot as occupied and start a session
UPDATE PARKING_SPOT SET "status" = 'occupied'
WHERE lot_id = 3 AND spot_number = 'SD-35';
 
INSERT INTO PARKING_SESSION (session_date, start_time, end_time, license_plate, lot_id, spot_id)
SELECT CURRENT_DATE, CURRENT_TIME, NULL, 'DEMO-001', 3,
    (SELECT spot_id FROM PARKING_SPOT WHERE lot_id = 3 AND spot_number = 'SD-35');
 
-- Verify active session
SELECT * FROM v_active_sessions WHERE license_plate = 'DEMO-001';
 
 
-- ── SECTION 7: UPDATE ─────────────────────────────────────────────────────────
 
-- End demo session
UPDATE PARKING_SESSION
SET end_time = CURRENT_TIME
WHERE license_plate = 'DEMO-001'
AND   end_time IS NULL;
 
-- Free the spot
UPDATE PARKING_SPOT
SET "status" = 'available'
WHERE lot_id = 3 AND spot_number = 'SD-35';
 
-- Change a student's permit type
UPDATE STUDENTS
SET permit_type = 'Overnight'
WHERE user_id = (SELECT user_id FROM USERS WHERE email = 'aj22@fsu.edu');
 
-- Verify
SELECT u."name", u.email, s.permit_type FROM USERS u
JOIN STUDENTS s ON s.user_id = u.user_id
WHERE u.email = 'aj22@fsu.edu';
 
-- Revert permit type
UPDATE STUDENTS
SET permit_type = 'Student'
WHERE user_id = (SELECT user_id FROM USERS WHERE email = 'aj22@fsu.edu');
 
-- Rename a lot
UPDATE PARKING_LOT
SET lot_name = 'Traditions Parking Garage'
WHERE lot_name = 'Traditions Garage';
 
-- Revert
UPDATE PARKING_LOT
SET lot_name = 'Traditions Garage'
WHERE lot_name = 'Traditions Parking Garage';
 
 
-- ── SECTION 8: DELETE ─────────────────────────────────────────────────────────
 
-- Clean up demo data in FK order
DELETE FROM PARKING_SESSION WHERE license_plate = 'DEMO-001';
DELETE FROM VEHICLE WHERE license_plate = 'DEMO-001';
DELETE FROM STUDENTS WHERE user_id = (SELECT user_id FROM USERS WHERE email = 'testdemo@fsu.edu');
DELETE FROM USERS WHERE email = 'testdemo@fsu.edu';
 
-- Confirm deletion
SELECT COUNT(*) AS should_be_zero FROM USERS WHERE email = 'testdemo@fsu.edu';
 
 
-- ── SECTION 9: ADVANCED — Time-Based Availability ────────────────────────────
 
-- Lots accessible to Student permit at 3:00 PM on a weekday
SELECT
    pl.lot_name,
    l.level_number,
    l.allowed_permit_type,
    la.start_time AS access_from,
    la.end_time   AS access_until,
    COUNT(ps.spot_id) FILTER (WHERE ps."status" = 'available') AS spots_open
FROM LEVEL_ACCESS la
JOIN "LEVEL"     l  ON  l.lot_id = la.lot_id AND l.level_id = la.level_id
JOIN PARKING_LOT pl ON pl.lot_id = la.lot_id
JOIN PARKING_SPOT ps ON ps.lot_id = la.lot_id AND ps.level_id = la.level_id
WHERE la.permit_type = 'Student'
AND   la.day_type    IN ('weekday', 'any')
AND   '15:00'::TIME  BETWEEN la.start_time AND la.end_time
GROUP BY pl.lot_name, l.level_number, l.allowed_permit_type, la.start_time, la.end_time
ORDER BY pl.lot_name;
 
-- Lots accessible at 2:00 AM (overnight/reserved only)
SELECT
    pl.lot_name,
    l.level_number,
    la.permit_type,
    la.start_time,
    la.end_time
FROM LEVEL_ACCESS la
JOIN "LEVEL"     l  ON  l.lot_id = la.lot_id AND l.level_id = la.level_id
JOIN PARKING_LOT pl ON pl.lot_id = la.lot_id
WHERE la.day_type IN ('any', 'weekday')
AND   '02:00'::TIME BETWEEN la.start_time AND la.end_time
ORDER BY pl.lot_name;
 
-- Congestion alert: flag lots by fill percentage
SELECT
    lot_name,
    level_number,
    allowed_permit_type,
    total_spots,
    occupied,
    available,
    pct_full,
    CASE
        WHEN pct_full >= 90 THEN 'Nearly Full'
        WHEN pct_full >= 70 THEN 'Getting Busy'
        WHEN pct_full >= 40 THEN 'Moderate'
        ELSE 'Plenty Available'
    END AS congestion_status
FROM v_occupancy_summary
ORDER BY pct_full DESC NULLS LAST;
 
-- Busiest hour of day for parking starts
SELECT
    EXTRACT(HOUR FROM start_time)::INT AS hour_of_day,
    COUNT(*)                           AS sessions_started,
    ROUND(COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (), 1)      AS pct_of_all_sessions
FROM PARKING_SESSION
WHERE end_time IS NOT NULL
GROUP BY hour_of_day
ORDER BY sessions_started DESC;
 
-- Sessions and avg duration per permit type
SELECT
    s.permit_type,
    COUNT(sess.session_id) AS total_sessions,
    ROUND(AVG(
        CASE WHEN sess.end_time IS NOT NULL
             THEN EXTRACT(EPOCH FROM (sess.end_time - sess.start_time))/60
        END
    ), 1) AS avg_duration_min
FROM PARKING_SESSION sess
JOIN VEHICLE  v ON v.license_plate = sess.license_plate
JOIN STUDENTS s ON s.user_id = v.owner_id
GROUP BY s.permit_type
ORDER BY total_sessions DESC;
 
-- Frequent parkers (more than 2 sessions)
SELECT
    u."name",
    u.email,
    s.permit_type,
    COUNT(sess.session_id) AS total_sessions
FROM PARKING_SESSION sess
JOIN VEHICLE  v ON v.license_plate = sess.license_plate
JOIN USERS    u ON u.user_id       = v.owner_id
JOIN STUDENTS s ON s.user_id       = v.owner_id
GROUP BY u."name", u.email, s.permit_type
HAVING COUNT(sess.session_id) > 2
ORDER BY total_sessions DESC;
 