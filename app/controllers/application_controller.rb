class ApplicationController < ActionController::API
  before_action :authenticate!

  private

  def authenticate!
    scheme, token = request.authorization.to_s.split(" ", 2)
    head :unauthorized and return unless scheme == "Bearer" && token.present?
    @current_client = ApiClient.find_by(token: token)
    head :unauthorized unless @current_client
  end
end
