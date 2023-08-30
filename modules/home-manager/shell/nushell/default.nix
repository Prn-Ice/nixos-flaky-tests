{
  programs.nushell = {
    enable = false;
    configFile.source = ./config.nu;
    envFile.source = ./env.nu;
  };
}
