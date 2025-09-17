{
  lib,
  config,
  ...
}: let
  inherit (builtins) toJSON typeOf head length filter concatLists concatStringsSep tryEval;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.lua) toLuaObject;
  cfg = config.vim.lazy;

  toLuaLznKeySpec = keySpec:
    (removeAttrs keySpec ["key" "lua" "action"])
    // {
      "@1" = keySpec.key;
      "@2" =
        if keySpec.lua
        then mkLuaInline keySpec.action
        else keySpec.action;
    };

  toLuaLznSpec = name: spec: let
    packageName =
      if typeOf spec.package == "string"
      then spec.package
      else if (spec.package ? pname && (tryEval spec.package.pname).success)
      then spec.package.pname
      else spec.package.name;
  in
    (removeAttrs spec ["package" "setupModule" "setupOpts" "keys"])
    // {
      "@1" =
        if spec.package != null && packageName != name && spec.load == null
        then
          abort ''
            vim.lazy.plugins.${name} does not match the package name ${packageName}.

            Please either:
            - rename it to vim.lazy.plugins.${packageName}, or
            - if you intend to use a custom loader, specify a
              vim.lazy.plugins.${name}.load function.
          ''
        else if spec.package == null && spec.load == null
        then
          abort ''
            vim.lazy.plugins.${name} has null package but no load function given.

            Please either specify a package, or (if you know what you're doing) provide a
            custom load function.
          ''
        else name;
      beforeAll =
        if spec.beforeAll != null
        then
          mkLuaInline ''
            function()
              ${spec.beforeAll}
            end
          ''
        else null;
      before =
        if spec.before != null
        then
          mkLuaInline ''
            function()
              ${spec.before}
            end
          ''
        else null;

      after =
        if spec.setupModule == null && spec.after == null
        then null
        else
          mkLuaInline ''
            function()
              ${optionalString (spec.beforeSetup != null) spec.beforeSetup}
              ${
              optionalString (spec.setupModule != null)
              "require(${toJSON spec.setupModule}).setup(${toLuaObject spec.setupOpts})"
            }
              ${optionalString (spec.after != null) spec.after}
            end
          '';

      load =
        if spec.load != null
        then
          mkLuaInline ''
            function(name)
              ${spec.load}
            end
          ''
        else null;

      keys =
        if typeOf spec.keys == "list" && length spec.keys > 0 && typeOf (head spec.keys) == "set"
        then map toLuaLznKeySpec (filter (keySpec: keySpec.key != null) spec.keys)
        # empty list or str or (listOf str)
        else spec.keys;
    };
  lznSpecs = mapAttrsToList toLuaLznSpec cfg.plugins;

  pluginPackages = filter (x: x != null) (mapAttrsToList (_: plugin: plugin.package) cfg.plugins);

  specToNotLazyConfig = _: spec: ''
    do
      ${optionalString (spec.before != null) spec.before}
      ${optionalString (spec.setupModule != null)
      "require(${toJSON spec.setupModule}).setup(${toLuaObject spec.setupOpts})"}
      ${optionalString (spec.after != null) spec.after}
    end
  '';

  specToKeymaps = _: spec:
    if typeOf spec.keys == "list"
    then map (x: removeAttrs x ["ft"]) (filter (lznKey: lznKey.action != null && lznKey.ft == null) spec.keys)
    else if spec.keys == null || typeOf spec.keys == "string"
    then []
    else [spec.keys];

  notLazyConfig =
    concatStringsSep "\n"
    (mapAttrsToList specToNotLazyConfig cfg.plugins);

  beforeAllJoined =
    concatStringsSep "\n"
    (filter (x: x != null) (mapAttrsToList (_: spec: spec.beforeAll) cfg.plugins));
in {
  config.vim = mkMerge [
    (mkIf cfg.enable {
      startPlugins = ["lz-n" "lzn-auto-require"];

      optPlugins = pluginPackages;
      augroups = [{name = "nvf_lazy_file_hooks";}];
      autocmds = [
        {
          event = ["BufReadPost" "BufNewFile" "BufWritePre"];
          group = "nvf_lazy_file_hooks";
          command = "doautocmd User LazyFile";
          once = true;
        }
      ];

      lazy.builtLazyConfig = ''
        ${optionalString (length lznSpecs > 0) "require('lz.n').load(${toLuaObject lznSpecs})"}
        ${optionalString cfg.enableLznAutoRequire "require('lzn-auto-require').enable()"}
      '';
    })

    (mkIf (!cfg.enable) {
      startPlugins = pluginPackages;
      lazy.builtLazyConfig = ''
        ${beforeAllJoined}
        ${notLazyConfig}
      '';
      keymaps = concatLists (mapAttrsToList specToKeymaps cfg.plugins);
    })
  ];
}
