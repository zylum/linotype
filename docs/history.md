---
layout: default
title: History
---

# History

How Linotype emerged from real-world challenges with AI-assisted development.

**Note:** This is an experiment. The author finds Linotype useful and beneficial, but is unsure if others will. Feedback is welcome.

## The Scale-of-Contribution Apocalypse

### I Lived This

Someone once described the risk of agentic AI engineering as a thought experiment: imagine an army of very smart graduate engineers, with mixed experience, given production access, arriving on Monday to start work.

For the author, that wasn't a thought experiment. It was a cautionary tale from a first serious engineering role. The codebase was a mission-critical financial system: complex, monolithic, evolved mess. No branching, few source-control tools, many subtle nuances. Built in 4GL LANSA on AS/400 mainframes.

The company hired straight from universities—varied backgrounds, smart future consultants—and had them billable on client sites within weeks: finding requirements and **committing production code**.

That was the **scale-of-contribution apocalypse**: new people contributing faster than they could understand the system. Complexity grew. Misunderstandings multiplied. The system needed safeguards.

What wasn't obvious then: that experience was building the mental model later needed for AI agents. The same patterns that kept a complex system coherent with dozens of junior engineers would become Linotype—a way to keep products coherent when AI agents contribute faster than humans can manually coordinate.

### Who Is This For?

Linotype is for teams where **contribution velocity outpaces understanding**:

- **Solo devs** using AI agents who want to keep coherence as their product grows
- **Small teams** (2–5 people) mixing human and AI contributions
- **AI-heavy orgs** where agents do most implementation work
- **Anyone** who's felt docs fall behind, decisions get lost, or handoffs break down

### Lessons Learned (The Important Bit)

Those patterns kept a complex system coherent with dozens of junior engineers. They're the foundation of Linotype.

#### Capabilities Over Change

**The failure:** We tried to reason about diffs, tickets, and patches. Nobody could answer "what does the system actually do?" We shipped changes without understanding their impact on capabilities.

The codebase was too complex for any one person to hold in their head. Managing change didn't tell us what the system could do. We had to focus on **capabilities**—what the system lets users accomplish—not just track changes.

**AI connection:** Agents are very good at change and very bad at preserving intent. They'll happily refactor your auth system without realising it breaks the "reset password" capability.

→ **Capabilities are the only stable abstraction when contributors scale faster than understanding.**

#### Modules Over Files

We tamed complexity with module conventions. Tables for agreements started with `A`; assets with `I`; change files with `J`. Asset drawdown: `IASSDRW`; customer billing address: `C3PYBIL`.

The language didn't support real modularity, scoping, or inheritance—so the team invented it. **Modules were social contracts, not technical ones.**

**AI connection:** Slugs are like cultural modularity for AI. You can't enforce boundaries in prompts, but you can set conventions that agents learn to respect.

#### Module Owners Over Collective Discovery

System knowledge wasn't enough; we needed people who knew how to apply it. More experienced "module owners" emerged and were appointed. Given a change, they knew the best way to deliver it.

Module owners weren't gatekeepers—they were **accelerators**. They gave **friendly authority** around the code so that what went in was coherent and coordinated. That **reduced fear**: juniors could move fast because someone was accountable. You weren't alone with production access; an expert would catch mistakes before they shipped.

**AI connection:** That's the origin of the [PDA and Module Architect roles](roles.html). Someone has to own the narrative, even when agents do the building.

#### Product Design Authority (PDA)

With multiple clients and empowered "teams" (consultants who could change code), each with different needs, we needed central coordination. Big changes—multi-currency, Euro adoption, Australian leasing rules—were run by one team: **Product Design Authority**.

**What went wrong without PDA:** Before PDA, teams built conflicting solutions to similar problems. Three date-handling approaches. Two incompatible currency models. Nobody knew which was "right" because nobody owned the narrative.

**PDA wasn't bureaucracy; it was narrative coherence.** PDA managed directional change—the big decisions about what we're building and why—not day-to-day builds.

**AI connection:** That maps to [slug types](slug-types.html): PDA owns Directional slugs (intent, architecture); builders own Build slugs (implementation).

#### Technical Guides & User Manuals

Each module had essential guides. Those [artefacts](structure.html) kept knowledge usable and helped new engineers understand the system. Without them, everyone rediscovered the same lessons—slowly, painfully, in production.

---

## Early Vibing (Late 2024)

Early experiments with "vibe coding" showed that a vague prompt could produce an okay website—a solid 60% answer. More iterations could get more complex sites, but progress was logarithmic. Quick wins unravelled into odd edge cases.

**The problems:**

- Context drift turned promising changes into dead ends
- Poorly supervised changes produced large, misunderstood edits
- Simple UI tweaks became long React rewrites from first principles
- Multiple rival, incompatible auth models appeared
- Unsupervised changes deleted hours of work—and the agent could then suggest learning git branches

**The realisation:** Vibe coding was the same failure mode as under-supervised graduates. Vague deltas lacked context—like giving an agile team only the user story and skipping the conversation.

The scale-of-contribution apocalypse was happening again, with AI agents instead of junior engineers.

---

## Early Rules (pre-v0.1)

Before v0, a first attempt: Cursor rules that enforced structure with folders:

```
/docs
  /capabilities
  /tech-guide
  /user-overview
  /architecture
```

Plus a "workflow": read docs before, think about impact, update documents after. Use git commits.

It helped—better structure, some documentation—but also added rigidity and maintenance cost. Hard to measure for limited use.

---

## Hello Kiro (The Thing I Didn't Know I Was Rebuilding)

**Kiro** was better. Spec-driven development could balance speed with enough context to build (closer to) right. After rapid vibing, it felt slow—but slow was steady, and steady was fast. We could still vibe tweaks and also spec what mattered.

But it still felt like we were **managing change**. A folder of specs only told half the story. You need the delta and what actually resulted. The code was the outcome; the understanding of it wasn't captured.

Where were the technical guides? Where was the discipline to maintain them? Where were the organisational safeguards that had kept the old system coherent?

---

## Linotype & Slugs

Linotype came from those experiences. The name comes from the printing technology that revolutionised typesetting by keeping type aligned and coherent at scale.

### What is a Linotype?

The **Linotype machine** (1886) revolutionised printing by casting entire lines of type at once—"line o' type"—instead of setting letters by hand. Before it, typesetters placed thousands of metal letters manually. One mistake meant resetting the line.

The Linotype kept everything **aligned and coherent**: the operator typed, the machine assembled letter moulds (matrices), cast a solid line, then returned the matrices for reuse. Automation kept consistency at scale.

**The parallel:** Just as the Linotype kept physical type aligned and reusable at scale, this operating model keeps docs, code, and decisions aligned and coherent as AI agents contribute faster than humans can manually coordinate.

### v0.1 – BMAD Inspirations

A few hours of debate on engineering and product philosophy (with ChatGPT) produced a lighter model: PDA, capabilities, context, templates, and a simple workflow for changes—the **slug**.

### v0.2 – Workflow & Build Notes

The `linotype.sh` script was added to manage transitions and to require build notes for every slug. Docs stayed in sync with reality—the main lesson from the PDA days.

### v0.3 – Roles & Slug Types

Who does what was made explicit: [roles](roles.html) (PDA, Module Architect, Builder) and [slug types](slug-types.html) (Directional vs Build) so ownership is clear.

### v0.4 – Focus, Optimise, Agent Contract

Added **focus** (loose/standard/strict) and **optimise** (speed/cost/quality) knobs in `_agent-rules.md`. Parallel workflow with **queue** stage and **worktrees**. Clear **Orchestrator/Executor** split with authoritative rules.

### v0.5 – Learning Layer

Added a **git-native learning layer** under `docs/learning/` for capturing signals, reflections, and context across the product lifecycle. Works across different apps regardless of how they run internally.

- **inbox/** — raw reflections
- **signals/** — normalised tracking with S-### IDs
- **snapshots/** — compiled context for agents
- CLI: `signal add`, `bundle snapshot`

See [v5](v5.html) for full details.

### v0.6 – LinoLoop and Releases

Added **LinoLoop** as a thin execution wrapper over executor briefs:

- `cli/linoloop <galley>` to run one galley loop
- `cli/linoloop <release-id>` to run an ordered release list from `docs/work/releases/<release-id>/galleys.txt`
- Runner fallback: if no loop runner is installed, print the brief for manual use

This keeps execution flow simple while preserving the existing galley/slug contract and agent rules.

---

## What Linotype Is (And Isn't)

**In one sentence:** Linotype recreates the organisational safeguards of large systems, but for AI agents.

### The problem

- AI agents work fast but lack context
- Docs fall behind code
- Decisions get lost
- Handoffs break down
- Coherence drifts over time

### The solution

- Small, delegable units of work (slugs)
- Docs updated as you go
- Build notes that capture what shipped
- Clear roles and ownership
- Proof over promises

### What Linotype is not

- **Not a framework** — No code to install, no dependencies
- **Not a methodology** — No certification, consultants, or 12-step program
- **Not a silver bullet** — Won't fix bad architecture or unclear product vision
- **Not "just better prompting"** — This is about organisational structure, not prompt engineering

---

[Getting started →](getting-started.html) · [How to use](how-to-use.html) · [Changelog](changelog.html)
