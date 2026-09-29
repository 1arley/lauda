class ExportJobsController < ApplicationController
  def index
    skip_authorization
    @export_jobs = policy_scope(ExportJob).includes(:report, :user).order(created_at: :desc)
    @pagy, @export_jobs = pagy(@export_jobs, items: 20)
  end

  def show
    @export_job = ExportJob.find(params.expect(:id))
    authorize @export_job

    if @export_job.completed?
      path = @export_job.artifact_path
      if path && File.file?(path)
        return send_file(path, filename: File.basename(path), type: 'application/pdf',
                               disposition: 'attachment')
      end

      head :not_found
    else
      redirect_to export_jobs_path, notice: 'Exportação ainda em processamento.'
    end
  end
end
