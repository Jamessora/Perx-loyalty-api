require "rails_helper"

RSpec.describe "Auth", type: :request do
  describe "liveness (no auth needed)" do
    it "returns 200 on /up" do
      get "/up"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "protected endpoints" do
    it "401s without Authorization header" do
      post "/users", params: { id: 1, name: "J", birthday_month: 10 }
      expect(response).to have_http_status(:unauthorized)
    end

    it "401s with wrong token" do
      post "/users",
           params: { id: 1, name: "J", birthday_month: 10 },
           headers: { "Authorization" => "Bearer wrong" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "200s/201s with valid token" do
      client = ApiClient.create!(name: "Test")
      post "/users",
           params: { id: 1, name: "J", birthday_month: 10 },
           headers: { "Authorization" => "Bearer #{client.token}" }
      expect(response).to have_http_status(:created)
    end
  end
end
