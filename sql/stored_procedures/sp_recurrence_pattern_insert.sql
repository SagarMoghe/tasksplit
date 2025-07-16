DELIMITER //

CREATE PROCEDURE tasksplit.sp_insert_recurrence_pattern(
    IN p_frequency ENUM('daily', 'weekly', 'monthly', 'yearly'),
    IN p_interval_value INT UNSIGNED,
    IN p_days_of_week SET('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'),
    IN p_day_of_month INT,
    IN p_month_of_year INT,
    IN p_end_date DATE,
    IN p_max_occurrences INT UNSIGNED,
    OUT p_pattern_id BIGINT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_pattern_id = 0;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Failed to insert recurrence pattern';
    END;

    START TRANSACTION;

    -- Validate inputs based on frequency
    CASE p_frequency
        WHEN 'daily' THEN
            -- For daily, we don't need days_of_week, day_of_month, or month_of_year
            SET p_days_of_week = NULL;
            SET p_day_of_month = NULL;
            SET p_month_of_year = NULL;
        WHEN 'weekly' THEN
            -- For weekly, we need days_of_week but not day_of_month or month_of_year
            SET p_day_of_month = NULL;
            SET p_month_of_year = NULL;
            IF p_days_of_week IS NULL THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Days of week required for weekly frequency';
            END IF;
        WHEN 'monthly' THEN
            -- For monthly, we need day_of_month but not days_of_week or month_of_year
            SET p_days_of_week = NULL;
            SET p_month_of_year = NULL;
            IF p_day_of_month IS NULL OR p_day_of_month < 1 OR p_day_of_month > 31 THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Valid day of month (1-31) required for monthly frequency';
            END IF;
        WHEN 'yearly' THEN
            -- For yearly, we need both day_of_month and month_of_year
            SET p_days_of_week = NULL;
            IF p_day_of_month IS NULL OR p_day_of_month < 1 OR p_day_of_month > 31 THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Valid day of month (1-31) required for yearly frequency';
            END IF;
            IF p_month_of_year IS NULL OR p_month_of_year < 1 OR p_month_of_year > 12 THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Valid month of year (1-12) required for yearly frequency';
            END IF;
    END CASE;

    -- Validate interval value
    IF p_interval_value < 1 THEN
        SET p_interval_value = 1;
    END IF;

    INSERT INTO tasksplit.recurrence_patterns (
        frequency,
        interval_value,
        days_of_week,
        day_of_month,
        month_of_year,
        end_date,
        max_occurrences
    ) VALUES (
        p_frequency,
        p_interval_value,
        p_days_of_week,
        p_day_of_month,
        p_month_of_year,
        p_end_date,
        p_max_occurrences
    );

    SET p_pattern_id = LAST_INSERT_ID();

    COMMIT;
END //

DELIMITER ;
