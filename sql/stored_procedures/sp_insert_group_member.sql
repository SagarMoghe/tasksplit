DELIMITER //

CREATE PROCEDURE tasksplit.sp_insert_group_member(
    IN p_group_id BIGINT UNSIGNED,
    IN p_user_id BIGINT UNSIGNED,
    IN p_role ENUM('admin', 'member'),
    OUT p_success BOOLEAN
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Failed to insert group member';
    END;

    START TRANSACTION;

    -- Verify that the group exists
    IF NOT EXISTS (SELECT 1 FROM tasksplit.groups WHERE id = p_group_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Group does not exist';
    END IF;

    -- Verify that the user exists
    IF NOT EXISTS (SELECT 1 FROM tasksplit.users WHERE user_id = p_user_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User does not exist';
    END IF;

    -- Check if the user is already a member of the group
    IF EXISTS (SELECT 1 FROM tasksplit.group_members 
               WHERE group_id = p_group_id AND user_id = p_user_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User is already a member of this group';
    END IF;

    INSERT INTO tasksplit.group_members (
        group_id,
        user_id,
        role
    ) VALUES (
        p_group_id,
        p_user_id,
        COALESCE(p_role, 'member')  -- If role is not specified, default to 'member'
    );

    SET p_success = TRUE;
    
    COMMIT;
END //

DELIMITER ;
