{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum str bool;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  options.vim.utility = {
    leetcode-nvim = {
      enable = mkEnableOption "complementary neovim plugin for leetcode.nvim";

      setupOpts = mkPluginSetupOption "leetcode-nvim" {
        logging = mkEnableOption "Whether to log leetcode.nvim status notifications." // { default = true; };
        image_support = mkEnableOption "Whether to render question description images using image.nvim (image-nvim must be enabled)." // { default = false; };

        lang = mkOption {
          type = enum [
            "cpp"
            "java"
            "python"
            "python3"
            "c"
            "csharp"
            "javascript"
            "typescript"
            "php"
            "swift"
            "kotlin"
            "dart"
            "golang"
            "ruby"
            "scala"
            "rust"
            "racket"
            "erlang"
            "elixir"
            "bash"
          ];
          default = "python3";
          description = "Language to start your session with";
        };

        arg = mkOption {
          type = str;
          default = "leetcode.nvim";
          description = "Argument for Neovim";
        };

        cn = {
          enabled = mkEnableOption "Enable leetcode.cn instead of leetcode.com" // { default = false; };
          translator = mkOption {
            type = bool;
            default = true;
            description = "Enable translator";
          };

          translate_problems = mkOption {
            type = bool;
            default = true;
            description = "Enable translation for problem questions";
          };
        };

        storage = {
          home = mkOption {
            type = luaInline;
            default = mkLuaInline "vim.fn.stdpath(\"data\") .. \"/leetcode\"";
            description = "Home storage directory";
          };

          cache = mkOption {
            type = luaInline;
            default = mkLuaInline "vim.fn.stdpath(\"cache\") .. \"/leetcode\"";
            description = "Cache storage directory";
          };
        };

        plugins = {
          non_standalone = mkEnableOption "To run leetcode.nvim in a non-standalone mode" // { default = false; };
        };
      };
    };
  };
}
