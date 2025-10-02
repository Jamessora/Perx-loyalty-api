require "rails_helper"

RSpec.describe "Transactions", type: :request do
  let!(:client) { ApiClient.create!(name: "Test") }
  let(:auth)    { { "Authorization" => "Bearer #{client.token}" } }

  it "creates user, ingests a txn, and records rewards" do
    post "/users", params: { id: 1, name: "Jerico", birthday_month: 10 }, headers: auth
    expect(response).to have_http_status(:created)

    post "/transactions",
      params: { user_id: 1, amount_cents: 50000, occurred_at: "2025-10-02T03:00:00+08:00", foreign: true },
      headers: auth
    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["monthly_points"].values.map(&:to_i).sum).to be >= 100

    get "/users/1/ledger", headers: auth
    expect(response).to have_http_status(:ok)
    ledger = JSON.parse(response.body)["ledger"]
    expect(ledger.any? { |e| e["type"] == "reward" }).to be true
  end
end
