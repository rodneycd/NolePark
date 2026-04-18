import os
from flask import Flask, jsonify, request
from flask_cors import CORS
from psycopg import connect
from psycopg.rows import dict_row


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
    user = execute_query("SELECT * FROM v_user_profiles WHERE user_id = %s", (user_id,))
    return jsonify(user[0] if user else {})

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
if __name__ == '__main__':
    # Bind to 0.0.0.0 and specify port 5000 for Docker
    app.run(host='0.0.0.0', port=5000, debug=True)