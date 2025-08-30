# Configuring supported LSP servers {#sec-languages-configuraing-lsp-servers}

One of the strengths of **nvf** is convenient aliases to quickly configure LSP
servers through the Nix module system. By default the LSP packages for relevant
language modules will be pulled into the closure. If this is not desirable, you
may modify [](#opt-vim.lsp.servers._name_.cmd) (see example below).

Any other forms of configuration can be done via [](#opt-vim.lsp.servers), which
is a wrapper for the Neovim Lua API available as`vim.lsp.config()`. Getting
familiar with `:help vim.lsp.config()` may help you better understand how to
configure LSPs.

```nix
{
  vim.languages.python = {
    enable = true;
    lsp = {
      enable = true;
      # You can now enable multiple LSPs per language
      servers = ["basedpyright"];
    };
  };

  # vim.lsp.servers is a wrapper for the lua API vim.lsp.config
  # (see :help vim.lsp.config)
  vim.lsp.servers = {
    basedpyright = {
      # `vim.languages.<lang>.lsp.package` is now removed, you have to
      # modify the cmd field, and remember to copy over the arguments!
      cmd = [(getExe pkgs.myCustomPackage) "--stdio"];

      # server specific settings, see documentation of the respective language
      # servers
      settings = {
        basedpyright.analysis.logLevel = "Error";
        python.pythonPath = getExe pkgs.myPython3;
      };
    };
  };
}
```
