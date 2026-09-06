Velero
======

Installs a pinned Velero Helm release in an EKS cluster and configures an S3
backup storage location. This role does not create an automatic backup
schedule. Backups and restores are started manually when required. AWS access
is provided by EKS IRSA; this role never accepts or stores AWS access keys.

Requirements
------------

* Create an IAM role with the Velero S3 policy and trust relationship for the
  Velero service account before running the role.
* Set `velero_s3_bucket` and `velero_irsa_role_arn` outside the role defaults.

Role Variables
--------------

Important variables are `velero_aws_region`, `velero_s3_bucket`,
`velero_namespace`, `velero_chart_version`, `velero_aws_plugin_version`,
`velero_retention_period`, `velero_environment`, and `velero_irsa_role_arn`.
Defaults are in `defaults/main.yml`; the bucket and role ARN are intentionally
empty so infrastructure-specific identifiers cannot be committed accidentally.

Dependencies
------------

No role dependencies.

Example Playbook
----------------

```yaml
- hosts: localhost
  gather_facts: false
  roles:
    - role: velero
      vars:
        velero_s3_bucket: my-private-velero-bucket
        velero_irsa_role_arn: arn:aws:iam::123456789012:role/velero
        velero_environment: dev
```

Backup procedure
----------------

The role does not create a `Schedule` resource. To create a manual backup,
use the configured `velero_retention_period` as the backup TTL:

  velero backup create production-backup-$(date +%Y%m%d%H%M%S) --include-namespaces '*' --ttl 720h --kubeconfig <path>

Check progress with `velero backup get` and inspect details with
`velero backup describe <backup-name> --details`.

Restore procedure
-----------------

List available backups, then restore into the cluster with:

    velero backup get --kubeconfig <path>
    velero restore create --from-backup <backup-name> --wait --kubeconfig <path>

Review the restore with `velero restore describe <restore-name> --details`.
For a dry run, restore into a separate namespace using Velero namespace
mapping options before restoring production workloads.

License
-------

MIT

Author Information
------------------

Project maintainers
