# SoundCloud Desktop — Nix Flake

This is a fork of [zxcloli666/SoundCloud-Desktop](https://github.com/zxcloli666/SoundCloud-Desktop) that provides a [Nix flake](https://nixos.wiki/wiki/Flakes) for building and installing the app. No upstream application code is modified — only Nix packaging is maintained here.

For the original project, features, and documentation, see the [upstream repository](https://github.com/zxcloli666/SoundCloud-Desktop).

## Usage

Run directly:
```bash
nix run github:g-pavlik/SoundCloud-Desktop?ref=nix-flake-v6.8.0
```

Install to profile:
```bash
nix profile install github:g-pavlik/SoundCloud-Desktop?ref=nix-flake-v6.8.0
```

As a flake input:
```nix
{
  inputs.soundcloud-desktop.url = "github:g-pavlik/SoundCloud-Desktop?ref=nix-flake-v6.8.0";
}
```

## Versions

| Tag | Upstream |
|-----|----------|
| `nix-flake-v6.8.0` | [6.8.0](https://github.com/zxcloli666/SoundCloud-Desktop/releases/tag/6.8.0) |
| `nix-flake-v6.7.2` | [6.7.2](https://github.com/zxcloli666/SoundCloud-Desktop/releases/tag/6.7.2) |
| `nix-flake-v6.6.0` | [6.6.0](https://github.com/zxcloli666/SoundCloud-Desktop/releases/tag/6.6.0) |
| `nix-flake-v6.5.1` | [6.5.1](https://github.com/zxcloli666/SoundCloud-Desktop/releases/tag/6.5.1) |
| `nix-flake-v6.3.0` | [6.3.0](https://github.com/zxcloli666/SoundCloud-Desktop/releases/tag/6.3.0) |

## License

[MIT](LICENSE) — same as upstream.
