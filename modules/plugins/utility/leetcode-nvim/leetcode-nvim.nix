{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum str;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  options.vim.utility = {
    leetcode-nvim = {
      enable = mkEnableOption "complementary neovim plugin for leetcode.nvim";

      setupOpts = mkPluginSetupOption "leetcode-nvim" {
        logging = mkEnableOption "logging for leetcode.nvim status notifications." // {default = true;};
        image_support = mkEnableOption "question description images using image.nvim (image-nvim must be enabled).";

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
          enabled = mkEnableOption "leetcode.cn instead of leetcode.com";
          translator = mkEnableOption "translator" // {default = true;};
          translate_problems = mkEnableOption "translation for problem questions" // {default = true;};
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
          non_standalone = mkEnableOption "leetcode.nvim in a non-standalone mode";
        };
      };
    };
  };
}
