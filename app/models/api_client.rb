class ApiClient < ApplicationRecord
  has_secure_token :token
end
