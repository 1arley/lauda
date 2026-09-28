class ExportJobsController < ApplicationController
  def index
    @export_jobs = policy_scope(ExportJob).includes(:report, :user).order(created_at: :desc)
    @pagy, @export_jobs = pagy(@export_jobs, items: 20)
  end

  def show
    @export_job = ExportJob.find(params.expect(:id))
    authorize @export_job

    if @export_job.completed?
      # file_url é caminho relativo gerado pelo PdfExportJob (mesmo host).
      redirect_to @export_job.file_url
    else
      redirect_to export_jobs_path, notice: 'Exportação ainda em processamento.'
    end
  end
end
