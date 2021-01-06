# Set the docker image tag to the name of the current branch.
# Shortened to 63 bytes because Gitlab does the same with the `CI_COMMIT_REF_SLUG`
# variable, which we use in the CI script to build the docker image.
dockerTag=$(git rev-parse --abbrev-ref HEAD | cut -c "-63")

# Only get the number from the issue (or whatever is in front of a dash
# otherwise) for the release name
releaseName="wordpress-${dockerTag%%-*}"

echo "Release name is $releaseName"
