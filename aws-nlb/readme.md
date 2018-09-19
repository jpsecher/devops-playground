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
- [x] Run nginx on both hosts. (manually installed)
- [x] Make the LB forward traffic to the hosts.

https://forums.aws.amazon.com/thread.jspa?threadID=263245

Good question! Don't know if this matches your configuration, but I deployed the sample web app on a new ECS cluster running in a private subnet (with Internet access through NAT instance). For the NLB, I selected the public subnet. I was then able to register the instance from the private subnet. Opened up for traffic from 10.0.0.0/16 to allow health checks, plus one more rule to cover my IP address. The health check took some time to stabilize, but after a short while I was able to access the web app. Adding/removing my IP address in the instance security group had the expected effect.
