class Report < ApplicationRecord
  include Discard::Model
  include Auditable

  belongs_to :assessment
  belongs_to :report_template
  belongs_to :created_by, class_name: 'User'
  has_many :export_jobs, dependent: :destroy

  enum :status, { draft: 0, in_review: 1, final: 2 }

  after_initialize { self.sections ||= [] }

  # reports não tem tenant_id: o tenant vem da avaliação. O escopo padrão
  # replica o que o acts_as_tenant faria via `through`, para que uma consulta
  # direta ao model não atravesse clínicas.
  default_scope lambda {
    if ActsAsTenant.current_tenant
      joins(:assessment).where(assessment: { tenant_id: ActsAsTenant.current_tenant.id })
    else
      all
    end
  }

  def tenant
    assessment&.tenant
  end
end
