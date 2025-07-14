CREATE TABLE IF NOT EXISTS tasksplit.transaction_categories (
                                        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                        name VARCHAR(50) NOT NULL,
                                        description TEXT,
                                        icon VARCHAR(50),
                                        color VARCHAR(7)  -- Hex color code
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
