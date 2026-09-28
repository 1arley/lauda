class ExportJob < ApplicationRecord
  belongs_to :tenant
  belongs_to :report
  belongs_to :user

  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }

  acts_as_tenant(:tenant)
end
