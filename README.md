# LLM vs Traditional Honeypots

This project compares a LLM-based honeypot (Beelzebub) with a traditional honeypot (Cowrie). Both honeypots send their logs to a centralized ClickHouse database for analysis and visualization via Grafana.

## Architecture

The project is designed to be deployed across three separate servers:

1.  **Database Server (`database/`):** Hosts ClickHouse and Grafana.
2.  **LLM Honeypot Server (`llmhoneypot/`):** Hosts Beelzebub (LLM honeypot) and Fluent Bit (log forwarder).
3.  **Traditional Honeypot Server (`tradhoneypot/`):** Hosts Cowrie (traditional honeypot) and Fluent Bit (log forwarder).

## Setup Instructions

### 1. Database Server

1.  Navigate to the `database/` directory.
2.  Configure the `.env` file with your desired credentials.
3.  Start the services:
    ```bash
    docker compose up -d
    ```
4.  Grafana will be available at `http://<DATABASE_SERVER_IP>:3000`.

### 2. LLM Honeypot Server

1.  Navigate to the `llmhoneypot/` directory.
2.  Configure the `.env` file:
    *   `CLICKHOUSE_HOST`: Set this to the public IP address of your Database Server.
    *   `CLICKHOUSE_USER` & `CLICKHOUSE_PASSWORD`: Match the credentials set on the Database Server.
3.  Start the services:
    ```bash
    docker compose up -d
    ```
4.  Beelzebub will be listening on port `22`.

### 3. Traditional Honeypot Server

1.  Navigate to the `tradhoneypot/` directory.
2.  Configure the `.env` file:
    *   `CLICKHOUSE_HOST`: Set this to the public IP address of your Database Server.
    *   `CLICKHOUSE_USER` & `CLICKHOUSE_PASSWORD`: Match the credentials set on the Database Server.
3.  Start the services:
    ```bash
    docker compose up -d
    ```
4.  Cowrie will be listening on port `22` (mapped from `2222` inside the container).

## Logging & Visualization

*   **Fluent Bit:** Both honeypot servers use Fluent Bit to tail log files or receive forward events and send them via HTTP to ClickHouse.
*   **ClickHouse:** Stores the logs in a structured format (see `database/clickhouse/init.sql`).
*   **Grafana:** Provisioned with a ClickHouse data source to visualize the attack data.

## Security (TLS)

Communication between the Honeypot Servers and the Database Server is encrypted using TLS (HTTPS) on port `8443`. 

*   A self-signed certificate is generated automatically in `database/clickhouse/certs/`.
*   Fluent Bit is configured with `tls On` and `tls.verify Off` to support the self-signed certificate.
*   ClickHouse is configured to listen on port `8443` for HTTPS.
