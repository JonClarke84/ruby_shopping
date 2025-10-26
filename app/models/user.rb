class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups
  has_one :user_group_selection, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email_address, presence: true, uniqueness: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  after_create :create_default_group

  private

  def create_default_group
    default_group = Group.create!(name: "#{first_name} #{last_name}")
    user_groups.create!(group: default_group)
  end
end
