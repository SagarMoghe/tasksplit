CREATE TABLE IF NOT EXISTS tasksplit.task_reminders (
                                reminder_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                task_id BIGINT UNSIGNED NOT NULL,
                                reminder_time TIMESTAMP NOT NULL,
                                remind_before INT NOT NULL, -- minutes before due date
                                status ENUM('pending', 'sent', 'failed') DEFAULT 'pending',
                                sent_at TIMESTAMP NULL,

                                FOREIGN KEY (task_id) REFERENCES tasks(task_id),

                                INDEX idx_reminder_time (reminder_time, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
