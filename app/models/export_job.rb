class ExportJob < ApplicationRecord
  belongs_to :tenant
  belongs_to :report
  belongs_to :user

  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }

  acts_as_tenant(:tenant)

  def process!
    update!(status: :processing)

    report = self.report
    pdf_bytes = Pdf::ReportGenerator.new(report).generate
    filename = "laudo_#{report.id}_#{id}.pdf"
    path = Rails.root.join('storage', 'exports', filename)

    FileUtils.mkdir_p(path.dirname)
    File.binwrite(path, pdf_bytes)

    update!(status: :completed, file_url: "/storage/exports/#{filename}", completed_at: Time.current)
  rescue StandardError => e
    update!(status: :failed, error_message: e.message)
    raise
  end

  def artifact_path
    return if file_url.blank?

    Rails.root.join('storage', 'exports', File.basename(file_url))
  end
end
