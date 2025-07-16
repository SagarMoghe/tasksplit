DELIMITER //

CREATE PROCEDURE tasksplit.sp_insert_task_comment(
    IN p_task_id BIGINT UNSIGNED,
    IN p_user_id BIGINT UNSIGNED,
    IN p_comment TEXT,
    OUT p_comment_id BIGINT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SET p_comment_id = 0;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Failed to insert task comment';
        END;

    START TRANSACTION;

    -- Verify that the task exists
    IF NOT EXISTS (SELECT 1 FROM tasksplit.tasks WHERE task_id = p_task_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task does not exist';
    END IF;

    -- Verify that the user exists
    IF NOT EXISTS (SELECT 1 FROM tasksplit.users WHERE user_id = p_user_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User does not exist';
    END IF;

    -- Validate comment text
    IF p_comment IS NULL OR TRIM(p_comment) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Comment text cannot be empty';
    END IF;

    -- Insert the comment
    INSERT INTO tasksplit.task_comments (
        task_id,
        user_id,
        comment
    ) VALUES (
                 p_task_id,
                 p_user_id,
                 TRIM(p_comment)
             );

    SET p_comment_id = LAST_INSERT_ID();

    -- Create a task event for the comment
    INSERT INTO tasksplit.task_events (
        task_id,
        user_id,
        event_type,
        comment,
        new_value
    ) VALUES (
                 p_task_id,
                 p_user_id,
                 'commented',
                 TRIM(p_comment),
                 JSON_OBJECT(
                         'comment_id', p_comment_id
                 )
             );

    COMMIT;
END //

DELIMITER ;