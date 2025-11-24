{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkRenamedOptionModule;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.strings) concatLines concatStringsSep optionalString;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.types) listOf str attrsOf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.spellcheck;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "spellChecking"] ["vim" "spellcheck"])
  ];

  options.vim.spellcheck = {
    enable = mkEnableOption "Neovim's built-in spellchecking";
    languages = mkOption {
      type = listOf str;
      default = ["en"];
      example = literalExpression ''["en" "de"]'';
      description = ''
        A list of languages that should be used for spellchecking.

        To add your own language files, you may place your `spell` directory in either
        {file}`$XDG_CONFIG_HOME/nvf` or in a path that is included in the
        [additionalRuntimePaths](#opt-vim.additionalRuntimePaths) list provided by nvf.
      '';
    };

    extraSpellWords = mkOption {
      type = attrsOf (listOf str);
      default = {};
      example = literalExpression ''{"en.utf-8" = ["nvf" "word_you_want_to_add"];}'';
      description = ''
        Additional words to be used for spellchecking. The names of each key will be
        used as the language code for the spell file. For example

        ```nix
        "en.utf-8" = [ ... ];
        ```

        will result in `en.utf-8.add.spl` being added to Neovim's runtime in the
        {file}`spell` directory.

        ::: {.warning}
        The attribute keys must be in `"<name>.<encoding>"` format for Neovim to
        compile your spellfiles without mangling the resulting file names. Please
        make sure that you enter the correct value, as nvf does not do any kind of
        internal checking. Please see {command}`:help mkspell` for more details.

        Example:

        ```nix
        # "en" is the name, and "utf-8" is the encoding. For most use cases, utf-8
        # will be enough, however, you may change it to any encoding format Neovim
        # accepts, e.g., utf-16.
        "en.utf-8" = ["nvf" "word_you_want_to_add"];
        => $out/spell/en-utf-8.add.spl
        ```
        :::

        Note that while adding a new language, you will still need to add the name of
        the language (e.g. "en") to the {option}`vim.spellcheck.languages` list by name
        in order to enable spellchecking for the language. By default only `"en"` is in
        the list.
      '';
    };

    ignoredFiletypes = mkOption {
      type = listOf str;
      default = ["toggleterm"];
      example = literalExpression ''["markdown" "gitcommit"]'';
      description = ''
        A list of filetypes for which spellchecking will be disabled.

        ::: {.tip}
        You may use {command}`:echo &filetype` in Neovim to find out the
        filetype for a specific buffer.
        :::
      '';
    };

    programmingWordlist.enable = mkEnableOption ''
      vim-dirtytalk, a wordlist for programmers containing
      common programming terms.

      ::: {.note}
      Enabling this option will unconditionally set
      {option}`vim.spellcheck.enable` to true as vim-dirtytalk
      depends on spellchecking having been set up.

      Run {command}`:DirtytalkUpdate` on first use to download the spellfile.
      :::
    '';
  };

  config = mkIf cfg.enable {
    vim = {
      additionalRuntimePaths = let
        compileJoinedSpellfiles =
          pkgs.runCommandLocal "nvf-compile-spellfiles" {
            # Use the same version of Neovim as the user's configuration
            nativeBuildInputs = [config.vim.package];

            spellfilesJoined = pkgs.symlinkJoin {
              name = "nvf-spellfiles-joined";
              paths = mapAttrsToList (name: value: pkgs.writeTextDir "spell/${name}.add" (concatLines value)) cfg.extraSpellWords;
              postBuild = "echo Spellfiles joined";
            };
          } ''
            # Fail on unset variables and non-zero exit codes
            # this might be the only way to trace when `nvim --headless`
            # fails in batch mode
            set -eu

            mkdir -p "$out/spell"
            for spellfile in "$spellfilesJoined"/spell/*.add; do
              name="$(basename "$spellfile" ".add")"
              echo "Compiling spellfile: $spellfile"
              nvim --headless --clean \
                --cmd "mkspell $out/spell/$name.add.spl $spellfile" -Es -n
            done
          '';
      in
        mkIf (cfg.extraSpellWords != {}) [
          # If .outPath is missing, additionalRuntimePaths receives the *function*
          # instead of a path, causing errors.
          compileJoinedSpellfiles.outPath
        ];

      options = {
        spell = true;

        # Workaround for Neovim's spelllang setup. It can be
        #  - a string, e.g., "en"
        #  - multiple strings, separated with commas, e.g., "en,de"
        # toLuaObject cannot generate the correct type here, unless we take a string here.
        spelllang = concatStringsSep "," cfg.languages;
      };

      # Register an autocommand to disable spellchecking in buffers with given filetypes.
      # If the list is empty, the autocommand does not need to be registered.
      luaConfigRC.spellcheck = entryAfter ["basic"] (optionalString (cfg.ignoredFiletypes != []) ''
        -- Disable spellchecking for certain filetypes
        -- as configured by `vim.spellcheck.ignoredFiletypes`
        vim.api.nvim_create_augroup("nvf_autocmds", {clear = false})
        vim.api.nvim_create_autocmd({ "FileType" }, {
          group = "nvf_autocmds",
          pattern = ${toLuaObject cfg.ignoredFiletypes},
          callback = function()
            vim.opt_local.spell = false
          end,
        })
      '');
    };
  };
}
