class SiteCounter < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  def self.increment!(name)
    counter = find_or_create_by!(name: name.to_s)
    counter.increment!(:value)
  end

  def self.count_for(name)
    find_by(name: name.to_s)&.value || 0
  end
end
