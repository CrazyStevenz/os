{ pkgs, ... }:

{
  users.users.work.packages = with pkgs; [
    beekeeper-studio # SQL client
    google-cloud-sdk
    slack # Desktop client for Slack
    watchman # Watches files and takes action when they change
  ];
}
