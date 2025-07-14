CREATE TABLE IF NOT EXISTS tasksplit.group_members (
                               group_id BIGINT UNSIGNED NOT NULL,
                               user_id BIGINT UNSIGNED NOT NULL,
                               role ENUM('admin', 'member') DEFAULT 'member',
                               joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

                               PRIMARY KEY (group_id, user_id),
                               FOREIGN KEY (group_id) REFERENCES tasksplit.groups(id) ON DELETE CASCADE,
                               FOREIGN KEY (user_id) REFERENCES tasksplit.users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
