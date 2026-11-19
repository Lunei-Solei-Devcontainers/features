# GPG Connect (gpg-connect)

A custom [devcontainer feature](https://github.com/devcontainers/features) that allows the importing of public GPG keys from provided source files
on the host machine.

This feature is two-fold and is separated into the exporting and importing of GPG keys. The first part of the process is exporting the public GPG keys
from the host machine. The second part of this process is importing the keys and that's where this feature comes in. This feature reads these files 
and attempts to automatically configure git to use any provided key(s) for signing.

## Usage
1) Create the relevant export files containing the key(s) you wish to import. This can be done via:
* Using the provided [export script](export-gpg-keys.sh).
* Manually creating the required `./tmp/.gpg-export.gpg` and `./tmp/.gpg-export.meta` files either in the container workspace itself or in the directory
to be mounted as the container's workspace.

2) In your `devcontainer.json` file:
```
{
    "features": {
        "ghcr.io/lunei-solei-devcontainers/features/gpg-connect:1": { }
    },
    "mounts": [
        "source=<PATH_TO_YOUR_GPG_AGENT_EXTRA_SOCKET>,target=/home/devcontainer/.gnupg/S.gpg-agent,type=bind"
    ]
}
```
> [!NOTE]
> The path to your GPG agent's extra socket will vary depending on which OS your local machine is running. To obtain this location, you can run the following
> in a terminal:
> ```
> gpgconf --list-dir agent-extra-socket
> ```

> [!TIP]
> `devcontainer` is the name of the default user when using [Lunei Solei Devcontainers images](https://github.com/lunei-solei-devcontainers/images). You
> can change this value to match your custom `remoteUser` if you wish.
