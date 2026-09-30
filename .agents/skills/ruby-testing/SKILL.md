---
name: ruby-testing
description: Use when writing or debugging tests in a Ruby project - RSpec or Minitest. Covers test design, factories vs fixtures, isolation, the shared-state traps that cause order-dependent failures, and how to debug a test that fails for a non-obvious reason.
---

# Ruby testing

Framework-agnostic principles, with RSpec and Minitest syntax side by side. Verify
which framework the project uses before writing anything — the two have similar APIs
with critical naming differences.

## Minitest vs RSpec divergence

| Concept | Minitest | test-unit |
| --- | --- | --- |
| Exception | `assert_raises` (plural) | `assert_raise` (singular) |
| Throw | `assert_throws` (plural) | `assert_throw` (singular) |
| Negation | `refute_*` | `assert_not_*` |
| Path exists | `assert_path_exists` | `assert_path_exist` |

`test-unit` aliases the minitest names, so minitest syntax works in test-unit but not
the reverse. RSpec is a third ecosystem entirely — `expect(x).to eq(y)`, never
`assert_equal`.

## Test design

- **One behavior per test.** The name should state the behavior, not the method.
  A test that asserts three unrelated things fails for one reason at a time, and the
  other two assertions never run.
- **`aggregate_failures` / grouped assertions** are the exception, not the rule: use
  them when several assertions describe *one* outcome.
- **Test behavior, not implementation.** Asserting that a private method was called
  makes the test fail on a harmless refactor.
- **Prefer real behavior over mocks.** Mock only what crosses a process boundary
  (HTTP, payment, email). A test suite full of mocks tests the mocks.
- Give setup only what the test needs. Extra setup hides which input actually mattered.
- Name the context for the condition: `context "when the record is archived"`, not
  `context "case 3"`.

## Isolation — the order-dependent failure

The most common real test bug is state leaking between examples.

- **Use the framework's isolation primitive first** (`use_transactional_tests` /
  `use_transactional_fixtures` in Rails, DatabaseCleaner otherwise). It is faster and
  less error-prone than manual truncation.
- If you enable it, understand its one real weakness: **it cannot roll back a test that
  commits its own transaction or talks to a second process** (a thread, a subprocess, a
  job worker). Those escape the outer transaction and leak into later examples. Either
  disable transactional tests for that suite or clean up explicitly.
- Random order (`config.order = :random`) turns hidden inter-test dependencies into
  immediate failures instead of rare, unreproducible ones. Turn it on.
- Freeze the clock and seed when a test depends on time or randomness. A test that
  passes on the 1st of the month and fails on the 2nd is broken.

## Factories vs fixtures

- **Factories** for most cases: readable, overridable, self-documenting. Use traits for
  variation instead of one factory per variant.
- **Fixtures** when you want speed or referential integrity across many records, or to
  express data that is deliberately weird.
- **Sequences on every unique field.** `Faker::Name.name` repeats and collides; a
  uniqueness validation will then fail *randomly depending on the seed*, which is the
  worst kind of flake. `sequence(:email) { |n| "user#{n}@example.com" }` fixes it
  permanently. Never "simplify" a sequence back to Faker.
- **Do not create deep graphs in a factory.** Associations should be minimal; a
  `create(:order)` that transitively builds a customer, an address, and three line items
  makes the actual setup invisible. `build_stubbed` for speed when persistence is
  irrelevant.
- **No logic in factories** (conditionals, computed attributes). They make failures
  unreadable and hide what the test depends on.

## Integration and request specs

- Test the boundary, not the internals: for HTTP, assert status, redirect target, and
  the specific content that matters — not the whole body.
- Assert **negation** where it is the actual risk. If data from another account must
  not appear, assert its absence explicitly; a test that only checks presence passes
  even when the leak exists.
- Auth setup belongs in a `before` block, not in each example.

## When a test fails unexpectedly

Work outward from the cause rather than re-running:

1. **Leaked state from another test** → run that file alone; if it passes, run with
   `--seed` variations or `--order random`.
2. **Time or locale** → freeze the clock; check date formatting, time zones, and
   `I18n` locale leakage between tests.
3. **Random data** → a sequence or seed problem, see above.
4. **Global config mutated by a previous test** → an initializer or `around` hook that
   does not restore what it changed.
5. **The framework's isolation is not covering this case** → see the transaction note
   above.

## Coverage

A coverage number is a signal, not a gate — a test suite can hit 100% while asserting
nothing. Prefer mutation testing where the project has it, or at minimum read the
uncovered lines and decide deliberately. If a project sets a coverage threshold, treat
it as a hard gate.
