# Tab Completion for Context Names — Design

**Date:** 2026-05-20
**Status:** Approved

## Goal

Make `dux <prefix><TAB>` autocomplete to a matching Docker context name. Example: with contexts `1context`, `2context`, `3context`, typing `dux 2<TAB>` expands to `dux 2context`.

Apply the same completion to `dux use <prefix><TAB>` and `dux delete <prefix><TAB>`.

## Problem

The repository already ships two completion systems, but only one of them actually works for context names:

1. **Hand-written static scripts** in `completions/dux.bash` and `completions/dux.zsh` — these correctly complete context names for the first positional argument of `dux`, `dux use`, and `dux delete`.
2. **Cobra-generated completion** via `dux completion bash|zsh|fish|powershell` — this is what `install.sh` actually wires up (`eval "$(dux completion <shell>)"`), but none of the Cobra commands define `ValidArgsFunction`, so contexts are never suggested.

Users who run the installer get the broken path. Users who manually source the static scripts get the working one.

## Design

Keep both completion systems. Fix the Cobra-generated one so the default install path works; leave the static scripts as a manual alternative.

### 1. Cobra completion (Go)

Add a small helper alongside the existing utilities in `cmd/dux/utils.go`:

```go
func contextCompletion(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
    names, err := docker.GetContextNames()
    if err != nil {
        return nil, cobra.ShellCompDirectiveError
    }
    return names, cobra.ShellCompDirectiveNoFileComp
}
```

Wire it into three commands:

- `rootCmd.ValidArgsFunction = contextCompletion` — first positional arg of bare `dux` completes from contexts. Cobra continues to auto-suggest subcommand names alongside, so users still see `create`, `delete`, etc.
- `useCmd.ValidArgsFunction = contextCompletion`
- `deleteCmd.ValidArgsFunction = contextCompletion`

The helper returns all context names; the shell filters by the typed prefix. `ShellCompDirectiveNoFileComp` suppresses the default filename fallback when no context matches.

`createCmd` is intentionally excluded — its first positional arg is a *new* name, not an existing one.

### 2. Static scripts

`completions/dux.bash` and `completions/dux.zsh` already complete contexts correctly for the supported commands. They remain in the repo unchanged, available for users who prefer to source them directly (e.g. via a future `make install-completions` or distro packaging) instead of using `dux completion <shell>`.

Minor sanity check during implementation: confirm the static scripts list the current subcommand set (`create`, `delete`, `list`, `use`, `current`, `prompt`, `version`). No structural changes are planned.

### 3. Fish

The static scripts cover bash and zsh only. Cobra's `dux completion fish` will now work end-to-end as a side effect of the Go fix, giving fish users coverage with no extra work.

## Out of Scope

- Flag-value completion for `dux create -r <ssh-host>` etc.
- Description text per context (could be added later via `cobra.CompletionWithDesc`-style returns).
- Restructuring the installer's completion setup.

## Verification

Manual checks after building:

1. `eval "$(./dux completion bash)"; dux <TAB>` shows context names interleaved with subcommands.
2. `eval "$(./dux completion bash)"; dux <prefix><TAB>` expands to the matching context.
3. Same for `dux use <prefix><TAB>` and `dux delete <prefix><TAB>`.
4. Repeat steps 1–3 with `zsh` and `fish` shells.
5. In a fresh shell, `source completions/dux.bash` (no Cobra eval) — confirm the static path still works.

## Files Touched

- `cmd/dux/utils.go` — add `contextCompletion` helper.
- `cmd/dux/root.go`, `cmd/dux/use.go`, `cmd/dux/delete.go` — set `ValidArgsFunction`.
- `completions/dux.bash`, `completions/dux.zsh` — unchanged unless the subcommand sanity check turns up a gap.
