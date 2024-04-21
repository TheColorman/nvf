{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.lists) isList;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.strings) optionalString;
  inherit (lib.trivial) boolToString;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.languages.dart;
  ftcfg = cfg.flutter-tools;
  servers = {
    dart = {
      package = pkgs.dart;
      lspConfig = ''
        lspconfig.dartls.setup{
          capabilities = capabilities;
          on_attach=default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/dart", "language-server", "--protocol=lsp"}''
        };
          ${optionalString (cfg.lsp.opts != null) "init_options = ${cfg.lsp.dartOpts}"}
        }
      '';
    };
  };
in {
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.dart-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf ftcfg.enable {
      vim.startPlugins =
        if ftcfg.enableNoResolvePatch
        then ["flutter-tools-patched"]
        else ["flutter-tools"];

      vim.luaConfigRC.flutter-tools = entryAnywhere ''
        require('flutter-tools').setup {
          lsp = {
            color = {
              enabled = ${boolToString ftcfg.color.enable},
              background = ${boolToString ftcfg.color.highlightBackground},
              foreground = ${boolToString ftcfg.color.highlightForeground},
              virtual_text = ${boolToString ftcfg.color.virtualText.enable},
              virtual_text_str = ${toString ftcfg.color.virtualText.character}
            },

            capabilities = capabilities,
            on_attach = default_on_attach;
            flags = lsp_flags,
          },
          ${optionalString cfg.dap.enable ''
          debugger = {
            enabled = true,
          },
        ''}
        }
      '';
    })
  ]);
}
