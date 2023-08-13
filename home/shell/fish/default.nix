{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    plugins = [
      # Enable a plugin (here grc for colorized command output) from nixpkgs
      {
        name = "grc";
        src = pkgs.fishPlugins.grc;
      }
      {
        name = "z";
        src = pkgs.fishPlugins.z;
      }
      # Manually packaging and enable a plugin
      {
        name = "nvm";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "nvm.fish";
        };
      }
    ];
  };

}
