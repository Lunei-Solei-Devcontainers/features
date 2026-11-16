# Lunei Solei Devcontainers Features (lunei-solei-devcontainers/features)
This repo contains custom features created to be used with [devcontainers](https://github.com/devcontainers/images).

For more information, see [devcontainer features](https://github.com/devcontainers/features).

## Table of Contents
* [Usage](#usage)
* [Contributing](#contributing)
    * [Contributors](#contributors)
* [Code of Conduct](#code-of-conduct)
* [License](#license)

## Usage
To use a feature from this repository, add the desired feature(s) to a `devcontainer.json` file. Each feature has a `README.md`
located within its directory declared in the `[./src](src)` directory.

Example `devcontainer.json`
```
{
    "name": "Example Devcontainer",
    "image": "ghcr.io/lunei-solei-devcontainers/dotnet",
    "features": {
        "ghcr.io/lunei-solei-devcontainers/features/gpg-connect:1": { }
    }
}
```

> [!NOTE]
> The `:latest` version annotation is added implicitly, if omitted. To pin to a specific version, append it to the end of the
> feature. All features in this repository follow [Semantic Versioning](https://semver.org/) conventions and thus support
> pinning to any major `:1`, minor `:1.0`, or patch `1.0.0` version by specifying the appropriate annotation.

## Security
For inquiries regarding anything related to this repository's security, see the [Security Guidelines](docs/SECURITY.md).

## Contributing
If you are interested in contributing, consult the repo's global [Contribution Guidelines](docs/CONTRIBUTING.md).

### Contributors
<a href="https://github.com/lunei-solei-devcontainers/features/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=lunei-solei-devcontainers/features" />
</a>

## Code of Conduct
See this repo's global [Code of Conduct](docs/CODE_OF_CONDUCT.md).

## License
[MIT](LICENSE) © Lunei Solei (@luneisolei)
