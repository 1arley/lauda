class DashboardController < ApplicationController
  def index
    skip_authorization
    @recent_patients = policy_scope(Patient).order(updated_at: :desc).limit(5)
    active = policy_scope(Assessment).active_assessments
    @active_assessments = active.includes(:patient, :owner).order(updated_at: :desc).limit(10)
    @stats = {
      total_patients: policy_scope(Patient).count,
      active_assessments: policy_scope(Assessment).active_assessments.count,
      pending_reports: policy_scope(Report).where(status: %i[draft in_review]).count
    }
    @show_onboarding = @stats.values.all?(&:zero?)
    @stale_applications = policy_scope(InstrumentApplication)
      .where(status: :scored)
      .includes(:assessment, { score_results: :normative_table }, instrument_version: :instrument)
      .select(&:norm_changed?)
  end
end
