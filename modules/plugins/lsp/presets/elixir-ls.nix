{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.elixir-ls;
in {
  options.vim.lsp.presets.elixir-ls = {
    enable = mkLspPresetEnableOption {
      option = "elixir-ls";
      display = "Elixir";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.elixir-ls = {
      enable = true;
      cmd = ["${pkgs.elixir-ls}/bin/elixir-ls"];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local matches = vim.fs.find({ 'mix.exs' }, { upward = true, limit = 2, path = fname })
          local child_or_root_path, maybe_umbrella_path = unpack(matches)
          local root_dir = vim.fs.dirname(maybe_umbrella_path or child_or_root_path)

          on_dir(root_dir)
        end
      '';
    };
  };
}
