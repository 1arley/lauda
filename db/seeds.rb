Rails.logger.debug '🌱 Seeding database...'

# Create demo tenant
tenant = Tenant.find_or_create_by!(subdomain: 'demo') do |t|
  t.name = 'Clínica Demo'
  t.cnpj = '12.345.678/0001-90'
end
Rails.logger.debug { "  ✓ Tenant: #{tenant.name}" }

ActsAsTenant.current_tenant = tenant

# Create admin user
admin = User.find_or_create_by!(email: 'admin@laudos-saas.com') do |u|
  u.name = 'Administrador'
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.tenant = tenant
  u.role = :tenant_admin
  u.confirmed_at = Time.current
end
Rails.logger.debug { "  ✓ Admin: #{admin.email}" }

# Create professional user
professional = User.find_or_create_by!(email: 'profissional@laudos-saas.com') do |u|
  u.name = 'Dra. Maria Silva'
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.tenant = tenant
  u.role = :professional
  u.confirmed_at = Time.current
end
Rails.logger.debug { "  ✓ Professional: #{professional.email}" }

# Create instruments
instruments_data = [
  { code: 'WISC-IV', name: 'Escala Wechsler de Inteligência para Crianças - 4ª Edição', category: :cognitive,
    author: 'David Wechsler' },
  { code: 'WAIS-III', name: 'Escala Wechsler de Inteligência para Adultos - 3ª Edição', category: :cognitive,
    author: 'David Wechsler' },
  { code: 'SRS-2', name: 'Escala de Responsividade Social - 2ª Edição', category: :behavioral,
    author: 'John Constantino' },
  { code: 'BPA-2', name: 'Bateria Psicológica para Avaliação da Atenção - 2ª Edição', category: :attention,
    author: 'Fabiano & Digiacomo' },
  { code: 'RAVLT', name: 'Teste de Aprendizagem Auditivo-Verbal de Rey', category: :memory, author: 'André Rey' }
]

instruments_data.each do |data|
  instrument = Instrument.find_or_create_by!(code: data[:code]) do |i|
    i.name = data[:name]
    i.category = data[:category]
    i.author = data[:author]
  end

  version = InstrumentVersion.find_or_create_by!(instrument: instrument, version: '1.0') do |v|
    v.norm_name = 'Padrão brasileiro'
    v.norm_year = 2013
  end

  NormativeTable.find_or_create_by!(instrument_version: version, name: 'Padrão geral') do |nt|
    nt.data = {
      scores: (0..20).map do |raw|
        {
          min: raw, max: raw,
          scaled: (raw + 1).clamp(1, 19),
          percentile: [(raw * 4.5), 0.1].max,
          classification: if raw < 5
                            'Muito baixo'
                          elsif raw < 10
                            'Limítrofe'
                          else
                            raw < 15 ? 'Médio' : 'Superior'
                          end
        }
      end
    }
  end

  Rails.logger.debug { "  ✓ Instrument: #{instrument.code}" }
end

# Create demo patient
patient = Patient.find_or_create_by!(cpf: '12345678901', tenant: tenant) do |p|
  p.name = 'João Silva Santos'
  p.birth_date = 8.years.ago.to_date
  p.gender = 'M'
  p.email = 'responsavel@email.com'
  p.phone = '(61) 99999-9999'
end
Rails.logger.debug { "  ✓ Patient: #{patient.name}" }

# Create report template
template = ReportTemplate.find_or_create_by!(name: 'Laudo Padrão - Avaliação Cognitiva', tenant: tenant) do |t|
  t.description = 'Template padrão para laudos de avaliação cognitiva'
  t.default = true
  t.sections = [
    { 'title' => 'Identificação',
      'content' => "Paciente: {{nome_paciente}}\nData de nascimento: {{data_nascimento}}\nIdade: {{idade}}\nAvaliação: {{titulo_avaliacao}}", 'section_type' => 'identification' },
    { 'title' => 'Introdução',
      'content' => 'O presente laudo refere-se à avaliação psicológica de {{nome_paciente}}, solicitada por {{solicitante}}.', 'section_type' => 'introduction' },
    { 'title' => 'Procedimentos',
      'content' => "Foram aplicados os seguintes instrumentos:\n{{instrumentos_aplicados}}", 'section_type' => 'procedure' },
    { 'title' => 'Resultados', 'content' => '{{resultados_detalhados}}', 'section_type' => 'results' },
    { 'title' => 'Conclusão', 'content' => '{{conclusao}}', 'section_type' => 'conclusion' },
    { 'title' => 'Recomendações', 'content' => '{{recomendacoes}}', 'section_type' => 'recommendations' }
  ]
end
Rails.logger.debug { "  ✓ Template: #{template.name}" }

# Create snippets
snippets_data = [
  { title: 'Conclusão - Desempenho Médio',
    content: 'Os resultados obtidos indicam desempenho dentro da faixa esperada para a idade e escolaridade, não sendo observadas dificuldades significativas nas funções avaliadas.', category: 'conclusion' },
  { title: 'Conclusão - Desempenho Baixo',
    content: 'Os resultados indicam desempenho abaixo do esperado para a idade e escolaridade, sugerindo a necessidade de investigação mais aprofundada e/ou intervenção.', category: 'conclusion' },
  { title: 'Recomendação - Acompanhamento',
    content: 'Recomenda-se acompanhamento psicológico com periodicidade semestral para monitoramento do desenvolvimento.', category: 'recommendation' },
  { title: 'Recomendação - Encaminhamento',
    content: 'Recomenda-se encaminhamento para avaliação neuropsicológica completa para melhor compreensão do perfil cognitivo.', category: 'recommendation' }
]

snippets_data.each do |data|
  Snippet.find_or_create_by!(title: data[:title], tenant: tenant) do |s|
    s.content = data[:content]
    s.category = data[:category]
  end
end
Rails.logger.debug { "  ✓ #{snippets_data.size} snippets" }

# Create demo assessment
assessment = Assessment.create!(
  tenant: tenant,
  patient: patient,
  owner: professional,
  title: 'Avaliação Cognitiva - Controle de Rotina',
  status: :draft,
  context: 'Avaliação solicitada para reavaliação anual.'
)
Rails.logger.debug { "  ✓ Assessment: #{assessment.title}" }

Rails.logger.debug ''
Rails.logger.debug '🎉 Seed complete!'
Rails.logger.debug ''
Rails.logger.debug '  Login: admin@laudos-saas.com / password123'
Rails.logger.debug '  ou: profissional@laudos-saas.com / password123'
