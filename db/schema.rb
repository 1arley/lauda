# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_30_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "answer_sets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "answers", null: false
    t.datetime "created_at", null: false
    t.uuid "instrument_application_id", null: false
    t.jsonb "metadata"
    t.integer "position"
    t.string "subtest_name"
    t.datetime "updated_at", null: false
    t.index ["instrument_application_id", "subtest_name"], name: "idx_on_instrument_application_id_subtest_name_66cd4c9ade"
    t.index ["instrument_application_id"], name: "index_answer_sets_on_instrument_application_id"
  end

  create_table "assessments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "conducted_at"
    t.text "context"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.datetime "finalized_at"
    t.uuid "owner_id", null: false
    t.uuid "patient_id", null: false
    t.integer "status", default: 0, null: false
    t.uuid "tenant_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_assessments_on_owner_id"
    t.index ["patient_id"], name: "index_assessments_on_patient_id"
    t.index ["tenant_id", "discarded_at"], name: "index_assessments_on_tenant_id_and_discarded_at"
    t.index ["tenant_id", "patient_id"], name: "index_assessments_on_tenant_id_and_patient_id"
    t.index ["tenant_id", "status"], name: "index_assessments_on_tenant_id_and_status"
    t.index ["tenant_id"], name: "index_assessments_on_tenant_id"
  end

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action", null: false
    t.uuid "auditable_id", null: false
    t.string "auditable_type", null: false
    t.jsonb "changeset"
    t.datetime "created_at", null: false
    t.jsonb "metadata"
    t.uuid "tenant_id", null: false
    t.uuid "user_id"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["tenant_id", "auditable_type", "auditable_id"], name: "idx_on_tenant_id_auditable_type_auditable_id_d58e58f45b"
    t.index ["tenant_id", "created_at"], name: "index_audit_logs_on_tenant_id_and_created_at"
    t.index ["tenant_id"], name: "index_audit_logs_on_tenant_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "export_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "error_message"
    t.string "file_url"
    t.string "format", default: "pdf", null: false
    t.uuid "report_id", null: false
    t.integer "status", default: 0, null: false
    t.uuid "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["report_id", "status"], name: "index_export_jobs_on_report_id_and_status"
    t.index ["report_id"], name: "index_export_jobs_on_report_id"
    t.index ["tenant_id", "status"], name: "index_export_jobs_on_tenant_id_and_status"
    t.index ["tenant_id"], name: "index_export_jobs_on_tenant_id"
    t.index ["user_id"], name: "index_export_jobs_on_user_id"
  end

  create_table "instrument_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "applied_at"
    t.uuid "applied_by_id", null: false
    t.uuid "assessment_id", null: false
    t.datetime "created_at", null: false
    t.uuid "instrument_version_id", null: false
    t.jsonb "metadata"
    t.text "notes"
    t.datetime "scored_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["applied_by_id"], name: "index_instrument_applications_on_applied_by_id"
    t.index ["assessment_id", "instrument_version_id"], name: "idx_on_assessment_id_instrument_version_id_1fc6096378"
    t.index ["assessment_id"], name: "index_instrument_applications_on_assessment_id"
    t.index ["instrument_version_id"], name: "index_instrument_applications_on_instrument_version_id"
  end

  create_table "instrument_versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.uuid "instrument_id", null: false
    t.jsonb "interpretation_rules"
    t.string "norm_name", null: false
    t.string "norm_source"
    t.integer "norm_year"
    t.jsonb "scoring_config"
    t.datetime "updated_at", null: false
    t.string "version", null: false
    t.index ["instrument_id", "version"], name: "index_instrument_versions_on_instrument_id_and_version", unique: true
    t.index ["instrument_id"], name: "index_instrument_versions_on_instrument_id"
  end

  create_table "instruments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "author"
    t.integer "category", default: 0, null: false
    t.string "code", null: false
    t.jsonb "config"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "publisher"
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_instruments_on_code", unique: true
  end

  create_table "normative_tables", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "age_range"
    t.datetime "created_at", null: false
    t.jsonb "data", null: false
    t.string "education_level"
    t.uuid "instrument_version_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["instrument_version_id", "name"], name: "index_normative_tables_on_instrument_version_id_and_name"
    t.index ["instrument_version_id"], name: "index_normative_tables_on_instrument_version_id"
  end

  create_table "patients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "birth_date"
    t.string "cpf"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "email"
    t.string "gender"
    t.jsonb "metadata"
    t.string "name", null: false
    t.text "notes"
    t.string "phone"
    t.uuid "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "cpf"], name: "index_patients_on_tenant_id_and_cpf", unique: true, where: "(cpf IS NOT NULL)"
    t.index ["tenant_id", "discarded_at"], name: "index_patients_on_tenant_id_and_discarded_at"
    t.index ["tenant_id", "name"], name: "index_patients_on_tenant_id_and_name"
    t.index ["tenant_id"], name: "index_patients_on_tenant_id"
  end

  create_table "report_templates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.boolean "default", default: false, null: false
    t.text "description"
    t.datetime "discarded_at"
    t.string "name", null: false
    t.jsonb "sections", null: false
    t.uuid "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "name"], name: "index_report_templates_on_tenant_id_and_name"
    t.index ["tenant_id"], name: "index_report_templates_on_tenant_id"
  end

  create_table "reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.datetime "discarded_at"
    t.text "final_text"
    t.datetime "finalized_at"
    t.uuid "report_template_id", null: false
    t.jsonb "sections", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id", "status"], name: "index_reports_on_assessment_id_and_status"
    t.index ["assessment_id"], name: "index_reports_on_assessment_id"
    t.index ["created_by_id"], name: "index_reports_on_created_by_id"
    t.index ["report_template_id"], name: "index_reports_on_report_template_id"
  end

  create_table "score_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "classification"
    t.datetime "computed_at", null: false
    t.datetime "created_at", null: false
    t.jsonb "details"
    t.uuid "instrument_application_id", null: false
    t.string "normative_fingerprint"
    t.uuid "normative_table_id", null: false
    t.decimal "percentile", precision: 10, scale: 2
    t.integer "position"
    t.decimal "raw_score", precision: 10, scale: 2
    t.decimal "scaled_score", precision: 10, scale: 2
    t.string "subtest_name"
    t.datetime "updated_at", null: false
    t.index ["instrument_application_id", "subtest_name"], name: "idx_on_instrument_application_id_subtest_name_d023bfb57c"
    t.index ["instrument_application_id"], name: "index_score_results_on_instrument_application_id"
    t.index ["normative_table_id"], name: "index_score_results_on_normative_table_id"
  end

  create_table "snippets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "category"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.uuid "tenant_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "category"], name: "index_snippets_on_tenant_id_and_category"
    t.index ["tenant_id"], name: "index_snippets_on_tenant_id"
  end

  create_table "tenants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cnpj"
    t.datetime "created_at", null: false
    t.string "logo_url"
    t.string "name", null: false
    t.jsonb "settings"
    t.string "subdomain", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_tenants_on_subdomain", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.datetime "discarded_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.uuid "tenant_id", null: false
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["tenant_id", "discarded_at"], name: "index_users_on_tenant_id_and_discarded_at"
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "answer_sets", "instrument_applications"
  add_foreign_key "assessments", "patients"
  add_foreign_key "assessments", "tenants"
  add_foreign_key "assessments", "users", column: "owner_id"
  add_foreign_key "audit_logs", "tenants"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "export_jobs", "reports"
  add_foreign_key "export_jobs", "tenants"
  add_foreign_key "export_jobs", "users"
  add_foreign_key "instrument_applications", "assessments"
  add_foreign_key "instrument_applications", "instrument_versions"
  add_foreign_key "instrument_applications", "users", column: "applied_by_id"
  add_foreign_key "instrument_versions", "instruments"
  add_foreign_key "normative_tables", "instrument_versions"
  add_foreign_key "patients", "tenants"
  add_foreign_key "report_templates", "tenants"
  add_foreign_key "reports", "assessments"
  add_foreign_key "reports", "report_templates"
  add_foreign_key "reports", "users", column: "created_by_id"
  add_foreign_key "score_results", "instrument_applications"
  add_foreign_key "score_results", "normative_tables"
  add_foreign_key "snippets", "tenants"
  add_foreign_key "users", "tenants"
end
