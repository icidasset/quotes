> __“Quotes”__
> — Steven Vandevelde


# Development

This project uses Nix to manage the project's environment. If you'd like to build this project without Nix, check out the dependencies in the `shell.nix` file (most are available through Homebrew as well).

```shell
# Install javascript dependencies
just install-deps

# Build, serve, watch
just
```


# Dependencies

| Project      | Version |
| ------------ | ------- |
| nodejs.org   | ^18     |
