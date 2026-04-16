import os
from flask import Flask, jsonify, request
from flask_cors import CORS
from psycopg import connect
from psycopg.rows import dict_row

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


@app.route('/api/users', methods=['GET'])
def get_users():
    users = execute_query("SELECT user_id, name, email FROM USERS;")
    return jsonify(users)

@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_profile(user_id):
    user = execute_query("SELECT * FROM v_user_profiles WHERE user_id = %s", (user_id,))
    return jsonify(user[0] if user else {})

if __name__ == '__main__':
    # Bind to 0.0.0.0 and specify port 5000 for Docker
    app.run(host='0.0.0.0', port=5000, debug=True)