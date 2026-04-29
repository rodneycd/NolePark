-- NolePark prediction helper views
-- Run after schema.sql (can run before or after seed.sql).

CREATE OR REPLACE VIEW v_prediction_legal_options AS
SELECT
    la.permit_type,
    la.day_type,
    la.start_time,
    la.end_time,
    l.lot_id,
    pl.lot_name,
    l.level_id,
    l.level_number,
    l.allowed_permit_type
FROM LEVEL_ACCESS la
JOIN "LEVEL" l
    ON la.lot_id = l.lot_id
   AND la.level_id = l.level_id
JOIN PARKING_LOT pl
    ON pl.lot_id = l.lot_id;

CREATE OR REPLACE VIEW v_prediction_level_capacity AS
SELECT
    lot_id,
    level_id,
    COUNT(*) AS total_spots
FROM PARKING_SPOT
GROUP BY lot_id, level_id;

-- Uses exact day of week for better prediction:
-- 0 = Sunday, 1 = Monday, 2 = Tuesday, ..., 6 = Saturday
CREATE OR REPLACE VIEW v_prediction_hourly_history AS
SELECT
    ps.lot_id,
    sp.level_id,
    EXTRACT(DOW FROM ps.session_date)::INT AS day_of_week,
    EXTRACT(HOUR FROM ps.start_time)::INT AS hour_of_day,
    COUNT(*) AS historical_sessions
FROM PARKING_SESSION ps
JOIN PARKING_SPOT sp
    ON ps.lot_id = sp.lot_id
   AND ps.spot_id = sp.spot_id
GROUP BY
    ps.lot_id,
    sp.level_id,
    EXTRACT(DOW FROM ps.session_date),
    EXTRACT(HOUR FROM ps.start_time);

CREATE OR REPLACE VIEW v_prediction_current_occupancy AS
SELECT
    lot_id,
    level_id,
    COUNT(*) FILTER (WHERE "status" = 'occupied') AS current_occupied
FROM PARKING_SPOT
GROUP BY lot_id, level_id;
