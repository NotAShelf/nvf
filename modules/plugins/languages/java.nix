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
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption deprecatedSingleOrListOf enumWithRename;

  cfg = config.vim.languages.java;

  defaultServers = ["jdt-language-server"];
  servers = ["jdt-language-server" "jls"];

  defaultFormat = ["astyle"];
  formats = ["astyle"];

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
              vim.list_extend(matches, vim.fn.glob(pattern, true, true))
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
        type = listOf (enumWithRename
          "vim.languages.java.lsp.servers"
          servers
          {
            jdtls = "jdt-language-server";
          });
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
        type =
          deprecatedSingleOrListOf "vim.languages.java.dap.debugger"
          (enum (attrNames dapConfigurations));
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
            setupOpts = cfg.extensions.gradle-nvim.setupOpts;
          };
        }
      ];
    })
  ]);
}
