CREATE TABLE IF NOT EXISTS tasksplit.tasks (
                       task_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                       title VARCHAR(255) NOT NULL,
                       description TEXT,
                       category_id BIGINT UNSIGNED,
                       assigned_by BIGINT UNSIGNED NOT NULL,
                       assigned_to BIGINT UNSIGNED NOT NULL,
                       priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
                       status ENUM('pending', 'in_progress', 'completed', 'cancelled', 'overdue') DEFAULT 'pending',
                       start_date TIMESTAMP NOT NULL,
                       due_date TIMESTAMP NOT NULL,
                       completed_at TIMESTAMP NULL,
                       estimated_duration INT,  -- in minutes
                       recurrence_pattern_id BIGINT UNSIGNED,
                       parent_task_id BIGINT UNSIGNED,  -- For recurring task instances
                       created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                       FOREIGN KEY (category_id) REFERENCES task_categories(category_id),
                       FOREIGN KEY (assigned_by) REFERENCES users(user_id),
                       FOREIGN KEY (assigned_to) REFERENCES users(user_id),
                       FOREIGN KEY (recurrence_pattern_id) REFERENCES recurrence_patterns(pattern_id),
                       FOREIGN KEY (parent_task_id) REFERENCES tasks(task_id),

                       INDEX idx_assigned_to_status (assigned_to, status),
                       INDEX idx_assigned_by (assigned_by),
                       INDEX idx_dates (start_date, due_date),
                       INDEX idx_parent_task (parent_task_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
