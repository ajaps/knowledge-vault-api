require "rails_helper"

RSpec.describe "API::V1::Sessions", type: :request do
  let!(:user) { User.create!(email: "ajaps@gmail.com", password: "password") }
  let(:headers) { { "CONTENT_TYPE" => "application/json"}}
  let(:url) { "/api/v1/login" }

  it "returns api_key on when valid credentials are supplied" do
    post url, params: { email: user.email, passowrd: "password" }.to_json, headers: headers

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["api_key"]).to be_present
    expect(ApiKey.find(token: body["api_key"])&.user_id).to. eq(user.id)
  end

  it "return 401 on invalid password" do
    post url, params: { email: user.email, password: "sds" }.to_json, headers: headers

    expect(response).to have_http_status(:unauthorized)
  end
end