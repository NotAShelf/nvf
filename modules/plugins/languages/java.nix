{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.types) listOf str enum;
  inherit (lib.attrsets) attrNames genAttrs;
  inherit (lib.lists) flatten;
  inherit (lib.meta) getExe;
  inherit (lib.generators) mkLuaInline toPretty;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;

  cfg = config.vim.languages.java;

  defaultServers = ["jdt-language-server"];
  servers = ["jdt-language-server" "jls" "intellij-server"];

  defaultFormat = ["astyle"];
  formats = ["astyle" "injected"];

  defaultDebugger = ["jls"];
  dapConfigurations = {
    jls = [
      {
        type = "jls";
        request = "attach";
        name = "Attach Auto";
        hostName = "localhost";
        port = 5005;
        sourceRoots = mkLuaInline ''
          function()
            local matches = {}

            -- only look max 3 deep, due to performance reasons
            for _, pattern in ipairs({
              "src/main/java",
              "*/src/main/java",
              "*/*/src/main/java",
              "*/*/*/src/main/java",
            }) do
              vim.list_extend(
                matches,
                vim.tbl_map(
                  function(path)
                    return vim.fn.fnamemodify(path, ":p")
                  end,
                  vim.fn.glob(pattern, true, true)
                )
              )
            end

            return matches
          end
        '';
      }
      {
        type = "jls";
        request = "attach";
        name = "Attach Manual";
        hostName = "localhost";
        port = 5005;
        sourceRoots = mkLuaInline ''
          function()
            local path = nvf_dap_cached_input(
              "java_jls_attach_root",
              "Path to src/main/java: ",
              vim.fn.getcwd() .. "/",
              "dir"
            )

            if path == "" then
              return {}
            end

            return { vim.fn.fnamemodify(path, ":p") }
          end
        '';
      }
    ];
    intellij-server = [
      {
        type = "intellij-server";
        request = "launch";
        name = "Launch";
        mainClass = mkLuaInline ''
          function()
            return coroutine.create(function(dap_run_co)
              local buf = vim.api.nvim_get_current_buf()
              local uri = vim.uri_from_fname(vim.api.nvim_buf_get_name(buf))
              local client = vim.lsp.get_clients({ name = "intellij-server", bufnr = buf })[1]

              local function finish(main_class)
                coroutine.resume(dap_run_co, main_class or "")
              end

              if not client then
                vim.notify(
                  "intellij-server DAP: LSP not running, cannot discover main classes",
                  vim.log.levels.ERROR
                )
                return finish(nvf_dap_cached_input(
                  "java_intellij_main_class",
                  "Main Class: ",
                  "",
                  "customlist,v:lua.nvf_no_completion"
                ))
              end

              client:request("textDocument/documentSymbol", {
                textDocument = { uri = uri },
              }, function(err, symbols)
                vim.schedule(function()
                  local mains = {}

                  local package_name
                  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
                    package_name = line:match("^%s*package%s+([%w_%.]+)%s*;")
                    if package_name then
                      break
                    end
                  end

                  local function find_mains(items)
                    for _, symbol in ipairs(items or {}) do
                      if not symbol.children then
                          goto continue
                      end

                      local has_main = false

                      for _, child in ipairs(symbol.children) do
                        if child.name == "main" then
                          has_main = true
                          break
                        end
                      end

                      if has_main then
                        local class_name = symbol.name
                        if package_name and package_name ~= "" then
                          class_name = package_name .. "." .. class_name
                        end
                        table.insert(mains, class_name)
                      end

                      find_mains(symbol.children)
                      ::continue::
                    end
                  end

                  if not err then
                    find_mains(symbols)
                  end

                  if #mains == 0 then
                    vim.notify(
                      "intellij-server DAP: no main entry points found, enter one manually",
                      vim.log.levels.WARN
                    )
                  end

                  _G.nvf_java_main_completion = function()
                    return mains
                  end

                  finish(nvf_dap_cached_input(
                    "java_intellij_main_class",
                    "Main Class: ",
                    mains[1] or "",
                    "customlist,v:lua.nvf_java_main_completion"
                  ))
                end)
              end, buf)
            end)
          end
        '';
      }
    ];
  };
in {
  options.vim.languages.java = {
    enable = mkEnableOption "Java language support";

    treesitter = {
      enable =
        mkEnableOption "Java treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "java";
    };

    lsp = {
      enable =
        mkEnableOption "Java LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Java LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Java formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = listOf (enum formats);
        default = defaultFormat;
        description = "Java formatter to use";
      };
    };

    dap = {
      enable =
        mkEnableOption "Java Debug Adapter"
        // {
          default = config.vim.languages.enableDAP;
          defaultText = literalExpression "config.vim.languages.enableDAP";
        };

      debugger = mkOption {
        type = listOf (enum (attrNames dapConfigurations));
        default = defaultDebugger;
        description = ''
          Java debugger to use.

          **JLS**

          For `jls` to work, you need to run your application with debug
          symbols and networking.

          The `jls` configuration is hardcoded to listen on port `5005`. This
          matches the configuration described
          [upstream](https://github.com/idelice/jls#usage). You can change this
          by modifying {option}`vim.debugger.nvim-dap.configurations.java`.
          ```nix
          # mkForce can be omitted if you want to retain our default
          # configurations
          vim.debugger.nvim-dap.configurations.java =
            lib.mkForce
            ${toPretty {indent = "  ";} dapConfigurations.jls};
          ```

          *Examples:*

          - Manual:
            1. Build with debug symbols.
               ```sh
               javac -g ...
               ```
            1. Run with debug socket.
               ```sh
               java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 -jar your.jar
               ```
          - Springboot Maven:
            For Springboot you can just pass the JVM args directly into the
            `spring-boot:run`.
            ```sh
            mvn spring-boot:run -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
            ```
        '';
      };
    };

    extensions = {
      maven-nvim = {
        enable = mkEnableOption "maven integration";
        setupOpts = mkPluginSetupOption "maven-nvim" {
          mvn_executable = mkOption {
            type = str;
            default = getExe pkgs.maven;
            defaultText = literalExpression "getExe pkgs.maven";
            description = ''
              The maven executable to use.
            '';
            example = ''
              - `"mvn"`: to use the maven from the `PATH`.
              - `"./mvnw"`: to use the projects maven.
              - `"$${getExe pkgs.maven}"`: to use maven from a nix package.
            '';
          };
        };
      };
      gradle-nvim = {
        enable = mkEnableOption "gradle integration";
        setupOpts = mkPluginSetupOption "gradle-nvim" {
          gadle_executable = mkOption {
            type = str;
            default = getExe pkgs.gradle;
            defaultText = literalExpression "getExe pkgs.gradle";
            description = ''
              The gradle executable to use.
            '';
            example = ''
              - `"gradle"`: to use the gradle from the `PATH`.
              - `"$${getExe pkgs.gradle}"`: to use gradle from a nix package.
            '';
          };
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
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["java"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.java = cfg.format.type;
      };
    })

    (mkIf cfg.dap.enable {
      vim.debugger.nvim-dap = {
        enable = true;
        presets = genAttrs cfg.dap.debugger (_: {enable = true;});
        configurations.java = flatten (map (name: dapConfigurations.${name}) cfg.dap.debugger);
      };
    })

    (mkIf cfg.extensions.maven-nvim.enable {
      vim = mkMerge [
        {
          startPlugins = ["nui-nvim" "plenary-nvim"];
          lazy.plugins.maven-nvim = {
            package = "maven-nvim";
            setupModule = "maven";
            cmd = [
              "Maven"
              "MavenExec"
              "MavenFavorites"
              "MavenInit"
            ];
            setupOpts = cfg.extensions.maven-nvim.setupOpts;
          };
        }
      ];
    })

    (mkIf cfg.extensions.gradle-nvim.enable {
      vim = mkMerge [
        {
          startPlugins = ["nui-nvim" "plenary-nvim"];
          lazy.plugins.gradle-nvim = {
            package = "gradle-nvim";
            setupModule = "gradle";
            cmd = [
              "Gradle"
              "GradleExec"
              "GradleFavorites"
              "GradleInit"
            ];
            setupOpts = cfg.extensions.gradle-nvim.setupOpts;
          };
        }
      ];
    })
  ]);
}
