module Pdf
  class ReportGenerator
    def initialize(report)
      @report = report
      @assessment = report.assessment
      @patient = @assessment.patient
      @tenant = @assessment.tenant
      @template = report.report_template
    end

    def generate
      pdf = Prawn::Document.new(page_size: 'A4', margin: 50)

      render_header(pdf)
      render_patient_info(pdf)
      render_sections(pdf)
      render_instrument_results(pdf)
      render_footer(pdf)

      pdf.render
    end

    private

    def render_header(pdf)
      pdf.font_size(18) do
        pdf.text @tenant.name, style: :bold, align: :center
      end

      if @tenant.cnpj.present?
        pdf.font_size(9) do
          pdf.text "CNPJ: #{@tenant.cnpj}", align: :center
        end
      end

      pdf.move_down 10
      pdf.stroke_horizontal_rule
      pdf.move_down 5
    end

    def render_patient_info(pdf)
      pdf.font_size(12) { pdf.text 'Laudo de Avaliação Psicológica', style: :bold }
      pdf.move_down 5

      info = [
        ['Paciente:', @patient.name],
        ['Data de Nascimento:', @patient.birth_date&.strftime('%d/%m/%Y')],
        ['Idade:', @patient.age ? "#{@patient.age} anos" : nil],
        ['Avaliação:', @assessment.title],
        ['Data:', @assessment.conducted_at&.strftime('%d/%m/%Y')],
        ['Profissional:', @assessment.owner.name]
      ].compact

      pdf.table(info, column_widths: [120, 380]) do
        style(:all, borders: [], padding: 3)
        column(0).font_style = :bold
      end

      pdf.move_down 15
    end

    def render_sections(pdf)
      @report.sections.each do |section|
        pdf.font_size(13) { pdf.text section['title'], style: :bold }
        pdf.move_down 3
        pdf.font_size(11) { pdf.text section['content'] || '', leading: 4 }
        pdf.move_down 10
      end
    end

    def render_instrument_results(pdf)
      applications = @assessment.instrument_applications.includes(:score_results, :instrument_version)

      return if applications.empty?

      pdf.start_new_page
      pdf.font_size(13) { pdf.text 'Anexo: Resultados dos Instrumentos', style: :bold }
      pdf.move_down 10

      applications.each do |app|
        pdf.font_size(11) { pdf.text app.instrument_version.display_name, style: :bold }
        pdf.move_down 5

        results = app.score_results.ordered
        next if results.empty?

        data = [%w[Subteste Bruto Padronizado Percentil Classificação]]
        results.each do |r|
          data << [
            r.subtest_name,
            r.raw_score&.to_s,
            r.scaled_score&.to_s,
            r.percentile&.to_s,
            r.classification
          ].compact
        end

        pdf.table(data, column_widths: [150, 60, 80, 70, 140]) do
          row(0).font_style = :bold
          row(0).background_color = 'EEEEEE'
        end

        pdf.move_down 10
      end
    end

    def render_footer(pdf)
      pdf.number_pages 'Página <page> de <total>',
                       at: [pdf.bounds.left, 0],
                       size: 8

      pdf.move_up 30
      pdf.font_size(8) do
        pdf.text "Documento gerado em #{Time.current.strftime('%d/%m/%Y %H:%M')}"
        pdf.text "Lauda - #{@tenant.name}"
      end
    end
  end
end
