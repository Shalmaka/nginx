# NGINX (Docker Only)

This repository provides a secure and lightweight NGINX setup that can be used as a web server, reverse proxy, forward proxy (for outbound internet access), stream (TCP/UDP) proxy, and SMTP proxy.

It is designed for Docker environments without Kubernetes and supports publishing services externally via a `macvlan` network, while communicating internally with backend containers through an isolated internal network.

## 🔧 Features

- **Web server and reverse proxy** with HTTPS support  
- **Forward proxy** capabilities for outbound internet access (requires additional configuration or modules)  
- **TCP/UDP stream proxy** for load balancing and forwarding non-HTTP protocols  
- **SMTP mail proxy** support
- **Dynamic environment-based configuration**  
- **Dual-network architecture:** macvlan (external) + isolated internal network  
- **Hardened, production-ready NGINX configuration**  
- **Runs as non-root user** for improved container security  
- **Isolated, audit-level logging**

<!-- ## 🧱 Project Structure

<pre>
.
├── Dockerfile               # Builds the secure NGINX container
├── entrypoint.sh            # Generates nginx.conf from template
├── nginx.conf.template      # Templated NGINX configuration
├── docker-compose.yml       # Compose setup with dual network
├── .env                     # Environment variables
├── create_macvlan.sh        # Script to create macvlan network
└── certs/                   # TLS certs mounted into the container
</pre> -->
<!-- 
## 🐳 How to Use (with Docker Compose)

This project includes a `docker-compose.yml` ready to be used in environments with dual network configuration:

- **`external`**: Exposed `macvlan` network for communication with the outside world
- **`internal`**: Isolated internal bridge network for communication between containers

To get started:

<pre>
1. Copy and edit the provided .env file with your environment settings
2. Ensure the external 'macvlan' and internal 'network' Docker networks exist
3. Run:
   docker compose up -d
</pre>

The Compose file already includes:

- A static IP configuration via `macvlan`
- An internal connection to upstream via a bridge network
- Strict security hardening (non-root, read-only FS, limited capabilities)
- Environment variable support via `.env`

> ✅ Use the `docker-compose.yml` in this repository as a base and adjust as needed.

### 💻 Creating the macvlan Network

Before starting the NGINX container, you need to create the `macvlan` network for the external IP exposure.

1. **Configure the `.env` file** with your environment settings (static IP, network, etc.).
2. **Run the `create_macvlan.sh` script** to create the network:

<pre>
./create_macvlan.sh
</pre>

This script will create a `macvlan` network using the `eth0` interface on your host system, with a specified subnet and gateway.

--- -->

<!-- ## ⚙️ Environment Variables

Defined in `.env`, used by Docker Compose.

| Variable              | Description                               |
|-----------------------|-------------------------------------------|
| `INTERFACE_NAME`      | The network interface (e.g., `eth0`) used for macvlan creation. |
| `VLAN_ID`             | The VLAN ID (e.g., `100`) used in the `macvlan` interface. |
| `STATIC_IP`           | Static IP assigned on macvlan             |
| `INTERFACE_HTTPS_PORT`| Port exposed inside container (usually 443) |
| `UPSTREAM_SERVER`     | Internal backend container name           |
| `UPSTREAM_PORT`       | Backend container port                    |
| `SERVER_NAME`         | Domain for server block                   |
| `CERT_FILENAME`       | Certificate file name (in `/www/certs`)   |
| `KEY_FILENAME`        | Private key file name (in `/www/certs`)   | -->

<!-- ## 📂 Example Directory Structure

<pre>
certs/
├── cert.pem
└── key.pem
</pre> -->

## 📜 License

This project is open source and licensed under the <a href="LICENSE">MIT License</a>.
