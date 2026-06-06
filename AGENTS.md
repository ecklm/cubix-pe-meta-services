# AGENTS.md

## Repository Shape
- This is a Terraform-only repo for Azure DNS meta services; there is no README or app code.
- Root zone is `azurerm_dns_zone.cubix_root` for `cubix.ecklm.com` in resource group `cubix-meta-services`.
- Student subzones are delegated by `students.tf` through `modules/student_zone`, which creates Azure DNS `NS` records only.

## Terraform Commands
- Format everything with `terraform fmt -recursive`.
- Validate locally with `terraform init -backend=false -reconfigure && terraform validate` if Azure backend auth/state access is not available.
- Use normal remote-state init with `terraform init` only when the Azure backend exists and your Azure login has state access.
- Do not recreate `scripts/bootstrap-tfstate.sh`; backend bootstrapping was intentionally removed.

## Remote State
- Backend is AzureRM in `provider.tf`: resource group `cubix-meta-services`, storage account `cubixmetastore`, container `tfstate`, key `metaservices.tfstate`.
- Backend uses Azure AD auth: `use_azuread_auth = true`; GitHub Actions relies on OIDC env vars rather than storage account keys.

## GitHub Actions / OIDC
- `.github/workflows/terraform.yml` runs `plan` on PRs, `apply` on pushes to `main`, and supports manual `workflow_dispatch` with `action = plan|apply`.
- PR plans are gated by the GitHub Environment `terraform-plan-approval`; configure that environment with required reviewers so PR checks stay pending until explicitly approved.
- Workflow expects GitHub secret `AZURE_CLIENT_ID`; tenant and subscription IDs are hardcoded in workflow/provider.
- `scripts/setup-github-oidc.sh` creates/reuses user-assigned managed identity `cubix-metaservices-github-terraform`, adds GitHub federated credentials, assigns Azure roles, and sets `AZURE_CLIENT_ID` via `gh secret set`.
- The OIDC setup script requires authenticated `az` and `gh`; run `gh auth login` first if needed.

## Student Zones
- `var.student_zones` is a map where each entry has `subdomain_name`, `name_servers`, and optional `ttl` defaulting to `300`.
- The module input `parent_zone` is structurally typed for an `azurerm_dns_zone`; pass `parent_zone = azurerm_dns_zone.cubix_root`.
- `*.auto.tfvars` is ignored by `.gitignore`; sample or local student data in auto tfvars will not be committed unless the ignore rule changes.
