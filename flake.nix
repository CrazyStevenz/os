{
  inputs.icedos.url = "github:icedos/core";
  # inputs.icedos.url = "path:/home/stef/code/os/.repos/core";

  outputs =
    { icedos, self, ... }:
    icedos.lib.mkIceDOS {
      configRoot = self;
    };
}
