#!/bin/bash

# Variables
REPO_OWNER="your-username-or-organization"
REPO_NAME="your-repo-name"

# Function to check if gh CLI is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        echo "gh CLI not found. Please install it from https://cli.github.com/"
        exit 1
    fi
}

# Function to list users with access to the repo
list_repo_access() {
    echo "Listing users with access to the repository '$REPO_OWNER/$REPO_NAME'..."

    # List collaborators
    echo -e "\nCollaborators:"
    gh api -H "Accept: application/vnd.github.v3+json" \
           /repos/$REPO_OWNER/$REPO_NAME/collaborators | jq -r '.[].login'

    # List teams (if it's an organization repo)
    if [ "$REPO_OWNER" != "$GITHUB_USER" ]; then
        echo -e "\nTeams:"
        gh api -H "Accept: application/vnd.github.v3+json" \
               /orgs/$REPO_OWNER/teams | jq -r '.[].slug' | while read team; do
            echo "Team: $team"
            gh api -H "Accept: application/vnd.github.v3+json" \
                   /orgs/$REPO_OWNER/teams/$team/members | jq -r '.[].login'
        done
    fi
}

# Function to grant access to a user
grant_access() {
    read -p "Enter username to grant access: " username
    gh api -X PUT -H "Accept: application/vnd.github.v3+json" \
           /repos/$REPO_OWNER/$REPO_NAME/collaborators/$username
    if [ $? -eq 0 ]; then
        echo "Granted access to $username."
    else
        echo "Failed to grant access to $username."
    fi
}

# Function to revoke access from a user
revoke_access() {
    read -p "Enter username to revoke access: " username
    gh api -X DELETE -H "Accept: application/vnd.github.v3+json" \
           /repos/$REPO_OWNER/$REPO_NAME/collaborators/$username
    if [ $? -eq 0 ]; then
        echo "Revoked access from $username."
    else
        echo "Failed to revoke access from $username."
    fi
}

# Check if gh CLI is installed
check_gh_cli

# Main menu
while true; do
    echo "Choose an option:"
    echo "1. List users with access"
    echo "2. Grant access to a user"
    echo "3. Revoke access from a user"
    echo "4. Exit"
    read -p "Option: " option
    case $option in
        1) list_repo_access ;;
        2) grant_access ;;
        3) revoke_access ;;
        4) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done
