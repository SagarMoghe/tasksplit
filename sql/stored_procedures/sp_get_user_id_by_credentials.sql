DELIMITER //

CREATE PROCEDURE get_user_id_by_credentials(
    IN p_email VARCHAR(255),
    IN p_password_hash CHAR(60),
    OUT p_user_id BIGINT UNSIGNED
)
BEGIN
    SELECT user_id INTO p_user_id
    FROM tasksplit.users
    WHERE email = p_email
      AND password_hash = p_password_hash
      AND status = 'active'
    LIMIT 1;

    -- Set to -1 if no _row was found
    IF p_user_id IS NULL THEN
        SET p_user_id = -1;
    END IF;

END //

DELIMITER ;