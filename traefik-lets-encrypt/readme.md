# Træfik with certificates.

1. Read `../setup.md`.
1. If not already bootstrapped, go to `../foundation` and kickstart the AWS infrastructure.
1. Run `terraform init`.
1. Run `terraform apply`.
1. Copy the hostnames into the `inventory.ini` so that Ansible knows which hosts to provision.
1. Run `ansible-playbook -i inventory.ini docker-host-0.yml`.
1. Save the `worker_token` or `manager_token` if needed.
1. Run `docker stack deploy -c stack-traefik.yml traefik`

## Plan 

- [x] Deploy a Docker host on AWS.
- [x] Get Træfik running in a container so that its adm interface can be reached through http.
