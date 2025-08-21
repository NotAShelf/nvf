{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.attrsets) attrValues filterAttrs mapAttrsToList;
  inherit (lib.lists) map optional optionals elem;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (builtins) concatStringsSep typeOf tryEval attrNames mapAttrs removeAttrs;

  cfg = config.vim.autocomplete.blink-cmp;
  cmpCfg = config.vim.autocomplete.nvim-cmp;
  inherit (cfg) mappings;

  getPluginName = plugin:
    if typeOf plugin == "string"
    then plugin
    else if (plugin ? pname && (tryEval plugin.pname).success)
    then plugin.pname
    else plugin.name;

  enabledBlinkSources = filterAttrs (_source: definition: definition.enable) cfg.sourcePlugins;
  blinkSourcePlugins = map (definition: definition.package) (attrValues enabledBlinkSources);

  blinkBuiltins = [
    "path"
    "lsp"
    "snippets"
    "buffer"
    "omni"
  ];
in {
  assertions =
    mapAttrsToList (provider: definition: {
      assertion = elem provider blinkBuiltins || definition.module != null;
      message = "`config.vim.autocomplete.blink-cmp.setupOpts.sources.providers.${provider}.module` is `null`: non-builtin providers must set `module`.";
    })
    cfg.setupOpts.sources.providers;

  vim = mkIf cfg.enable {
    startPlugins = ["blink-compat"] ++ blinkSourcePlugins ++ (optional cfg.friendly-snippets.enable "friendly-snippets");
    lazy.plugins = {
      blink-cmp = {
        package = "blink-cmp";
        setupModule = "blink.cmp";
        inherit (cfg) setupOpts;

        # TODO: lazy disabled until lspconfig is lazy loaded
        #
        # event = ["InsertEnter" "CmdlineEnter"];

        after =
          # lua
          ''
            ${optionalString (config.vim.lazy.enable && cmpCfg.enable)
              (concatStringsSep "\n" (map
                (package: "require('lz.n').trigger_load(${toLuaObject (getPluginName package)})")
                cmpCfg.sourcePlugins))}
          '';
      };
    };

    autocomplete = {
      enableSharedCmpSources = true;
      blink-cmp.setupOpts = {
        sources = let
          # We do not want nvim-cmp compat sources overriding built-in blink sources
          filteredCmpSources = removeAttrs cmpCfg.sources blinkBuiltins;
        in {
          default =
            [
              "lsp"
              "path"
              "snippets"
              "buffer"
            ]
            ++ optionals cmpCfg.enable (attrNames filteredCmpSources)
            ++ (attrNames enabledBlinkSources);
          providers =
            optionalAttrs cmpCfg.enable (
              mapAttrs (name: _: {
                inherit name;
                module = "blink.compat.source";
              })
              filteredCmpSources
            )
            // (mapAttrs (name: definition: {
                inherit name;
                inherit (definition) module;
              })
              enabledBlinkSources);
        };
        snippets = mkIf config.vim.snippets.luasnip.enable {
          preset = "luasnip";
        };

        keymap = {
          ${mappings.complete} = ["show" "fallback"];
          ${mappings.close} = ["hide" "fallback"];
          ${mappings.scrollDocsUp} = ["scroll_documentation_up" "fallback"];
          ${mappings.scrollDocsDown} = ["scroll_documentation_down" "fallback"];
          ${mappings.confirm} = ["accept" "fallback"];

          ${mappings.next} = [
            "select_next"
            "snippet_forward"
            (mkLuaInline
              # lua
              ''
                function(cmp)
                  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                  has_words_before = col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil

                  if has_words_before then
                    return cmp.show()
                  end
                end
              '')
            "fallback"
          ];
          ${mappings.previous} = [
            "select_prev"
            "snippet_backward"
            "fallback"
          ];
        };

        # cmdline is not enabled by default, we're just providing keymaps in
        # case the user enables them
        cmdline.keymap = {
          ${mappings.complete} = ["show" "fallback"];
          ${mappings.close} = ["hide" "fallback"];
          ${mappings.scrollDocsUp} = ["scroll_documentation_up" "fallback"];
          ${mappings.scrollDocsDown} = ["scroll_documentation_down" "fallback"];
          # NOTE: mappings.confirm is skipped because our default, <CR> would
          # lead to accidental triggers of blink.accept instead of executing
          # the cmd

          ${mappings.next} = ["select_next" "show" "fallback"];
          ${mappings.previous} = ["select_prev" "fallback"];
        };
      };
    };
  };
}
