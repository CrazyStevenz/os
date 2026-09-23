{ ... }:

{
  inputs.claude-code = {
    url = "github:sadjow/claude-code-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs.nixosModules =
    { inputs, ... }:
    [
      {
        nixpkgs.overlays = [ inputs.claude-code.overlays.default ];
      }
    ];
}
