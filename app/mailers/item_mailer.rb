class ItemMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.item_mailer.in_stock.subject
  #
  def in_stock
    @item = params[:item]
    mail to: params[:subscriber].email
  end
end
