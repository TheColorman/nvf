{
  lib,
  config,
  ...
}:
with lib;
with builtins; {
  options.vim = {
    autocomplete = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "enable autocomplete";
      };

      type = mkOption {
        type = types.enum ["nvim-cmp"];
        default = "nvim-cmp";
        description = "Set the autocomplete plugin. Options: [nvim-cmp]";
      };
    };
  };
}
