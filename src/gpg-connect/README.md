# GPG Connect (gpg-connect)

A custom [devcontainer feature](https://github.com/devcontainers/features) that allows the importing of public GPG keys from provided source files
on the host machine.

This feature is two-fold and is separated into the exporting and importing of GPG keys. The first part of the process is exporting the public GPG keys
from the host machine. The second part of this process is importing the keys and that's where this feature comes in. This feature reads these files 
and attempts to automatically configure git to use any provided key(s) for signing.

## Table of Contents
* [Usage](#usage)
* [Contributing](#contributing)
    * [Contributors](#contributors)
* [Code of Conduct](#code-of-conduct)
* [License](#license)

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
    }
}
```

## Contributing
If you are interested in contributing, consult the repo's global [Contribution Guidelines](../../docs/CONTRIBUTING.md).

### Contributors
<a href="https://github.com/lunei-solei-devcontainers/features/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=lunei-solei-devcontainers/features" />
</a>

## Code of Conduct
See this repo's global [Code of Conduct](../../docs/CODE_OF_CONDUCT.md).

## License
[MIT](../../LICENSE) © Lunei Solei (@luneisolei)
