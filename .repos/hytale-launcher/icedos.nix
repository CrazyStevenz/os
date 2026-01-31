{ ... }:

{
  inputs.hytale-launcher = {
    url = "github:JPyke3/hytale-launcher-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs.nixosModules =
    { inputs, ... }:
    [
      {
        environment.systemPackages = [
          inputs.hytale-launcher.packages.x86_64-linux.default
        ];
      }
    ];

  meta.name = "default";
}
