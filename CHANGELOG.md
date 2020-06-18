## [0.1.3] - 2020-06-18

* Only set imagePullSecrets if the corresponding helm value is set.
* Run apache as non-root user, and listen on port 8080 inside the docker
  container.

## [0.1.2] - 2020-06-09

* Moved repository to open.greenhost.net/openappstack/wordpress-helm
* Removed `*_enabled` tags from config
* Removed `with_items` elements from ansible playbook
