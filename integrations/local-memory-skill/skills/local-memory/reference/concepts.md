# The World Memory model

Local Memory is built on a four-level knowledge hierarchy. Knowledge enters as raw
observation and is promoted toward durable understanding through validation. This
file explains the model the tools operate on; for tool syntax see `mcp.md`, `cli.md`,
or `rest.md`.

## Knowledge levels

| Level | Name | Weight range | Lifespan | Meaning |
|-------|------|--------------|----------|---------|
| L0 | Observation | 0.0–1.0 | Ephemeral | Raw intake meant to be processed, not kept as-is |
| L1 | Learning | 1.0–5.0 | Volatile | A candidate insight synthesized from observations |
| L2 | Pattern | 5.0–9.0 | Durable | A generalization validated across multiple learnings |
| L3 | Schema | 9.0–10.0 | Permanent | A theoretical framework that explains patterns |

`weight` is the confidence/durability score within a level. It rises on successful
validation and falls on failed validation or decay.

## The lifecycle

```
observe ──► reflect ──► evolve(validate) ──► evolve(promote) ──► relate
  (L0)       (L0→L1)      (weight up)         (L1→L2→L3)        (link graph)
                │
                └─ question ──► resolve   (track and close knowledge gaps)
```

1. **observe** — record intake at L0 (or directly at a higher level when you already
   know its standing). Capture context and source, not just the bare fact.
2. **reflect** — synthesize one or many L0 observations into L1 learnings. This is
   where raw notes become reusable insight.
3. **evolve(validate)** — record that a learning held up (`success=true`) or failed
   (`success=false`). Success raises weight; failure lowers it.
4. **evolve(promote)** — advance a memory to the next level once it has earned it.
   Promotion can also happen automatically when thresholds are met.
5. **relate** — connect memories with typed edges so the graph encodes structure, not
   just isolated facts.

### Promotion thresholds (defaults)

Promotion is gated on validation count, weight, and confidence (all configurable):

- **L1 → L2 (Learning → Pattern):** ≥3 validations, weight ≥5.0, confidence ≥0.80
- **L2 → L3 (Pattern → Schema):** ≥5 validations, weight ≥9.0, confidence ≥0.90

Set `auto_promote: true` on `observe` to let a memory advance automatically once it
clears the thresholds.

## Decay and maintenance

Knowledge that is never re-validated goes stale. `evolve(operation="decay")` reduces
the weight of memories untouched for `threshold_days` (default 30); memories that
fall below the archival threshold (~0.5) become candidates for archival. Always
preview with `dry_run=true` before applying.

Scheduled decay is **disabled by default** (`evolution.decay_enabled: false`). When
enabled in daemon mode, it runs on an interval (default: every 24h, 30-day threshold).

Run `validate` periodically to check graph integrity — orphaned references,
relationship cycles, weight/level mismatches, stale questions, broken promotion
chains, duplicate edges. It is read-only by default (`dry_run=true`); applying fixes
requires both `dry_run=false` **and** `confirm_auto_fix=true`.

## Contradiction detection

When new knowledge conflicts with existing knowledge, Local Memory can detect it
automatically. Detection layers (all must pass) include shared core vocabulary, same
domain, negation asymmetry, opposing word pairs (always/never, increases/decreases),
and the opposing terms applying to the same subject.

Detected contradictions surface in `bootstrap` output and as `question`s of type
`contradiction`. Resolve them with `resolve` rather than deleting one side — this
keeps the reasoning trail intact.

## Questions: tracking what you don't know

Questions make epistemic gaps first-class:

- `epistemic_gap` — something you know you don't know and should investigate
- `contradiction` — a detected conflict between memories
- `prediction_failure` — a prediction that turned out wrong (a learning signal)

Record with `question`, list pending ones with `questions`, and close them with
`resolve`. Resolution types:

| Type | Use when |
|------|----------|
| `answered` | An epistemic gap now has an answer |
| `a_supersedes` / `b_supersedes` | One memory is correct, the other outdated |
| `conditional` | Both correct under different conditions |
| `merged` | Synthesize a new memory from both (set `create_synthesis=true`) |
| `context` | Different contexts; no real conflict |
| `invalidated` | Both memories were wrong |

## Relationship types

`relate` connects two memories with a typed, weighted (0.0–1.0) edge:

| Type | Meaning |
|------|---------|
| `references` | General reference (default) |
| `contradicts` | Conflicting information |
| `expands` | Elaborates on / builds upon |
| `similar` | Related content |
| `sequential` | Temporal or logical order |
| `causes` | Causal link |
| `enables` | Prerequisite / dependency |

Two ways to find connections:

- **`find_related`** — hybrid of explicit graph edges + vector similarity, seeded by a
  memory ID. Returns related memories with level, connection strength, similarity.
- **`map_graph`** — traverses *explicit* `relate` edges only (no similarity overlay),
  returning nodes/edges/distances.
- **`discover`** — surfaces *latent* relationship candidates across the base without
  needing IDs; useful after a batch of observations.

## Reasoning over knowledge

Once patterns (L2) and schemas (L3) exist, three tools reason from them:

- **`predict`** — given a context/action, predict likely outcomes from patterns/schemas.
- **`explain`** — trace the causal path between two states through `causes`/`enables` edges.
- **`counterfactual`** — "what if" reasoning over an alternative condition.

Each accepts `use_ai=true` for richer, LLM-enhanced output (requires a local model;
see `setup.md`).

## Domains and sessions

- **Domain** — a topical bucket (`programming`, `ai-research`, a project name). Set it
  on `observe`; filter by it on `search`/`bootstrap`. Rename in bulk with
  `migrate_domain` (preview with `dry_run` first).
- **Session** — groups memories from one working context. `session_filter_mode`
  controls retrieval scope: `all` (cross-session, the usual choice), `session_only`,
  or `session_and_shared`. Auto-generated by default (commonly from git branch +
  directory).

## Token optimization

Every read tool supports `response_format` to trade detail for tokens:

| Format | Roughly | Use for |
|--------|---------|---------|
| `detailed` | 100% | When you need full content |
| `summary` | ~50% | Truncated content, balanced |
| `concise` | ~30% | Essential fields — a good default |
| `ids_only` | ~5% | You only need IDs to fetch later |

`search` additionally offers `format: "intelligent"` with a `max_tokens` budget that
auto-optimizes the payload, and named `response_template`s (e.g. `agent_minimal`,
`analysis_ready`) for common agent use cases.
