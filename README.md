# LLM vs Traditional Honeypots

An infrastructure framework and comparative study analyzing a Generative AI-powered honeypot (Beelzebub) against a traditional emulation honeypot (Cowrie). Both configurations ship attack records to a centralized ClickHouse OLAP database for visualization in Grafana.

## Features

- **Honeypot Comparison**: Runs both Beelzebub (LLM SSH emulation) and Cowrie (scripted shell emulation) side-by-side.
- **Secure Log Pipeline**: Integrates Fluent Bit agents that tail logs on honeypot nodes and forward them securely via TLS (HTTPS/8443) to ClickHouse.
- **Aggregated Analytics**: clickhouse database schemas designed specifically for high-throughput log recording and query processing.
- **Dashboard Provisioning**: Includes custom Grafana boards configured to query session dynamics and attack signatures directly from ClickHouse.

## Architecture Overview

This project is deployed across three separate servers to replicate a real-world edge deployment:

```text
[ LLM Honeypot Node (Beelzebub) ]
  - SSH Server (Port 22)
  - Fluent Bit (Log Agent) ---------\
                                      \
                                       v  TLS Encrypted (Port 8443)
                                  [ Database Server ]
                                    - ClickHouse OLAP DB
                                    - Grafana (Port 3000)
                                       ^
                                       /  TLS Encrypted (Port 8443)
                                      /
[ Traditional Honeypot Node (Cowrie) ]
  - SSH Server (Port 22 / 2222)
  - Fluent Bit (Log Agent) ---------/
```

## Tech Stack

- **Honeypots**: Go (Beelzebub), Python/Twisted (Cowrie)
- **Log Pipeline**: Fluent Bit
- **Data Warehousing**: ClickHouse
- **Analytics Visualization**: Grafana
- **Deployment**: Docker, Docker Compose

## Setup

### 1. Database Server
1. Navigate to `./database/`.
2. Configure credentials in the `.env` file.
3. Start the containers:
   ```bash
   docker compose up -d
   ```
   Grafana will start on `http://<DATABASE_SERVER_IP>:3000` and ClickHouse will listen on `8443` (TLS) and `9000` (native client).

### 2. LLM Honeypot Server
1. Navigate to `./llmhoneypot/`.
2. Edit `.env` to point `CLICKHOUSE_HOST` to the public IP of your Database Server and match your credentials.
3. Start Beelzebub and Fluent Bit:
   ```bash
   docker compose up -d
   ```
   Beelzebub emulates an SSH server on port `22`.

### 3. Traditional Honeypot Server
1. Navigate to `./tradhoneypot/`.
2. Edit `.env` to configure your clickhouse target host.
3. Start Cowrie and Fluent Bit:
   ```bash
   docker compose up -d
   ```
   Cowrie listens on port `22` (redirected internally to `2222`).

## Comparative Findings

### Key Research Metrics

- **Attacker Engagement**: The LLM-powered honeypot (Beelzebub) logged **6.5x more commands** and double the average session depth (4.36 vs 1.12) compared to the traditional honeypot (Cowrie).
- **Retention**: Beelzebub recorded higher per-attacker retention, keeping malicious actors interactive for longer periods due to its open-ended shell responses.
- **Latency Tradeoff**: LLM inference added substantial delay (averaging up to 3500ms), while the traditional honeypot responded instantly.
- **Optimal Emulation Model**: **ChatGPT 4o-mini** provided the most cost-effective and low-latency balance for shell simulation.

## Lessons Learned

- **Model Placement**: Running local open-source LLMs (such as LLaMA) on the honeypot node requires heavy VPS resources. Cloud APIs are far more practical.
- **Latency Impacts Bots**: Low response times are often more critical than high-fidelity shell behavior for automated botnets, which execute scripts and disconnect if timing thresholds are exceeded.
- **Fluent Bit Pipeline**: Centralized logging directly into ClickHouse is stable, but reliance on Fluent-Bit SQLite buffers can introduce project risks if plugins undergo breaking updates.
- **Prompt Engineering**: Crafting strict system prompts is necessary to stop the LLM from hallucinating commands that do not exist or exposing its virtualized identity.
