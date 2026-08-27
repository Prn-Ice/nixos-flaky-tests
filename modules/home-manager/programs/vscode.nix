{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    # profiles.default.extensions = with pkgs.vscode-extensions; [
    #   anthropic.claude-code
    # ];
  };

  home.packages = with pkgs; [
    antigravity-ide-fhs
  ];
}
