let
  # RTX 3070
  gpuIDs = [
    "10de:249d" # Graphics
    "10de:228b" # Audio
  ];
in
{ pkgs, lib, config, ... }: {
  # options.vfio.enable = with lib;
  #   mkEnableOption "Configure the machine for VFIO";
  options.vfio = with lib; {
    enable = mkEnableOption "Configure the machine for Nvidia VFIO passthrough";
  };

  config =
    let cfg = config.vfio;
    in
    lib.mkIf cfg.enable
      {
        boot = {
          initrd.kernelModules = [
            "vfio_pci"
            "vfio"
            "vfio_iommu_type1"
          ];

          kernelParams = [
            # enable IOMMU
            "amd_iommu=on"
          ] ++ lib.optional cfg.enable
            # isolate the GPU
            ("vfio-pci.ids=" + lib.concatStringsSep "," gpuIDs);
        };

        virtualisation.spiceUSBRedirection.enable = true;
        hardware.opengl.enable = true;
      };
}
