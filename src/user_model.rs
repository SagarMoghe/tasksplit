use mysql::prelude::*;
use mysql::{FromRowError, MySqlError, Row};
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

impl User {
    pub fn new(
        first_name: String,
        last_name: String,
        email: String,
        password_hash: String,
        phone: Option<String>,
        profile_picture_url: Option<String>
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


    pub fn full_name(&self) -> String {
        format!("{} {}", self.first_name, self.last_name)
    }

    pub fn is_active(&self) -> bool {
        matches!(self.status, UserStatus::Active)
    }

    // pub fn find_by_id(conn: &mut impl Queryable, id: u64) -> mysql::Result<Option<User>> {
    //     conn.query_first(
    //         format!("SELECT * FROM users WHERE user_id = {id}").as_str()
    //     )
    // }
    //
    // pub fn find_by_email(conn: &mut impl Queryable, email: &str) -> Result<Option<User>, MySqlError> {
    //     conn.query_first(
    //         format!("SELECT * FROM users WHERE email = {email} AND status = 'active'").as_str())
    // }

    pub fn create(&mut self,
                  conn: &mut impl Queryable
    ) -> () {
        //Result<User, MySqlError>
        let user_id = Self::insert_new_user(&self, conn).expect("TODO: panic message");
        self.user_id = user_id;

    }

    fn insert_new_user(&self,
        conn: &mut impl Queryable,

    ) -> Result<u64, Box<dyn std::error::Error>> {
        // Execute the stored procedure
        conn.exec_drop(
            "CALL sp_insert_new_user(?, ?, ?, ?, ?, ?, @user_id)",
            (&self.first_name, &self.last_name, &self.email, &self.password_hash, &self.phone, &self.profile_picture_url)
        )?;

        // Retrieve the output parameter
        let user_id: Option<u64> = conn.query_first("SELECT @user_id")?;

        match user_id {
            Some(id) if id != u64::MAX => Ok(id),
            _ => Err("Failed to insert new user".into())
        }
    }


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

// impl FromRow for User {
//     fn from_row(row: Row) -> User {
//         User {
//             user_id: row.get("user_id").unwrap(),
//             first_name: row.get("first_name").unwrap(),
//             last_name: row.get("last_name").unwrap(),
//             email: row.get("email").unwrap(),
//             password_hash: row.get("password_hash").unwrap(),
//             status: match row.get::<String, _>("status").unwrap().as_str() {
//                 "active" => UserStatus::Active,
//                 "inactive" => UserStatus::Inactive,
//                 "deleted" => UserStatus::Deleted,
//                 _ => UserStatus::Active,
//             },
//         }
//     }

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
                last_login_at: row.get("last_login_at").unwrap(),
                email_verified_at: row.get("email_verified_at").unwrap(),
                phone: row.get("phone").unwrap(),
                profile_picture_url: row.get("profile_picture_url").unwrap(),
            }
        }

        fn from_row_opt(row: Row) -> Result<Self, FromRowError>
        where
            Self: Sized
        {
            todo!()
        }

}