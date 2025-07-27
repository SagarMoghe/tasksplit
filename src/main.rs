mod user_model;
use dotenv::dotenv;
use std::env;
use mysql::*;
use mysql::prelude::*;
use tokio;
use crate::user_model::User;

#[derive(Debug)]
struct DbConfig {
    host: String,
    user: String,
    password: String,
    database: String,
    port: u16,
}

fn load_env() -> Result<(), Box<dyn std::error::Error>> {
    // Try to load from .env file, return error if file exists but can't be parsed
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
            host: env::var("DB_HOST")
                .map_err(|_| "DB_HOST environment variable is required")?,
            user: env::var("DB_USER")
                .map_err(|_| "DB_USER environment variable is required")?,
            password: env::var("DB_PASSWORD")
                .map_err(|_| "DB_PASSWORD environment variable is required")?,
            database: env::var("DB_NAME")
                .map_err(|_| "DB_NAME environment variable is required")?,
            port: env::var("DB_PORT")
                .map_err(|_| "DB_PORT environment variable is required")?
                .parse::<u16>()
                .map_err(|_| "DB_PORT must be a valid port number")?
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


    let user_id = 1; // example user_id
    match conn.query_first::<User, _>(
        format!("SELECT * FROM users WHERE user_id = {user_id}").as_str()
    )? {
        Some(user) => {
            println!("Found user: {} {}", user.first_name, user.last_name);
            println!("Full name: {}", user.full_name());
            println!("Email: {}", user.email);
            println!("Active: {}", user.is_active());
            println!("Password Hash: {}", user.password_hash);
            println!("created at: {:?}",user.created_at);
            println!("updated at: {:?}",user.updated_at);
            println!("last_login_at: {}", user.last_login_at.unwrap_or_default());
            println!("last_login_at: {}", user.email_verified_at.unwrap_or_default());
            println!("last_login_at: {}", user.phone.unwrap_or_default());
            println!("last_login_at: {}", user.profile_picture_url.unwrap_or_default());
        },
        None => {
            println!("No user found with ID: {}", user_id);
        }
    }
    Ok(())
}
