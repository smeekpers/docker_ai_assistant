#!/usr/bin/env zsh

set -euo pipefail

stage_python=false
run_all_files=false
run_all_hooks=false
stage_all=false
stash_ref=""

refresh_git_state() {
  staged_files=("${(@0)$(git diff --cached --name-only --diff-filter=ACMR -z 2>/dev/null || true)}")
  staged_python=()
  modified_python=("${(@0)$(git ls-files --modified --others --exclude-standard -z -- '*.py' 2>/dev/null || true)}")
  unstaged_tracked=("${(@0)$(git diff --name-only -z 2>/dev/null || true)}")
  overlap_files=()
  staged_files=(${staged_files:#})
  modified_python=(${modified_python:#})
  unstaged_tracked=(${unstaged_tracked:#})

  for file in ${staged_files[@]}; do
    if [[ "$file" == *.py ]]; then
      staged_python+=("$file")
    fi

    if (( ${unstaged_tracked[(Ie)$file]} > 0 )); then
      overlap_files+=("$file")
    fi
  done
}

restore_stash() {
  if [[ -z "$stash_ref" ]]; then
    return 0
  fi

  echo "Restoring unstaged tracked files from ${stash_ref}..."
  git stash pop --index "$stash_ref"
}

for arg in "$@"; do
  case "$arg" in
    --stage-python)
      stage_python=true
      ;;
    --all-files)
      run_all_files=true
      ;;
    --all-hooks)
      run_all_hooks=true
      ;;
    --stage-all)
      stage_all=true
      ;;
    -h|--help)
      cat <<'EOF'
Usage: ./scripts/resolve_precommit.sh [--stage-python] [--stage-all] [--all-files] [--all-hooks]

Options:
  --stage-python  Stage modified Python files before running pre-commit.
  --stage-all     Stage unstaged tracked files before running pre-commit.
  --all-files     Run the full pre-commit hook suite across all files.
  --all-hooks     Alias for --all-files.
  -h, --help      Show this help message.
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

if [[ ! -f .pre-commit-config.yaml ]]; then
  echo "Run this script from the repository root." >&2
  exit 1
fi

refresh_git_state

echo "Pre-commit diagnosis"
echo "- staged files: ${#staged_files[@]}"
echo "- staged Python files: ${#staged_python[@]}"
echo "- modified unstaged Python files: ${#modified_python[@]}"
echo "- unstaged tracked files: ${#unstaged_tracked[@]}"
echo "- staged/unstaged overlap files: ${#overlap_files[@]}"

if $run_all_files || $run_all_hooks; then
  echo "Running the full pre-commit suite across all files..."
  exec pre-commit run --all-files
fi

if (( ${#modified_python[@]} > 0 )); then
  if $stage_python; then
    echo "Staging modified Python files before running pre-commit:"
    printf '  %s\n' "${modified_python[@]}"
    git add -- "${modified_python[@]}"
    refresh_git_state
  fi
fi

if (( ${#unstaged_tracked[@]} > 0 )); then
  if $stage_all; then
    echo "Staging unstaged tracked files before running pre-commit:"
    printf '  %s\n' "${unstaged_tracked[@]}"
    git add -- "${unstaged_tracked[@]}"
    refresh_git_state
  elif (( ${#overlap_files[@]} > 0 )); then
    echo "Cannot safely auto-stash files that have both staged and unstaged changes:"
    printf '  %s\n' "${overlap_files[@]}"
    echo "Next steps:"
    echo "  - rerun with: ./scripts/resolve_precommit.sh --stage-all"
    echo "  - or manually separate staged and unstaged changes for those files"
    exit 0
  else
    stash_label="resolve_precommit_auto_stash_$(date +%s)"
    echo "Temporarily stashing unstaged tracked files before running pre-commit:"
    printf '  %s\n' "${unstaged_tracked[@]}"
    git stash push --keep-index -m "$stash_label" >/dev/null
    stash_ref=$(git stash list --format='%gd %s' | awk -v label="$stash_label" 'index($0, label) { print $1; exit }')
    if [[ -z "$stash_ref" ]]; then
      echo "Failed to create a temporary stash for unstaged tracked files." >&2
      exit 1
    fi
    refresh_git_state
  fi
fi

if (( ${#staged_files[@]} > 0 )); then
  echo "Running the full pre-commit suite on staged files:"
  printf '  %s\n' "${staged_files[@]}"
  set +e
  pre-commit run --files "${staged_files[@]}"
  exit_code=$?
  set -e

  if ! restore_stash; then
    echo "Pre-commit finished, but restoring the temporary stash failed." >&2
    echo "Recover manually with: git stash list && git stash pop ${stash_ref}" >&2
    exit 1
  fi

  exit $exit_code
fi

if (( ${#modified_python[@]} > 0 )); then
  echo "Black was skipped because no Python files are currently staged."
  echo "Modified Python files exist but are not staged:"
  printf '  %s\n' "${modified_python[@]}"
  echo "Next steps:"
  echo "  - stage them manually with: git add <file>"
  echo "  - or rerun with: ./scripts/resolve_precommit.sh --stage-python"
  echo "  - or rerun with: ./scripts/resolve_precommit.sh --stage-all"
  echo "  - or run the full hook suite with: ./scripts/resolve_precommit.sh --all-files"
  exit 0
fi

echo "No staged files were found for pre-commit to validate."
echo "This is expected when nothing has been staged yet."
echo "If you still want validation, use one of:"
echo "  - ./scripts/resolve_precommit.sh --all-files"
echo "  - ./scripts/resolve_precommit.sh --stage-all"
echo "  - git add <files> && ./scripts/resolve_precommit.sh"
