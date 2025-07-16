CREATE TABLE IF NOT EXISTS tasksplit.task_attachments (
                                  attachment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                  task_id BIGINT UNSIGNED NOT NULL,
                                  uploaded_by BIGINT UNSIGNED NOT NULL,
                                  file_name VARCHAR(255) NOT NULL,
                                  file_path VARCHAR(512) NOT NULL,
                                  file_size BIGINT UNSIGNED NOT NULL,
                                  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

                                  FOREIGN KEY (task_id) REFERENCES tasks(task_id),
                                  FOREIGN KEY (uploaded_by) REFERENCES users(user_id),

                                  INDEX idx_task (task_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
