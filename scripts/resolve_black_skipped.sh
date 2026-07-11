#!/usr/bin/env zsh

set -euo pipefail

stage_python=false
run_all_files=false

refresh_black_state() {
	staged_files=("${(@0)$(git diff --cached --name-only --diff-filter=ACMR -z 2>/dev/null || true)}")
	modified_python=("${(@0)$(git ls-files --modified --others --exclude-standard -z -- '*.py' 2>/dev/null || true)}")
	tracked_python=("${(@0)$(git ls-files -z -- '*.py' 2>/dev/null || true)}")
	staged_files=(${staged_files:#})
	modified_python=(${modified_python:#})
	tracked_python=(${tracked_python:#})
	staged_python=()

	for file in ${staged_files[@]}; do
		if [[ "$file" == *.py ]]; then
			staged_python+=("$file")
		fi
	done
}

for arg in "$@"; do
	case "$arg" in
		--stage-python)
			stage_python=true
			;;
		--all-files)
			run_all_files=true
			;;
		-h|--help)
			cat <<'EOF'
Usage: ./scripts/resolve_black_skipped.sh [--stage-python] [--all-files]

Options:
	--stage-python  Stage modified Python files before running Black.
	--all-files     Run Black across all tracked Python files.
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

refresh_black_state

echo "Black diagnosis"
echo "- staged Python files: ${#staged_python[@]}"
echo "- modified unstaged Python files: ${#modified_python[@]}"
echo "- tracked Python files: ${#tracked_python[@]}"

if (( ${#modified_python[@]} > 0 )) && $stage_python; then
	echo "Staging modified Python files before running Black:"
	printf '  %s\n' "${modified_python[@]}"
	git add -- "${modified_python[@]}"
	refresh_black_state
fi

if (( ${#staged_python[@]} > 0 )); then
	echo "Running Black on staged Python files:"
	printf '  %s\n' "${staged_python[@]}"
	exec pre-commit run black --files "${staged_python[@]}"
fi

if (( ${#modified_python[@]} > 0 )) && ! $stage_python; then
	echo "Black was skipped because no Python files are currently staged."
	echo "Modified Python files exist but are not staged:"
	printf '  %s\n' "${modified_python[@]}"
	echo "Next steps:"
	echo "  - rerun with: ./scripts/resolve_black_skipped.sh --stage-python"
	echo "  - or run across all tracked Python files with: ./scripts/resolve_black_skipped.sh --all-files"
	exit 0
fi

if $run_all_files || (( ${#staged_python[@]} == 0 )); then
	if (( ${#tracked_python[@]} == 0 )); then
		echo "No tracked Python files were found for Black to format."
		exit 0
	fi

	echo "Running Black across all tracked Python files:"
	printf '  %s\n' "${tracked_python[@]}"
	exec pre-commit run black --files "${tracked_python[@]}"
fi
