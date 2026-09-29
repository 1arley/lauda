# Contexto do domínio

## Aplicação de Instrumento

Liga uma Avaliação a uma versão específica de instrumento. Mantém as respostas registradas, os resultados calculados e o estado do ciclo (`pending`, `answered`, `scored` ou `error`).

O cálculo usa somente uma Tabela Normativa vinculada à mesma versão aplicada.

## Exportação de Laudo

Representa a geração assíncrona de um PDF para um Laudo. O registro `ExportJob` acompanha os estados (`pending`, `processing`, `completed` ou `failed`) e é dono do artefato; cada download verifica a autorização do tenant.

## Contexto da Requisição

Agrupa usuário, tenant e IP durante uma requisição. O contexto é atribuído no controller base e limpo ao final; requisições anônimas não herdam o tenant anterior.
