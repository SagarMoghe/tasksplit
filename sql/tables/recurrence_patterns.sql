CREATE TABLE IF NOT EXISTS tasksplit.recurrence_patterns (
                                     pattern_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                     frequency ENUM('daily', 'weekly', 'monthly', 'yearly') NOT NULL,
                                     interval_value INT UNSIGNED NOT NULL DEFAULT 1,  -- e.g., every 2 weeks
                                     days_of_week SET('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'),
                                     day_of_month INT,  -- 1-31
                                     month_of_year INT,  -- 1-12
                                     end_date DATE,
                                     max_occurrences INT UNSIGNED,
                                     created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

                                     CHECK (day_of_month BETWEEN 1 AND 31),
                                     CHECK (month_of_year BETWEEN 1 AND 12)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
