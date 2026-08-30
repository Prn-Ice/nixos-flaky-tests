{ ... }:

{
  security.polkit = {
    enable = true;
    enablePkexecWrapper = true;
  };

  # rtkit is optional but recommended
  security.rtkit.enable = true;
}
