{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    plugins = [
      # Enable a plugin (here grc for colorized command output) from nixpkgs
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
      # Manually packaging and enable a plugin
      # {
      #   name = "nvm";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "jorgebucaran";
      #     repo = "nvm.fish";
      #     rev = "2.2.13";
      #     sha256 = "sha256-LV5NiHfg4JOrcjW7hAasUSukT43UBNXGPi1oZWPbnCA=";
      #   };
      # }
    ];
  };

}
