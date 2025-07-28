DELIMITER //

CREATE PROCEDURE tasksplit.sp_insert_new_user(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_email VARCHAR(255),
    IN p_password_hash CHAR(60),
    IN p_phone VARCHAR(20),
    IN p_profile_picture_url VARCHAR(255),
    OUT p_user_id BIGINT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SET p_user_id = 0; -- Indicate error
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Failed to insert new user';
        END;

    START TRANSACTION;

    INSERT INTO users (
        first_name,
        last_name,
        email,
        password_hash,
        phone,
        profile_picture_url,
        created_at
    ) VALUES (
                 p_first_name,
                 p_last_name,
                 p_email,
                 p_password_hash,
                 p_phone,
                 p_profile_picture_url,
                 NOW()
             );

    SET p_user_id = LAST_INSERT_ID();

    COMMIT;
END //

DELIMITER ;
