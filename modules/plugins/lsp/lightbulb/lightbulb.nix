{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) bool enum int str nullOr listOf;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  options.vim.lsp = {
    lightbulb = {
      enable = mkEnableOption "Lightbulb for code actions. Requires an emoji font";
      setupOpts = mkPluginSetupOption "lightbulb" {
        priority = mkOption {
          type = int;
          default = 10;
          description = "Priority of the lightbulb for all handlers except float";
        };

        hide_in_unfocused_buffer = mkOption {
          type = bool;
          default = true;
          description = "Whether to hide the lightbulb when the buffer is not focused";
        };

        link_highlights = mkOption {
          type = bool;
          default = true;
          description = ''
            Whether or not to link the highlight groups automatically.

            Default highlight group links:
            - LightBulbSign -> DiagnosticSignInfo
            - LightBulbFloatWin -> DiagnosticFloatingInfo
            - LightBulbVirtualText -> DiagnosticVirtualTextInfo
            - LightBulbNumber -> DiagnosticSignInfo
            - LightBulbLine -> CursorLine
          '';
        };

        validate_config = mkOption {
          type = enum ["always" "never" "auto"];
          default = "auto";
          description = "Whether to perform full validation of configuration";
        };

        action_kinds = mkOption {
          type = nullOr (listOf str);
          default = null;
          description = "The kind of action to show";
        };

        # 1. Sign Column
        # this is the default
        sign = {
          enabled = mkEnableOption "sign column" // {default = true;};
          text = mkOption {
            type = str;
            default = "💡";
            description = ''
              Text to show in the sign column.

              Must be between 1-2 characters
            '';
          };

          hl = mkOption {
            type = str;
            default = "LightBulbSign";
            description = "Highlight group to highlight the sign column text";
          };
        };

        # 2. Virtual Text
        virtual_text = {
          enabled = mkEnableOption "virtual text";
          text = mkOption {
            type = str;
            default = "💡";
            description = ''
              Text to show in the virt_text.
              Must be between 1-2 characters.
            '';
          };

          pos = mkOption {
            type = luaInline;
            default = mkLuaInline "eol";
            description = ''
              Position of virtual text given to `|nvim_buf_set_extmark|`.

              - Can be a number representing a fixed column (see `virt_text_pos`).
              - Can be a string representing a position (see `virt_text_win_col`).
            '';
          };

          hl = mkOption {
            type = str;
            default = "LightBulbVirtualText";
            description = "Highlight group to highlight the virtual text";
          };

          hl_mode = mkOption {
            type = enum ["combine" "replace"];
            default = "combine";
            description = ''
              How to apply the highlight group to the virtual text.

              See `hl_mode` of |nvim_buf_set_extmark|.
            '';
          };
        };

        # 3. Floating Window
        float = {
          enabled = mkEnableOption "float";
          text = mkOption {
            type = str;
            default = "💡";
            description = "Text to show in the floating window";
          };

          hl = mkOption {
            type = str;
            default = "LightBulbFloatWin";
            description = "Highlight group to highlight the floating window";
          };

          win_opts = mkOption {
            type = luaInline;
            default = mkLuaInline "{focusable = true}";
            description = ''
              Window options.
              See `|vim.lsp.util.open_floating_preview|` and `|nvim_open_win|`.
              Note that some options may be overridden by `|open_floating_preview|`.
            '';
          };
        };

        # 4. Status Text
        status_text = {
          enabled = mkEnableOption "status text";
          text = mkOption {
            type = str;
            default = "💡";
            description = "Text to set if a lightbulb is available.";
          };

          text_unavailable = mkOption {
            type = str;
            default = "";
            description = "Text to set if a lightbulb is unavailable";
          };
        };

        # 5. Number Column
        number = {
          enabled = mkEnableOption "number column";
          hl = mkOption {
            type = str;
            default = "LightBulbNumber";
            description = "Highlight group to highlight the number column if there is a lightbulb";
          };
        };

        # 6. Content line
        line = {
          enabled = mkEnableOption "content line";
          hl = mkOption {
            type = str;
            default = "LightBulbLine";
            description = "Highlight group to highlight the line if there is a lightbulb";
          };
        };

        autocmd = {
          enabled = mkEnableOption "autocmd creation" // {default = true;};
          updatetime = mkOption {
            type = int;
            default = 200;
            description = "Set to a negative value to avoid setting the updatetime";
          };

          events = mkOption {
            type = listOf str;
            default = ["CursorHold" "CursorHoldI"];
            description = "Events to trigger the autocmd on";
          };

          pattern = mkOption {
            type = luaInline;
            default = mkLuaInline "{'*'}";
            description = "Pattern to match the autocmd on";
          };
        };

        ignore = {
          clients = mkOption {
            type = listOf str;
            default = [];
            example = ["null-ls" "lua_ls"];
            description = "LSP client names to ignore.";
          };

          ft = mkOption {
            type = listOf str;
            default = [];
            example = ["neo-tree" "lua"];
            description = "Filetypes to ignore.";
          };

          actions_without_kinds = mkOption {
            type = bool;
            default = false;
            example = true;
            description = "Ignore code actions without a `kind` like `refactor.rewrite`, quickfix";
          };
        };
      };
    };
  };
}
