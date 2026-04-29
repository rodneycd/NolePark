import os
from flask import Flask, jsonify, request
from flask_cors import CORS
from psycopg import connect
from psycopg.rows import dict_row
from functools import wraps

PERMIT_HIERARCHY = {
    'Student': ['Student'],
    'Overnight': ['Overnight', 'Student'],
    'Reserved': ['Reserved', 'Overnight', 'Student'],
    'Faculty': ['Faculty', 'Student']
}


app = Flask(__name__)
CORS(app)

CONN_STR = "host=postgres dbname=myapp user=myuser password=mypassword"

# --- DATABASE UTILITIES ---
def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        # Retrieve the user ID from the custom header
        user_id = request.headers.get('X-User-Id')
        
        if not user_id:
            return jsonify({"success": False, "message": "Authentication required"}), 401
        
        try:
            is_admin = execute_query(
                'SELECT 1 FROM "ADMIN" WHERE user_id = %s', 
                (user_id,)
            )
            
            if not is_admin:
                return jsonify({"success": False, "message": "Admin privileges required"}), 403
                
        except Exception as e:
            print(f"Auth Decorator Error: {e}")
            return jsonify({"success": False, "message": "Server error during auth check"}), 500
            
        return f(*args, **kwargs)
    return decorated_function

def get_db_connection():
    return connect(CONN_STR, row_factory=dict_row)

def execute_query(query, params=None, fetch=True):
    """Universal helper to run SQL and handle commits/closing."""
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(query, params or ())
            if fetch:
                result = cur.fetchall()
                return result
            conn.commit()
            return None
# --- ROUTES ---

@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    user = execute_query("SELECT user_ID, password FROM USERS WHERE email = %s", (email,))

    if user and user[0]['password'] == password:
        return {"success": True, "user_id":user[0]['user_id']}, 200
    return {"success": False, "message": "Invalid credentials"}, 400


@app.route('/api/signup', methods=['POST'])
def signup():
    data = request.json
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    fsuid = data.get('fsuid')

    if not all([name, email, password, fsuid]):
        return {"success": False, "message": "Missing required fields"}, 400

    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO USERS (name, email, password) VALUES (%s, %s, %s) RETURNING user_id",
                    (name, email, password)
                )
                new_user_id = cur.fetchone()['user_id']

                cur.execute(
                    "INSERT INTO STUDENTS (user_id, fsuid, permit_type) VALUES (%s, %s, %s)",
                    (new_user_id, fsuid, 'None')
                )

                conn.commit()
                
                return {
                    "success": True, 
                    "user_id": new_user_id, 
                    "message": "Account created! Go to Settings to finish setup."
                }, 201

    except Exception as e:
        # If email or fsuid is already there, it throws a UniqueViolation
        print(f"Signup Error: {e}")
        return {"success": False, "message": "Email or FSUID already in use"}, 409


@app.route('/api/users', methods=['GET'])
def get_users():
    users = execute_query("SELECT user_id, name, email FROM USERS;")
    return jsonify(users)

@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_profile(user_id):
    user_data = execute_query("SELECT * FROM v_user_profiles WHERE user_id = %s", (user_id,))
    
    if not user_data:
        return jsonify({}), 404
    
    profile = user_data[0]
    admin_check = execute_query('SELECT 1 FROM "ADMIN" WHERE user_id = %s', (user_id,))
    profile['user_role'] = 'admin' if admin_check else 'student'

    return jsonify(profile)
@app.route('/api/permits', methods=['GET'])
def get_permits():
    permits = execute_query("SELECT permit_type FROM PERMIT")
    return jsonify(permits)

@app.route('/api/users/<int:user_id>/permit', methods=['PUT'])
def update_user_permit(user_id):
    data = request.json
    new_permit = data.get('permit_type')

    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # update the student record linked to this user
                cur.execute(
                    "UPDATE STUDENTS SET permit_type = %s WHERE user_id = %s",
                    (new_permit, user_id)
                )
                conn.commit()
                return {"success": True, "message": "Permit updated!"}, 200
    except Exception as e:
        print(f"Update Error: {e}", flush=True)
        return {"success": False, "message": "Database error"}, 500

@app.route('/api/lots/occupancy/<int:user_id>', methods=['GET'])
def get_permit_specific_occupancy(user_id):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT permit_type FROM STUDENTS WHERE user_id = %s", (user_id,))
                user_permit = cur.fetchone()['permit_type']

                accessible_permits = PERMIT_HIERARCHY.get(user_permit, [user_permit])

                #Query the view but only include levels the user can park on
                query = """
                    SELECT 
                        pl.lot_id, 
                        pl.lot_name, 
                        CASE WHEN g.lot_id IS NOT NULL THEN 'garage' ELSE 'surface' END as lot_type,
                        SUM(available) as user_available,
                        SUM(total_spots) as user_total_capacity,
                        ROUND(SUM(occupied) * 100.0 / NULLIF(SUM(total_spots), 0), 1) as user_pct_full
                    FROM v_occupancy_summary v
                    JOIN PARKING_LOT pl ON v.lot_id = pl.lot_id
                    LEFT JOIN GARAGE g ON pl.lot_id = g.lot_id
                    WHERE allowed_permit_type = ANY(%s)
                    GROUP BY pl.lot_id, pl.lot_name, g.lot_id
                """
                cur.execute(query, (accessible_permits,))
                results = cur.fetchall()
                cleaned_results = []
                for row in results:
                    row['user_available'] = int(row['user_available'])
                    row['user_pct_full'] = float(row['user_pct_full'])
                    cleaned_results.append(row)
                return jsonify(cleaned_results), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/users/<int:user_id>/vehicles', methods=['GET'])
def get_user_vehicles(user_id):
    try:
        query = "SELECT license_plate, make, model, color, year FROM VEHICLE WHERE owner_id = %s"
        vehicles = execute_query(query, (user_id,))
        return jsonify(vehicles), 200
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/vehicles', methods=['POST'])
def register_vehicle():
    data = request.json
    plate = data.get('license_plate', '').strip().upper()
    user_id = data.get('owner_id')

    try:
        # Check the 5-car limit
        count_query = "SELECT COUNT(*) as count FROM VEHICLE WHERE owner_id = %s"
        count_res = execute_query(count_query, (user_id,))
        
        # count_res is a list of dicts: [{'count': 0}]
        if count_res[0]['count'] >= 5:
            return jsonify({"success": False, "message": "Vehicle limit (5) reached."}), 400

        insert_query = """
            INSERT INTO VEHICLE (license_plate, make, model, color, year, owner_id)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        execute_query(insert_query, (plate, data['make'], data['model'], data['color'], data['year'], user_id), fetch=False)
        
        return jsonify({"success": True, "message": "Vehicle registered!"}), 201

    except Exception as e:
        if "unique constraint" in str(e).lower():
            return jsonify({"success": False, "message": "This plate is already registered."}), 409
        return jsonify({"success": False, "message": "Database error."}), 500

@app.route('/api/vehicles/<string:plate>', methods=['DELETE'])
def unregister_vehicle(plate):
    try:
        # Ensure an active session vehicle cannot be deleted
        active_check_query = "SELECT * FROM v_active_sessions WHERE license_plate = %s"
        is_active = execute_query(active_check_query, (plate.upper(),))

        if is_active:
            return jsonify({
                "success": False, 
                "message": f"Vehicle {plate} is currently parked in {is_active[0]['lot_name']}. End the session before removing."
            }), 400
        
        query = "DELETE FROM VEHICLE WHERE license_plate = %s"
        execute_query(query, (plate.upper(),), fetch=False)
        return jsonify({"success": True, "message": "Vehicle removed."}), 200
    
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

@app.route('/api/lots/search', methods=['GET'])
def search_lots():
    name = request.args.get('name')
    lot_type = request.args.get('lot_type')
    spot_type = request.args.get('spot_type')
    min_avail = request.args.get('available', type=int)
    max_pct = request.args.get('occupancy_percent', type=float)

    # Base Query using existing v_occupancy_summary
    # We aggregate level-data into lot-level data here
    query = """
        SELECT 
            os.lot_id, 
            os.lot_name,
            CASE 
                WHEN s.lot_id IS NOT NULL THEN 'surface'
                ELSE 'garage'
            END AS lot_type,
            SUM(os.total_spots) AS user_total_capacity,
            SUM(os.available) AS user_available,
            ROUND(AVG(os.pct_full), 1) AS user_pct_full,
            SUM(os.handicap_spots) AS handicap_spots,
            SUM(os.motorcycle_spots) AS motorcycle_spots
        FROM v_occupancy_summary os
        LEFT JOIN SURFACE_LOT s ON os.lot_id = s.lot_id
        WHERE 1=1
    """
    params = []

    # Dynamic Filtering (Conditional Query Building)
    if name:
        query += " AND os.lot_name ILIKE %s"
        params.append(f"%{name}%")

    if lot_type:
        # Filter based on the CASE result or join existence
        if lot_type.lower() == 'surface':
            query += " AND s.lot_id IS NOT NULL"
        elif lot_type.lower() == 'garage':
            query += " AND s.lot_id IS NULL"

    if spot_type == 'handicap':
        query += " AND os.handicap_spots > 0"
    elif spot_type == 'motorcycle':
        query += " AND os.motorcycle_spots > 0"

    # Final Aggregation Grouping
    query += " GROUP BY os.lot_id, os.lot_name, s.lot_id"

    having_clauses = []
    
    if min_avail is not None:
        having_clauses.append("SUM(os.available) >= %s")
        params.append(min_avail)
        
    if max_pct is not None:
        # Max fullness logic: user wants lots UNDER this percent
        having_clauses.append("AVG(os.pct_full) <= %s")
        params.append(max_pct)

    if having_clauses:
        query += " HAVING " + " AND ".join(having_clauses)

    try:
        results = execute_query(query, tuple(params))
        return jsonify(results), 200
    except Exception as e:
        print(f"[ERROR] Lot Search Failed: {e}")
        return jsonify({"error": "Failed to retrieve search results"}), 500

@app.route('/api/lots/<int:lot_id>/levels', methods=['GET'])
def get_lot_levels(lot_id):
    # Aggregating spot types specifically for available spots
    query = """
        SELECT 
            level_id, 
            level_number, 
            allowed_permit_type,
            total_spots,
            available,
            pct_full,
            (SELECT COUNT(*) FROM PARKING_SPOT 
             WHERE lot_id = os.lot_id AND level_id = os.level_id 
             AND status = 'available' AND spot_type = 'handicap') as avail_handicap,
            (SELECT COUNT(*) FROM PARKING_SPOT 
             WHERE lot_id = os.lot_id AND level_id = os.level_id 
             AND status = 'available' AND spot_type = 'motorcycle') as avail_motorcycle
        FROM v_occupancy_summary os
        WHERE lot_id = %s
        ORDER BY level_number ASC
    """
    return jsonify(execute_query(query, (lot_id,))), 200

@app.route('/api/sessions/<int:user_id>/active', methods=['GET'])
def get_active_session(user_id):
    query = """
        SELECT 
            session_id, lot_name, spot_number, 
            start_time::time(0), license_plate AS vehicle_plate,
            make AS vehicle_make, model AS vehicle_model
        FROM v_active_sessions 
        WHERE owner_id = %s
    """
    result = execute_query(query, (user_id,))
    
    if not result:
        return jsonify(None), 200
        
    session = result[0]
    session['start_time'] = str(session['start_time'])
    return jsonify(session), 200

@app.route('/api/sessions/<int:user_id>/start', methods=['POST'])
def start_session(user_id):
    data = request.json
    plate = data.get('license_plate')
    lot_id = data.get('lot_id')
    spot_num = data.get('spot_number')

    student = execute_query("SELECT permit_type FROM STUDENTS WHERE user_id = %s", (user_id,))
    if not student:
        return jsonify({"error": "User does not have a student permit record."}), 403
    
    user_permit = student[0]['permit_type']
    accessible = PERMIT_HIERARCHY.get(user_permit, [user_permit])

    # Check Spot & Permit Requirements
    spot_query = """
        SELECT s.spot_id, s.status, l.allowed_permit_type 
        FROM PARKING_SPOT s 
        JOIN "LEVEL" l ON s.lot_id = l.lot_id AND s.level_id = l.level_id
        WHERE s.lot_id = %s AND s.spot_number = %s
    """
    spot_result = execute_query(spot_query, (lot_id, spot_num,))
    
    if not spot_result:
        return jsonify({"error": "Spot not found in this lot."}), 404
    
    spot = spot_result[0]
    
    # Standard Checks
    if spot['status'] == 'occupied':
        return jsonify({"error": "Spot is already occupied."}), 409

    if spot['allowed_permit_type'] not in accessible:
        return jsonify({"error": f"Permit Mismatch: {spot['allowed_permit_type']} required."}), 403

    execute_query("""
        INSERT INTO PARKING_SESSION (license_plate, lot_id, spot_id)
        VALUES (%s, %s, %s)
    """, (plate, lot_id, spot['spot_id']), fetch=False)
    
    execute_query("""
        UPDATE PARKING_SPOT SET status = 'occupied' 
        WHERE lot_id = %s AND spot_id = %s
    """, (lot_id, spot['spot_id']), fetch=False)
    
    return jsonify({"success": True}), 201

@app.route('/api/sessions/<int:user_id>/end/<int:session_id>', methods=['POST'])
def end_session(user_id, session_id):
    check_query = """
        SELECT sess.lot_id, sess.spot_id 
        FROM PARKING_SESSION sess
        JOIN VEHICLE v ON sess.license_plate = v.license_plate
        WHERE sess.session_id = %s AND v.owner_id = %s AND sess.end_time IS NULL
    """
    session_data = execute_query(check_query, (session_id, user_id))

    if not session_data:
        return jsonify({"error": "Active session not found or unauthorized."}), 404

    target = session_data[0]

    # End Session & Free Spot
    execute_query("UPDATE PARKING_SESSION SET end_time = CURRENT_TIME WHERE session_id = %s", 
                  (session_id,), fetch=False)
    
    execute_query("UPDATE PARKING_SPOT SET status = 'available' WHERE lot_id = %s AND spot_id = %s", 
                  (target['lot_id'], target['spot_id']), fetch=False)

    return jsonify({"success": True}), 200

@app.route('/api/lots/suggest', methods=['GET'])
def suggest_lots():
    query = request.args.get('q', '')
    if len(query) < 2:
        return jsonify([])

    lots = execute_query("""
        SELECT lot_id, lot_name FROM PARKING_LOT 
        WHERE lot_name ILIKE %s ORDER BY lot_name LIMIT 5
    """, (f'%{query}%',))
    
    return jsonify(lots), 200

@app.route('/api/admin/dashboard-stats', methods=['GET'])
@admin_required
def get_dashboard_stats():
    try:
        # 1. Get Active Sessions
        # execute_query returns a list, so we grab the first item [0]
        active_res = execute_query("SELECT COUNT(*) as count FROM v_active_sessions")
        active_count = active_res[0]['count'] if active_res else 0
        
        # 2. Get Infrastructure Summary
        summary_res = execute_query("""
            SELECT 
                COUNT(DISTINCT lot_id) as total_lots,
                SUM(total_spots) as total_spots,
                AVG(pct_full) as avg_occupancy
            FROM v_occupancy_summary
        """)
        
        # Use .get() to avoid errors if the database is empty (None values)
        row = summary_res[0] if summary_res else {}

        stats = [
            { "label": "Active Sessions", "value": active_count, "icon": "🚗" },
            { "label": "Managed Lots", "value": row.get('total_lots', 0), "icon": "🏢" },
            { "label": "Total Spots", "value": row.get('total_spots', 0), "icon": "🅿️" },
            { "label": "Campus Occupancy", "value": f"{round(row.get('avg_occupancy') or 0)}%", "icon": "📊" }
        ]
        
        return jsonify(stats), 200

    except Exception as e:
        print(f"Error in dashboard-stats: {e}")
        return jsonify({"error": str(e)}), 500
    
@app.route('/api/admin/inventory', methods=['GET'])
@admin_required
def get_admin_inventory():
    try:
        # Use your existing view! 
        # We group by lot to get the 'Structure' info (levels/total spots)
        query = """
            SELECT 
                lot_id,
                lot_name,
                MAX(level_number) as levels, 
                SUM(total_spots) as total_spots,
                SUM(occupied) as occupied
            FROM v_occupancy_summary
            GROUP BY lot_id, lot_name
        """
        results = execute_query(query)
        
        # Add a simple 'type' logic if it's not in your view yet
        for lot in results:
            lot['type'] = 'Garage' if lot['levels'] > 1 else 'Surface'
            
        return jsonify(results), 200
    except Exception as e:
        print(f"Inventory Error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/admin/create-lot-infrastructure', methods=['POST'])
@admin_required
def create_lot_infrastructure():
    data = request.json
    lot_name = data.get('name')
    # Using your 'lot_name' column name from PARKING_LOT
    level_configs = data.get('level_configs') 

    if not lot_name or not level_configs:
        return jsonify({"error": "Missing required fields"}), 400

    conn = get_db_connection()
    cur = conn.cursor()

    try:
        # 1. Insert the Lot (Using your PARKING_LOT table)
        # Note: 'prefix' isn't in your schema, so we'll use it for logic but not DB storage
        # unless you add it to PARKING_LOT. 
        cur.execute(
            "INSERT INTO PARKING_LOT (lot_name) VALUES (%s) RETURNING lot_id",
            (lot_name,)
        )
        lot_id = cur.fetchone()['lot_id']

        for config in level_configs:
            # 2. Validation
            total = config['total_spots']
            hc_count = config.get('hc_count', 0)
            moto_count = config.get('moto_count', 0)

            if (hc_count + moto_count) > total:
                raise ValueError(f"Level {config['level_number']} specialty spots exceed capacity.")

            # 3. Insert the Level (Using your "LEVEL" table)
            # Note: "LEVEL" is a reserved word, so we quote it.
            cur.execute(
                """
                INSERT INTO "LEVEL" (lot_id, level_number, allowed_permit_type) 
                VALUES (%s, %s, %s) RETURNING level_id
                """,
                (lot_id, config['level_number'], config['permit_type'])
            )
            level_id = cur.fetchone()['level_id']

            # 4. Generate Spots (Using your PARKING_SPOT table)
            for i in range(1, total + 1):
                # Determine Spot Type (standard, handicap, motorcycle)
                if i <= hc_count:
                    s_type = 'handicap'
                elif i <= (hc_count + moto_count):
                    s_type = 'motorcycle'
                else:
                    s_type = 'standard'

                # Spot number logic
                # Using the prefix from the form to build a string for ps.spot_number
                prefix = data.get('prefix', 'LOT')
                formatted_spot_num = f"{prefix}{config['level_number']}-{i}"

                cur.execute(
                    """
                    INSERT INTO PARKING_SPOT (lot_id, level_id, spot_number, spot_type, "status") 
                    VALUES (%s, %s, %s, %s, 'available')
                    """,
                    (lot_id, level_id, formatted_spot_num, s_type)
                )

        conn.commit()
        return jsonify({"message": f"Successfully generated {lot_name} infrastructure."}), 201

    except Exception as e:
        conn.rollback()
        print(f"Transaction Error: {e}")
        return jsonify({"error": str(e)}), 500

    finally:
        cur.close()
        conn.close()

    
@app.route('/api/admin/active-sessions', methods=['GET'])
@admin_required
def get_active_sessions():
    try:
        # Pulling from your view which already joins USERS, VEHICLES, and LOTS
        query = """
            SELECT 
                v.session_id,
                v.owner_name,
                s.fsuid, 
                v.permit_type,
                v.license_plate,
                v.make,
                v.model,
                v.lot_name,
                v.level_number,
                v.spot_number,
                TO_CHAR(v.start_time, 'HH12:MI AM') as start_time_fmt
            FROM v_active_sessions v
            LEFT JOIN students s ON v.owner_id = s.user_id
            ORDER BY v.start_time DESC
        """
        sessions = execute_query(query)
        return jsonify(sessions), 200
    except Exception as e:
        print(e)
        return jsonify({"error": str(e)}), 500

@app.route('/api/admin/infrastructure', methods=['GET'])
@admin_required
def get_all_infrastructure():
    conn = get_db_connection() 
    cursor = conn.cursor()
    
    try:
        query = """
            SELECT 
                pl.lot_id, 
                pl.lot_name, 
                (SELECT COUNT(*) FROM "LEVEL" l WHERE l.lot_id = pl.lot_id) as levels
            FROM PARKING_LOT pl;
        """
        cursor.execute(query)
        rows = cursor.fetchall()
        
        lots = []
        for row in rows:
            lots.append({
                "lot_id": row['lot_id'],
                "lot_name": row['lot_name'],
                "levels": row['levels']
            })
            
        return jsonify(lots), 200
    except Exception as e:
        print(f"Database Error: {e}")
        return jsonify({"message": "Error fetching infrastructure"}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/admin/infrastructure/<int:lot_id>', methods=['GET'])
@admin_required
def get_infra_details(lot_id):
    # Get level details
    levels_query = """
        SELECT L.*, P.lot_name
        FROM "LEVEL" L 
        JOIN PARKING_LOT P ON L.lot_id = P.lot_id 
        WHERE L.lot_id = %s 
        ORDER BY level_number
    """
    levels = execute_query(levels_query, (lot_id,))
    # Get spot breakdown
    spots_query = """
        SELECT spot_type, status, COUNT(*) as count 
        FROM PARKING_SPOT 
        WHERE lot_id = %s 
        GROUP BY spot_type, status
    """
    spots = execute_query(spots_query, (lot_id,))
    return jsonify({"levels": levels, "spots": spots})

@app.route('/api/admin/level/<int:lot_id>/<int:level_id>', methods=['PATCH'])
@admin_required
def update_level_permit(lot_id, level_id):
    new_permit = request.json.get('permit_type')
    query = '''
        SELECT COUNT(*) as count 
        FROM PARKING_SESSION ps
        JOIN PARKING_SPOT spot ON ps.lot_id = spot.lot_id AND ps.spot_id = spot.spot_id
        WHERE spot.level_id = %s 
        AND ps.end_time IS NULL
    '''

    result = execute_query(query, (level_id,))
    active_count = result[0]['count'] if result else 0

    if active_count > 0:
        return jsonify({
            "error": "Level Occupied",
            "message": f"Cannot change permit type. There are {active_count} active sessions on this level. Close out session(s) first."
        }), 400
    
    execute_query(
        'UPDATE "LEVEL" SET allowed_permit_type = %s WHERE lot_id = %s AND level_id = %s',
        (new_permit, lot_id, level_id),
        fetch=False
    )
    return jsonify({"message": "Permit updated"})

@app.route('/api/admin/infrastructure/<int:lot_id>', methods=['DELETE'])
@admin_required
def delete_infra(lot_id):
    active = execute_query('''
        SELECT COUNT(*) as count FROM PARKING_SESSION 
        WHERE lot_id = %s AND end_time IS NULL
    ''', (lot_id,))
    
    if active[0]['count'] > 0:
        return jsonify({
            "error": "Occupied", 
            "message": f"Lot has {active[0]['count']} active users. Close out session(s) first."
        }), 400
        
    execute_query('DELETE FROM PARKING_LOT WHERE lot_id = %s', (lot_id,))
    return jsonify({"success": True})

# --- Individual Action ---
@app.route('/api/admin/sessions/close/<int:session_id>', methods=['POST'])
@admin_required
def close_session(session_id):
    # Standard manual checkout
    execute_query('''
        UPDATE PARKING_SESSION SET end_time = CURRENT_TIMESTAMP 
        WHERE session_id = %s AND end_time IS NULL
    ''', (session_id,), fetch=False)
    return jsonify({"success": True})


@app.route('/api/lots/predict', methods=['POST'])
def predict_lots():
    data = request.json
    permit_type = data.get('permit_type')
    day_of_week = data.get('day_of_week')
    arrival_time = data.get('arrival_time')

    if not permit_type or not day_of_week or not arrival_time:
        return jsonify({"error": "permit_type, day_of_week, and arrival_time are required"}), 400

    try:
        day_of_week = int(day_of_week)

        if day_of_week in [0, 6]:
            day_type = 'weekend'
        else:
            day_type = 'weekday'
        hour_of_day = int(arrival_time.split(':')[0])

        query = """
            WITH prediction_base AS (
                SELECT
                    lpo.lot_id,
                    lpo.lot_name,
                    CASE
                        WHEN s.lot_id IS NOT NULL THEN 'surface'
                        ELSE 'garage'
                    END AS lot_type,
                    lpo.level_id,
                    lpo.level_number,
                    lc.total_spots,
                    COALESCE(hh.historical_sessions, 0) AS historical_occupied,
                    COALESCE(co.current_occupied, 0) AS current_occupied,
                    LEAST(
                        lc.total_spots,
                        GREATEST(
                            COALESCE(hh.historical_sessions, 0),
                            COALESCE(co.current_occupied, 0)
                        )
                    ) AS predicted_occupied
                FROM v_prediction_legal_options lpo
                JOIN v_prediction_level_capacity lc
                    ON lpo.lot_id = lc.lot_id
                AND lpo.level_id = lc.level_id
                LEFT JOIN v_prediction_hourly_history hh
                    ON lpo.lot_id = hh.lot_id
                AND lpo.level_id = hh.level_id
                AND hh.day_of_week = %s
                AND hh.hour_of_day = %s
                LEFT JOIN v_prediction_current_occupancy co
                    ON lpo.lot_id = co.lot_id
                    AND lpo.level_id = co.level_id
                LEFT JOIN SURFACE_LOT s
                    ON lpo.lot_id = s.lot_id
                WHERE lpo.permit_type = %s
                    AND lpo.day_type IN (%s, 'any')
                    AND %s >= lpo.start_time
                    AND %s < lpo.end_time
            )
            SELECT
                lot_id,
                lot_name,
                lot_type,
                level_id,
                level_number,
                total_spots,
                historical_occupied,
                current_occupied,
                predicted_occupied,
                total_spots - predicted_occupied AS predicted_available,
                ROUND(
                    predicted_occupied * 100.0 / NULLIF(total_spots, 0),
                    1
                ) AS predicted_percent_full,
                CASE
                    WHEN ROUND(predicted_occupied * 100.0 / NULLIF(total_spots, 0), 1) < 40
                        THEN 'Low congestion'
                    WHEN ROUND(predicted_occupied * 100.0 / NULLIF(total_spots, 0), 1) < 75
                        THEN 'Moderate congestion'
                    ELSE 'High congestion'
                END AS congestion_label,
                ROW_NUMBER() OVER (
                    ORDER BY
                        ROUND(predicted_occupied * 100.0 / NULLIF(total_spots, 0), 1) ASC,
                        (total_spots - predicted_occupied) DESC
                ) AS recommendation_rank
            FROM prediction_base
            ORDER BY recommendation_rank;
        """

        results = execute_query(
            query,
            (day_of_week, hour_of_day, permit_type, day_type, arrival_time, arrival_time)
        )

        cleaned_results = []
        for row in results:
            row['predicted_percent_full'] = float(row['predicted_percent_full']) if row['predicted_percent_full'] is not None else 0.0
            cleaned_results.append(row)

        return jsonify(cleaned_results), 200

    except Exception as e:
        print(f"[ERROR] Prediction Failed: {e}", flush=True)
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Bind to 0.0.0.0 and specify port 5000 for Docker
    app.run(host='0.0.0.0', port=5000, debug=True)