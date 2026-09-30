class ReportsController < ApplicationController
  before_action :set_assessment
  before_action :set_report, only: %i[show edit update finalize export_pdf]

  def show
    authorize @report
  end

  def new
    @report = @assessment.reports.build
    authorize @report
    @templates = policy_scope(ReportTemplate).active_templates
  end

  def edit
    authorize @report
    @snippets = policy_scope(Snippet).active_snippets
  end

  def create
    @report = @assessment.reports.build(report_params)
    @report.sections = @report.report_template.sections if @report.report_template && @report.sections.blank?
    @report.created_by = current_user
    authorize @report

    if @report.save
      redirect_to edit_assessment_report_path(@assessment, @report), notice: 'Laudo criado.'
    else
      @templates = policy_scope(ReportTemplate).active_templates
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @report

    if @report.update(report_params)
      redirect_to edit_assessment_report_path(@assessment, @report), notice: 'Laudo salvo.'
    else
      @snippets = policy_scope(Snippet).active_snippets
      render :edit, status: :unprocessable_content
    end
  end

  def finalize
    authorize @report
    @report.update(status: :final, finalized_at: Time.current)
    redirect_to assessment_report_path(@assessment, @report), notice: 'Laudo finalizado.'
  end

  def export_pdf
    authorize @report
    export_job = ExportJob.create!(
      tenant: current_user.tenant,
      report: @report,
      user: current_user,
      status: :pending
    )

    PdfExportJob.perform_later(export_job.id)
    redirect_to assessment_report_path(@assessment, @report), notice: 'Exportação em andamento.'
  end

  private

  def set_assessment
    @assessment = Assessment.find(params.expect(:assessment_id))
  end

  def set_report
    @report = @assessment.reports.find(params.expect(:id))
  end

  def report_params
    params.expect(report: [:report_template_id, { sections: [%i[title content section_type]] }])
  end
end
