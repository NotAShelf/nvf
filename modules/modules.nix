{
  pkgs,
  lib,
}: let
  inherit (lib.modules) mkDefault;
  inherit (lib.lists) concatLists;
  allModules = let
    # The core neovim modules.
    # Contains configuration for core neovim features
    # such as spellchecking, mappings, and the init script (init.vim).
    neovim = map (p: ./neovim + "/${p}") [
      "init"
      "mappings"
    ];

    # Individual plugin modules, separated by the type of plugin.
    # While adding a new type, you must make sure your type is
    # included in the list below.
    plugins = map (p: ./plugins + "/${p}") [
      "assistant"
      "autopairs"
      "comments"
      "completion"
      "dashboard"
      "debugger"
      "diagnostics"
      "filetree"
      "formatter"
      "git"
      "languages"
      "lsp"
      "mini"
      "minimap"
      "notes"
      "projects"
      "repl"
      "rich-presence"
      "runner"
      "session"
      "snippets"
      "spellcheck"
      "statusline"
      "tabline"
      "terminal"
      "theme"
      "treesitter"
      "ui"
      "utility"
      "visuals"
    ];

    # The neovim wrapper, used to build a wrapped neovim package
    # using the configuration passed in `neovim` and `plugins` modules.
    wrapper = map (p: ./wrapper + "/${p}") [
      "build"
      "environment"
      "rc"
      "warnings"
      "lazy"
    ];

    # Extra modules, such as deprecation warnings
    # or renames in one place.
    extra = map (p: ./extra + "/${p}") [
      "deprecations.nix"
    ];
  in
    concatLists [neovim plugins wrapper extra];
in
  allModules
  ++ [
    {
      _module.args = {
        baseModules = allModules;
        pkgsPath = mkDefault pkgs.path;
        pkgs = mkDefault pkgs;
      };
    }
  ]
