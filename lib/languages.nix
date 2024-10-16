# From home-manager: https://github.com/nix-community/home-manager/blob/master/modules/lib/booleans.nix
{lib}: let
  inherit (builtins) isString getAttr;
  inherit (lib.options) mkOption;
  inherit (lib.types) bool;
  inherit (lib.meta) getExe;
  inherit (lib.strings) optionalString;
  inherit (lib.lists) optionals;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.lua) toLuaObject;
in {
  # A wrapper around `mkOption` to create a boolean option that is
  # used for Language Server modules.
  mkEnable = desc:
    mkOption {
      description = "Turn on ${desc} for enabled languages by default";
      type = bool;
      default = false;
    };

  # Converts a boolean to a yes/no string. This is used in lots of
  # configuration formats.
  diagnosticsToLua = {
    lang,
    config,
    diagnosticsProviders,
  }:
    mapListToAttrs
    (v: let
      type =
        if isString v
        then v
        else getAttr v.type;
      package =
        if isString v
        then diagnosticsProviders.${type}.package
        else v.package;
    in {
      name = "${lang}-diagnostics-${type}";
      value = diagnosticsProviders.${type}.nullConfig package;
    })
    config;

  # `mkLspConfig` is a helper function that generates a LspConfig configuration
  # from at least a name and a package,  optionally also `capabilities`, and
  # `on_attach`.
  # TODO: nixpkgs-like doc comments from that one RFC
  mkLspConfig = {
    # Mandatory arguments
    name,
    package,
    # Optional arguments for the sake of flexibility
    args ? [],
    cmd ? [(getExe package)] ++ optionals (args != []) args,
    capabilities ? "capabilities",
    on_attach ? "on_attach",
    init_opts ? "",
  }: let
    generatedConfig = {
      inherit cmd;
      capabilities = mkLuaInline capabilities;
      on_attach = mkLuaInline on_attach;
      init_opts = mkLuaInline (optionalString (init_opts != "") init_opts);
    };
  in {
    inherit package;
    lspConfig = ''
      lspconfig.${name}.setup(${toLuaObject generatedConfig})
    '';
  };
}
