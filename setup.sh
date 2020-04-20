#!/usr/bin/env bash

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

function ensure_command() {
  if ! (command -v parallel 1>/dev/null); then
    uname | grep -q Darwin && brew install parallel
  fi
  parallel 'if ! (command -v {} 1>/dev/null); then (uname | grep -q Darwin && brew install {}) fi' ::: "$@"
}

ensure_command shellcheck
parallel 'find . -type f -name "*.{//}" | parallel {/}' ::: sh/shellcheck

grep -v guard < Gemfile > .overcommit_gems.rb
bundle install --quiet --gemfile=.overcommit_gems.rb

bundle install --quiet
