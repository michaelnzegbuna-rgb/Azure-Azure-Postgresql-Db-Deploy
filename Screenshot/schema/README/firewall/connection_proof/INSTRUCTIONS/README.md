# Azure PostgreSQL Flexible Server Deployment and Management Report

## Project Introduction

This repository provides a comprehensive overview of the deployment, configuration, security hardening, and operational management of an Azure Database for PostgreSQL Flexible Server environment.

The implementation demonstrates the complete lifecycle of a cloud-hosted relational database solution, including server provisioning, network security configuration, database design, data manipulation, authentication controls, monitoring, scaling operations, backup management, and disaster recovery validation.

The project objectives were successfully achieved through the deployment of a managed PostgreSQL platform, implementation of secure connectivity options, development of a relational database schema, execution of data operations, integration with Microsoft Entra ID authentication, and validation of backup and recovery capabilities.

---

# Server Deployment Architecture

## Infrastructure Design Considerations

The PostgreSQL environment was designed with two primary objectives:

1. Maintain compatibility with Azure Free Tier resources.
2. Deliver sufficient functionality to support development and testing workloads.

### Resource Identification

| Component         | Configuration      |
| ----------------- | ------------------ |
| Server Name       | psql-lab-olamileye |
| Resource Group    | rg-postgres-lab    |
| Deployment Region | West Europe        |

The selected resource group serves as a centralized container for all database-related resources, simplifying administration and lifecycle management.

---

## Compute and Storage Configuration

The deployment utilizes Azure Database for PostgreSQL Flexible Server, which offers greater operational flexibility compared to alternative deployment models.

### Server Specifications

| Configuration Item | Value                            |
| ------------------ | -------------------------------- |
| Service Model      | Azure PostgreSQL Flexible Server |
| PostgreSQL Version | 16                               |
| Compute Tier       | Burstable B1ms                   |
| vCPUs              | 1                                |
| Memory             | 2 GiB                            |
| Storage Capacity   | 32 GiB                           |

The Flexible Server model was selected because it supports customizable maintenance windows, burstable performance profiles, and seamless virtual network integration.

Storage allocation was intentionally kept at the minimum Free Tier threshold to optimize resource consumption while satisfying project requirements.

---

## Availability and Administrative Access

### High Availability Configuration

High availability functionality was intentionally disabled because the deployment targets a non-production environment where cost efficiency takes precedence over redundancy.

### Administrative Account

A dedicated administrative account named **pgadmin** was created instead of relying on predictable default administrator names.

This approach reduces exposure to common brute-force attack patterns and aligns with security best practices.

---

# Security and Network Protection Strategy

## Multi-Layer Security Design

The database environment was configured using a defense-in-depth model. Security controls were implemented across both the network and identity layers to reduce reliance on any single protection mechanism.

---

## Public and Private Connectivity Options

### Restricted Public Access

For initial validation and testing activities, controlled public access was enabled using a firewall rule that permits connections exclusively from an approved developer workstation.

**Firewall Rule**

```text
AllowMyDevIP
```

This configuration prevents unauthorized internet-based access while allowing administrative testing.

---

### Private Network Integration

To further enhance security, private networking was implemented using Azure Virtual Network integration.

#### Networking Components

| Resource         | Configuration     |
| ---------------- | ----------------- |
| Virtual Network  | vnet-postgres-lab |
| Address Space    | 10.0.0.0/16       |
| Database Subnet  | snet-db           |
| Subnet Range     | 10.0.1.0/24       |
| Private Endpoint | pe-psql-lab       |

The private endpoint enables secure communication between internal resources and the PostgreSQL server without traversing the public internet.

---

### Private DNS Resolution

A private DNS zone was associated with the virtual network to ensure database hostname resolution remains internal to the Azure environment.

**Private DNS Zone**

```text
privatelink.postgres.database.azure.com
```

This configuration automatically resolves database requests to a private IP address rather than a publicly routable endpoint, significantly reducing exposure.

---

# Authentication and Data Encryption

## Secure Transport Enforcement

All database communications are encrypted using Transport Layer Security (TLS).

### Security Configuration

| Setting                   | Value   |
| ------------------------- | ------- |
| SSL Enabled               | Yes     |
| Secure Transport Required | Yes     |
| Minimum TLS Version       | TLS 1.2 |

Any connection attempt that does not meet the required encryption standards is automatically rejected.

---

## Microsoft Entra ID Authentication

In addition to traditional PostgreSQL username/password authentication, Microsoft Entra ID integration was enabled to provide modern identity-based access control.

### Authentication Methods

* Native PostgreSQL Authentication
* Microsoft Entra Authentication

The deployment account was configured as the Entra administrator for the server, enabling centralized identity management and token-based access.

---

## Validation of Token-Based Access

Authentication using Azure-issued access tokens was successfully verified through the Azure CLI and PostgreSQL client.

```bash
az login

token=$(az account get-access-token \
--resource https://ossrdbms-aad.database.windows.net \
--query accessToken -o tsv)

PGPASSWORD=$token psql \
-h psql-lab-olamileye.postgres.database.azure.com \
-U your-email@domain.com \
-d postgres \
--sslmode=require
```

The successful connection confirmed proper integration between Azure identity services and PostgreSQL authentication mechanisms.

---

# Database Design and Data Operations

## Relational Data Model

A structured relational schema was created to support a sample inventory and order management application.

The design consists of three interconnected entities:

* Categories
* Products
* Orders

Relationships were established using primary and foreign key constraints to ensure referential integrity across the database.

---

## Schema Validation Through CRUD Operations

The database design was validated by executing all core CRUD activities.

### Create Operations

Initial data was inserted into category tables, followed by related product records and corresponding order transactions.

### Read Operations

Queries were executed to retrieve product information, perform joins between tables, and verify that relationships were functioning correctly.

### Update Operations

Product pricing and inventory quantities were modified to confirm update functionality.

### Delete Operations

Selected product records were removed to verify deletion logic and ensure relational constraints behaved as expected.

The successful completion of these tests confirmed the integrity and reliability of the schema design.

---

# Resource Scaling and Performance Management

## Compute Resource Scaling

To evaluate elasticity, the server's compute resources were increased from the Burstable B1ms tier to B2ms under simulated workload conditions.

### Scaling Results

| Configuration | Before | After |
| ------------- | ------ | ----- |
| Compute Tier  | B1ms   | B2ms  |
| vCPUs         | 1      | 2     |

The scaling operation required approximately two minutes to complete and involved a brief service restart.

---

## Storage Expansion

Storage capacity was increased from 32 GiB to 64 GiB without requiring server downtime.

### Important Observation

Azure PostgreSQL storage can only be increased; reductions are not supported after expansion.

---

## Storage Auto-Growth

Automatic storage scaling was enabled to prevent capacity-related interruptions.

When utilization exceeds approximately 85%, Azure automatically allocates additional storage resources.

---

# Monitoring and Operational Visibility

## Azure Monitor Integration

Continuous monitoring was implemented using Azure Monitor Metrics.

The following performance indicators were tracked:

* CPU Utilization
* Memory Consumption
* Active Connections
* Network Throughput

This provides visibility into resource consumption and overall database health.

---

## Proactive Alerting

An automated alert rule was configured to notify administrators of sustained high CPU utilization.

### Alert Criteria

| Metric            | Threshold |
| ----------------- | --------- |
| CPU Usage         | Above 80% |
| Evaluation Window | 5 Minutes |

Email notifications are automatically generated when the condition is triggered.

---

## Query Performance Analysis

Query Performance Insight was utilized to identify inefficient SQL statements and evaluate execution performance.

This feature assists with workload optimization by highlighting resource-intensive queries and execution bottlenecks.

---

# Backup and Recovery Strategy

## Backup Configuration

Automated backups were enabled with a retention period of seven days, which represents the minimum retention period available within the Azure Free Tier.

### Backup Settings

| Configuration    | Value                           |
| ---------------- | ------------------------------- |
| Retention Period | 7 Days                          |
| Storage Type     | Locally Redundant Storage (LRS) |

---

## Point-in-Time Recovery Validation

The recovery process was tested by restoring the database to a new PostgreSQL Flexible Server instance.

### Recovery Target

```text
psql-lab-restored
```

The restored server was deployed in the same Azure region and successfully recovered all database objects and records.

This exercise confirmed that backup data could be used to recover services in the event of accidental data loss or operational failure.

---

# Evidence and Validation Screenshots

The screenshots included in this repository provide verification of the deployment activities and configuration steps performed throughout the project.

### Server Deployment Verification

Displays the operational status of the PostgreSQL server, including compute specifications, storage allocation, and connectivity details.

**Screenshot:** Server Overview

---

### Network Security Configuration

Demonstrates both firewall-based access control and private endpoint integration within the virtual network.

**Screenshot:** Firewall and Private Link Configuration

---

### Client Connectivity Validation

Confirms successful authentication and connectivity from a PostgreSQL client environment, with database objects visible and accessible.

**Screenshot:** PostgreSQL Client Connection

---

# Project Summary

This implementation successfully demonstrates the deployment and management of an Azure Database for PostgreSQL Flexible Server environment using cloud-native security, networking, monitoring, and recovery capabilities.

The project validates key database administration tasks including secure provisioning, private networking, identity integration, schema development, CRUD operations, resource scaling, monitoring, backup management, and disaster recovery testing. Together, these components provide a secure, resilient, and operationally manageable relational database platform within Microsoft Azure.
