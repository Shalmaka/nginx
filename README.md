# NGINX (Docker Only)

This repository provides a secure, modular, and lightweight NGINX setup designed exclusively for Docker environments (no Kubernetes).  
It can operate as:

- A web server and reverse proxy  
- An HTTP egress proxy (CONNECT)  
- A TCP/UDP stream proxy  
- An SMTP proxy (via the NGINX `mail` module)  
- A load balancer for HTTP, TCP, and SMTP services  

The system is built to be **immutable**, **secure**, **modular**, and **easy to extend**, with configuration dynamically loaded from structured directories.

---

## 🔧 Features

- **Reverse proxy & web server** with HTTPS support  
- **HTTP egress proxy** using CONNECT  
- **TCP/UDP egress proxy** using the `stream` module  
- **SMTP egress proxy** using the `mail` module, supporting:
  - SMTP (25)
  - SMTPS (465)
  - Submission (587)
  - IP/network ACLs
  - Load balancing & failover
- **Fully modular configuration**, organized by purpose:
  - `ingress/http.d/*.conf`
  - `ingress/stream.d/*.conf`
  - `egress/http.d/*.conf`
  - `egress/stream.d/*.conf`
  - `egress/mail.d/*.conf`
- **Smart entrypoint** that validates and assembles the final configuration  
- **Optional dual-network architecture**:
  - `macvlan` for external exposure  
  - `bridge` for internal container communication  
- **Runs as non-root**  
- **Read-only filesystem**  
- **Hardened, production-grade NGINX configuration**  
- **Isolated, structured logging**

---

## 🧱 Modular Configuration Structure

The configuration is split into independent, purpose-specific directories:
```
/etc/nginx/conf-enabled/
├── ingress/
│   ├── http.d/
│   └── stream.d/
├── egress/
│   ├── http.d/
│   ├── stream.d/
│   └── mail.d/
└── core/
```

Each directory contains only the `.conf` files relevant to that traffic type.

The entrypoint ensures:

- required directories exist  
- at least one valid configuration is present  
- the final NGINX configuration is assembled without errors  

---

## 📡 Egress Capabilities

### HTTP (CONNECT)
A true forward proxy for outbound internet access, supporting:

- dynamic host/port selection  
- ACLs  
- domain restrictions  
- full auditing  

### STREAM (TCP/UDP)
Static forwarding for non-HTTP protocols such as:

- databases  
- message queues  
- binary protocols  
- DNS, syslog, SNMP, etc.  

Supports load balancing and failover.

### SMTP (MAIL)
A real SMTP proxy using the NGINX `mail` module:

- SMTP (25)  
- SMTPS (465)  
- Submission (587)  
- STARTTLS passthrough  
- IP/network ACLs  
- Load balancing  
- Failover  

Configurations are added as:

```
/etc/nginx/conf-enabled/egress/mail.d/mail-*.conf
```

---

## 🔐 Security

- Runs as **non-root**  
- **Read-only filesystem**  
- Minimal attack surface  
- No unnecessary modules  
- No shell access  
- Strict ACLs  
- No internal ports exposed  
- Immutable configuration at runtime  

---

## 🐳 Docker Usage

The container is designed for Docker environments with:

- an isolated internal network (`bridge`)  
- an optional external network (`macvlan`)  
- mounted volumes only for certificates and logs  

It can serve as:

- a reverse proxy  
- an egress gateway  
- a load balancer  
- an internal SMTP relay  
- a secure network gateway for containers  

---

## 📜 License

This project is open source and licensed under the  
<a href="LICENSE">MIT License</a>.
