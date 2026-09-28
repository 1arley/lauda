class PatientsController < ApplicationController
  before_action :set_patient, only: %i[show edit update destroy]

  def index
    @q = policy_scope(Patient).ransack(params[:q])
    @pagy, @patients = pagy(@q.result(distinct: true).order(:name), items: 20)
  end

  def show
    authorize @patient
    @assessments = @patient.assessments.includes(:owner).order(created_at: :desc)
  end

  def new
    @patient = Patient.new
    authorize @patient
  end

  def edit
    authorize @patient
  end

  def create
    @patient = Patient.new(patient_params)
    authorize @patient

    if @patient.save
      redirect_to @patient, notice: 'Paciente cadastrado.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @patient

    if @patient.update(patient_params)
      redirect_to @patient, notice: 'Paciente atualizado.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @patient
    @patient.discard!
    redirect_to patients_path, notice: 'Paciente removido.'
  end

  private

  def set_patient
    @patient = Patient.find(params.expect(:id))
  end

  def patient_params
    params.expect(patient: %i[name birth_date cpf gender email phone notes])
  end
end
