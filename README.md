# lab-dev-env

## Build

```sh
docker build --platform linux/amd64 -t lab-dev-env .
```

## Running the Container

The following sections provide commands for running the container as a development environment. If the host does not have any CLIs installed, the first method can be used. If the host has CLIs installed, the second will require less setup.

### Authenticating Within the Container

```sh
docker run \
    -e HOST_PROJECT=$(pwd) \
    --mount type=bind,source=$(pwd),target=/home/project \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    -p1485:1485 \
    --name lab-dev-env \
    lab-dev-env
```

Some notes about the above command:

- The `HOST_PROJECT` environment variable is required for preview and validate commands.
- `--mount type=bind,source=$(pwd),target=/home/project` mounts the host directory (the lab repo directory) into the container.
- `--mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock` mounts the host's docker socket into the container. This is optional and only needed when developing CLI/IDE-based labs.
- `-p1485:1485` exposes port 1485 on the host machine. This is the port that the IDE runs on.
- `--name lab-dev-env` gives the container a name.
- `lab-dev-env` is the name of the image to run.

CLI tools can then be authenticated within the container if needed. For example:

- `gh auth login`
- `aws configure`
- `az login`
- `gcloud auth login`

### For Hosts with CLI Tools Authenticated

For systems with AWS, Az, gcloud, and/or gh CLIs installed, the authentication can be passed through using volume mounts. The following example is for a host with GitHub CLI, and AWS CLI installed.

```sh
docker run \
    -e HOST_PROJECT=$(pwd) \
    --mount type=bind,source=$(pwd),target=/home/project \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    --mount type=bind,source=$HOME/.aws,target=/home/coder/.aws \
    --mount type=bind,source=$HOME/.config/gh/,target=/home/coder/.config/gh \
    -p1485:1485 \
    --name lab-dev-env \
    lab-dev-env
```

The following mount passes Azure CLI authentication through to the container:

```sh
    --mount type=bind,source=$HOME/.azure,target=/home/coder/.azure
```

The following mount passes Google Cloud CLI authentication through to the container:

```sh
    --mount type=bind,source=$HOME/.config/gcloud,target=/home/coder/.config/gcloud
```

## Using Container as a Development Environment

Navigate to `http://localhost:1485` in your browser to access the IDE. You will need to acknowledge that it is an insecure connection. This is because the certificate is self-signed. Some features require using HTTPS, so a self-signed certificate is used for running the server.

Most features of the IDE will work without trusting the certificate. However, some features like Markdown Preview will not work without trusting the certificate. [See HTTPS Certificate Errors to add trust](#https-certificate-errors).

### HTTPS Certificate Errors

To remove the certificate error, you can add the certificate to your trusted certificates. The certificate is located at `deploy-container/server.crt` in this repository. You can copy it to your host machine and add it to your trusted certificates.

The certificate was generated using

```sh
openssl req -x509 -out server.crt -keyout server.key \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=localhost' -extensions EXT -config <( \
   printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
```

#### Trusting the Certificate in MacOS

![MacOS Certificate Trust](https://user-images.githubusercontent.com/3911650/281890786-767a2446-26e2-498c-8bd1-398b004f66af.png)

In Finder, double-click `deploy-container/server.crt`. This adds and opens it in Keychain Access.
Double-click **localhost** in Keychain Access.
In the **Trust** section, change **When using this certificate** to **Always Trust**.
Your browser should now trust the certificate and features like Markdown Preview should work.

## Using Container as Remote Dev Container with VS Code

Not started
