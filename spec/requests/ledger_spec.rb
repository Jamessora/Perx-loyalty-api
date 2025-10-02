require "rails_helper"

RSpec.describe "Ledger API (month accumulation)", type: :request do
  def json = JSON.parse(response.body)

  let!(:client)  { ApiClient.create!(name: "SpecClient") }
  let(:headers)  { { "Authorization" => "Bearer #{client.token}" } }

  before do
    post "/users", params: { id: 9, name: "M", birthday_month: 1 }, headers: headers
    expect(response).to have_http_status(:created)
  end

  it "does NOT grant Free Coffee when 100 pts are split across two different calendar months" do
    # 300 USD domestic => 30 pts
    # 300 USD foreign  => 30 * 2 = 60 pts  (total across months = 90, adjust amounts as you like)
    last_month = (Time.now.utc.to_date << 1).to_time.utc
    this_month = Time.now.utc.beginning_of_month + 3600

    post "/transactions",
         params: { user_id: 9, amount_cents: 3_0000, occurred_at: last_month.iso8601, foreign: true },
         headers: headers
    expect(response).to be_successful

    post "/transactions",
         params: { user_id: 9, amount_cents: 4_0000, occurred_at: this_month.iso8601, foreign: false }, # 40 pts
         headers: headers
    expect(response).to be_successful

    get "/users/9/ledger", headers: headers
    rewards = json["ledger"].select { |e| e["type"] == "reward" }

    # ensure there's NO "100+ points in "this month" reward
    month_key = Time.now.utc.strftime("%Y-%m")
    expect(rewards.map { |r| r.dig("metadata", "reason") })
      .not_to include("100+ points in #{month_key}")
  end

  it "grants Free Coffee when 100+ pts are accumulated within the same calendar month" do
    now = Time.now.utc
    # Two transactions within this month that sum to >=100 pts
    # 300 USD foreign => 60 pts, plus 400 USD domestic => 40 pts, total = 100
    post "/transactions",
         params: { user_id: 9, amount_cents: 3_0000, occurred_at: now.iso8601, foreign: true },
         headers: headers
    expect(response).to be_successful

    post "/transactions",
         params: { user_id: 9, amount_cents: 4_0000, occurred_at: (now + 3600).iso8601, foreign: false },
         headers: headers
    expect(response).to be_successful

    get "/users/9/ledger", headers: headers
    rewards = json["ledger"].select { |e| e["type"] == "reward" }
    month_key = now.strftime("%Y-%m")

    expect(rewards.map { |r| r.dig("metadata", "reward") }).to include("FREE_COFFEE")
    expect(rewards.map { |r| r.dig("metadata", "reason") }).to include("100+ points in #{month_key}")
  end
end
