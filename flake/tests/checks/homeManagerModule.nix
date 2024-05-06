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

    config = {
      home-manager = {
        sharedModules = [
          homeManagerModules.nvf
        ];

        users.test = {
          home.stateVersion = "24.05";
          programs.nvf.enable = true;
        };
      };
    };
  };

  testScript = "";
}
