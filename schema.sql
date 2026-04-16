-- NolePark schema.sql
 
-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS PARKING_SESSION  CASCADE;
DROP TABLE IF EXISTS PARKING_SPOT     CASCADE;
DROP TABLE IF EXISTS LEVEL_ACCESS     CASCADE;
DROP TABLE IF EXISTS "LEVEL"          CASCADE;
DROP TABLE IF EXISTS SURFACE_LOT      CASCADE;
DROP TABLE IF EXISTS GARAGE           CASCADE;
DROP TABLE IF EXISTS PARKING_LOT      CASCADE;
DROP TABLE IF EXISTS VEHICLE          CASCADE;
DROP TABLE IF EXISTS STUDENTS         CASCADE;
DROP TABLE IF EXISTS "ADMIN"          CASCADE;
DROP TABLE IF EXISTS USERS            CASCADE;
DROP TABLE IF EXISTS PERMIT           CASCADE;
 
-- Permit types and time-window rules
-- FD: permit_type -> all columns
CREATE TABLE PERMIT (
    permit_type         VARCHAR(20) PRIMARY KEY,
    description         TEXT        NOT NULL,
    student_lot_start   TIME,
    student_lot_end     TIME,
    employee_lot_start  TIME,
    employee_lot_end    TIME,
    overnight_start     TIME,
    overnight_end       TIME,
    is_overnight        BOOLEAN DEFAULT FALSE,
    is_reserved         BOOLEAN DEFAULT FALSE,
    is_faculty          BOOLEAN DEFAULT FALSE,
    max_vehicles        INT DEFAULT 5
);
 
-- Base user table for all accounts
-- FD: user_id -> password, name, email
CREATE TABLE USERS (
    user_id    SERIAL       PRIMARY KEY,
    "password" TEXT         NOT NULL,
    "name"     VARCHAR(100) NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL
);
 
-- Student subset of USERS
-- FD: user_id -> permit_type, fsuid, role
CREATE TABLE STUDENTS (
    user_id     INT         PRIMARY KEY
                            REFERENCES USERS(user_id) ON DELETE CASCADE,
    permit_type VARCHAR(20) NOT NULL
                            REFERENCES PERMIT(permit_type),
    fsuid       VARCHAR(20) UNIQUE,
    "role"      VARCHAR(10) DEFAULT 'user'
                            CHECK ("role" IN ('user','admin'))
);
 
-- Admin subset of USERS
CREATE TABLE "ADMIN" (
    user_id INT PRIMARY KEY
                REFERENCES USERS(user_id) ON DELETE CASCADE
);
 
-- Registered vehicles
-- FD: license_plate -> make, model, color, year, owner_id
CREATE TABLE VEHICLE (
    license_plate VARCHAR(20) PRIMARY KEY,
    make          VARCHAR(50) NOT NULL,
    model         VARCHAR(50) NOT NULL,
    color         VARCHAR(30) NOT NULL,
    "year"        INT         NOT NULL CHECK ("year" >= 1990 AND "year" <= 2030),
    owner_id      INT         REFERENCES USERS(user_id) ON DELETE SET NULL
);
 
-- Parent table for all parking lots
-- FD: lot_id -> lot_name, admin_id, address
CREATE TABLE PARKING_LOT (
    lot_id   SERIAL       PRIMARY KEY,
    lot_name VARCHAR(100) NOT NULL,
    admin_id INT          REFERENCES "ADMIN"(user_id) ON DELETE SET NULL,
    address  TEXT
);
 
-- Garage subtype (multi-level)
CREATE TABLE GARAGE (
    lot_id INT PRIMARY KEY
               REFERENCES PARKING_LOT(lot_id) ON DELETE CASCADE
);
 
-- Surface lot subtype (flat, single level)
-- FD: lot_id -> total_spots
CREATE TABLE SURFACE_LOT (
    lot_id      INT PRIMARY KEY
                    REFERENCES PARKING_LOT(lot_id) ON DELETE CASCADE,
    total_spots INT NOT NULL CHECK (total_spots > 0)
);
 
-- Garage level; surface lots each get one row here too
-- FD: (lot_id, level_id) -> level_number, allowed_permit_type
CREATE TABLE "LEVEL" (
    lot_id              INT         NOT NULL
                                    REFERENCES PARKING_LOT(lot_id) ON DELETE CASCADE,
    level_id            SERIAL,
    level_number        INT         NOT NULL,
    allowed_permit_type VARCHAR(20) NOT NULL
                                    REFERENCES PERMIT(permit_type),
    PRIMARY KEY (lot_id, level_id)
);
 
-- Time-based access rules: which permits can use a level and when
-- FD: (lot_id, level_id, permit_type, day_type) -> start_time, end_time
CREATE TABLE LEVEL_ACCESS (
    lot_id      INT         NOT NULL,
    level_id    INT         NOT NULL,
    permit_type VARCHAR(20) NOT NULL REFERENCES PERMIT(permit_type),
    day_type    VARCHAR(10) NOT NULL CHECK (day_type IN ('weekday','weekend','any')),
    start_time  TIME        NOT NULL,
    end_time    TIME        NOT NULL,
    PRIMARY KEY (lot_id, level_id, permit_type, day_type),
    FOREIGN KEY (lot_id, level_id) REFERENCES "LEVEL"(lot_id, level_id)
);
 
-- Individual parking spots
-- FD: (lot_id, spot_id) -> level_id, status, color, spot_type, spot_number
CREATE TABLE PARKING_SPOT (
    lot_id      INT         NOT NULL,
    spot_id     SERIAL,
    level_id    INT         NOT NULL,
    "status"    VARCHAR(20) NOT NULL DEFAULT 'available'
                            CHECK ("status" IN ('available','occupied')),
    color       VARCHAR(20),
    spot_type   VARCHAR(20) NOT NULL DEFAULT 'standard'
                            CHECK (spot_type IN ('standard','handicap','motorcycle')),
    spot_number VARCHAR(10),
    PRIMARY KEY (lot_id, spot_id),
    FOREIGN KEY (lot_id, level_id) REFERENCES "LEVEL"(lot_id, level_id)
);
 
-- Parking session record
-- FD: session_id -> session_date, start_time, end_time, license_plate, lot_id, spot_id
CREATE TABLE PARKING_SESSION (
    session_id    SERIAL      PRIMARY KEY,
    session_date  DATE        NOT NULL DEFAULT CURRENT_DATE,
    start_time    TIME        NOT NULL DEFAULT CURRENT_TIME,
    end_time      TIME,
    license_plate VARCHAR(20) REFERENCES VEHICLE(license_plate) ON DELETE SET NULL,
    lot_id        INT         NOT NULL,
    spot_id       INT         NOT NULL,
    FOREIGN KEY (lot_id, spot_id) REFERENCES PARKING_SPOT(lot_id, spot_id)
);
 
-- View: all available spots with full location info
CREATE OR REPLACE VIEW v_available_spots AS
SELECT
    ps.lot_id,
    pl.lot_name,
    ps.spot_id,
    ps.spot_number,
    ps.color,
    ps.spot_type,
    l.level_id,
    l.level_number,
    l.allowed_permit_type
FROM PARKING_SPOT ps
JOIN PARKING_LOT pl ON pl.lot_id = ps.lot_id
JOIN "LEVEL"      l ON  l.lot_id = ps.lot_id AND l.level_id = ps.level_id
WHERE ps."status" = 'available';
 
-- View: occupancy summary per lot and level (used for congestion queries)
CREATE OR REPLACE VIEW v_occupancy_summary AS
SELECT
    pl.lot_id,
    pl.lot_name,
    l.level_id,
    l.level_number,
    l.allowed_permit_type,
    COUNT(ps.spot_id)                                              AS total_spots,
    COUNT(ps.spot_id) FILTER (WHERE ps."status" = 'occupied')     AS occupied,
    COUNT(ps.spot_id) FILTER (WHERE ps."status" = 'available')    AS available,
    COUNT(ps.spot_id) FILTER (WHERE ps.spot_type = 'handicap')    AS handicap_spots,
    COUNT(ps.spot_id) FILTER (WHERE ps.spot_type = 'motorcycle')  AS motorcycle_spots,
    ROUND(
        COUNT(ps.spot_id) FILTER (WHERE ps."status" = 'occupied')
        * 100.0 / NULLIF(COUNT(ps.spot_id), 0), 1
    )                                                              AS pct_full
FROM PARKING_SPOT ps
JOIN PARKING_LOT  pl ON pl.lot_id = ps.lot_id
JOIN "LEVEL"       l ON  l.lot_id = ps.lot_id AND l.level_id = ps.level_id
GROUP BY pl.lot_id, pl.lot_name, l.level_id, l.level_number, l.allowed_permit_type;
 
-- View: active (in-progress) sessions with full user and spot info
CREATE OR REPLACE VIEW v_active_sessions AS
SELECT
    sess.session_id,
    sess.session_date,
    sess.start_time,
    sess.license_plate,
    v.owner_id,
    u."name"      AS owner_name,
    s.permit_type,
    sess.lot_id,
    pl.lot_name,
    sess.spot_id,
    ps.spot_number,
    ps.spot_type,
    l.level_number
FROM PARKING_SESSION sess
JOIN VEHICLE      v  ON v.license_plate = sess.license_plate
JOIN USERS        u  ON u.user_id       = v.owner_id
JOIN STUDENTS     s  ON s.user_id       = v.owner_id
JOIN PARKING_LOT  pl ON pl.lot_id       = sess.lot_id
JOIN PARKING_SPOT ps ON ps.lot_id       = sess.lot_id AND ps.spot_id = sess.spot_id
JOIN "LEVEL"      l  ON  l.lot_id       = ps.lot_id   AND  l.level_id = ps.level_id
WHERE sess.end_time IS NULL;


CREATE OR REPLACE VIEW v_user_profiles AS
SELECT 
    u.user_id, 
    u.name, 
    u.email,
    CASE 
        WHEN a.user_id IS NOT NULL THEN 'admin'
        WHEN s.user_id IS NOT NULL THEN 'student'
        ELSE 'user' 
    END AS user_role,
    s.fsuid,
    s.permit_type
FROM USERS u
LEFT JOIN STUDENTS s ON u.user_id = s.user_id
LEFT JOIN "ADMIN" a ON u.user_id = a.user_id;