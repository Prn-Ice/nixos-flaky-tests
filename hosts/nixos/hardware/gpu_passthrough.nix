let
  # RTX 3070
  gpuIDs = [
    "10de:249d" # Graphics
    "10de:228b" # Audio
  ];
in
{ lib, config, ... }: {
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
            # isolate the GPU
            "vfio-pci.ids=${lib.concatStringsSep "," gpuIDs}"
          ];

          extraModprobeConfig = "options vfio-pci ids=${lib.concatStringsSep "," gpuIDs}";
        };

        hardware.opengl.enable = true;
      };
}
