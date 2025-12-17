{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    profiles.default.extensions = [];
  };

  home.packages = with pkgs; [
    antigravity-fhs
  ];
}
