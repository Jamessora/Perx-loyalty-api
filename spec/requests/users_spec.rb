require "rails_helper"

RSpec.describe "Users API", type: :request do
  def json = JSON.parse(response.body)

  let!(:client)  { ApiClient.create!(name: "SpecClient") }
  let(:headers)  { { "Authorization" => "Bearer #{client.token}" } }

  describe "POST /users" do
    it "creates a user (201) with explicit name" do
      post "/users",
           params: { id: 1, name: "Jerico", birthday_month: 10 },
           headers: headers

      expect(response).to have_http_status(:created)
      expect(json).to include("ok" => true, "user_id" => 1)
    end

    it "creates a user with default name when name is blank" do
      post "/users",
           params: { id: 2, name: "", birthday_month: 5 },
           headers: headers

      expect(response).to have_http_status(:created)

      expect(json["user_id"]).to eq(2)
    end

    it "422s when birthday_month is out of range" do
      post "/users",
           params: { id: 3, name: "X", birthday_month: 13 },
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["error"]).to match(/birthday_month/i)
    end

    it "422s when required params are missing" do
      post "/users",
           params: { name: "Nope" }, 
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "401s without Authorization header" do
      post "/users", params: { id: 4, name: "A", birthday_month: 1 }
      expect(response).to have_http_status(:unauthorized)
    end

    it "401s with an invalid token" do
      post "/users",
           params: { id: 5, name: "A", birthday_month: 1 },
           headers: { "Authorization" => "Bearer WRONG" }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
