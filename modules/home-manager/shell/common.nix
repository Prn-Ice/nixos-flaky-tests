{ pkgs, ... }:
# nix tooling
{
  home.packages = with pkgs; [
    alejandra
    deadnix
    statix
    nil
    nixd
    nixfmt-rfc-style
    devbox
    shfmt
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  # Enable nix index for fish
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };
}
