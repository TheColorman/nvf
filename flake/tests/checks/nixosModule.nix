{
  nixosTest,
  nixosModules,
  ...
}:
nixosTest {
  name = "home-manager-test";

  nodes.machine = {
    imports = [
      nixosModules.nvf
      ../profiles/minimal.nix
    ];

    programs.nvf.enable = true;
  };

  testScript = "";
}
