class PdfExportJob < ApplicationJob
  queue_as :default

  def perform(export_job_id)
    export_job = ExportJob.find(export_job_id)
    export_job.update!(status: :processing)

    report = export_job.report
    pdf_bytes = Pdf::ReportGenerator.new(report).generate

    filename = "laudo_#{report.id}_#{Time.current.strftime('%Y%m%d_%H%M%S')}.pdf"
    filepath = Rails.root.join('storage', 'exports', filename)
    FileUtils.mkdir_p(File.dirname(filepath))
    File.binwrite(filepath, pdf_bytes)

    export_job.update!(
      status: :completed,
      file_url: "/storage/exports/#{filename}",
      completed_at: Time.current
    )
  rescue StandardError => e
    export_job.update!(
      status: :failed,
      error_message: e.message
    )
    raise e
  end
end
