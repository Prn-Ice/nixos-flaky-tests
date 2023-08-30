{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-design-icons

      # normal fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji

      # nerdfonts
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    ];
  };
}
