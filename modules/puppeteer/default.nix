{ pkgs, ... }:

{
  environment.variables = {
    PUPPETEER_EXECUTABLE_PATH = "/run/current-system/sw/bin/helium";
  };
}
