DELIMITER //

CREATE PROCEDURE tasksplit.sp_insert_new_group(
    IN p_name VARCHAR(100),
    IN p_description TEXT,
    IN p_created_by_user_id BIGINT UNSIGNED,
    OUT p_group_id BIGINT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_group_id = -1;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Failed to insert new group';
    END;

    START TRANSACTION;

    -- Verify that the created_by_user_id exists
    IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = p_created_by_user_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Created by user does not exist';
    END IF;

    INSERT INTO `groups` (
        name,
        description,
        created_by_user_id
    ) VALUES (
        p_name,
        p_description,
        p_created_by_user_id
    );

    SET p_group_id = LAST_INSERT_ID();

    COMMIT;
END //

DELIMITER ;
