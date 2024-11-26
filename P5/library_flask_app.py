from flask import Flask, render_template, request, redirect, url_for, jsonify
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv
import os

# Create the Flask app
app = Flask(__name__)

load_dotenv()
# connect to the database
def create_connection():
    try:
        connection = mysql.connector.connect(
            host="127.0.0.1",
            user="root",
            password=os.getenv('DB_PASSWORD'),
            database="Library",
        )
        if connection.is_connected():
            print("Connected to the database")
        return connection
    except Error as e:
        print(f"Error: {e}")
        return None

# DEFINE API ENDPOINTS

# endpoints for CheckoutLibraryItem



# endpoints for Books



# enpoints for LibraryAccounts



# endpoints for Reviews



# enpoints for ReserveLibraryItem
@app.route('/reservations/person/<int:card_id>', methods=['GET'])
def get_reservations_by_person(card_id):
    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        # Select reservations for a specific person (CardID)
        cursor.execute("""
            SELECT * FROM ReserveLibraryItem
            WHERE CardID = %s
        """, (card_id,))
        
        reservations = cursor.fetchall()
        cursor.close()
        connection.close()

        if not reservations:
            return jsonify({"message": f"No reservations found for CardID {card_id}"}), 404

        return jsonify(reservations), 200
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500

# use this to test my post request in command line
# Invoke-WebRequest -Uri "http://127.0.0.1:5000/reservations" -Method Post -Headers @{"Content-Type"="application/json"} -Body '{"ItemID": 30, "CardID": 7, "PlaceInLine": 3}'
@app.route('/reservations', methods=['POST'])
def add_reservation():
    data = request.get_json()

    # Ensure required fields are provided
    item_id = data.get('ItemID')
    card_id = data.get('CardID')
    place_in_line = data.get('PlaceInLine')

    if not item_id or not card_id or not place_in_line:
        return jsonify({"error": "Missing required fields"}), 400

    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor()

    try:
        # Insert the new reservation into the database
        insert_query = """
            INSERT INTO ReserveLibraryItem (ItemID, CardID, PlaceInLine)
            VALUES (%s, %s, %s)
        """
        cursor.execute(insert_query, (item_id, card_id, place_in_line))
        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({
            "message": "Reservation added successfully",
            "ReservationID": cursor.lastrowid
        }), 201
    
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500


# Run the app
if __name__ == '__main__':
    app.run(debug=True)
