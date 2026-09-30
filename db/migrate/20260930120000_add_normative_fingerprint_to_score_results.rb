class AddNormativeFingerprintToScoreResults < ActiveRecord::Migration[8.1]
  def change
    add_column :score_results, :normative_fingerprint, :string
  end
end
