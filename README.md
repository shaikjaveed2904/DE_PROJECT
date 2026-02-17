# Search Keyword Performance Analyzer

A Python-based data engineering tool that processes Adobe Analytics hit-level data to identify which search engines and keywords generate the most revenue.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Output](#output)
- [How It Works](#how-it-works)
- [AWS Deployment](#aws-deployment)
- [Infrastructure as Code (Terraform)](#infrastructure-as-code-terraform)
- [Scalability](#scalability)
- [Error Handling](#error-handling)
- [Future Enhancements](#future-enhancements)

---

## Overview

This tool answers the business question:

> **Which external search engines and keywords are driving the most revenue?**

It processes tab-delimited Adobe Analytics hit-level data, filters for purchase events, and aggregates revenue by search engine domain and keyword — producing a clean, sorted report.

**Supported Search Engines:** Google, Yahoo, Bing, MSN

---

## Prerequisites

- Python 3.7+
- (Optional) Terraform for infrastructure provisioning

---

## Project Structure

```
DE_PROJECT/
│
├── de_project/
│   ├── search_keyword_performance.py   # Main application script
│   ├── sample_data.tsv                 # Sample input data for testing
│   ├── output_example.tsv              # Expected output for validation
│   │
│   └── terraform/
│       ├── main.tf
│       ├── provider.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── README.md
```

---

## Installation

**1. Clone the repository:**

```bash
git clone <repo-url>
cd DE_PROJECT
```

**2. (Optional) Set up a virtual environment:**

```bash
python3 -m venv venv
source venv/bin/activate
```

No additional dependencies are required — the script uses Python's standard library.

---

## Usage

Run the script with the path to your input `.tsv` file as the only argument:

```bash
python de_project/search_keyword_performance.py de_project/sample_data.tsv
```

**To validate against the expected output:**

```bash
diff YYYY-mm-dd_SearchKeywordPerformance.tab de_project/output_example.tsv
```

---

## Output

The script generates a tab-delimited file in the current working directory:

**Filename format:** `YYYY-mm-dd_SearchKeywordPerformance.tab`

**Columns:**

| Search Engine Domain | Search Keyword | Revenue |
|----------------------|----------------|---------|

- Includes a header row
- Sorted by Revenue (descending)
- Only includes rows from purchase events (event ID 1)

---

## How It Works

The script processes the input file with the following logic:

1. **Read** — Parses the input file line-by-line for memory efficiency.
2. **Filter** — Keeps only rows where:
   - The referrer URL contains a supported search engine domain (`google.*`, `yahoo.*`, `bing.*`, `msn.*`)
   - The `event_list` column contains purchase event ID `1`
3. **Extract** — Parses the referrer URL to pull:
   - Search engine domain
   - Search keyword (`q=` parameter for Google/Bing/MSN; `p=` parameter for Yahoo)
4. **Parse Revenue** — Reads the `product_list` column (format: `Category;ProductName;Quantity;Revenue;Events`) and sums the 4th field across all products in the row.
5. **Aggregate** — Groups total revenue by Search Engine Domain + Search Keyword.
6. **Sort & Write** — Outputs results sorted by revenue descending.

---

## AWS Deployment

The application is deployed on AWS EC2 and accessible at:

```
http://52.66.30.106:8501/
```

**EC2 Configuration:**

| Setting | Value |
|---|---|
| Region | ap-south-1 |
| Instance Type | t3.micro |
| AMI | Amazon Linux 2023 |
| Open Ports | 22 (SSH), 8501 (App) |

---

## Infrastructure as Code (Terraform)

AWS infrastructure is provisioned using Terraform. The configuration creates an EC2 instance, security group, and public IP association.

**To provision:**

```bash
cd de_project/terraform
terraform init
terraform plan
terraform apply
```

After apply, retrieve the public IP and DNS:

```bash
terraform output
```

**Resources created:**
- EC2 Instance (t3.micro)
- Security Group (SSH + Port 8501)
- Public IP association

---

## Scalability

The current design processes data line-by-line, avoiding full in-memory loading. This works well for moderately large files.

**For very large files (10 GB+), the recommended architecture is:**

- Store raw data in **Amazon S3**
- Process with **AWS Glue** (Apache Spark) or **EMR** for distributed aggregation
- Partition S3 data for parallel reads
- Store results in **S3**, **Redshift**, or query via **Athena**
- Orchestrate with **AWS Step Functions** or **EventBridge**

---

## Error Handling

The script handles the following gracefully:

- Malformed or incomplete rows are skipped
- Records without purchase events are excluded
- Invalid or missing revenue values are ignored

**Assumptions:**
- Input file contains `event_list`, `product_list`, and `referrer` columns
- Revenue values in `product_list` are numeric
- Referrer URLs contain valid query parameters

---

## Future Enhancements

- Add unit tests with `pytest`
- Structured logging with CloudWatch integration
- Dockerize the application
- CI/CD pipeline via GitHub Actions
- S3-triggered Lambda for automated processing
- Output storage in a data warehouse for dashboarding
