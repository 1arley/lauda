class ExportJobsController < ApplicationController
  def index
    @export_jobs = policy_scope(ExportJob).includes(:report, :user).order(created_at: :desc)
    @pagy, @export_jobs = pagy(@export_jobs, items: 20)
  end

  def show
    @export_job = ExportJob.find(params.expect(:id))
    authorize @export_job

    if @export_job.completed?
      redirect_to @export_job.file_url, allow_other_host: true
    else
      redirect_to export_jobs_path, notice: 'Exportação ainda em processamento.'
    end
  end
end
