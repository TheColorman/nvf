{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.types) int listOf str bool;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  options.vim.ui.illuminate = {
    enable = mkEnableOption ''
      automatic highlighting ofother uses of the word under the cursor [vim-illuminate]
    '';

    setupOpts = mkPluginSetupOption "illuminate" {
      providers = mkOption {
        type = luaInline;
        default = mkLuaInline ''{"lsp", "treesitter", "regex"}'';
        example = ''lib.generators.mkLuaInline "providers = {\"lsp\"}"'';
        description = ''
          Provider used to get references in the buffer, ordered by priority

          ::: {.warning}
          This option takes verbatim Lua code, which **must** be a table of
          providers in the order of desired priority. If using a function, you
          must make sure that the function returns a table of strings.
          :::
        '';
      };

      delay = mkOption {
        type = int;
        default = 120;
        example = 100;
        description = "Delay, in milliseconds";
      };

      filetype_overrides = mkOption {
        type = listOf str;
        default = [];
        description = ''
          Filetype specific overrides.

          The keys are strings to represent the filetype while the values are
          tables that supports the same keys passed to .configure except for
          `filetypes_denylist` and `filetypes`.
        '';
      };

      filetype_denylist = mkOption {
        type = listOf str;
        default = ["dirbuf" "dirvish" "fugitive" "NvimTree" "TelescopePrompt"];
        example = literalExpression ''mkForce [ ]'';
        description = ''
          Filetypes to not illuminate, this overrides filetypes_allowlist
        '';
      };

      files_allowlist = mkOption {
        type = listOf str;
        default = [];
        description = ''
          Filetypes to illuminate, this is overridden by filetypes_denylist

          ::: {.note}
          You must set `filetype_denylist` to an empty list with `mkForce [ ]`
          to override the defaults to allow filetypes_allowlist to take effect
          :::
        '';
      };

      modes_denylist = mkOption {
        type = listOf str;
        default = [];
        example = "no -- operator pending";
        description = ''
          Modes to not illuminate, this overrides modes_allowlist

          See `:help mode()` for possible values.
        '';
      };

      modes_allowlist = mkOption {
        type = listOf str;
        default = [];
        example = "no -- operator pending";
        description = ''
          Modes to illuminate, this is overridden by modes_denylist
          See `:help mode()` for possible values.
        '';
      };

      providers_regex_syntax_denylist = mkOption {
        type = listOf str;
        default = [];
        description = ''
          Syntax to illuminate, this overrides providers_regex_syntax_allowlist

          ::: {.note}
          Only applies to the 'regex' provider Use
          `:echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')`
          :::
        '';
      };

      providers_regex_syntax_allowlist = mkOption {
        type = listOf str;
        default = [];
        description = ''
          Syntax to not illuminate, this overrides providers_regex_syntax_denylist
          ::: {.note}
          Only applies to the 'regex' provider Use
          `:echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')`
          :::
        '';
      };

      under_cursor = mkOption {
        type = bool;
        default = true;
        description = "Whether or not to illuminate under the cursor";
      };

      large_file_cutoff = mkOption {
        type = luaInline;
        default = mkLuaInline "nil";
        description = ''
          Number of lines at which to use large_file_config
          The `under_cursor` option is disabled when this cutoff is hit
        '';
      };

      large_file_overrides = mkOption {
        type = luaInline;
        default = mkLuaInline "nil";
        example = literalExpression ''lib.generators.mkLuaInline "{providers = {\"lsp\"}, delay = 130 }"'';
        description = ''
          Config to use for large files (based on large_file_cutoff).

          Supports the same keys passed to .configure
          If nil, vim-illuminate will be disabled for large files.
        '';
      };

      min_count_to_highlight = mkOption {
        type = int;
        default = 1;
        description = ''
          Minimum number of matches required to perform highlighting
        '';
      };

      should_enable = mkOption {
        type = luaInline;
        default = mkLuaInline "function(bufnr) return true end";
        description = ''
          Acallback that overrides all other settings to
          enable/disable illumination.

          This will be called a lot so avoid doing anything expensive in it.
        '';
      };

      case_insensitive_regex = mkOption {
        type = bool;
        default = false;
        description = "Whether to enable regex case sensitivity";
      };
    };
  };
}
