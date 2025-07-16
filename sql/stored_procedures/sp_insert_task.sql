DELIMITER //

CREATE PROCEDURE tasksplit.sp_insert_task(
    IN p_title VARCHAR(255),
    IN p_description TEXT,
    IN p_created_by BIGINT UNSIGNED,
    IN p_assigned_to BIGINT UNSIGNED,
    IN p_category_id BIGINT UNSIGNED,
    IN p_group_id BIGINT UNSIGNED,
    IN p_priority ENUM ('low', 'medium', 'high'),
    IN p_status ENUM ('pending', 'in_progress', 'completed', 'cancelled'),
    IN p_due_date TIMESTAMP,
    IN p_parent_task_id BIGINT UNSIGNED,
    OUT p_task_id BIGINT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SET p_task_id = 0;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Failed to insert task';
        END;

    START TRANSACTION;

    -- Validate required fields
    IF p_title IS NULL OR TRIM(p_title) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task title cannot be empty';
    END IF;

    -- Verify that the creator exists
    IF NOT EXISTS (SELECT 1 FROM tasksplit.users WHERE user_id = p_created_by) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Creator user does not exist';
    END IF;

    -- Verify assignee if provided
    IF p_assigned_to IS NOT NULL AND
       NOT EXISTS (SELECT 1 FROM tasksplit.users WHERE user_id = p_assigned_to) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Assigned user does not exist';
    END IF;

    -- Verify category if provided
    IF p_category_id IS NOT NULL AND
       NOT EXISTS (SELECT 1 FROM tasksplit.task_categories WHERE category_id = p_category_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task category does not exist';
    END IF;

    -- Verify group if provided
    IF p_group_id IS NOT NULL AND
       NOT EXISTS (SELECT 1 FROM tasksplit.groups WHERE group_id = p_group_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Group does not exist';
    END IF;

    -- Verify parent task if provided
    IF p_parent_task_id IS NOT NULL AND
       NOT EXISTS (SELECT 1 FROM tasksplit.tasks WHERE task_id = p_parent_task_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Parent task does not exist';
    END IF;

    -- Validate due date
    IF p_due_date IS NOT NULL AND p_due_date < CURRENT_TIMESTAMP THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Due date cannot be in the past';
    END IF;

    -- Insert the task
    INSERT INTO tasksplit.tasks (title,
                                 description,
                                 assigned_by,
                                 assigned_to,
                                 category_id,
                                 group_id,
                                 priority,
                                 status,
                                 start_date,
                                 due_date,
                                 parent_task_id)
    VALUES (TRIM(p_title),
            p_description,
            p_created_by,
            p_assigned_to,
            p_category_id,
            p_group_id,
            COALESCE(p_priority, 'medium'),
            COALESCE(p_status, 'pending'),
            NOW(),
            p_due_date,
            p_parent_task_id);

    SET p_task_id = LAST_INSERT_ID();

    -- Create a task creation event
    INSERT INTO tasksplit.task_events (task_id,
                                       user_id,
                                       event_type,
                                       new_value)
    VALUES (p_task_id,
            p_created_by,
            'created',
            JSON_OBJECT(
                    'title', p_title,
                    'assigned_to', p_assigned_to,
                    'category_id', p_category_id,
                    'priority', COALESCE(p_priority, 'medium'),
                    'status', COALESCE(p_status, 'pending'),
                    'due_date', p_due_date
            ));
    COMMIT;
END //

DELIMITER ;