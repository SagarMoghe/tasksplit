DELIMITER //

CREATE PROCEDURE tasksplit.sp_insert_task_attachment(
    IN p_task_id BIGINT UNSIGNED,
    IN p_uploaded_by BIGINT UNSIGNED,
    IN p_file_name VARCHAR(255),
    IN p_file_path VARCHAR(512),
    IN p_file_size BIGINT UNSIGNED,
    OUT p_attachment_id BIGINT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SET p_attachment_id = 0;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Failed to insert task attachment';
        END;

    START TRANSACTION;

    -- Verify that the task exists
    IF NOT EXISTS (SELECT 1 FROM tasksplit.tasks WHERE task_id = p_task_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task does not exist';
    END IF;

    -- Verify that the user exists
    IF NOT EXISTS (SELECT 1 FROM tasksplit.users WHERE user_id = p_uploaded_by) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User does not exist';
    END IF;

    -- Validate file size
    IF p_file_size = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'File size cannot be zero';
    END IF;

    -- Insert the attachment
    INSERT INTO tasksplit.task_attachments (
        task_id,
        uploaded_by,
        file_name,
        file_path,
        file_size
    ) VALUES (
                 p_task_id,
                 p_uploaded_by,
                 p_file_name,
                 p_file_path,
                 p_file_size
             );

    SET p_attachment_id = LAST_INSERT_ID();

    -- Also create a task event for the attachment
    INSERT INTO tasksplit.task_events (
        task_id,
        user_id,
        event_type,
        new_value
    ) VALUES (
                 p_task_id,
                 p_uploaded_by,
                 'attachment_added',
                 JSON_OBJECT(
                         'attachment_id', p_attachment_id,
                         'file_name', p_file_name
                 )
             );

    COMMIT;
END //

DELIMITER ;