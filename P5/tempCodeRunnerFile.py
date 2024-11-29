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