# SQL / CRM

DDL and schema scripts for the CRM side: Customer, Lead, Opportunity, Campaign, CustomerInteraction, SalesRepresentative.

Data is synthetically generated with Python/Faker (`data_generator.py`, fixed random seed), keyed to the same customer IDs used on the ERP side so cross-system joins work. Known, planted data-quality defects (duplicate customers, invalid emails, orphaned IDs) live here on purpose — they're what the Data Quality Framework is built to catch.
