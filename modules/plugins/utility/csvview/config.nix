{
  options,
  config,
  lib,
  ...
}: let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.utility.csvview;

  keys = cfg.mappings;
  inherit (options.vim.utility.csvview) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins.csvview-nvim = {
        package = "csvview-nvim";
        setupModule = "csvview";
        inherit (cfg) setupOpts;

        cmd = ["CsvViewEnable" "CsvViewDisable" "CsvViewToggle" "CsvViewInfo"];

        keys = [
          (mkKeymap "n" keys.toggle "<cmd>CsvViewToggle<CR>" {desc = mappings.toggle.description;})
        ];
      };

      # csvview.nvim has no built-in auto-enable, so drive it with a FileType
      # autocommand. The `is_enabled` guard keeps this idempotent so
      # re-firing FileType (e.g. `:e!`, `:set ft=csv`) doesn't warn about an
      # already-attached buffer.
      autocmds = mkIf cfg.autoEnable [
        {
          event = ["FileType"];
          pattern = ["csv" "tsv"];
          callback = mkLuaInline ''
            function(args)
              if not require("csvview").is_enabled(args.buf) then
                require("csvview").enable()
              end
            end
          '';
          desc = "Automatically enable CSV view for CSV/TSV files";
        }
      ];
    };
  };
}
