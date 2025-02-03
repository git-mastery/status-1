#!/bin/bash

# TODO maybe this should be a dedicated CLI instead of a complex Bash script

set -e

check_binary() {
  if ! which "$1" >/dev/null; then
    (>&2 echo "$2")
    exit 1
  fi
}

# TODO Maybe check if Github connection is working as well?
check_binary "git" "You need to install Github"
check_binary "gh" "You need to install the Github CLI"

if ! gh auth status >/dev/null 2>&1; then
  echo "You aren't logged in to Github CLI yet. Run gh auth login to login"
  exit 1
fi

# Get current directory name to get exercise name
EXERCISE_NAME=${PWD##*/}

# Check if PR exists already
OPEN_PR=$(gh pr list --repo git-mastery/$EXERCISE_NAME --state "open" --author "@me")

CURRENT_USERNAME=$(gh api user -q ".login")

HEAD=$1

if [[ -z $OPEN_PR ]]; then
  echo "You don't have an open PR for $EXERCISE_NAME yet, creating one on your behalf"
  if [[ -z $HEAD ]]; then
    CURRENT_BRANCH=$(git branch --show-current)
    echo "Using current branch $CURRENT_BRANCH"
    git push -u origin $CURRENT_BRANCH
    gh pr create \
      --repo git-mastery/$EXERCISE_NAME \
      --title "[$CURRENT_USERNAME] [$EXERCISE_NAME] Submission" \
      --body "" \
      --head $CURRENT_USERNAME:$CURRENT_BRANCH
  else
    echo "Using $HEAD instead"
    git push -u origin $HEAD
    gh pr create \
      --repo git-mastery/$EXERCISE_NAME \
      --title "[$CURRENT_USERNAME] [$EXERCISE_NAME] Submission" \
      --body "" \
      --head $CURRENT_USERNAME:$HEAD
  fi
else
  # If a PR already exists, we can just push directly
  if [[ -z $HEAD ]]; then
    CURRENT_BRANCH=$(git branch --show-current)
    echo "Pushing $CURRENT_BRANCH"
    git push -u origin $CURRENT_BRANCH
  else
    echo "Pushing $HEAD"
    git push -u origin $HEAD
  fi
fi
