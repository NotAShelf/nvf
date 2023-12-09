# Tidal Cycles {#sec-default-tidal}

```bash
$ nix run github:notashelf/neovim-flake#tidal file.tidal
```

Utilizing [vim-tidal](https://github.com/tidalcycles/vim-tidal) and mitchmindtree's fantastic
[tidalcycles.nix](https://github.com/mitchmindtree/tidalcycles.nix) start playing with tidal cycles in a single command.

In your tidal file, type a cycle e.g. `d1 $ s "drum"` and then press _ctrl+enter_. Super collider with superdirt, and a
modified GHCI with tidal will start up and begin playing. Note, you need jack enabled on your system. If you are using
pipewire, its as easy as setting `services.pipewire.jack.enable = true` in your configuration.
