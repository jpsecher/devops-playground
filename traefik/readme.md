# Træfik with certificates.

1. Read `../readme.md`.
1. If not already bootstrapped, go to `../foundation` and kickstart the AWS infrastructure.
1. Run `terraform init`.
1. Run `terraform apply`.
1. Copy the hostnames into the `inventory.ini` so that Ansible knows which hosts to provision.
1. Run `ansible-playbook docker-host-0`.

## Plan 

- [x] Deploy a Docker host on AWS.
- [x] Get Træfik running in a container so that its adm interface can be reached through http.
- [ ] Get a dummy container running in several instances so it can be demonstrated that Træfik load balances between the containers.

