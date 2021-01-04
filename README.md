## Setup

### Prerequisites

1. Make sure you have `kubernetes-cli` and `helm` (version >= 3) installed on
   your development machine
2. Make sure you have a running kubernetes cluster that your kubectl is
   connected to. Check this by running `kubectl version`. It should tell you the
   client and server version of Kubernetes.
4. The redis and MariaDB helm charts live in a custom Bitnami chart repository
   (the ones in the helm stable repository are deprecated and moved there). Get
   the repository by running:

   ```
   $ helm repo add bitnami https://charts.bitnami.com/bitnami
   ```
5. The chart assumes you have nginx ingress running in IP range `10.0.0.0/8`. If
   you do, the access logs will show remote IP addresses from the
   `X-Forwarded-For` header. Otherwise, the proxy IP address is shown in the
   access logs.

   If you don't use `nginx` ingress and you enable `mu_cron`, make sure to block
   the path from `wordpress.mu_cron.cronjob.path` from outside traffic.

### Start WordPress on Kubernetes

#### Configuration

Copy `values-local.yaml.example` to `values-local.yaml`. This file contains a
lot of variables that you can change to adjust the WordPress installation to
your needs.

For a simple WordPress installation, you only need to edit the following values:

|               Parameter               |                 Description                   |              Default              |
|---------------------------------------|-----------------------------------------------|-----------------------------------|
| `ansibleVars.WP_URL`                  | The URL of your WordPress website             | http://localhost                  |
| `ansibleVars.WP_TITLE`                | The title of the site                         | Demo WP                           |
| `ansibleVars.WP_THEME_ACTIVE`                | A *slug* for the theme you want to install on your site (can also be changed through interface) | twentytwenty |
| `ansibleVars.WP_EMAIL`                | The administrator's email adress              | youremailhere@example.com         |
| `database.db.user`                    | Database user                                 | wordpress                         |
| `database.db.password`                | `wordpress` db user password                  | You **really** need to set this   |
| `database.db.rootUser.password `      | root user password                            | You **really** need to set this   |
| `database.db.replicationUser.password`| replication user password                     | You **really** need to set this   |

You can read the descriptions of the other variables in
`values-local.yaml.example` and of even more variables in `values.yaml`.

##### Note about theme fallback
If there is no theme available to activate in wp_content then the fallback theme will be used
This is set by wordpress.site.theme_fallback from values.yaml 

##### Note about the `ansibleVars`:

All the variables under `ansibleVars` are used by the ansible playbook that is
run in the init container to configure the WordPress website. You can find their
default values in the `values.yaml` file. You can override single values of
`ansibleVars.<any variable>` in your `values-local.yaml` file. __NOTE__: if you
would want to override variables in `ansibleSecrets`, you have to copy the whole
`ansibleSecrets` string to `values-local.yaml`!

#### Installation

1. Install the helm dependencies by typing `helm dep update`
2. Start WordPress by typing running `install.sh`.

   __NOTE__: if you override the image or initImage tags in values.yaml,
   installation with this script ignores that.

See [What happens when I install this?](#what-happens-when-i-install-this) for
information on what happens now.

#### Removal

To undo an installation and remove all traces of it ever existing, use the
`delete.sh` script. __NOTE__: use this at your own risk! Your databases, uploads, etc. will be removed for ever!

## Troubleshooting

To debug the **init** container, you can use `kubectl logs`, but because it is
not the default container, you need to use the `-c` argument as follows:

```bash
$ kubectl logs <pod> -c init-wordpress
```

## What happens when I install this?

### Installed pods

Helm will set up the kubernetes pods that are needed to run your website:

1. A WordPress pod that serves the site
2. Two MariaDB pods running the database (master-slave setup by default, unless
   you changed this in `values-local.yaml`)
3. If you configured Redis, a Redis pod is also set up

The MariaDB and Redis pods are documented in the official [helm charts
repository](https://github.com/helm/charts), this file documents the WordPress
pod that will serve the site.

### Init container

This chart provides an "init container" for the WordPress pod. This container
sets up the wordpress. Each time a pod is (re)started, the init container:

1. Downloads WordPress to a temporary directory
2. Configures that fresh WordPress
3. Downloads and activates the plugins specified in
   `ansibleVars.wordpress_default_plugins`

### WordPress setup

After the init container is done, persistent volumes are mounted:

- `wpContentDir` contains the `wp-content` directory and is persistent over pod
  restarts
- `wpUploadDir` contains the `uploads` directory that is usually a subdirectory
  of the `wp-content` dir and is persistent.
- A configmap containing the `.htaccess` file for the uploads dir is mounted in
  `wpUploadDir`/.htaccess

## Importing an existing WordPress site

We assume you have:

- A running kubernetes cluster
- `kubectl` installed on your machine and configured to connect to your running
  cluster.
- `tar` installed
- A database dump of your old website's database called `dump.sql`.
- The contents of the `wp-content` folder (usually at
  `/var/www/html/wp-content`) in a local directory called `wp-content`.


Make sure the copy of the wp-content directory and the database dump are made at
the same time.

We will go through the following steps:

1. Set up a new WordPress site by installing this chart
2. Import the Database
3. Import the files from wp-content

### Set up a new WordPress site

Follow the instructions under [Start WordPress on
Kubernetes](#start-wordpress-on-kubernetes)

You might have to edit the following variables to reflect your current site's:

- Set `DB_PREFIX` to the database prefix that your current WordPress uses
- Set `WP_VERSION` to the version of your current WordPress site.
- Check if your current WordPress uses Redis. This is usually the case when you
  have the `redis-cache` plugin installed. If so, enable redis in your
  `values-local.yaml` by setting `redis.enabled` to `true`.

After installing, check if your site is available at the URL you specified in
`values-local.yaml`. When it is, type `helm ls` to find the name of your
deployment. In the rest of this document we will assume that your WordPress
deployment is named `wordpress-master`.

### Import the database

Make sure to remove all explicit URLs to your site from the database. If you
host your site on `example.com`, WordPress tends to put links in the database as
`https://example.com/<link to your post>` or `http://example.com/<link to your
post>`. If you want to try this new deployment on a different domain, that will
not work. To fix this, search for `https://example.com` in your database and
remove it. Repeat this step for `http://example.com`.

When your database file is ready, import it with the following command:

```bash
$ kubectl exec -i wordpress-master-mariadb-master-0 -- mysql -uwordpress -p<your password> --database=wordpress_db < dump.sql
```

A breakup of the command:

- `kubectl exec` means you want to execute a command in a container
- `-i` makes sure that `stdin` is passed to the container. This means that we
  can use `< dump.sql` to import the database export from your local system.
- We assume your database is running in a pod named
  `wordpress-master-mariadb-master-0`.
- `--` tells kubectl to stop interpreting command line arguments as kubectl
  arguments
- `mysql` executes the `mysql` command in the container, with the following
  arguments: 
  - `-uwordpress` sets the MySQL user to wordpress
  - `-p` provides the prassword of the `wordpress` user
  - `--database=wordpress_db` selects the `wordpress_db` database.
- `< dump.sql` reads the file `dump.sql` and inserts it into the mysql command.
  Change this if your MySQL database dump has a different filename.


### Import the files from wp-content/uploads

Similar to how you would normally use `scp` to copy files to a server, you can
use `kubectl cp` to copy files to your wordpress pod. Make sure that you copy
your uploads directory contents to the directory you have configured as the
`wpUploadDir` in the `values-local.yaml`. If you haven't configured it, it
defaults to `/var/www/wp-uploads-mount`. Also make sure it does not contain a
`.htaccess` file because that is provided by this chart.

run `kubectl get pods` to figure out what the name is of the pod running
WordPress:

```bash
$ kubectl get pods
NAME                                                 READY     STATUS    RESTARTS   AGE
wordpress-master-0                               1/1       Running   0          20d
wordpress-master-mariadb-master-0                1/1       Running   9          20d
wordpress-master-mariadb-slave-0                 1/1       Running   12         20d
```

In this case, we have 2 mariadb pods and one WordPress pod. We can copy the
wp-content contents to the pod with the following command:

```bash
$ kubectl cp uploads/ wordpress-master-0:/var/www/wp-uploads-mount
```

You'll have to change the ownership of the files to the `www-data` user: 

```bash
$ kubectl exec -it wordpress-master-0 -- chown -R www-data:www-data /var/www/wp-uploads-mount
```

Note: this will say 
`chown: changing ownership of '/var/www/wp-uploads-mount/.htaccess': Read-only file system`. 
Don't worry, that's the mounted `.htaccess` file. All the other files' ownership *will* have changed.

## Known issues

Take a look at https://open.greenhost.net/openappstack/wordpress-helm/-/issues
for issues that are already reported.

## Attribution

Most of this helm chart was made by following
[this](https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/)
and
[this](https://medium.com/@gajus/the-missing-ci-cd-kubernetes-component-helm-package-manager-1fe002aac680).
