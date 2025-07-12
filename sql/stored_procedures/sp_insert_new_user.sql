DELIMITER //

CREATE PROCEDURE tasksplit.insert_new_user(
    IN first_name VARCHAR(50),
    IN last_name VARCHAR(50),
    OUT p_user_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SET p_user_id = -1; -- Indicate error
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Failed to insert new user';
        END;

    START TRANSACTION;

    INSERT INTO users (
        first_name,
        last_name,
        created_at
    ) VALUES (
                 first_name,
                 last_name,
                 NOW()

             );

    SET p_user_id = LAST_INSERT_ID();

    COMMIT;
END //

DELIMITER ;