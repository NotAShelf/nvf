{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optional;
  inherit (lib.strings) optionalString;
  inherit (lib.trivial) boolToString;
  inherit (lib.nvim.binds) addDescriptionsToMappings;

  cfg = config.vim.lsp;
  usingNvimCmp = config.vim.autocomplete.nvim-cmp.enable;
  usingBlinkCmp = config.vim.autocomplete.blink-cmp.enable;
  conformCfg = config.vim.formatter.conform-nvim;
  conformFormatOnSave = conformCfg.enable && conformCfg.setupOpts.format_on_save != null;

  augroup = "nvf_lsp";
  mappingDefinitions = options.vim.lsp.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
  mkBinding = binding: action:
    if binding.value != null
    then "vim.keymap.set('n', '${binding.value}', ${action}, {buffer=bufnr, noremap=true, silent=true, desc='${binding.description}'})"
    else "";
in {
  config = mkIf cfg.enable {
    vim = {
      autocomplete.nvim-cmp = mkIf usingNvimCmp {
        sources = {nvim_lsp = "[LSP]";};
        sourcePlugins = ["cmp-nvim-lsp"];
      };

      augroups = [{name = augroup;}];
      autocmds =
        (optional cfg.inlayHints.enable {
          group = augroup;
          event = ["LspAttach"];
          desc = "LSP on-attach enable inlay hints autocmd";
          callback = mkLuaInline ''
            function(event)
              local bufnr = event.buf
              local client = vim.lsp.get_client_by_id(event.data.client_id)
              if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
              end
            end
          '';
        })
        ++ (optional (!conformFormatOnSave) {
          group = augroup;
          event = ["BufWritePre"];
          desc = "LSP on-attach create format on save autocmd";
          callback = mkLuaInline ''
            function(ev)
              if vim.b.disableFormatSave or not vim.g.formatsave then
                return
              end

              local bufnr = ev.buf

              ${optionalString cfg.null-ls.enable ''
              -- prefer null_ls formatter
              do
                local clients = vim.lsp.get_clients({
                  bufnr = bufnr,
                  name = "null-ls",
                  method = "textDocument/formatting",
                })
                if clients[1] then
                  vim.lsp.buf.format({ bufnr = bufnr, id = clients[1].id })
                  return
                end
              end
            ''}

              local clients = vim.lsp.get_clients({
                bufnr = bufnr,
                method = "textDocument/formatting",
              })
              if clients[1] then
                vim.lsp.buf.format({ bufnr = bufnr, id = clients[1].id })
              end
            end
          '';
        });

      pluginRC.lsp-setup = ''
        vim.g.formatsave = ${boolToString cfg.formatOnSave};

        local attach_keymaps = function(client, bufnr)
          ${mkBinding mappings.goToDeclaration "vim.lsp.buf.declaration"}
          ${mkBinding mappings.goToDefinition "vim.lsp.buf.definition"}
          ${mkBinding mappings.goToType "vim.lsp.buf.type_definition"}
          ${mkBinding mappings.listImplementations "vim.lsp.buf.implementation"}
          ${mkBinding mappings.listReferences "vim.lsp.buf.references"}
          ${mkBinding mappings.nextDiagnostic "vim.diagnostic.goto_next"}
          ${mkBinding mappings.previousDiagnostic "vim.diagnostic.goto_prev"}
          ${mkBinding mappings.openDiagnosticFloat "vim.diagnostic.open_float"}
          ${mkBinding mappings.documentHighlight "vim.lsp.buf.document_highlight"}
          ${mkBinding mappings.listDocumentSymbols "vim.lsp.buf.document_symbol"}
          ${mkBinding mappings.addWorkspaceFolder "vim.lsp.buf.add_workspace_folder"}
          ${mkBinding mappings.removeWorkspaceFolder "vim.lsp.buf.remove_workspace_folder"}
          ${mkBinding mappings.listWorkspaceFolders "function() vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders())) end"}
          ${mkBinding mappings.listWorkspaceSymbols "vim.lsp.buf.workspace_symbol"}
          ${mkBinding mappings.hover "vim.lsp.buf.hover"}
          ${mkBinding mappings.signatureHelp "vim.lsp.buf.signature_help"}
          ${mkBinding mappings.renameSymbol "vim.lsp.buf.rename"}
          ${mkBinding mappings.codeAction "vim.lsp.buf.code_action"}
          ${mkBinding mappings.format "vim.lsp.buf.format"}
          ${mkBinding mappings.toggleFormatOnSave "function() vim.b.disableFormatSave = not vim.b.disableFormatSave end"}
        end

        ${optionalString config.vim.ui.breadcrumbs.enable ''local navic = require("nvim-navic")''}
        default_on_attach = function(client, bufnr)
          attach_keymaps(client, bufnr)
          ${optionalString config.vim.ui.breadcrumbs.enable ''
          -- let navic attach to buffers
          if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
          end
        ''}
        end

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        ${optionalString usingNvimCmp ''
          -- TODO(horriblename): migrate to vim.lsp.config['*']
          -- HACK: copied from cmp-nvim-lsp. If we ever lazy load lspconfig we
          -- should re-evaluate whether we can just use `default_capabilities`
          capabilities = {
            textDocument = {
              completion = {
                dynamicRegistration = false,
                completionItem = {
                  snippetSupport = true,
                  commitCharactersSupport = true,
                  deprecatedSupport = true,
                  preselectSupport = true,
                  tagSupport = {
                    valueSet = {
                      1, -- Deprecated
                    }
                  },
                  insertReplaceSupport = true,
                  resolveSupport = {
                    properties = {
                      "documentation",
                      "detail",
                      "additionalTextEdits",
                      "sortText",
                      "filterText",
                      "insertText",
                      "textEdit",
                      "insertTextFormat",
                      "insertTextMode",
                    },
                  },
                  insertTextModeSupport = {
                    valueSet = {
                      1, -- asIs
                      2, -- adjustIndentation
                    }
                  },
                  labelDetailsSupport = true,
                },
                contextSupport = true,
                insertTextMode = 1,
                completionList = {
                  itemDefaults = {
                    'commitCharacters',
                    'editRange',
                    'insertTextFormat',
                    'insertTextMode',
                    'data',
                  }
                }
              },
            },
          }
        ''}

        ${optionalString usingBlinkCmp ''
          capabilities = require('blink.cmp').get_lsp_capabilities()
        ''}
      '';
    };
  };
}
