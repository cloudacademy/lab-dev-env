# lab-dev-env

## Build

```sh
docker build --platform linux/amd64 -t lab-dev-env .
```

## Using Container as a Development Environment

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
