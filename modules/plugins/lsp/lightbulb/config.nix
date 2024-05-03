{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.lsp;
in {
  config = mkIf (cfg.enable && cfg.lightbulb.enable) {
    vim = {
      startPlugins = ["nvim-lightbulb"];

      luaConfigRC.lightbulb = entryAnywhere ''
        require("nvim-lightbulb").setup(${toLuaObject cfg.lightbulb.setupOpts})
      '';
    };
  };
}
