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

  cfg = config.vim.lsp.presets.ccls;
in {
  options.vim.lsp.presets.ccls = {
    enable = mkLspPresetEnableOption "ccls" "CC" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.ccls = {
      enable = true;
      cmd = [(getExe pkgs.ccls)];
      offset_encoding = "utf-32";
      root_markers = [".git" ".ccls" "compile_commands.json"];
      workspace_required = true;
      on_attach = mkLuaInline ''
        function(client, bufnr)
          local function switch_source_header(bufnr)
            local method_name = "textDocument/switchSourceHeader"
            local params = vim.lsp.util.make_text_document_params(bufnr)
            client:request(method_name, params, function(err, result)
              if err then
                error(tostring(err))
              end
              if not result then
                vim.notify('corresponding file cannot be determined')
                return
              end
              vim.cmd.edit(vim.uri_to_fname(result))
            end, bufnr)
          end

          vim.api.nvim_buf_create_user_command(
            bufnr,
            "LspCclsSwitchSourceHeader",
            function(arg)
              switch_source_header(client, 0)
            end,
            {desc = "Switch between source/header"}
          )
        end
      '';
    };
  };
}
