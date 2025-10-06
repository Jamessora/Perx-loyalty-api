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

## Prerequisites

- Ruby 3.3
- Bundler
- SQLite

## Setup
Run the following:

- bundle exec rails db:prepare
- bundle exec rails db:seed

For the auth token
- bundle exec rails c
  - client = ApiClient.create!(name: "Playground")
  - client.token

## Testing the endpoint via Powershell

- Create user
```
# set your token
$TOKEN = "<PASTE_TOKEN_HERE>"

# form-encoded body (same as -d in curl)
$body = @{
  id = 1
  name = "Jerico"
  birthday_month = 10
}

Invoke-RestMethod `
  -Uri "http://localhost:3000/users" `
  -Method Post `
  -Headers @{ Authorization = "Bearer $TOKEN" } `
  -Body $body
```

- Post a transaction
```
$txn = @{
  user_id      = 1
  amount_cents = 50000
  occurred_at  = "2025-10-02T00:00:00Z"
  foreign      = $true
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/transactions" -Method Post `
  -Headers @{ Authorization = "Bearer $TOKEN" } `
  -ContentType "application/json" -Body $txn

# Get ledger
Invoke-RestMethod -Uri "http://localhost:3000/users/1/ledger" -Headers @{ Authorization = "Bearer $TOKEN" }
```
Then you would see the user's eligible rewards

<img width="386" height="83" alt="image" src="https://github.com/user-attachments/assets/bb7f7869-8b61-4775-be8a-966af9ad888f" />

## Testing with the seeds file

Run the following:

- `bundle exec rails c`

- 

```
puts "Clients:", ApiClient.pluck(:id,:name,:token).map{_1.join(" | ")}
puts "\nUsers:", User.pluck(:id,:name,:birthday_month).map{_1.join(" | ")}
puts "\nTransactions (id,user,amount_cents,points,occurred_at,foreign):"
pp Transaction.order(:user_id,:occurred_at).pluck(:id,:user_id,:amount_cents,:points,:occurred_at,:foreign)
puts "\nLedger (id,user,type,key,metadata):"
pp LedgerEntry.order(:user_id,:created_at).pluck(:id,:user_id,:entry_type,:key,:metadata)
```
