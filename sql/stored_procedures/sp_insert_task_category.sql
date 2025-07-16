DELIMITER //

CREATE PROCEDURE tasksplit.sp_insert_task_category(
    IN p_name VARCHAR(100),
    IN p_description TEXT,
    IN p_color VARCHAR(7),
    IN p_icon VARCHAR(50),
    OUT p_category_id BIGINT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_category_id = 0;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Failed to insert task category';
    END;

    START TRANSACTION;

    -- Validate that name is not empty
    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Category name cannot be empty';
    END IF;

    -- Validate color format if provided (should be hex color like '#RRGGBB')
    IF p_color IS NOT NULL AND p_color NOT REGEXP '^#[0-9A-Fa-f]{6}$' THEN
        -- If invalid format, use default gray color
        SET p_color = '#808080';
    END IF;

    -- Check if category with the same name already exists
    IF EXISTS (SELECT 1 FROM tasksplit.task_categories WHERE name = p_name) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Category with this name already exists';
    END IF;

    INSERT INTO tasksplit.task_categories (
        name,
        description,
        color,
        icon
    ) VALUES (
        TRIM(p_name),
        p_description,
        COALESCE(p_color, '#808080'),  -- Use default gray if color is NULL
        p_icon
    );

    SET p_category_id = LAST_INSERT_ID();

    COMMIT;
END //

DELIMITER ;
