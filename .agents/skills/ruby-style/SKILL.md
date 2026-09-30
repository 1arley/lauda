---
name: ruby-style
description: Use when writing or reviewing Ruby code, or when a style question comes up. Covers idiom, naming, method structure, exceptions, and collections - plus the cases where mainstream style guides disagree with each other and how to resolve the conflict.
---

# Ruby style and idiom

Distilled from the [Shopify Ruby Style Guide](https://github.com/Shopify/ruby-style-guide)
(a decade of practice, written to be RuboCop-enforceable), cross-checked against
[GitLab](https://gitlab.com/gitlab-org/gitlab) and
[Discourse](https://github.com/discourse/discourse) conventions.

## Resolve conflicts by precedence

Major guides contradict each other. When they do, this order wins:

1. **The project's own linter config** (`.rubocop.yml` and whatever it inherits). It is
   executable, it gates CI, and it is what the team actually agreed to.
2. **The project's existing surrounding code.** Match the file you are in.
3. **This guide**, for anything the linter does not cover.

Do not "correct" a project to match a style guide. If the project uses single quotes
and disables `frozen_string_literal`, that is a decision someone made; changing it is
an unrelated diff that will fail their lint gate.

## Method structure

- **Single Level of Abstraction Principle** — all lines in a method at one level. Mixing
  a query, a `map`, and a string build in one method is the violation. This is the most
  commonly ignored rule in the guide and the most valuable one.
- **Guard clauses** over nested conditionals. Nesting is the usual symptom of a method
  doing two things.
- **No more than three levels of block nesting.**
- **No defensive programming** for cases that cannot occur. Every `nil` guard needs a
  justification. Guards against impossible states are untestable and rot.
- **Do not mutate arguments.** Prefer a functional style.
- **Prefer keyword arguments** over an options hash when there are two or more params.
- No monkeypatching. No `send` (use `public_send`, which respects visibility).

## Exceptions

- `raise SomeError, "message"` — class and message as two arguments, never an instance
  (`raise SomeError.new("m")` cannot take a backtrace).
- **No bare rescue modifier** (`read_file rescue nil`). It swallows syntax errors and
  everything else. Use a method-body `rescue` clause.
- Never rescue `Exception` — a blind `rescue` rescues `StandardError`, which is what
  you almost always want.
- Avoid empty `rescue`. If you rescue, log or re-raise or handle specifically.
- Do not return from an `ensure` block; it silently discards the in-flight exception.
- Prefer standard-library exceptions over inventing new ones until the domain genuinely
  needs a new vocabulary.
- Name the exception variable `error`, not `e`.

## Naming

- `snake_case` for methods/variables/files, `CamelCase` for classes/modules, keeping
  acronyms uppercase (`HTTPClient`, not `HttpClient`).
- Predicates end in `?` and return real booleans. Never `is_` prefix, never `get_`
  prefix.
- `!` suffix only where a non-bang counterpart exists. It marks the more dangerous
  version (`save` returns a boolean, `save!` raises).
- No class variables (`@@`) — they leak across the inheritance tree.
- One class or module per file, filename matching the constant.
- No magic numbers; extract to a named constant.
- `attr_reader` / `attr_accessor`, never bare `attr`.

## Collections and strings

- Prefer `map` over `collect`, `find` over `detect`, `select` over `find_all`, `size`
  over `length`.
- Prefer literal `[]` / `{}` over `Array.new` / `Hash.new`.
- **`Hash#fetch` when the key should be present.** A typo'd `heroes[:supermman]` silently
  returns `nil` and fails far from the cause; `fetch` raises at the right line. Use a
  default value for the common fallback case.
- Shorthand hash syntax when all keys are symbols; hash rockets otherwise.
- Trailing comma in multi-line literals.
- Prefer interpolation or `format` over `+` concatenation.
- `sub` when replacing one occurrence, `gsub` only when you mean all of them.
- `^`/`$` match lines; `\A`/`\z` match string bounds. For validation and untrusted
  input, `\A`/`\z` is almost always what you meant — `"some injection\nusername"` passes
  a `^username$` check.
- Non-capturing groups `(?:...)` when you do not use the capture.
- Prefer `Time` over `DateTime`; `Time.iso8601` over `Time.parse` for known-format input.

## Ruby 3.x features worth using

- Pattern matching (`case/in`) for multi-branch structured dispatch.
- Endless methods for genuine one-liners: `def index? = false`.
- Hash shorthand `{x:, y:}` and `it` in block params.
- Safe navigation `&.` — but do not use it to paper over a `nil` that signals a bug.

## Comments and complexity

Comment **why**, not what. Keep them in sync with the code. The highest-value comments
record a constraint or a decision whose rationale is not visible in the code — e.g. why
a string helper that returns punctuated input unchanged, so the next person does not
"fix" it.

Treat test code with the same care as production code. Prefer one behavior per test; use
`aggregate_failures` when several assertions describe one outcome.

## Before you finish

```bash
bundle exec rubocop
bundle exec rubocop -a    # safe autocorrects only
```

Run the project's linter, not this guide. The linter is the gate.
