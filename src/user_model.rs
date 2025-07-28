use mysql::prelude::*;
use mysql::{FromRowError, PooledConn, Row};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum UserStatus {
    Active,
    Inactive,
    Deleted,
}

impl UserStatus {
    fn default() -> UserStatus {
        UserStatus::Active
    }
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
    pub created_at: Option<String>,
    pub updated_at: Option<String>,
    pub last_login_at: Option<String>,
    pub email_verified_at: Option<String>,
    pub phone: Option<String>,
    pub profile_picture_url: Option<String>,
}

pub struct UserWithConn {
    pub user: User,
    pub pooled_conn: PooledConn,
}

impl User {
    pub fn new(
        first_name: String,
        last_name: String,
        email: String,
        password_hash: String,
        phone: Option<String>,
        profile_picture_url: Option<String>,
    ) -> Self {
        User {
            user_id: 0, // Will be set by database
            first_name,
            last_name,
            email,
            password_hash,
            status: UserStatus::Active,
            created_at: None,
            updated_at: None,
            last_login_at: None,
            email_verified_at: None,
            phone,
            profile_picture_url,
        }
    }
}

impl UserWithConn {
    pub fn insert_new_user(&mut self) -> Result<u64, Box<dyn std::error::Error>> {
        // Execute the stored procedure
        self.pooled_conn.exec_drop(
            "CALL sp_insert_new_user(?, ?, ?, ?, ?, ?, @user_id)",
            (
                &self.user.first_name,
                &self.user.last_name,
                &self.user.email,
                &self.user.password_hash,
                &self.user.phone,
                &self.user.profile_picture_url,
            ),
        )?;

        // Retrieve the output parameter
        let user_id: Option<u64> = self.pooled_conn.query_first("SELECT @user_id")?;
        match user_id {
            Some(id) if id != u64::MAX => {
                self.user.user_id = id;
                Ok(id)
            }
            _ => Err("Failed to insert new user".into()),
        }
    }

    pub fn update(&mut self) -> mysql::Result<()> {
        self.pooled_conn.exec_drop(
            "UPDATE users SET
                first_name = ?,
                last_name = ?,
                email = ?,
                status = ?,
                phone = ?,
                profile_picture_url = ?
            WHERE user_id = ?",
            (
                &self.user.first_name,
                &self.user.last_name,
                &self.user.email,
                match self.user.status {
                    UserStatus::Active => "active",
                    UserStatus::Inactive => "inactive",
                    UserStatus::Deleted => "deleted",
                },
                &self.user.phone,
                &self.user.profile_picture_url,
                self.user.user_id,
            ),
        )
    }
}

impl FromRow for User {
    fn from_row(row: Row) -> Self {
        User {
            user_id: 0,
            first_name: "".to_string(),
            last_name: "".to_string(),
            email: "".to_string(),
            password_hash: "".to_string(),
            status: UserStatus::Active,
            created_at: None,
            updated_at: None,
            last_login_at: None,
            email_verified_at: None,
            phone: None,
            profile_picture_url: None,
        }
    }

    fn from_row_opt(row: Row) -> Result<Self, FromRowError>
    where
        Self: Sized,
    {
        todo!()
    }
}
