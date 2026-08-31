# abap-rap-procurement-managed

abap rap procurement managed app

# Enterprise Managed RAP 3-Tier Requisition System (ABAP Cloud)

# ABAP RAP Procurement Managed

An SAP ABAP RESTful Application Programming Model (RAP) implementation of a managed Purchase Requisition application with draft support.

## Overview

This repository contains a 3-tier hierarchical Purchase Requisition application built using the **ABAP RESTful Application Programming Model (RAP)** and designed for **SAP BTP ABAP Environment (ABAP Cloud / Steampunk)**.

The application demonstrates:

* Managed RAP business object implementation
* Draft-enabled transactional processing
* 3-tier hierarchical Purchase Requisition structure
* CDS-based data modeling
* RAP Behavior Definitions and Behavior Implementations
* OData V4 service exposure
* ABAP EML-based testing
* Test/master data generation

## Architecture

The application follows a typical RAP layered architecture:

```text
Database Tables
      │
      ▼
Basic CDS Views
      │
      ▼
Interface CDS Views
      │
      ▼
RAP Behavior Definition
      │
      ▼
Behavior Implementation
      │
      ▼
Projection CDS Views
      │
      ▼
Service Definition
      │
      ▼
OData V4 Service Binding
```

## Repository Structure

The repository uses an **ABAP package-based structure exported through abapGit**. The `src` directory contains the ABAP repository objects used by the application, including:

* Database tables for master, transactional, and draft persistence
* CDS data models and projection views
* RAP Behavior Definitions (BDEF)
* RAP Behavior Implementations / behavior pools
* Service Definitions
* OData V4 Service Bindings
* Utility classes for test data generation and EML-based testing

## RAP Business Object

The main business object represents a hierarchical Purchase Requisition:

```text
Purchase Requisition
        │
        ├── Items
        │     │
        │     └── Account Assignments
        │
        └── Draft-enabled transactional processing
```

The implementation demonstrates how a managed RAP business object can be modeled across persistence, CDS, behavior, and service layers.

## Technology Stack

* **SAP ABAP RESTful Application Programming Model (RAP)**
* **ABAP Cloud**
* **CDS (Core Data Services)**
* **RAP Behavior Definition Language**
* **ABAP EML (Entity Manipulation Language)**
* **OData V4**
* **abapGit**
* **Eclipse ADT**

## System Requirements

* SAP BTP ABAP Environment (ABAP Cloud / Steampunk)
* Eclipse with **ABAP Development Tools (ADT)**
* ABAP Cloud Development Tools
* GitHub account/repository
* abapGit
* ABAP Language Version: **ABAP for Cloud Development**

## Development Environment

The project is intended to be developed and tested using **Eclipse ADT** against an SAP BTP ABAP Environment system.

The repository can be used with **abapGit** to synchronize the ABAP development objects between the ABAP system and GitHub.

## Getting Started

1. Set up an SAP BTP ABAP Environment system.
2. Install Eclipse ADT with the ABAP Cloud Development Tools.
3. Configure the ABAP Cloud project in Eclipse.
4. Install/configure abapGit in the ABAP system.
5. Clone or pull this repository using abapGit.
6. Activate the repository objects in the appropriate dependency order.
7. Run the provided utility/data-generation classes where required.
8. Publish and test the OData V4 service through the RAP service binding.

## Testing

The project includes utility classes intended to support:

* Master/test data generation
* ABAP EML-based business object testing
* RAP transactional scenario testing

Testing can be performed directly from Eclipse ADT using ABAP Unit/EML tooling and through the exposed OData V4 service.

## Learning Objectives

This project is intended to demonstrate practical RAP development concepts including:

* Data modeling with CDS
* Interface and projection views
* Managed RAP BOs
* Draft handling
* Determinations, validations, and actions
* Behavior implementations
* EML
* OData V4 service exposure
* ABAP Cloud development
* Git-based ABAP development with abapGit

## Status

This repository is a **RAP development and learning project** demonstrating an enterprise-style Purchase Requisition scenario on ABAP Cloud.

## License

Add the applicable project license here.
