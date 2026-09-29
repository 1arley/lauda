class InstrumentVersion < ApplicationRecord
  belongs_to :instrument
  has_many :normative_tables, dependent: :destroy
  has_many :instrument_applications, dependent: :destroy

  validates :version, presence: true, uniqueness: { scope: :instrument_id }
  validates :norm_name, presence: true

  # Instrumentos ainda sem configuração de pontuação usam esta grade padrão,
  # para que o lançamento de respostas nunca quebre por coluna nil.
  DEFAULT_SCORING_CONFIG = { 'subtests' => ['Subteste 1', 'Subteste 2', 'Subteste 3'], 'items_per_subtest' => 5 }.freeze

  scope :active_versions, -> { where(active: true) }

  def scoring_config
    value = super
    value.presence || DEFAULT_SCORING_CONFIG
  end

  def display_name
    "#{instrument.name} v#{version} (#{norm_name})"
  end
end
