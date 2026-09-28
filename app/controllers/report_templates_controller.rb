class ReportTemplatesController < ApplicationController
  before_action :set_report_template, only: %i[show edit update destroy]

  def index
    @report_templates = policy_scope(ReportTemplate).active_templates.order(:name)
  end

  def new
    @report_template = ReportTemplate.new
    authorize @report_template
  end

  def edit
    authorize @report_template
  end

  def create
    @report_template = ReportTemplate.new(report_template_params)
    authorize @report_template

    if @report_template.save
      redirect_to @report_template, notice: 'Template criado.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @report_template

    if @report_template.update(report_template_params)
      redirect_to @report_template, notice: 'Template atualizado.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @report_template
    @report_template.discard!
    redirect_to report_templates_path, notice: 'Template removido.'
  end

  private

  def set_report_template
    @report_template = ReportTemplate.find(params.expect(:id))
  end

  def report_template_params
    params.expect(report_template: [:name, :description, :default, { sections: %i[title content section_type] }])
  end
end
