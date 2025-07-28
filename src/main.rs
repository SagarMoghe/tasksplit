mod user_model;

use crate::user_model::{User, UserWithConn};
use dotenv::dotenv;
use mysql::prelude::*;
use mysql::*;
use std::env;
use std::{thread, time::Duration}; // For sync sleep
use tokio;

#[derive(Debug)]
struct DbConfig {
    host: String,
    user: String,
    password: String,
    database: String,
    port: u16,
}

fn load_env() -> Result<(), Box<dyn std::error::Error>> {
    // Try to load from .env file, return error if a file exists but can't be parsed
    match dotenv() {
        Ok(_) => println!("Loaded environment from .env file"),
        Err(e) => match e {
            dotenv::Error::Io(io_err) if io_err.kind() == std::io::ErrorKind::NotFound => {
                println!("No .env file found, using environment variables");
            }
            _ => return Err(Box::new(e)),
        },
    }

    Ok(())
}

impl DbConfig {
    fn from_env() -> Result<Self, Box<dyn std::error::Error>> {
        load_env().expect("TODO: panic message");

        Ok(DbConfig {
            host: env::var("DB_HOST").map_err(|_| "DB_HOST environment variable is required")?,
            user: env::var("DB_USER").map_err(|_| "DB_USER environment variable is required")?,
            password: env::var("DB_PASSWORD")
                .map_err(|_| "DB_PASSWORD environment variable is required")?,
            database: env::var("DB_NAME")
                .map_err(|_| "DB_NAME environment variable is required")?,
            port: env::var("DB_PORT")
                .map_err(|_| "DB_PORT environment variable is required")?
                .parse::<u16>()
                .map_err(|_| "DB_PORT must be a valid port number")?,
        })
    }

    fn to_opts(&self) -> OptsBuilder {
        OptsBuilder::new()
            .ip_or_hostname(Some(&self.host))
            .user(Some(&self.user))
            .pass(Some(&self.password))
            .db_name(Some(&self.database))
            .tcp_port(self.port)
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Load and validate database configuration
    let config = DbConfig::from_env()?;

    // Create a connection pool
    let pool = Pool::new(config.to_opts())?;

    // Get a connection from the pool
    let mut conn = pool.get_conn()?;

    let user_id = test_user_model().expect("TODO: panic message");

    match conn
        .query_first::<User, _>(format!("SELECT * FROM users WHERE user_id = {user_id}").as_str())?
    {
        Some(user) => {
            println!("user details: {:#?}", user);
        }
        None => {
            println!("No user found with ID: {}", user_id);
        }
    }

    Ok(())
}

fn test_user_model() -> Result<u64, Box<dyn std::error::Error>> {
    // Load and validate database configuration
    let config = DbConfig::from_env()?;

    // Create a connection pool
    let pool = Pool::new(config.to_opts())?;

    // Get a connection from the pool
    let conn = pool.get_conn()?;

    let mut user_id: u64 = 0;

    // Create a new user
    let user = User::new(
        "John".to_string(),
        "Smith".to_string(),
        "Jonathan.smith@example.com".to_string(),
        "existing_hash2".to_string(),
        Some("1234567890".to_string()),
        None,
    );

    // Create UserWithConn instance
    let mut user_with_conn = UserWithConn {
        user,
        pooled_conn: conn,
    };

    // Insert the user and get the ID
    match user_with_conn.insert_new_user() {
        Ok(id) => {
            user_id = id;
            println!("User inserted successfully with ID: {}", &id);
            Ok(id)
        }
        Err(e) => {
            println!("Failed to insert user: {}", e);
            Err(e)
        }
    }
    .expect("Failed to insert user");

    println!("Going to sleep for 5 seconds...");
    thread::sleep(Duration::from_secs(5));
    println!("Woke up!");

    println!("Modified user details: {:#?}", user_with_conn.user);
    user_with_conn.user.first_name = "Jonathan".to_string();
    user_with_conn.user.phone = Some("9876543210".to_string());
    println!("Modified user details: {:#?}", user_with_conn.user);

    // Update in database
    match user_with_conn.update() {
        Ok(_) => {
            println!("User updated successfully!");
            Ok(user_id)
        }
        Err(e) => {
            println!("Failed to update user: {}", e);
            Err(Box::new(e))
        }
    }
}
