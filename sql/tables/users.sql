CREATE TABLE IF NOT EXISTS tasksplit.users (
                                               user_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                               first_name VARCHAR(50) NOT NULL,
                                               last_name VARCHAR(50) NOT NULL,
                                               email VARCHAR(255) NOT NULL UNIQUE,
                                               password_hash CHAR(60) NOT NULL,  -- For bcrypt hashes
                                               status ENUM('active', 'inactive', 'deleted') DEFAULT 'active',
                                               created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                               updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                               last_login_at TIMESTAMP NULL,
                                               email_verified_at TIMESTAMP NULL,
                                               phone VARCHAR(20),
                                               profile_picture_url VARCHAR(255),

    -- Indexes for better query performance
                                               INDEX idx_email (email),
                                               INDEX idx_status (status),
                                               INDEX idx_names (first_name, last_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;