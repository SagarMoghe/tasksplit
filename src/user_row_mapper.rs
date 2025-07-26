use mysql::Row;
use mysql::prelude::FromRow;

impl FromRow for User {
    fn from_row(row: Row) -> Self {
        User {
            user_id: row.get("user_id").unwrap(),
            first_name: row.get("first_name").unwrap(),
            last_name: row.get("last_name").unwrap(),
            email: row.get("email").unwrap(),
            password_hash: row.get("password_hash").unwrap(),
            status: row.get::<String, _>("status")
                .map(|s| match s.as_str() {
                    "active" => UserStatus::Active,
                    "inactive" => UserStatus::Inactive,
                    "deleted" => UserStatus::Deleted,
                    _ => UserStatus::default(),
                })
                .unwrap(),
            created_at: row.get("created_at").unwrap(),
            updated_at: row.get("updated_at").unwrap(),
            last_login_at: row.get("last_login_at"),
            email_verified_at: row.get("email_verified_at"),
            phone: row.get("phone"),
            profile_picture_url: row.get("profile_picture_url"),
        }
    }
}
