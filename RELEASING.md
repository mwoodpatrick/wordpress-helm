## Release procedure

When releasing a new version of the wordpress-helm chart, please remember to do
the following:
* update `CHANGELOG.md`;
* change the chart version in `Chart.yaml`;
* change the default `image.tag` and `initImage.tag` in `values.yaml` to the new
  version (e.g., "0.1.3");
* create a git tag for the new version (e.g., "0.1.3") and push it to Gitlab
  (any branch will do); the CI will create and push docker images tagged by that
  same version string.
  (You can push all git tags using `git push --tags`, or this specific one using
  `git push origin 0.1.3`.)
