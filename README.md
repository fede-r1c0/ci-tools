# Dockerfile for CI/CD Tools

This Dockerfile is based on Ubuntu 20.04 and contains various infrastructure tools installed like:

- Node.js 18.17.0
- npm 9.8.1
- yarn 1.22.19
- Python 3.9.17
- pip 23.2.1
- petry 1.1.7
- Go 1.20.3
- awscli 2.13.7
- kubectl 1.27.1
- Helm 3.11.3
- Sops 3.7.1
- ArgoCD 2.7.10
- Terragrunt 0.45.4
- Terraform 0.48.6

Image tested with Kaniko and Gitlab Runners.

## Using the Dockerfile

- Make sure you have Docker installed on your system.
- Clone this repository or download the Dockerfile.
- Review or update environment variables for tools versions.

## Building the Image

To build the image, run this command in the directory where the Dockerfile is located:

    docker build -t ci-tools:1.0.0 -f Dockerfile .

Replace image_name and tag with the desired name and tag for your image.

## Running the Container

Once the image is built, you can run an interactive container using the following command:

    docker run -it --rm ci-tools:1.0.0

This will provide you with an environment inside the container with all the installed tools and versions.

### Contributing to the Project

If you wish to contribute to the project by adding new tools or updating existing versions, we would love to receive your contributions! Follow these steps to contribute:

- Fork this repository and clone your copy to your local machine.
- Make the changes you desire in the Dockerfile configurations (e.g., adding or updating versions in the Dockerfile file).
- Make sure to test the changes to verify everything works correctly.
- Commit the changes and submit a pull request to this repository.
- Our team will review your pull request and, if appropriate, merge it with the project.

Note: Be sure to follow best practices and maintain coding style consistency to facilitate review and collaboration.
