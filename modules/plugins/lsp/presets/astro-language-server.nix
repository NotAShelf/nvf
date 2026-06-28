{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.astro-language-server;
in {
  options.vim.lsp.presets.astro-language-server = {
    enable = mkLspPresetEnableOption {
      option = "astro-language-server";
      display = "Astro";
      inherit config;
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.astro-language-server = {
      enable = true;
      cmd = [
        (getExe (pkgs.symlinkJoin {
          name = "astro-ls-wrapper";
          paths = [pkgs.astro-language-server];
          meta.mainProgram = "astro-ls";
          buildInputs = [pkgs.makeBinaryWrapper];
          postBuild = "wrapProgram $out/bin/astro-ls --prefix NODE_PATH : '${pkgs.typescript}/lib/node_modules'";
        }))
        "--stdio"
      ];
      root_markers = [".git" "package.json" "tsconfig.json" "jsconfig.json"];
      init_options.typescript = {};
      before_init = mkLuaInline ''
        function(_, config)
          if config.init_options and config.init_options.typescript and not config.init_options.typescript.tsdk then
            config.init_options.typescript.tsdk = util.get_typescript_server_path(config.root_dir)
          end
        end
      '';
    };
  };
}
