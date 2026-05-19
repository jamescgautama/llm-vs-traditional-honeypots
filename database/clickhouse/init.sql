CREATE DATABASE IF NOT EXISTS logs;

CREATE USER IF NOT EXISTS default_user IDENTIFIED WITH plaintext_password BY 'default_password';
GRANT SELECT, INSERT ON logs.* TO default_user;

CREATE TABLE IF NOT EXISTS logs.cowrie (
    timestamp DateTime64(3),
    eventid String,
    src_ip String,
    username String,
    password String,
    input String,
    session String,
    level String DEFAULT 'info',
    message String DEFAULT ''
) ENGINE = MergeTree()
ORDER BY (timestamp, eventid);

CREATE TABLE logs.beelzebub (
    DateTime DateTime64(3),
    ID String,
    SourceIp String,
    User String,
    Password String,
    Command String,
    CommandOutput String,
    Protocol String,
    Description String,
    level String,
    msg String
)
ENGINE = MergeTree()
ORDER BY (DateTime, ID);
