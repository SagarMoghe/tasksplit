use mysql::prelude::*;
use mysql::{FromRowError, Row};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum UserStatus {
    Active,
    Inactive,
    Deleted,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub user_id: u64,
    pub first_name: String,
    pub last_name: String,
    pub email: String,
    #[serde(skip_serializing)]
    pub password_hash: String,
    pub status: UserStatus,
}

impl User {
    // pub fn new(
    //     first_name: String,
    //     last_name: String,
    //     email: String,
    //     password_hash: String,
    // ) -> Self {
    //     User {
    //         user_id: 0, // Will be set by database
    //         first_name,
    //         last_name,
    //         email,
    //         password_hash,
    //         status: UserStatus::Active,
    //     }
    // }

    pub fn full_name(&self) -> String {
        format!("{} {}", self.first_name, self.last_name)
    }

    pub fn is_active(&self) -> bool {
        matches!(self.status, UserStatus::Active)
    }

    // pub fn find_by_id(conn: &mut impl Queryable, id: u64) -> Result<Option<User>, MySqlError> {
    //     conn.query_first(
    //         format!("SELECT * FROM users WHERE user_id = {id}").as_str()
    //     )
    // }
    //
    // pub fn find_by_email(conn: &mut impl Queryable, email: &str) -> Result<Option<User>, MySqlError> {
    //     conn.query_first(
    //         format!("SELECT * FROM users WHERE email = {email} AND status = 'active'").as_str())
    // }

    // pub fn create(
    //     &self,
    //     conn: &mut impl Queryable
    // ) -> Result<User, MySqlError> {
    //     conn.exec_drop(
    //         "INSERT INTO users (first_name, last_name, email, password_hash, status)
    //          VALUES (?, ?, ?, ?, ?)",
    //         (
    //             &self.first_name,
    //             &self.last_name,
    //             &self.email,
    //             &self.password_hash,
    //             match self.status {
    //                 UserStatus::Active => "active",
    //                 UserStatus::Inactive => "inactive",
    //                 UserStatus::Deleted => "deleted",
    //             },
    //         )
    //     )?;
    //
    //     let user_id = conn.
    //     Self::find_by_id(conn, user_id)
    //         .and_then(|opt_user| opt_user.ok_or(MySqlError::UnknownError("Failed to retrieve created user".into())))
    // }

    // pub fn update(&self, conn: &mut impl Queryable) -> Result<(), MySqlError> {
    //     conn.exec_drop(
    //         "UPDATE users SET
    //             first_name = ?,
    //             last_name = ?,
    //             email = ?,
    //             status = ?
    //         WHERE user_id = ?",
    //         (
    //             &self.first_name,
    //             &self.last_name,
    //             &self.email,
    //             match self.status {
    //                 UserStatus::Active => "active",
    //                 UserStatus::Inactive => "inactive",
    //                 UserStatus::Deleted => "deleted",
    //             },
    //             self.user_id,
    //         )
    //     )
    // }
}

impl FromRow for User {
    fn from_row(row: Row) -> User {
        User {
            user_id: row.get("user_id").unwrap(),
            first_name: row.get("first_name").unwrap(),
            last_name: row.get("last_name").unwrap(),
            email: row.get("email").unwrap(),
            password_hash: row.get("password_hash").unwrap(),
            status: match row.get::<String, _>("status").unwrap().as_str() {
                "active" => UserStatus::Active,
                "inactive" => UserStatus::Inactive,
                "deleted" => UserStatus::Deleted,
                _ => UserStatus::Active,
            },
        }
    }

    fn from_row_opt(_row: Row) -> Result<Self, FromRowError>
    where
        Self: Sized
    {
        todo!()
    }
}