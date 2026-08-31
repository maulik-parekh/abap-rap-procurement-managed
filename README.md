# abap-rap-procurement-managed
abap rap procurement managed app
# Enterprise Managed RAP 3-Tier Requisition System (ABAP Cloud)

## Overview
This repository contains a full production-ready implementation of a 3-tier hierarchical Purchase Requisition system built on the **ABAP RESTful Application Programming Model (RAP)** with Draft Enablement in SAP BTP ABAP Environment (Steampunk).

## Repository Structure
- `/src/tables` - Data definitions for master, transactional, and draft persistence.
- `/src/cds` - Basic, Interface, and Projection CDS views.
- `/src/rap` - Behavior Definitions (BDEF) and Behavior Implementations (BIL).
- `/src/services` - Service Definitions and Service Bindings (OData V4).
- `/src/utility` - Data Generator and EML Test Runner classes.

## System Requirements
- SAP BTP ABAP Environment (Steampunk / Free Tier)
- Eclipse ADT with ABAP Cloud Development Tools
- ABAP Language Version: **ABAP Cloud**
