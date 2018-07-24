# Initial setup on your local computer

## Secrets

Create a `secrets.tf` file in root of this repository (it is ignored by Git):

    variable "safe-ips" {
      #         |My home IP| Office pub IP
      default = "1.2.3.4/32, 5.6.7.8/32"
    }

## AWS

Tell terraform to use a specific AWS account (which of course must already be setup with AWS API key etc.):

    $ export AWS_PROFILE=kaleidoscope

## Ansible

To avoid specifying the key all the time, put the location of the private key in `ansible.cfg` like

    [defaults]
    private_key_file = /Users/jps/.ssh/kaleidoscope-jp.pem

And stop Ansible asking for confirmation about hosts all the time:

    $ export ANSIBLE_HOST_KEY_CHECKING=False

## Docker

To interact with Docker (Swarm), make a SSH tunnel (in a separate terminal) to one of the swarm nodes:

    $ ssh -i ~/.ssh/kaleidoscope-jp.pem -N -L 2375:/var/run/docker.sock \
          ubuntu@ec2-xx-xx-xx-xx.eu-west-1.compute.amazonaws.com

And tell Docker to use that tunnel:

    $ unset DOCKER_TLS_VERIFY
    $ unset DOCKER_CERT_PATH
    $ unset DOCKER_MACHINE_NAME
    $ export DOCKER_HOST=tcp://localhost:2375
