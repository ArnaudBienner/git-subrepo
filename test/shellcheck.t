#!/usr/bin/env bash

source test/setup

use Test::More

# TODO Should probably check the `shellcheck --version` here too.
if ! command -v shellcheck >/dev/null; then
  plan skip_all "The 'shellcheck' utility is not installed"
fi

IFS=$'\n' read -d '' -r -a shell_files <<< "$(
  echo .rc
  find lib -type f
  echo test/setup
  find test -name '*.t'
  echo share/enable-completion.sh
)" || true

skips=(
  # We want to keep these 2 here always:
  SC1090  # Can't follow non-constant source. Use a directive to specify location.
  SC1091  # Not following: bash+ was not specified as input (see shellcheck -x).

  # These are errors/warnings we can fix one at a time:
  SC1007  # Remove space after = if trying to assign a value (for empty string, use var='' ... ).
  SC1083  # This { is literal. Check expression (missing ;/\n?) or quote it.
  SC1087  # Use braces when expanding arrays, e.g. ${array[idx]} (or ${var}[.. to quiet).
  SC2004  # $/${} is unnecessary on arithmetic variables.
  SC2006  # Use $(...) notation instead of legacy backticked `...`.
  SC2016  # Expressions don't expand in single quotes, use double quotes for that.
  SC2030  # Modification of branch is local (to subshell caused by (..) group).
  SC2031  # ____ was modified in a subshell. That change might be lost.
  SC2034  # ____ appears unused. Verify use (or export if used externally).
  SC2046  # Quote this to prevent word splitting.
  SC2048  # Use "$@" (with quotes) to prevent whitespace problems.
  SC2053  # Quote the right-hand side of == in [[ ]] to prevent glob matching.
  SC2059  # Don't use variables in the printf format string. Use printf "..%s.." "$foo".
  SC2063  # Grep uses regex, but this looks like a glob.
  SC2068  # Double quote array expansions to avoid re-splitting elements.
  SC2086  # Double quote to prevent globbing and word splitting.
  SC2088  # Tilde does not expand in quotes. Use $HOME.
  SC2119  # Use subrepo:clone "$@" if function's $1 should mean script's $1.
  SC2120  # ____ references arguments, but none are ever passed.
  SC2128  # Expanding an array without an index only gives the first element.
  SC2140  # Word is of the form "A"B"C" (B indicated). Did you mean "ABC" or "A\"B\"C"?
  SC2145  # Argument mixes string and array. Use * or separate argument.
  SC2148  # Tips depend on target shell and yours is unknown. Add a shebang.
  SC2152  # Can only return 0-255. Other data should be written to stdout.
  SC2154  # ____ is referenced but not assigned.
  SC2155  # Declare and assign separately to avoid masking return values.
  SC2162  # read without -r will mangle backslashes.
  SC2164  # Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
  SC2166  # Prefer [ p ] && [ q ] as [ p -a q ] is not well defined.
  SC2196  # egrep is non-standard and deprecated. Use grep -E instead.
  SC2206  # Quote to prevent word splitting/globbing, or split robustly with mapfile or read -a.
  SC2207  # Prefer mapfile or read -a to split command output (or quote to avoid splitting).
  SC2219  # Instead of 'let expr', prefer (( expr )) .
  SC2221  # This pattern always overrides a later one on line 1028.
  SC2222  # This pattern never matches because of a previous pattern on line 1026.
  SC2236  # Use -n instead of ! -z.
  SC2239  # Ensure the shebang uses an absolute path to the interpreter.
)
skip=$(IFS=,; echo "${skips[*]}")

for file in "${shell_files[@]}"; do
  is "$(shellcheck -e "$skip" "$file")" "" \
    "The shell file '$file' passes shellcheck"
done

done_testing

# vim: set ft=sh: