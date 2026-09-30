---
name: rails-architecture
description: Use when deciding where code belongs in a Rails app, when adding a service or model behavior, or when a controller is growing. Covers fat-model-thin-controller without the God object trap, when to extract a service, POROs vs ActiveRecord, and background jobs.
---

# Rails architecture

The core tension in Rails: the convention "fat models, thin controllers" is correct
about controllers and frequently wrong about models. Both failure modes are common.

## Where code belongs

| Change in shape | Put it in |
| --- | --- |
| One model, a few fields | A scope or a model method |
| Behavior involving one model, no others | A model method or a PORO |
| Behavior spanning 2+ models | A service object |
| Behavior that must run outside a request | A background job |
| Pure computation, no persistence | A PORO or value object |
| Authorization decision | A policy object |

**Thin controllers** is right. A controller should: authorize, load, call one other
object, and respond. When a controller grows a conditional, a loop, or business rules,
that logic belongs elsewhere.

**Fat models** is where it goes wrong. A model holding rules for every bounded context
is a God object: every feature touches it, merge conflicts concentrate there, and nothing
can be deleted safely. The failure is not size, it is *responsibilities*.

## Service objects

Extract when the logic spans multiple models, is reused from more than one entry point
(controller, job, another service), or is independently complex enough to test alone.

The trap: a service that is just a `save` wrapper, or that takes a hash and mutates its
arguments, adds indirection without buying anything.

What a good service looks like:

```ruby
class Order::Fulfillment
  def initialize(order, warehouse)   # explicit dependencies
    @order = order
    @warehouse = warehouse
  end

  def call
    ActiveRecord::Base.transaction do
      # reserve stock, create shipment, notify
    end
  end
end
```

- Named after the operation (`FinalizeAssessment`), not `AssessmentService`.
- Owns its transaction when the operation must be atomic. Do not leave the caller to
  remember, and do not nest transactions expecting them to behave independently.
- Returns a value. Raising or returning a result object beats returning `true`/`false`.
- Do not re-fetch what it was handed.

## POROs and value objects

Not everything is ActiveRecord. A value object that is compared by its contents belongs
in a plain class, not a table with four columns. Use a PORO when the object has no
identity, is short-lived, or would be clearer immutable.

Keep the boundary explicit — a PORO takes and returns plain values, and does not reach
into the database itself.

## Resolution by convention, not inheritance

`find_calculator` style dispatch — derive a class name from data and resolve it — is
fine and keeps a registry out of the codebase:

```ruby
class_name = type.downcase.tr('-', '_').camelize
"Report::Renderers::#{class_name}Renderer".constantize
rescue NameError
  Report::Renderers::GenericRenderer
end
```

The subtlety worth a comment: many string-manipulation helpers leave input containing
punctuation unchanged, which is why the normalization step above it has to exist at all.
That is exactly the kind of reasoning a comment should preserve.

Prefer explicit registries when the set is small and known. Convention-over-configuration
is worth the cost only when it removes real duplication.

## Background jobs

- Jobs **will** retry and **may** run twice. Make them idempotent, or accept duplicates
  and make the effect idempotent.
- Pass ids, not records. A record serialized into a job is a stale snapshot.
- Give each job type its own queue, so a slow one does not block password resets.
- Do not assume request-scoped state exists. Thread-locals, the current user, and the
  database connection are not available as they are in a controller.
- Set an explicit `retry_on` policy. The default retries every error 5 times, which
  usually turns a permanent failure into a slow one.

## Fat controller, thin service, or model?

A quick test for a model method: does it need another model? If yes, it is probably a
service. Does it need the database? If no, it is a PORO. Does it change with each
request's authorization? Then it is a policy.

## Multi-tenancy

If a project is multi-tenant, the scoping is a correctness property, not a feature, and
the framework usually does not enforce it. Confirm the actual configuration — some
libraries raise when a tenant is missing, others silently return every tenant's rows.
See the `multi-tenant-rails` skill for the full checklist.

## Background jobs and schema

Keep migrations reversible and safe: add columns as nullable, backfill in batches, then
add the constraint. Never edit an already-applied migration. A migration that locks a
large table will take the app down.
