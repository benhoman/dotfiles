#!/usr/bin/env bash
set -e

# Examples of call:
# git-clone-bare-for-worktrees git@github.com:name/repo.git
# => Clones to a /repo directory
#
# git-clone-bare-for-worktrees git@github.com:name/repo.git my-repo
# => Clones to a /my-repo directory
#
# git-clone-bare-for-worktrees -b feature-branch git@github.com:name/repo.git
# => Clones to a /repo directory and creates a worktree for feature-branch
#
# git-clone-bare-for-worktrees --branch main git@github.com:name/repo.git my-repo
# => Clones to a /my-repo directory and creates a worktree for main

show_usage() {
  echo "Usage: $0 [-b|--branch BRANCH_NAME] <git_url> [directory_name]"
  echo ""
  echo "Options:"
  echo "  -b, --branch BRANCH_NAME  Create a worktree for the specified branch after cloning"
  echo "  -h, --help               Show this help message"
  echo ""
  echo "Arguments:"
  echo "  git_url                  The Git repository URL to clone"
  echo "  directory_name           Optional directory name (defaults to repo name)"
}

# Parse command line arguments
branch_name=""
while [[ $# -gt 0 ]]; do
  case $1 in
    -b|--branch)
      branch_name="$2"
      shift 2
      ;;
    -h|--help)
      show_usage
      exit 0
      ;;
    -*)
      echo "Error: Unknown option $1" >&2
      show_usage
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

url=$1
if [[ -z "$url" ]]; then
  echo "Error: Git URL is required" >&2
  show_usage
  exit 1
fi

basename=${url##*/}
name=${2:-${basename%.*}}

mkdir -p $name
cd "$name"

# Moves all the administrative git files (a.k.a $GIT_DIR) under .bare directory.
#
# Plan is to create worktrees as siblings of this directory.
# Example targeted structure:
# .bare
# main
# new-awesome-feature
# hotfix-bug-12
# ...
git clone --bare "$url" .bare
echo "gitdir: ./.bare" >.git

# Explicitly sets the remote origin fetch so we can fetch remote branches
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

# Gets all branches from origin
git fetch origin

# Create worktree for specified branch if provided
if [[ -n "$branch_name" ]]; then
  echo "Creating worktree for branch: $branch_name"
  
  # Check if branch exists on remote
  if git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
    echo "Branch '$branch_name' exists on remote, creating worktree..."
    git worktree add --track -b "$branch_name" "$branch_name" "origin/$branch_name"
    echo ""
    echo "Worktree setup complete!"
    echo "To work on '$branch_name': cd $name/$branch_name"
  else
    echo "Error: Branch '$branch_name' not found on remote"
    echo "Available remote branches:"
    git branch -r --format='%(refname:short)' | sed 's/origin\///'
    exit 1
  fi
fi
