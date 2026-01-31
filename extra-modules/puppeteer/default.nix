{ pkgs, ... }:

{
  environment.variables = {
    PUPPETEER_EXECUTABLE_PATH = "${pkgs.ungoogled-chromium}/bin/chromium";
  };
}
