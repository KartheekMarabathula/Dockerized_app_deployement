CREATE DATABASE IF NOT EXISTS two_tier_db;
USE two_tier_db;

CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message TEXT
);

-- ADD THIS LINE:
GRANT ALL PRIVILEGES ON two_tier_db.* TO 'kartheek'@'%';
FLUSH PRIVILEGES;
