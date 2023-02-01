{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim;

  wrapLuaConfig = luaConfig: ''
    lua << EOF
    ${luaConfig}
    EOF
  '';

  mkMappingOption = it:
    mkOption ({
        default = {};
        type = with types; attrsOf (nullOr str);
      }
      // it);
in {
  options.vim = {
    viAlias = mkOption {
      description = "Enable vi alias";
      type = types.bool;
      default = true;
    };

    vimAlias = mkOption {
      description = "Enable vim alias";
      type = types.bool;
      default = true;
    };

    configRC = mkOption {
      description = "vimrc contents";
      type = nvim.types.dagOf types.lines;
      default = {};
    };

    luaConfigRC = mkOption {
      description = "vim lua config";
      type = nvim.types.dagOf types.lines;
      default = {};
    };

    builtConfigRC = mkOption {
      internal = true;
      type = types.lines;
      description = "The built config for neovim after resolving the DAG";
    };

    startPlugins = nvim.types.pluginsOpt {
      default = [];
      description = "List of plugins to startup.";
    };

    optPlugins = nvim.types.pluginsOpt {
      default = [];
      description = "List of plugins to optionally load";
    };

    globals = mkOption {
      default = {};
      description = "Set containing global variable values";
      type = types.attrs;
    };

    nnoremap =
      mkMappingOption {description = "Defines 'Normal mode' mappings";};

    inoremap = mkMappingOption {
      description = "Defines 'Insert and Replace mode' mappings";
    };

    vnoremap = mkMappingOption {
      description = "Defines 'Visual and Select mode' mappings";
    };

    xnoremap =
      mkMappingOption {description = "Defines 'Visual mode' mappings";};

    snoremap =
      mkMappingOption {description = "Defines 'Select mode' mappings";};

    cnoremap =
      mkMappingOption {description = "Defines 'Command-line mode' mappings";};

    onoremap = mkMappingOption {
      description = "Defines 'Operator pending mode' mappings";
    };

    tnoremap =
      mkMappingOption {description = "Defines 'Terminal mode' mappings";};

    nmap = mkMappingOption {description = "Defines 'Normal mode' mappings";};

    imap = mkMappingOption {
      description = "Defines 'Insert and Replace mode' mappings";
    };

    vmap = mkMappingOption {
      description = "Defines 'Visual and Select mode' mappings";
    };

    xmap = mkMappingOption {description = "Defines 'Visual mode' mappings";};

    smap = mkMappingOption {description = "Defines 'Select mode' mappings";};

    cmap =
      mkMappingOption {description = "Defines 'Command-line mode' mappings";};

    omap = mkMappingOption {
      description = "Defines 'Operator pending mode' mappings";
    };

    tmap =
      mkMappingOption {description = "Defines 'Terminal mode' mappings";};
  };

  config = let
    mkVimBool = val:
      if val
      then "1"
      else "0";
    valToVim = val:
      if (isInt val)
      then (builtins.toString val)
      else
        (
          if (isBool val)
          then (mkVimBool val)
          else (toJSON val)
        );

    filterNonNull = mappings: filterAttrs (name: value: value != null) mappings;
    globalsScript =
      mapAttrsFlatten (name: value: "let g:${name}=${valToVim value}")
      (filterNonNull cfg.globals);

    matchCtrl = it: match "Ctrl-(.)(.*)" it;
    mapKeyBinding = it: let
      groups = matchCtrl it;
    in
      if groups == null
      then it
      else "<C-${toUpper (head groups)}>${head (tail groups)}";
    mapVimBinding = prefix: mappings:
      mapAttrsFlatten (name: value: "${prefix} ${mapKeyBinding name} ${value}")
      (filterNonNull mappings);

    nmap = mapVimBinding "nmap" config.vim.nmap;
    imap = mapVimBinding "imap" config.vim.imap;
    vmap = mapVimBinding "vmap" config.vim.vmap;
    xmap = mapVimBinding "xmap" config.vim.xmap;
    smap = mapVimBinding "smap" config.vim.smap;
    cmap = mapVimBinding "cmap" config.vim.cmap;
    omap = mapVimBinding "omap" config.vim.omap;
    tmap = mapVimBinding "tmap" config.vim.tmap;

    nnoremap = mapVimBinding "nnoremap" config.vim.nnoremap;
    inoremap = mapVimBinding "inoremap" config.vim.inoremap;
    vnoremap = mapVimBinding "vnoremap" config.vim.vnoremap;
    xnoremap = mapVimBinding "xnoremap" config.vim.xnoremap;
    snoremap = mapVimBinding "snoremap" config.vim.snoremap;
    cnoremap = mapVimBinding "cnoremap" config.vim.cnoremap;
    onoremap = mapVimBinding "onoremap" config.vim.onoremap;
    tnoremap = mapVimBinding "tnoremap" config.vim.tnoremap;

    resolveDag = {
      name,
      dag,
      mapResult,
    }: let
      sortedDag = nvim.dag.topoSort dag;
      result =
        if sortedDag ? result
        then mapResult sortedDag.result
        else abort ("Dependency cycle in ${name}: " + toJSON sortedConfig);
    in
      result;
  in {
    vim = {
      configRC = {
        globalsScript = nvim.dag.entryAnywhere (concatStringsSep "\n" globalsScript);

        luaScript = let
          mkSection = r: ''
            -- SECTION: ${r.name}
            ${r.data}
          '';
          mapResult = r: (wrapLuaConfig (concatStringsSep "\n" (map mkSection r)));
          luaConfig = resolveDag {
            name = "lua config script";
            dag = cfg.luaConfigRC;
            inherit mapResult;
          };
        in
          nvim.dag.entryAfter ["globalsScript"] luaConfig;

        mappings = let
          maps = [nmap imap vmap xmap smap cmap omap tmap nnoremap inoremap vnoremap xnoremap snoremap cnoremap onoremap tnoremap];
          mapConfig = concatStringsSep "\n" (map (v: concatStringsSep "\n" v) maps);
        in
          nvim.dag.entryAfter ["globalsScript"] mapConfig;
      };

      builtConfigRC = let
        mkSection = r: ''
          " SECTION: ${r.name}
          ${r.data}
        '';
        mapResult = r: (concatStringsSep "\n" (map mkSection r));
        vimConfig = resolveDag {
          name = "vim config script";
          dag = cfg.configRC;
          inherit mapResult;
        };
      in
        vimConfig;
    };
  };
}
