CREATE TABLE IF NOT EXISTS tasksplit.task_events (
                             event_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                             task_id BIGINT UNSIGNED NOT NULL,
                             user_id BIGINT UNSIGNED NOT NULL,
                             event_type ENUM(
        'created',
        'updated',
        'status_changed',
        'reassigned',
        'commented',
        'attachment_added',
        'reminder_sent',
        'recurrence_modified'
    ) NOT NULL,
                             old_value JSON,
                             new_value JSON,
                             comment TEXT,
                             created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

                             FOREIGN KEY (task_id) REFERENCES tasks(task_id),
                             FOREIGN KEY (user_id) REFERENCES users(user_id),

                             INDEX idx_task_created (task_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
