# tag-versions-jira-github

This shell script will assign a tag to your repo at it's current point, compare to a previous tag, and find all pull requeusts in between.

From there, it will create a version in JIRA and add the tickets to those version.  The branches in the pull requests must match the ticket names in JIRA.

Requires JIRA CLI to be install.
