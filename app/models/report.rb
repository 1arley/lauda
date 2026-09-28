class Report < ApplicationRecord
  include Discard::Model
  include Auditable

  belongs_to :assessment
  belongs_to :report_template
  belongs_to :created_by, class_name: 'User'
  has_many :export_jobs, dependent: :destroy

  enum :status, { draft: 0, in_review: 1, final: 2 }

  after_initialize { self.sections ||= [] }

  acts_as_tenant :tenant, through: :assessment

  def tenant
    assessment&.tenant
  end
end
