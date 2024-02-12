# Simple Example

This example illustrates how to use the `secure-web-proxy` module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | Project ID where SWP and it's components will be created. | `string` | n/a | yes |
| region | The GCP region in which SWP and it's components will be deployed. | `string` | `"us-central1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| certificate\_manager\_id | Identifier of the certificate manager resource created for SWP. |
| gateway\_id | Identifier for the secure web proxy gateway. |
| policy\_id | Identifier of the secure web proxy gateway policy. |
| project\_id | Project ID for the DNS response policy. |
| region | Project ID for the DNS response policy. |
| rule\_ids | Identifiers of the secure web proxy rules created. |
| url\_list\_ids | Identifiers of the secure web proxy url lists. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
