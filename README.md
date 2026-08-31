# ABAP RAP Procurement Managed

**Enterprise-Style Managed RAP 3-Tier Purchase Requisition System (ABAP Cloud)**

An SAP **ABAP RESTful Application Programming Model (RAP)** implementation of a managed Purchase Requisition application with draft support.

## Overview

This repository contains a 3-tier hierarchical Purchase Requisition application built using the **ABAP RESTful Application Programming Model (RAP)** and designed for **SAP BTP ABAP Environment (ABAP Cloud / Steampunk)**.

The project demonstrates how a transactional procurement business object can be modeled and exposed using modern ABAP Cloud development practices.

The application demonstrates:

* Managed RAP business object implementation
* Draft-enabled transactional processing
* 3-tier hierarchical Purchase Requisition structure
* CDS-based data modeling
* Interface and projection CDS views
* RAP Behavior Definitions (BDEF)
* RAP Behavior Implementations / behavior pools
* Determinations, validations, and actions
* Value-help CDS views
* Virtual element handling
* OData V4 service exposure
* ABAP EML-based testing
* Master/test data generation
* ABAP Cloud development using Eclipse ADT
* Git-based development using abapGit

---

## Business Object

The application models a hierarchical Purchase Requisition business object with three transactional levels:

```text
Purchase Requisition
        │
        ├── Items
        │      │
        │      └── Account Assignments
        │
        └── Draft-enabled processing
```

The hierarchy represents:

* **Purchase Requisition Header**
* **Purchase Requisition Items**
* **Account Assignments**

The RAP business object is implemented using managed RAP with draft support.

---

## Architecture

The application follows a typical RAP layered architecture:

```text
                    ABAP Cloud
                        │
                        ▼
              ┌───────────────────┐
              │   Database Tables │
              │ Master / Txn /    │
              │ Draft Persistence │
              └─────────┬─────────┘
                        │
                        ▼
              ┌───────────────────┐
              │    Basic CDS      │
              │   Data Models     │
              └─────────┬─────────┘
                        │
                        ▼
              ┌───────────────────┐
              │  Interface CDS    │
              │  Business Object  │
              └─────────┬─────────┘
                        │
                        ▼
              ┌───────────────────┐
              │ RAP Behavior      │
              │ Definition        │
              └─────────┬─────────┘
                        │
                        ▼
              ┌───────────────────┐
              │ Behavior Pool /   │
              │ Implementation   │
              └─────────┬─────────┘
                        │
                        ▼
              ┌───────────────────┐
              │ Projection CDS    │
              │ Service Exposure  │
              └─────────┬─────────┘
                        │
                        ▼
              ┌───────────────────┐
              │ Service Definition│
              └─────────┬─────────┘
                        │
                        ▼
              ┌───────────────────┐
              │ OData V4 Service  │
              │ Binding           │
              └───────────────────┘
```

---

## RAP Layering

The main RAP implementation consists of the following layers:

### 1. Persistence Layer

Database tables provide persistence for:

* Master data
* Purchase Requisition header
* Purchase Requisition items
* Account assignments
* Draft data

The repository currently contains persistence objects including:

```text
zmaterial_master
zsupplier_master
zcost_center_m

zpr_header
zpr_item
zpr_account

zpr_header_d
zpr_item_d
zpr_account_d
```

Draft tables provide persistence for draft-enabled transactional processing.

---

### 2. CDS Data Model

The CDS layer provides the semantic data model used by the RAP business object.

The repository contains interface and projection-style CDS entities for:

* Purchase Requisition header
* Purchase Requisition items
* Account assignments
* Material value help
* Supplier value help
* Cost center value help

Examples include:

```text
ZI_ProcurementHeader
ZI_ProcurementItem
ZI_AccountAssignment

ZI_MaterialVH
ZI_SupplierVH
ZI_CostCenterVH

ZC_ProcurementHeader
ZC_ProcurementItem
ZC_AccountAssignment
```

The CDS layer separates the transactional business object model from the service-facing projection.

---

### 3. RAP Behavior Layer

The RAP behavior layer defines the transactional behavior of the business object.

The repository contains Behavior Definitions for the interface and projection layers, together with the corresponding behavior implementation.

The behavior implementation is provided through the behavior pool:

```text
ZBP_I_PROCUREMENTHEADER
```

The behavior layer demonstrates concepts such as:

* Managed processing
* Draft handling
* Validations
* Determinations
* Actions
* Transactional consistency
* EML-based interaction

---

### 4. Projection Layer

Projection CDS views define the service-facing representation of the business object.

The projection layer exposes the relevant business object entities while keeping the underlying interface model separated from the external service contract.

---

### 5. Service Layer

The RAP business object is exposed using an OData V4 service.

The repository contains:

```text
ZSD_PROCUREMENT
```

as the Service Definition and:

```text
ZSB_PROCUREMENT_UI_V4
```

as the OData V4 Service Binding.

The service layer provides the external API surface for consuming the RAP business object.

---

## Value Helps

The project includes CDS-based value-help objects for common procurement master data.

Current value-help examples include:

```text
ZI_MaterialVH
ZI_SupplierVH
ZI_CostCenterVH
```

These are used to support selection and navigation scenarios involving:

* Materials
* Suppliers
* Cost Centers

---

## Virtual Elements

The project also contains a dedicated utility class for virtual-element processing:

```text
ZCL_PR_VIRTUAL_ELEMENTS
```

This demonstrates how calculated or dynamically derived values can be handled outside the persisted database fields when appropriate.

---

## Utility and Test Support

The repository includes utility classes to support development and testing.

### Test Data Generator

```text
ZCL_PR_DATA_GENERATOR
```

This class is intended to help create master and transactional test data required for exercising the Purchase Requisition business object.

### Behavior Test Classes

The behavior pool also contains test-class support for validating RAP transactional scenarios.

Testing can be performed using:

* ABAP Unit
* ABAP EML
* Eclipse ADT
* OData V4 service consumption

---

## Repository Structure

The repository uses an **ABAP package-based structure exported through abapGit**.

The `src` directory contains the ABAP repository objects used by the application, including:

```text
src/
│
├── Database Tables
│   ├── Master data
│   ├── Transactional persistence
│   └── Draft persistence
│
├── CDS Views
│   ├── Interface views
│   ├── Projection views
│   └── Value-help views
│
├── RAP Behavior
│   ├── Behavior Definitions
│   ├── Behavior Pool
│   └── Test Classes
│
├── Services
│   ├── Service Definition
│   └── OData V4 Service Binding
│
└── Utility / Supporting Classes
    ├── Test Data Generator
    └── Virtual Element Handler
```

The repository is intentionally kept in the structure generated/exported by the ABAP development environment and **does not require manually reorganizing the Git `src` directory into artificial folders**.

---

## Technology Stack

* **SAP ABAP RESTful Application Programming Model (RAP)**
* **ABAP Cloud**
* **SAP BTP ABAP Environment**
* **Core Data Services (CDS)**
* **RAP Behavior Definition Language**
* **Managed RAP**
* **Draft-enabled RAP**
* **ABAP EML (Entity Manipulation Language)**
* **OData V4**
* **Eclipse ADT**
* **abapGit**
* **ABAP Unit**

---

## System Requirements

The project is intended for development in an SAP ABAP Cloud environment.

### Required

* SAP BTP ABAP Environment
* Eclipse
* ABAP Development Tools (ADT)
* ABAP Cloud Development Tools
* abapGit
* GitHub account/repository
* ABAP Language Version: **ABAP for Cloud Development**

---

## Development Environment

The project is intended to be developed and tested using **Eclipse ADT** connected to an SAP BTP ABAP Environment system.

The repository can be synchronized between the ABAP system and GitHub using **abapGit**.

Typical development flow:

```text
Eclipse ADT
     │
     ▼
ABAP Cloud System
     │
     ▼
Develop RAP Objects
     │
     ▼
Test with EML / ADT
     │
     ▼
Expose OData V4 Service
     │
     ▼
abapGit
     │
     ▼
GitHub
```

---

## Getting Started

### 1. Set up ABAP Cloud

Create or obtain access to an SAP BTP ABAP Environment system.

### 2. Install Eclipse ADT

Install Eclipse with the **ABAP Development Tools (ADT)** and configure the ABAP Cloud project.

### 3. Configure abapGit

Configure abapGit in the ABAP system and connect it to the GitHub repository.

### 4. Pull the Repository

Clone/pull the repository using abapGit into the appropriate ABAP package.

### 5. Activate the Objects

Activate the repository objects in dependency order.

A typical activation flow is:

```text
Database Tables
      ↓
Basic / Interface CDS
      ↓
Behavior Definitions
      ↓
Behavior Implementation
      ↓
Projection CDS
      ↓
Service Definition
      ↓
Service Binding
```

### 6. Generate Test Data

Run:

```text
ZCL_PR_DATA_GENERATOR
```

where required to create the test/master data needed for testing.

### 7. Test the RAP Business Object

Use Eclipse ADT and ABAP EML to test:

* Create
* Read
* Update
* Delete
* Validations
* Determinations
* Actions
* Draft processing
* Hierarchical operations

### 8. Test the OData V4 Service

Publish/activate the service binding and test the exposed RAP service using the available ADT/OData tooling.

---

## Testing

The project includes support for testing the RAP business object through ABAP-based tooling.

Testing areas include:

### Persistence

Verify that:

* Master data exists
* Transactional records are created correctly
* Draft records are persisted correctly

### RAP Behavior

Verify:

* Create operations
* Update operations
* Delete operations
* Validations
* Determinations
* Actions
* Authorization/transactional behavior where implemented

### Hierarchy

Verify the relationship:

```text
Purchase Requisition
        │
        ├── Items
        │
        └── Account Assignments
```

### Draft

Verify:

* Draft creation
* Draft modification
* Draft activation
* Draft persistence
* Transactional consistency

### Service

Verify the OData V4 service exposed by:

```text
ZSB_PROCUREMENT_UI_V4
```

---

## Learning Objectives

This project is intended to demonstrate practical RAP development concepts, including:

* ABAP Cloud development
* RAP managed business objects
* Draft-enabled RAP
* CDS data modeling
* Interface CDS views
* Projection CDS views
* Associations and compositions
* RAP Behavior Definitions
* Behavior Implementations
* Validations
* Determinations
* Actions
* Value helps
* Virtual elements
* ABAP EML
* OData V4 service exposure
* Service Definitions
* Service Bindings
* ABAP Unit testing
* Test data generation
* Git-based ABAP development using abapGit
* Eclipse ADT development workflow

---

## Project Flow

At a high level, the application follows this flow:

```text
                    User / Consumer
                           │
                           ▼
                    OData V4 Service
                           │
                           ▼
                    Service Binding
                           │
                           ▼
                    Service Definition
                           │
                           ▼
                    Projection CDS
                           │
                           ▼
                 RAP Behavior Definition
                           │
                           ▼
                 Behavior Implementation
                           │
                           ▼
                    Interface CDS
                           │
                           ▼
                   Database Persistence
```

Supporting components:

```text
Master Data
    │
    ├── Material
    ├── Supplier
    └── Cost Center

Supporting RAP Features
    │
    ├── Value Helps
    ├── Virtual Elements
    ├── Test Data Generator
    └── ABAP EML / Test Classes
```

---

## ABAP Cloud Focus

This project is designed around the principles of modern **ABAP Cloud development** rather than classic procedural ABAP development.

The implementation focuses on:

* RAP-based transactional processing
* CDS-first data modeling
* Behavior-driven business logic
* OData V4 service exposure
* ABAP EML
* Eclipse ADT
* Cloud-compatible ABAP development

---

## Project Status

This repository is an **enterprise-style RAP development and learning project** demonstrating a Purchase Requisition scenario on SAP BTP ABAP Environment.

It is intended to serve as:

* A practical RAP reference project
* An ABAP Cloud learning project
* An example of managed RAP with draft
* A demonstration of hierarchical transactional modeling
* A starting point for further procurement application development

---

## Notes

This project is intended for development, learning, experimentation, and demonstration purposes.

Before using the implementation in a production environment, additional project-specific work may be required, including:

* Authorization and access-control design
* Error-handling refinement
* Performance testing
* Security review
* Production deployment configuration
* Monitoring and operational requirements
* Business-specific validation and compliance requirements

---

## License

This project does not currently specify a license.

If this repository is intended for public reuse, add an appropriate open-source license and update this section accordingly.
