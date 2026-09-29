class PdfExportJob < ApplicationJob
  queue_as :default

  def perform(export_job_id)
    ExportJob.find(export_job_id).process!
  end
end
