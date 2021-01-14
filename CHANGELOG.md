## [0.1.6] - 2021-01-14

* Improve how `WP_CRON_CONTROL_SECRET` works / make sure `helm install` works with default values
* Add support for parent and child themes
* Only spawn cronjobs if the WordPress pod is ready
* Update database in Ansible playbook
* Allow extra arguments to `install.sh` scripts
* Fix rights issue with `config.php` that caused restarted pods to fail
* Squelch "Cannot set fs attributes on a non-existent symlink target" message

## [0.1.5] - 2020-09-23

* Re-enable some redis commands disabled by Bitnami by default
* Harden WordPress default file and directory permissions
* Show external IP in `kubectl logs` output by using mod_remoteip
* Add Kubernetes CronJob for running Cron-control jobs
* Rsync backups to remote storage
* Make `enableServicesLink` flag configurable so services can be hidden from devs
* Use `us_en` locale by default to prevent problems with new wordpress releases
* Set max upload size to 50m
* Add custom php.ini
* Fix MU_PLUGIN_DIR path
* Bump default WordPress version to 5.4.2

## [0.1.4] - 2020-07-08

* Use PodSecurityContext instead of container security contexts
* If enabled, merge roles from OIDC server into OIDC accounts

## [0.1.3] - 2020-06-18

* Only set imagePullSecrets if the corresponding helm value is set.
* Run apache as non-root user, and listen on port 8080 inside the docker
  container.

## [0.1.2] - 2020-06-09

* Moved repository to open.greenhost.net/openappstack/wordpress-helm
* Removed `*_enabled` tags from config
* Removed `with_items` elements from ansible playbook
