# Preview all emails at http://localhost:3000/rails/mailers/item_mailer
class ItemMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/item_mailer/in_stock
  def in_stock
    ItemMailer.in_stock
  end
end
