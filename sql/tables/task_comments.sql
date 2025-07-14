CREATE TABLE IF NOT EXISTS tasksplit.task_comments (
                               comment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                               task_id BIGINT UNSIGNED NOT NULL,
                               user_id BIGINT UNSIGNED NOT NULL,
                               comment TEXT NOT NULL,
                               created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                               updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

                               FOREIGN KEY (task_id) REFERENCES tasks(task_id),
                               FOREIGN KEY (user_id) REFERENCES users(user_id),

                               INDEX idx_task_date (task_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
