{
  inputs,
  nixosTest,
  homeManagerModules,
  ...
}:
nixosTest {
  name = "home-manager-test";

  nodes.machine = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      ../profiles/minimal.nix
    ];

    home-manager = {
      sharedModules = [
        homeManagerModules.nvf
      ];

      users.test = {
        programs.nvf.enable = true;
      };
    };
  };

  testScript = "";
}
