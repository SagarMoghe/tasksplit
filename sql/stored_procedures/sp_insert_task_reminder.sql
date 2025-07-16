DELIMITER //

CREATE PROCEDURE tasksplit.sp_insert_task_reminder(
    IN p_task_id BIGINT UNSIGNED,
    IN p_reminder_time TIMESTAMP,
    IN p_remind_before INT,
    OUT p_reminder_id BIGINT UNSIGNED
)
BEGIN
    DECLARE task_due_date TIMESTAMP;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SET p_reminder_id = 0;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Failed to insert task reminder';
        END;

    START TRANSACTION;

    -- Verify that the task exists and get its due date
    SELECT due_date INTO task_due_date
    FROM tasksplit.tasks
    WHERE task_id = p_task_id;

    IF task_due_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task does not exist or has no due date';
    END IF;

    -- Validate remind_before (minutes)
    IF p_remind_before <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Reminder time must be greater than 0 minutes';
    END IF;

    -- If reminder_time is not provided, calculate it from due_date and remind_before
    IF p_reminder_time IS NULL THEN
        SET p_reminder_time = DATE_SUB(task_due_date, INTERVAL p_remind_before MINUTE);
    END IF;

    -- Validate that reminder time is not in the past
    IF p_reminder_time <= NOW() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Reminder time cannot be in the past';
    END IF;

    -- Validate that reminder time is not after the task due date
    IF p_reminder_time > task_due_date THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Reminder time cannot be after the task due date';
    END IF;

    -- Insert the reminder
    INSERT INTO tasksplit.task_reminders (
        task_id,
        reminder_time,
        remind_before,
        status
    ) VALUES (
                 p_task_id,
                 p_reminder_time,
                 p_remind_before,
                 'pending'
             );

    SET p_reminder_id = LAST_INSERT_ID();

    -- Create a task event for the reminder creation
    INSERT INTO tasksplit.task_events (
        task_id,
        user_id,
        event_type,
        new_value
    ) VALUES (
                 p_task_id,
                 (SELECT assigned_by FROM tasksplit.tasks WHERE task_id = p_task_id), -- use task creator as the event user
                 'reminder_sent',
                 JSON_OBJECT(
                         'reminder_id', p_reminder_id,
                         'reminder_time', p_reminder_time,
                         'remind_before', p_remind_before
                 )
             );

    COMMIT;
END //

DELIMITER ;
