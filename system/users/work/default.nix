{ pkgs, ... }:

{
  users.users.work.packages = with pkgs; [
    beekeeper-studio # SQL client
    slack # Desktop client for Slack
    watchman # Watches files and takes action when they change
  ];
}
