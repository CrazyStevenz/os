{ pkgs, ... }:

{
  users.users.work.packages = with pkgs; [
    slack # Desktop client for Slack
    warp
    watchman # Watches files and takes action when they change
  ];
}
