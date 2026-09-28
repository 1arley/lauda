class InstrumentApplicationsController < ApplicationController
  before_action :set_assessment
  before_action :set_instrument_application, only: %i[show edit_answers update_answers score results destroy]

  def new
    @instrument_application = @assessment.instrument_applications.build
    authorize @instrument_application
    @available_versions = InstrumentVersion.active_versions.includes(:instrument)
  end

  def create
    @instrument_application = @assessment.instrument_applications.build(instrument_application_params)
    @instrument_application.applied_by = current_user
    authorize @instrument_application

    if @instrument_application.save
      redirect_to edit_answers_assessment_instrument_application_path(@assessment, @instrument_application),
                  notice: 'Instrumento adicionado.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit_answers
    authorize @instrument_application
    @answer_sets = @instrument_application.answer_sets.ordered
  end

  def update_answers
    authorize @instrument_application

    params[:answer_sets]&.each_value do |attrs|
      answer_set = @instrument_application.answer_sets.find_or_initialize_by(subtest_name: attrs[:subtest_name])
      answer_set.answers = attrs[:answers]
      answer_set.position = attrs[:position]
      answer_set.save!
    end

    @instrument_application.update(status: :answered, applied_at: Time.current)
    redirect_to score_assessment_instrument_application_path(@assessment, @instrument_application),
                notice: 'Respostas salvas.'
  end

  def score
    authorize @instrument_application
    @normative_tables = @instrument_application.instrument_version.normative_tables
  end

  def compute
    authorize @instrument_application

    normative_table = NormativeTable.find(params.expect(:normative_table_id))
    @instrument_application.compute!(normative_table_id: normative_table.id)

    redirect_to results_assessment_instrument_application_path(@assessment, @instrument_application),
                notice: 'Cálculo realizado.'
  rescue StandardError => e
    redirect_to score_assessment_instrument_application_path(@assessment, @instrument_application),
                alert: "Erro no cálculo: #{e.message}"
  end

  def results
    authorize @instrument_application
    @score_results = @instrument_application.score_results.ordered
    @instrument = @instrument_application.instrument_version.instrument
  end

  def destroy
    authorize @instrument_application
    @instrument_application.destroy
    redirect_to @assessment, notice: 'Instrumento removido.'
  end

  private

  def set_assessment
    @assessment = Assessment.find(params.expect(:assessment_id))
  end

  def set_instrument_application
    @instrument_application = @assessment.instrument_applications.find(params.expect(:id))
  end

  def instrument_application_params
    params.expect(instrument_application: [:instrument_version_id])
  end
end
