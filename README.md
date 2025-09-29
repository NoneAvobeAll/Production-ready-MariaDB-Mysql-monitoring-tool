# Production-Ready MariaDB/MySQL Monitoring Tool

## Overview
This tool is designed to monitor MariaDB/MySQL databases, providing insights into performance, resource usage, and potential issues. It generates detailed reports in JSON and HTML formats and supports alerting via Slack and Telegram. Additionally, it includes an SSH tunneling system for secure remote database access.

---

## Features
- **Database Metrics Collection**:
  - Global status metrics (e.g., temp tables, disk usage).
  - Top memory-consuming threads.
  - Long-running queries.
  - InnoDB buffer pool statistics.
  - Transaction locks and waits.

- **Report Generation**:
  - JSON and professional-grade HTML reports.

- **Alerting System**:
  - Slack notifications.
  - Telegram bot integration.

- **Secure Access**:
  - SSH tunneling for remote database access.

---

## Requirements
- **Software**:
  - Bash
  - MariaDB/MySQL client
  - jq
  - curl
  - SSH client

- **Environment**:
  - Linux-based system

---

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/NoneAvobeAll/Production-ready-MariaDB-Mysql-monitoring-tool.git
   cd Production-ready-MariaDB-Mysql-monitoring-tool
   ```

2. Set up the configuration:
   - Edit `config.sh` to set your database credentials, thresholds, and alerting configurations.

3. Ensure the required directories exist:
   ```bash
   mkdir -p /var/log/db_monitor /var/www/html/db_monitor_reports
   ```

4. Install dependencies:
   ```bash
   sudo apt-get install mysql-client jq curl ssh
   ```

---

## Usage
1. Run the monitoring script:
   ```bash
   ./db_monitor.sh
   ```

2. View the generated reports:
   - JSON: `/var/log/db_monitor/`
   - HTML: `/var/www/html/db_monitor_reports/`

3. Enable SSH tunneling (if required):
   - Set `ENABLE_SSH_TUNNEL=true` in `config.sh`.

---

## Configuration
Edit the `config.sh` file to customize the following:
- **Database Credentials**:
  - `MYSQL_USER`, `MYSQL_PASS`, `MYSQL_HOST`, `MYSQL_PORT`
- **Thresholds**:
  - `TMP_DISK_THRESHOLD`, `LONG_QUERY_THRESHOLD`, `HIGH_MEMORY_THRESHOLD_MB`
- **Alerting**:
  - Slack: `ENABLE_SLACK`, `SLACK_WEBHOOK_URL`
  - Telegram: `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`
- **SSH Tunneling**:
  - `ENABLE_SSH_TUNNEL`, `SSH_USER`, `SSH_HOST`, `LOCAL_PORT`

---

## Author
**Abubakkar**  
System Administrator

---

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## Contributing
Contributions are welcome! Feel free to fork the repository and submit a pull request.

---

## Support
For issues or questions, please open an issue in the [GitHub repository](https://github.com/NoneAvobeAll/Production-ready-MariaDB-Mysql-monitoring-tool/issues).