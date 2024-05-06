{
  nixosTest,
  nixosModules,
  ...
}:
nixosTest {
  name = "nixos-test";

  nodes.machine = {
    imports = [
      nixosModules.nvf
      ../profiles/minimal.nix
    ];

    config = {
      programs.nvf.enable = true;
    };
  };

  testScript = "";
}
