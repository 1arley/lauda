class AssessmentsController < ApplicationController
  before_action :set_assessment, only: %i[show edit update destroy finalize]

  def index
    skip_authorization
    @assessments = policy_scope(Assessment)
    @assessments = @assessments.where(patient_id: params[:patient_id]) if params[:patient_id].present?
    @assessments = @assessments.where(status: params[:status]) if params[:status].present?
    @pagy, @assessments = pagy(@assessments.includes(:patient, :owner).order(created_at: :desc), items: 20)
  end

  def show
    authorize @assessment
    @instrument_applications = @assessment.instrument_applications.includes(:instrument_version, :score_results)
    @reports = @assessment.reports.includes(:report_template)
  end

  def new
    @assessment = Assessment.new
    authorize @assessment
    @patients = policy_scope(Patient).order(:name)
  end

  def edit
    authorize @assessment
  end

  def create
    @assessment = Assessment.new(assessment_params)
    @assessment.owner = current_user
    authorize @assessment

    if @assessment.save
      redirect_to @assessment, notice: 'Avaliação criada com sucesso.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @assessment

    if @assessment.update(assessment_params)
      redirect_to @assessment, notice: 'Avaliação atualizada.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @assessment
    @assessment.discard!
    redirect_to assessments_path, notice: 'Avaliação arquivada.'
  end

  def finalize
    authorize @assessment
    if @assessment.instrument_applications.scored.any?
      @assessment.update(status: :final, finalized_at: Time.current)
      redirect_to @assessment, notice: 'Avaliação finalizada.'
    else
      redirect_to @assessment, alert: 'Calcule pelo menos um instrumento antes de finalizar.'
    end
  end

  private

  def set_assessment
    @assessment = Assessment.find(params.expect(:id))
  end

  def assessment_params
    params.expect(assessment: %i[patient_id title context conducted_at])
  end
end
