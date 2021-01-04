# Set the docker image tag to the current branch:
dockerTag=$(git rev-parse --abbrev-ref HEAD | cut -c "-63")

# Only get the number from the issue (or whatever is in front of a dash
# otherwise) for the release name
releaseName="wordpress-${dockerTag%%-*}"

echo "Release name is $releaseName"
