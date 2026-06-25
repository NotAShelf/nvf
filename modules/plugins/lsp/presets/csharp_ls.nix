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

  cfg = config.vim.lsp.presets.csharp_ls;
in {
  # HACK: this server should be named `csharp-ls`, but the extension `csharpls-extended-lsp-nvim` only works if it is named `csharp_ls`
  options.vim.lsp.presets.csharp_ls = {
    enable = mkLspPresetEnableOption "csharp_ls" "C#" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.csharp_ls = {
      cmd = mkLuaInline ''
        function(dispatchers, config)
           return vim.lsp.rpc.start({ '${getExe pkgs.csharp-ls}', '--features', 'razor-support' , '--features', 'metadata-uris'}, dispatchers, {
            -- csharp-ls attempt to locate sln, slnx or csproj files from cwd, so set cwd to root directory.
            -- If cmd_cwd is provided, use it instead.
            cwd = config.cmd_cwd or config.root_dir,
            env = config.cmd_env,
            detached = config.detached,
          })
        end
      '';
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
           local fname = vim.api.nvim_buf_get_name(bufnr)
           on_dir(util.root_pattern '*.sln'(fname) or util.root_pattern '*.slnx'(fname) or util.root_pattern '*.csproj'(fname))
         end
      '';
      init_options = {
        AutomaticWorkspaceInit = true;
      };
      get_language_id = mkLuaInline ''
        function(_, ft)
            if ft == 'cs' then
              return 'csharp'
            end
            return ft
          end
      '';
    };
  };
}
