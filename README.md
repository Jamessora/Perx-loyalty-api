# Loyalty API (Rails)

A small Rails API that exposes authenticated endpoints for a loyalty platform.  


## Rules implemented
**Point Earning**
- Level 1: For every **$100** spent → **10 points** (full hundreds only).
- Level 2: Spending in a **foreign country** → **2× points**.

**Reward Issuance**
- Level 1: If a user reaches **≥100 points in a calendar month**, grant **Free Coffee**.
- Level 2:
  - **Birthday month** → **Free Coffee**.
  - **New user** spends **>$1000 within 60 days of first transaction** → **Free Movie Tickets**.

## Authentication
Server-to-server **Bearer API key**:
