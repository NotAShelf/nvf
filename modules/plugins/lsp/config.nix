{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;
  inherit (lib.trivial) boolToString;
  inherit (lib.nvim.binds) addDescriptionsToMappings;

  cfg = config.vim.lsp;
  usingNvimCmp = config.vim.autocomplete.nvim-cmp.enable;
  usingBlinkCmp = config.vim.autocomplete.blink-cmp.enable;
  self = import ./module.nix {inherit config lib pkgs;};

  mappingDefinitions = self.options.vim.lsp.mappings;
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

        -- Enable formatting
        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

        format_callback = function(client, bufnr)
          if vim.g.formatsave then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                ${
          if config.vim.lsp.null-ls.enable
          then ''
            if vim.b.disableFormatSave then
              return
            end

            local function is_null_ls_formatting_enabled(bufnr)
                local file_type = vim.api.nvim_buf_get_option(bufnr, "filetype")
                local generators = require("null-ls.generators").get_available(
                    file_type,
                    require("null-ls.methods").internal.FORMATTING
                )
                return #generators > 0
            end

            if is_null_ls_formatting_enabled(bufnr) then
               vim.lsp.buf.format({
                  bufnr = bufnr,
                  filter = function(client)
                    return client.name == "null-ls"
                  end
                })
            else
                vim.lsp.buf.format({
                  bufnr = bufnr,
                })
            end
          ''
          else "
              vim.lsp.buf.format({
                bufnr = bufnr,
              })
        "
        }
              end,
            })
          end
        end

        ${optionalString config.vim.ui.breadcrumbs.enable ''local navic = require("nvim-navic")''}
        default_on_attach = function(client, bufnr)
          attach_keymaps(client, bufnr)
          format_callback(client, bufnr)
          ${optionalString config.vim.ui.breadcrumbs.enable ''
          -- let navic attach to buffers
          if client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
          end
        ''}
        end

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        ${optionalString usingNvimCmp ''
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
