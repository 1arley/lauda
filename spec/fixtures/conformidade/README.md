# Exemplos de conformidade

Cada JSON deve vir de um exemplo trabalhado em manual autorizado. O campo `source`
registra manual, edição e página; o exemplo não deve ser preenchido com valores
inventados. Não há fixture de instrumento enquanto não houver uma fonte autorizada.

O JSON precisa incluir `source`, `normative_table`, `answer_sets` e `expected`.
Cada item de `answer_sets` tem `subtest_name`, `position` e `answers`; cada item
de `expected` tem `subtest_name`, `raw_score` e `scaled_score`.

`patient_birth_date` pode ser substituído por `patient_age` quando o exemplo do
manual informar somente a idade.
