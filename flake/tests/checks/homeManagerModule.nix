{
  inputs,
  nixosTest,
  homeManagerModules,
  ...
}:
nixosTest {
  name = "home-manager-test";
  skipLint = true;

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

  testScript = ''
    import subprocess
    machine.wait_for_unit("default.target")

    def check_errs(process):
      # Check for errors
      print("Connecting to Neovim process")

      # Capture stdout and stderr
      stdout, stderr = process.communicate()

      # Print captured stdout and stderr
      if stdout:
        print("Captured stdout:")
        print(stdout.decode('utf-8'))
      if stderr:
        print("Captured stderr:")
        print(stderr.decode('utf-8'))

    def run_neovim_headless():
      print("Running Neovim in headless mode.")

      # Run Neovim in headless mode
      nvim_process = subprocess.Popen(['nvim', '--headless'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

      check_errs(nvim_process)

      # Load configuration file
      nvim_process.stdin.write(b':NonExistentCommand\n')
      nvim_process.stdin.flush()

    # run Neovim in headless mode
    # and expect it to return sucessfully
    machine.succeed(run_neovim_headless())
  '';
}
