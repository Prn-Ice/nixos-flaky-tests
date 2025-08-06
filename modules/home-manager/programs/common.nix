{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # command line tools
    fastfetch
    grc

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # networking tools
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    asciinema

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor
    graphviz
    zgrviewer
    nix-du

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    lshw
    clinfo
    glxinfo
    vulkan-tools
    xdg-utils # for xdg-open etc.

    # communication
    slack
    discord
    zoom-us
    # Failing build
    # megasync
    localsend
    transmission_4-qt6

    # vpn
    protonvpn-gui

    # editor
    typora
  ];

  programs = {
    starship = {
      enable = true;
      # custom settings
      settings = {
        add_newline = false;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
      };
    };

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };
  };
}
