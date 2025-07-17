{ pkgs, ... }:

{
  users.users.work.packages = with pkgs; [
    # beekeeper-studio # SQL client
    code-cursor # AI-powered code editor built on vscode
    slack # Desktop client for Slack
    watchman # Watches files and takes action when they change
    windsurf # Agentic IDE powered by AI Flow paradigm
  ];

  services.postgresql = {
    enable = false;
    package = pkgs.postgresql_16;
    identMap = ''
      # ArbitraryMapName systemUser DBUser
        superuser_map    work       reader
    '';
  };
}
