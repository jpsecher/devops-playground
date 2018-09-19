# Network Load Balancer on AWS

1. Read `../setup.md`.
1. If not already bootstrapped, go to `../foundation` and kickstart the AWS infrastructure.
1. Run `terraform init`.
1. Run `terraform apply`.
1. Copy the hostnames into the `inventory.ini` so that Ansible knows which hosts to provision.
1. Run `ansible-playbook -i inventory.ini docker-host-0.yml`.
1. Run `docker stack deploy -c stack-whoami.yml aws-nlb`

## Plan

- [x] Deploy a Network LB with one Target Group on AWS.
- [x] Deploy two hosts in a private network with a NAT gateway.
- [ ] Put Docker Swarm on the hosts.
- [ ] Run whoami in host mode on both hosts.
- [ ] Make the LB forward traffic to the hosts.
