class Snippet < ApplicationRecord
  belongs_to :tenant

  validates :title, presence: true
  validates :content, presence: true

  acts_as_tenant(:tenant)

  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :active_snippets, -> { where(active: true) }
end
