{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (builtins) attrNames isList;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) either listOf package str enum bool nullOr;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;

  defaultServer = "julials";
  servers = {
    julials = {
      package = pkgs.julia.withPackages ["LanguageServer"];
      internalFormatter = true;
      lspConfig = ''
        lspconfig.julials.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''
            {
              "${optionalString (cfg.lsp.package != null) "${cfg.lsp.package}/bin/"}julia",
              "--startup-file=no",
              "--history-file=no",
              "--eval",
              [[
                using LanguageServer

                depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
                project_path = let
                    dirname(something(
                        ## 1. Finds an explicitly set project (JULIA_PROJECT)
                        Base.load_path_expand((
                            p = get(ENV, "JULIA_PROJECT", nothing);
                            p === nothing ? nothing : isempty(p) ? nothing : p
                        )),
                        ## 2. Look for a Project.toml file in the current working directory,
                        ##    or parent directories, with $HOME as an upper boundary
                        Base.current_project(),
                        ## 3. First entry in the load path
                        get(Base.load_path(), 1, nothing),
                        ## 4. Fallback to default global environment,
                        ##    this is more or less unreachable
                        Base.load_path_expand("@v#.#"),
                    ))
                end
                @info "Running language server" VERSION pwd() project_path depot_path
                server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)
                server.runlinter = true
                run(server)
              ]]
            }
          ''
        }
        }
      '';
    };
  };

  cfg = config.vim.languages.julia;
in {
  options = {
    vim.languages.julia = {
      enable = mkEnableOption "Julia language support";

      treesitter = {
        enable = mkEnableOption "Julia treesitter" // {default = config.vim.languages.enableTreesitter;};
        package = mkGrammarOption pkgs "julia";
      };

      lsp = {
        enable = mkOption {
          type = bool;
          default = config.vim.lsp.enable;
          description = ''
            Whether to enable Julia LSP support.

            ::: {.note}
            The entirety of Julia is bundled with nvf, if you enable this
            option, since there is no way to provide only the LSP server.

            If you want to avoid that, you have to change
            [](#opt-vim.languages.julia.lsp.package) to use the Julia binary
            in {env}`PATH` (set it to `null`), and add the `LanguageServer` package to
            Julia in your devshells.
            :::
          '';
        };

        server = mkOption {
          type = enum (attrNames servers);
          default = defaultServer;
          description = "Julia LSP server to use";
        };

        package = mkOption {
          description = ''
            Julia LSP server package, `null` to use the Julia binary in {env}`PATH`, or
            the command to run as a list of strings.
          '';
          type = nullOr (either package (listOf str));
          default = servers.${cfg.lsp.server}.package;
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.julia-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
