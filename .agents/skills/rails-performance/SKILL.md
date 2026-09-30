---
name: rails-performance
description: Use when a Rails page or endpoint is slow, when writing a query, or when reviewing code that touches the database in a loop. Covers N+1 detection, counter caches, includes vs preload vs eager_load, batching, pagination, and the caching layers.
---

# Rails performance

From the [Rails guides](https://guides.rubyonrails.org/), plus the performance cops that
large codebases ([GitLab](https://gitlab.com/gitlab-org/gitlab)) enable on purpose —
those exist because each one was a real incident.

## N+1 queries — the default failure mode

The most common Rails performance bug, and the easiest to introduce without noticing.
A view loop over a relation, touching an association per record, is N+1 by default.

```ruby
@orders.each { |o| o.line_items.count }   # 1 + N queries
```

**Detect it, do not guess.** In development:

```ruby
ActiveRecord::Base.logger = nil
# or in console
ActiveRecord::Base.connection.enable_query_log!
# run the code, then:
ActiveRecord::Base.connection.cached_query_count
```

Or use `Bullet` (the `bullet` gem) in development, which raises on the offending line.
`rack-mini-profiler` gives per-request totals.

### Fix, in order of preference

1. **Counter cache** — best when you only need the number. Add a column, declare
   `belongs_to :parent, counter_cache: :children_count`, backfill, and maintain it in
   a background job. This removes the query entirely and forever.
2. **`includes` / `preload`** — when you need the associated records.
3. **`.select` with a join and aggregate** — when you need the count grouped across a
   relation that is already being joined.

```ruby
Order.select(:id, :total).left_joins(:line_items)
     .group('orders.id')
     .select('COUNT(line_items.id) AS line_items_count')
```

### `includes` vs `preload` vs `eager_load`

- `includes` — let Rails decide. One query with a LEFT JOIN, or two queries. This is
  almost always the right default.
- `preload` — always separate queries. Use when the association is filtered or the join
  would multiply rows.
- `eager_load` — force a single joined query. Use when you must select columns from the
  joined table in one round trip.

**`strict_loading`** is the strongest fix: it raises in development if a lazy-loaded
association is touched outside an `includes`, converting a silent N+1 into an immediate,
located error. Consider it on hot endpoints.

## Queries

- **`pluck` over `select(...).map`** when you only need columns — it skips model
  instantiation and any overridden attribute methods. `pick(:id)` over
  `pluck(:id).first`.
- **`find_each` / `find_in_batches` for anything large.** `Model.all.each` loads the
  entire table into memory. Batches default to 1000.
- **Add indexes for what you filter and sort by**, including composite order matching
  the query: `(tenant_id, status)` is not the same as `(status, tenant_id)`.
- **`count` vs `exists?`** — `exists?` runs `SELECT 1 ... LIMIT 1`; do not load records
  to test for presence.
- **`find_or_create_by` is not atomic.** Under concurrency two processes can both create.
  Use `create_or_find_by` (relying on a unique index to reject the loser), or rescue
  `ActiveRecord::RecordNotUnique`.
- Avoid `pluck` without a limit on user-supplied or unbounded relations.
- Prefer `where.associated` / `where.missing` over hand-written subqueries.
- On large tables, `find_each` respects the primary key order; an `order` on the relation
  is ignored with a warning unless you pass `error_on_ignore: true`.

## Pagination

Never render an unbounded relation. The tools differ by framework; the rule does not —
paginate every index and every potentially-large collection, and return the total count
separately rather than loading it.

Note that `count` on a large table is itself a full scan. Cache it, or approximate, if
it appears on every request.

## Caching

Layered, cheapest first:

1. **Database indexes** — usually the whole win.
2. **Fragment caching** in views, keyed by the data that varies. Invalidate
   explicitly on write; prefer version/updated_at keys over manual expiry.
3. **`Rails.cache`** for expensive computed values, with a real expiry policy.
4. **HTTP caching** (`stale?`, `fresh_when`, ETag) — the cheapest to add, and it scales
   further than any server-side cache.

Use the cache store consistently. Memcached evicts; Redis does not — a dev/prod mismatch
here produces bugs that only appear in production.

## Background work

Move slow work off the request: mail, PDF generation, exports, third-party calls. Give
jobs an explicit queue, make them idempotent (they will retry), and keep them cheap by
passing ids rather than objects.

## What to actually do

Measure first. `rails console` plus `ActiveSupport::Notifications`, a query log, or
`rack-mini-profiler` will tell you where the time goes. Optimizing an unmeasured query
is how you end up with a cache that costs more than it saves.
