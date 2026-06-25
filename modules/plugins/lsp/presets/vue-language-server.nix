{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.vue-language-server;
in {
  options.vim.lsp.presets.vue-language-server = {
    enable = mkEnableOption ''
      the Vue.js Language Server.

      This LSP doesn't work standalone and requires either
      {option}`vim.lsp.presets.vtsls.enable`
      or
      {option}`vim.lsp.presets.typescript-language-server.enable`
      to work as expected.

      Default `filetypes = ${lib.generators.toPretty {} []}`. \
      Use {option}`vim.lsp.servers.vue-language-server` for customization
    '';
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.vue-language-server = {
      enable = true;
      cmd = [(getExe pkgs.vue-language-server) "--stdio"];
      root_markers = [".git" "tsconfig.json" "package.json"];
      on_init =
        mkLuaInline
        # This LSP doesn't work standalone and requires a TypeScripts LSP to work.
        # It can work with `typescript-language-server`, but it is not great, thus we prefer `vtsls`
        ''
          function(client)
            retries = 0
            local function typescriptHandler(_, result, context)
              local function getLSP(name)
                return vim.lsp.get_clients({ bufnr = context.bufnr, name = name})[1]
              end

              local typescipt_lsp = getLSP('vtsls') or getLSP('typescript-language-server')
              if not typescipt_lsp then
                if retries <= 10 then
                  retries = retries + 1
                  vim.defer_fn(function()
                    typescriptHandler(_, result, context)
                  end, 100)
                else
                  vim.notify(
                    'Could not find `vtsls`, `typescript-language-server`, or `typescript-go` lsp, required by `vue-language-server`.',
                    vim.log.levels.ERROR
                  )
                end
                return
              end

              local param = unpack(result)
              local id, command, payload = unpack(param)
              typescipt_lsp:exec_cmd({
                title = 'vue-language-server-forwarded',
                command = 'typescript.tsserverRequest',
                arguments = {
                  command,
                  payload,
                },
              }, { bufnr = context.bufnr }, function(_, r)
                local response_data = { { id, r and r.body } }
                client:notify('tsserver/response', response_data)
              end)
            end

            client.handlers['tsserver/request'] = typescriptHandler
          end
        '';
    };
  };
}
