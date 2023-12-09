# Old Method {#sec-old-method}

Users who have not yet updated to 0.5, or prefer a more hands-on approach may use the old method where the load order
of the plugins is determined by DAGs.

```nix
{
  # fetch plugin source from GitHub and add it to startPlugins
  config.vim.startPlugins = [
    (pkgs.fetchFromGitHub {
      owner = "FrenzyExists";
      repo = "aquarium-vim";
      rev = "d09b1feda1148797aa5ff0dbca8d8e3256d028d5";
      sha256 = "CtyEhCcGxxok6xFQ09feWpdEBIYHH+GIFVOaNZx10Bs=";
    })
  ];
}
```
