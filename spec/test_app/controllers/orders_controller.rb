class OrdersController < ActionController::Base
  def update_address
    Order.last.update address: "new address"
    render text: "ok"
  end

  protected

  def current_user
    @current_user ||= User.create name: "Current user"
  end
  helper_method :current_user
end
