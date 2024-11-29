from flask import Flask, request, jsonify
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
@app.route('/accounts/person/<int:card_id>', methods=['GET'])
def get_account_by_person(card_id):
    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT * FROM LibraryAccount
            WHERE CardID = %s
        """, (card_id,))
        
        account = cursor.fetchone()
        cursor.close()
        connection.close()

        if not account:
            return jsonify({"message": f"No account found for CardID {card_id}"}), 404

        return jsonify(account), 200
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500
    

@app.route('/accounts', methods=['POST'])
def create_account():
    data = request.get_json()

    name = data.get('Name')

    if not name:
        return jsonify({"error": "Missing required fields"}), 400

    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor()

    try:        
        cursor.execute("""
            INSERT INTO LibraryAccount (Name, NumChecked, NumReserved, OverdueFees)
            VALUES (%s, 0, 0, 0)
        """, (name,))
        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({
            "message": "Account created successfully",
            "CardID": cursor.lastrowid
        }), 201
    
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500
    

@app.route('/accounts/person/<int:card_id>', methods=['PUT'])
def update_account_by_person(card_id):
    data = request.get_json()

    card_id = data.get('CardID')
    name = data.get('Name')
    fees = data.get('OverdueFees')

    if not card_id or not name:
        return jsonify({"error": "Missing required fields"}), 400
    
    if not fees:
        if fees != 0:
            return jsonify({"error": "Missing required fields"}), 400

    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor()

    try:
        cursor.execute("""
            SELECT Name FROM LibraryAccount
            WHERE CardID = %s
        """, (card_id,))

        account = cursor.fetchone()

        if not account:
            return jsonify({"message": f"No account found for CardID {card_id}"}), 404
        
        cursor.execute("""
            UPDATE LibraryAccount
            SET Name = %s, OverdueFees = %s
            WHERE CardID = %s
        """, (name, fees, card_id))
        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({
            "message": "Account updated successfully",
            "CardID": card_id
        }), 200
    
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500
    

@app.route('/accounts/person/<int:card_id>', methods=['DELETE'])
def delete_account_by_person(card_id):
    data = request.get_json()

    card_id = data.get('CardID')

    if not card_id:
        return jsonify({"error": "Missing required fields"}), 400

    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor()

    try:
        cursor.execute("""
            SELECT * FROM LibraryAccount
            WHERE CardID = %s
        """, (card_id,))

        account = cursor.fetchone()

        if not account:
            return jsonify({"message": f"No account found for CardID {card_id}"}), 404
        if account[2] != 0:
            return jsonify({"message": f"CardID {card_id} still has items checked out, please return items before deleting the account"}), 403
        if account[3] != 0:
            return jsonify({"message": f"CardID {card_id} still has items reserved, please cancel reservations before deleting the account"}), 403
        if account[4] != 0:
            return jsonify({"message": f"CardID {card_id} still has outstanding overdue fees, please pay all fees before deleting the account"}), 403
        
        cursor.execute("""
            DELETE FROM LibraryAccount
            WHERE CardID = %s
        """, (card_id,))
        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({
            "message": "Account deleted successfully",
            "CardID": card_id
        }), 200
    
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500


# endpoints for Reviews
@app.route('/reviews/person/<int:card_id>', methods=['GET'])
def get_reviews_by_person(card_id):
    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT * FROM Reviews
            WHERE CardID = %s
        """, (card_id,))
        
        reviews = cursor.fetchall()
        cursor.close()
        connection.close()

        if not reviews:
            return jsonify({"message": f"No reviews found for CardID {card_id}"}), 404

        return jsonify(reviews), 200
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500
    

@app.route('/reviews', methods=['POST'])
def add_review():
    data = request.get_json()

    card_id = data.get('CardID')
    item_id = data.get('ItemID')
    comments = data.get('Comments')
    rating = data.get('Rating')

    if not card_id or not item_id or not comments or not rating:
        return jsonify({"error": "Missing required fields"}), 400

    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor()

    try:
        cursor.execute("""
            SELECT ReviewID FROM Reviews
            WHERE CardID = %s AND ItemID = %s
        """, (card_id, item_id))

        reviews = cursor.fetchone()

        if reviews:
            return jsonify({"message": f"CardID {card_id} has already written a review for ItemID {item_id}, please navigate to the update review page"}), 403
        
        cursor.execute("""
            INSERT INTO Reviews (CardID, ItemID, Comments, Rating)
            VALUES (%s, %s, %s, %s)
        """, (card_id, item_id, comments, rating))
        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({
            "message": "Review added successfully",
            "ReviewID": cursor.lastrowid
        }), 201
    
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500
    

@app.route('/reviews/person/<int:card_id>', methods=['PUT'])
def update_review_by_person(card_id):
    data = request.get_json()

    card_id = data.get('CardID')
    item_id = data.get('ItemID')
    comments = data.get('Comments')
    rating = data.get('Rating')

    if not card_id or not item_id or not comments or not rating:
        return jsonify({"error": "Missing required fields"}), 400

    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor()

    try:
        cursor.execute("""
            SELECT ReviewID FROM Reviews
            WHERE CardID = %s AND ItemID = %s
        """, (card_id, item_id))

        reviews = cursor.fetchone()

        if not reviews:
            return jsonify({"message": f"CardID {card_id} has not written a review for ItemID {item_id} yet, please navigate to the create review page"}), 403
        
        cursor.execute("""
            UPDATE Reviews
            SET Comments = %s, Rating = %s
            WHERE CardID = %s AND ItemID = %s
        """, (comments, rating, card_id, item_id))
        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({
            "message": "Review updated successfully",
            "ReviewID": reviews[0]
        }), 200
    
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500
    

@app.route('/reviews/person/<int:card_id>', methods=['DELETE'])
def delete_review_by_person(card_id):
    data = request.get_json()

    card_id = data.get('CardID')
    item_id = data.get('ItemID')

    if not card_id or not item_id:
        return jsonify({"error": "Missing required fields"}), 400

    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor()

    try:
        cursor.execute("""
            SELECT ReviewID FROM Reviews
            WHERE CardID = %s AND ItemID = %s
        """, (card_id, item_id))

        reviews = cursor.fetchone()

        if not reviews:
            return jsonify({"message": f"No review found for ItemID {item_id} by CardID {card_id}"}), 404
        
        cursor.execute("""
            DELETE FROM Reviews
            WHERE CardID = %s AND ItemID = %s
        """, (card_id, item_id))
        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({
            "message": "Review deleted successfully",
            "ReviewID": reviews[0]
        }), 200
    
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500


# enpoints for ReserveLibraryItem
# GET: select all reservations from a person
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

# POST: insert a new reservation into the table
# use this to test my post request in command line
# Invoke-WebRequest -Uri "http://127.0.0.1:5000/reservations" -Method Post -Headers @{"Content-Type"="application/json"} -Body '{"ItemID": 30, "CardID": 7}'
@app.route('/reservations', methods=['POST'])
def add_reservation():
    data = request.get_json()
    item_id = data.get('ItemID')
    card_id = data.get('CardID')

    if not item_id or not card_id:
        return jsonify({"error": "Missing required fields"}), 400

    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor()

    try:
        # Insert the new reservation into the database
        cursor.execute("""
            SELECT ReservationCount FROM LibraryItemState
            WHERE ItemID = %s
        """, (item_id,))

        place_in_line = cursor.fetchone()[0] + 1

        cursor.execute("""
            INSERT INTO ReserveLibraryItem (ItemID, CardID, PlaceInLine)
            VALUES (%s, %s, %s)
        """, (item_id, card_id, place_in_line))

        cursor.execute("""
            UPDATE LibraryItemState
            SET ReservationCount = %s
            WHERE ItemID = %s
        """, (place_in_line, item_id))

        cursor.execute("""
            UPDATE LibraryAccount
            SET NumReserved = NumReserved + 1
            WHERE CardID = %s
        """, (card_id,))

        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({
            "message": "Reservation added successfully",
            "ReservationID": cursor.lastrowid
        }), 201
    
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500

# PUT: change the number in line a person's reservation is
@app.route('/reservations/<int:reservation_id>', methods=['PUT'])
def update_reservation(reservation_id):
    data = request.json
    item_id = data.get('ItemID')
    card_id = data.get('CardID')
    place_in_line = data.get('PlaceInLine')

    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    try:
        cursor = connection.cursor()
        update_query = """
        UPDATE ReserveLibraryItem
        SET ItemID = %s, CardID = %s, PlaceInLine = %s
        WHERE ReservationID = %s
        """
        cursor.execute(update_query, (item_id, card_id, place_in_line, reservation_id))
        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({"message": "Reservation updated successfully"}), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    
# DELETE: delete a reservation based on a person (use if a user deletes their library account)
@app.route('/reservations/person/<int:card_id>', methods=['DELETE'])
def delete_reservation(card_id):
    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500
    try:
        cursor = connection.cursor()
        delete_query = "DELETE FROM ReserveLibraryItem WHERE CardID = %s"
        cursor.execute(delete_query, (card_id,))
        connection.commit()
        if cursor.rowcount > 0:
            cursor.close()
            connection.close()
            return jsonify({"message": "Reservations deleted successfully"}), 200
        else:
            cursor.close()
            connection.close()
            return jsonify({"message": "Account not found"}), 404
    except Error as e:
        return jsonify({"error": str(e)}), 500


# Run the app
if __name__ == '__main__':
    app.run(debug=True)
