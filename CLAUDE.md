# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal notes workspace of Andre Junges (`ajunges`). **Not a code project** — no build system, no tests, no package manager, no source code. Only markdown. Do not search for `package.json`, do not suggest linters, CI, or test runners.

Current contents: [claude-code-desktop-performance.md](claude-code-desktop-performance.md) — a personal pt-BR reference guide on optimizing Claude Code Desktop on macOS (context management, memory, workflows, subagents, hooks, env vars, anti-patterns). [README.md](README.md) is a single-line placeholder.

## Language

**Respond in Brazilian Portuguese (pt-BR) by default.** All existing content and the user's own prompts are in pt-BR. Keep ecosystem/technical terms in English (prompt, context window, subagent, hook, skill, worktree, etc.) — they appear untranslated in the existing guide and that is the intended style. Only switch languages if the user explicitly asks.

## Documentation style

The existing guide defines the house style for new notes and edits:

- Numbered H2 sections (`## 1.`, `## 2.`, ...) separated by horizontal rules (`---`)
- Markdown tables for comparisons — "antes/depois", "quando usar", "incluir/não incluir"
- Fenced code blocks for commands, JSON configs, and example prompts
- Imperative, opinionated tone — it's a personal playbook, not neutral docs; minimal hedging
- Reference guides end with a **Fontes** section linking primary sources (Anthropic docs first)

When editing `claude-code-desktop-performance.md`, preserve its numbered-section structure and tone.

## Repo conventions

- Default branch: `main`. No CI, no required PR workflow — commits land directly on `main` unless the user asks for a branch/PR.
- **Public repository** at `ajunges/aj-openworkspace` — everything committed is world-readable.
- `.claude/settings.local.json` is machine-local and must not be committed. Before `git add -A`, either add `.claude/` to a `.gitignore` or stage files explicitly by name.
- Use `gh` CLI for any GitHub interaction (repo state, issues, PRs) — it is available and authenticated.
