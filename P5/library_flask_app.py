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

@app.route('/checkout/person/<int:card_id>', methods=['GET'])
def get_checked_out_items_by_person(card_id):
    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT * FROM CheckOutLibraryItem
            WHERE CardID = %s
        """, (card_id,))
        
        items = cursor.fetchall()
        cursor.close()
        connection.close()

        if not items:
            return jsonify({"message": f"No checked-out items found for CardID {card_id}"}), 404

        return jsonify(items), 200
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500


@app.route('/checkout', methods=['POST'])
def checkout_item():
    data = request.get_json()

    card_id = data.get('CardID')
    item_id = data.get('ItemID')
    borrow_date = data.get('BorrowDate')
    return_by_date = data.get('ReturnByDate')

    if not card_id or not item_id or not borrow_date or not return_by_date:
        return jsonify({"error": "Missing required fields"}), 400

    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor()

    try:
        cursor.execute("""
            SELECT CopiesAvailable FROM LibraryItemState
            WHERE ItemID = %s
        """, (item_id,))
        item_state = cursor.fetchone()

        if not item_state or item_state[0] <= 0:
            return jsonify({"message": "Item is not available for checkout"}), 403

        cursor.execute("""
            INSERT INTO CheckOutLibraryItem (ItemID, CardID, BorrowDate, ReturnByDate)
            VALUES (%s, %s, %s, %s)
        """, (item_id, card_id, borrow_date, return_by_date))

        cursor.execute("""
            UPDATE LibraryItemState
            SET CopiesAvailable = CopiesAvailable - 1
            WHERE ItemID = %s
        """, (item_id,))

        cursor.execute("""
            UPDATE LibraryAccount
            SET NumChecked = NumChecked + 1
            WHERE CardID = %s
        """, (card_id,))

        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({"message": "Item checked out successfully"}), 201
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500


@app.route('/checkout/<int:checkout_id>', methods=['DELETE'])
def return_checked_out_item(checkout_id):
    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor()

    try:

        cursor.execute("""
            SELECT ItemID, CardID FROM CheckOutLibraryItem
            WHERE CheckoutID = %s
        """, (checkout_id,))
        checkout = cursor.fetchone()

        if not checkout:
            return jsonify({"message": "Checkout record not found"}), 404

        item_id, card_id = checkout

        cursor.execute("""
            DELETE FROM CheckOutLibraryItem
            WHERE CheckoutID = %s
        """, (checkout_id,))

        cursor.execute("""
            UPDATE LibraryItemState
            SET CopiesAvailable = CopiesAvailable + 1
            WHERE ItemID = %s
        """, (item_id,))

        cursor.execute("""
            UPDATE LibraryAccount
            SET NumChecked = NumChecked - 1
            WHERE CardID = %s
        """, (card_id,))

        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({"message": "Item returned successfully"}), 200
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500



# endpoints for Books

@app.route('/books/<int:item_id>', methods=['GET'])
def get_book_by_id(item_id):
    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT * FROM Books
            WHERE ItemID = %s
        """, (item_id,))
        
        book = cursor.fetchone()
        cursor.close()
        connection.close()

        if not book:
            return jsonify({"message": f"No book found with ItemID {item_id}"}), 404

        return jsonify(book), 200
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500


@app.route('/books', methods=['POST'])
def add_book():
    data = request.get_json()

    item_id = data.get('ItemID')
    language = data.get('Language')
    genre = data.get('Genre')
    title = data.get('Title')
    publication_year = data.get('PublicationYear')
    num_copies = data.get('NumCopies')
    book_type = data.get('BookType')
    publisher_id = data.get('PublisherID')

    if not item_id or not language or not genre or not title or not publication_year or not num_copies or not book_type or not publisher_id:
        return jsonify({"error": "Missing required fields"}), 400

    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor()

    try:
        cursor.execute("""
            INSERT INTO LibraryItem (ItemID, ItemType)
            VALUES (%s, 'Book')
        """, (item_id,))

        cursor.execute("""
            INSERT INTO Books (ItemID, Language, Genre, Title, PublicationYear, NumCopies, BookType, PublisherID)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (item_id, language, genre, title, publication_year, num_copies, book_type, publisher_id))

        cursor.execute("""
            INSERT INTO LibraryItemState (ItemID, CopiesAvailable, ReservationCount)
            VALUES (%s, %s, 0)
        """, (item_id, num_copies))

        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({"message": "Book added successfully", "ItemID": item_id}), 201
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500


@app.route('/books/<int:item_id>', methods=['PUT'])
def update_book(item_id):
    data = request.get_json()

    language = data.get('Language')
    genre = data.get('Genre')
    title = data.get('Title')
    publication_year = data.get('PublicationYear')
    num_copies = data.get('NumCopies')
    book_type = data.get('BookType')
    publisher_id = data.get('PublisherID')

    if not language or not genre or not title or not publication_year or not num_copies or not book_type or not publisher_id:
        return jsonify({"error": "Missing required fields"}), 400

    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor()

    try:
        cursor.execute("""
            UPDATE Books
            SET Language = %s, Genre = %s, Title = %s, PublicationYear = %s, NumCopies = %s, BookType = %s, PublisherID = %s
            WHERE ItemID = %s
        """, (language, genre, title, publication_year, num_copies, book_type, publisher_id, item_id))

        cursor.execute("""
            UPDATE LibraryItemState
            SET CopiesAvailable = %s
            WHERE ItemID = %s
        """, (num_copies, item_id))

        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({"message": "Book updated successfully", "ItemID": item_id}), 200
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500


@app.route('/books/<int:item_id>', methods=['DELETE'])
def delete_book(item_id):
    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor()

    try:
        cursor.execute("""
            SELECT * FROM Books
            WHERE ItemID = %s
        """, (item_id,))
        book = cursor.fetchone()

        if not book:
            return jsonify({"message": f"No book found with ItemID {item_id}"}), 404

        cursor.execute("""
            DELETE FROM LibraryItemState
            WHERE ItemID = %s
        """, (item_id,))

        cursor.execute("""
            DELETE FROM Books
            WHERE ItemID = %s
        """, (item_id,))

        cursor.execute("""
            DELETE FROM LibraryItem
            WHERE ItemID = %s
        """, (item_id,))

        connection.commit()
        cursor.close()
        connection.close()

        return jsonify({"message": "Book deleted successfully", "ItemID": item_id}), 200
    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500


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

    if not item_id or not card_id or not place_in_line:
        return jsonify({"error": "Missing required fields"}), 400

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
    
# DELETE: delete a reservation based on a person
@app.route('/reservations/person/<int:card_id>', methods=['DELETE'])
def delete_reservation(card_id):
    data = request.json
    reservation_id = data.get('ReservationID')
    card_id = data.get('CardID')

    if not reservation_id or not card_id:
        return jsonify({"error": "Missing required fields"}), 400

    connection = create_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500
    try:
        cursor = connection.cursor()
        cursor.execute("""
            SELECT * FROM ReserveLibraryItem
            WHERE ReservationID = %s
        """, (reservation_id,))

        reservation = cursor.fetchone()

        if not reservation:
            return jsonify({"message": f"No reservation found for ReservationID {reservation_id}"}), 404
        if reservation[2] != card_id:
            return jsonify({"message": f"Reservation {reservation_id} was not authored by CardID {card_id}, you cannot delete this reservation"}), 403
        
        delete_query = "DELETE FROM ReserveLibraryItem WHERE ReservationID = %s"
        cursor.execute(delete_query, (reservation_id,))
        cursor.execute("""
            UPDATE LibraryAccount
            SET NumReserved = NumReserved - 1
            WHERE CardID = %s
        """, (card_id,))
        cursor.execute("""
            UPDATE ReserveLibraryItem
            SET PlaceInLine = PlaceInLine - 1
            WHERE ItemID = %s AND PlaceInLine > %s
        """, (reservation[1], reservation[3]))
        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({"message": "Reservation deleted successfully"}), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500


# Run the app
if __name__ == '__main__':
    app.run(debug=True)
