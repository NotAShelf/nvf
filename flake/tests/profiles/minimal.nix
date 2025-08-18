# The 'minimal' test profile for nvf. This exposes the bare minimum for defining the test
# VMs. If an addition is test-specific (e.g., targeting at a specific functionality) then
# it does not belong here. However machine configuration that must be propagated to *all*
# tests should be defined here.
{
  virtualisation = {
    cores = 2;
    memorySize = 2048;
    qemu.options = ["-vga none -enable-kvm -device virtio-gpu-pci,xres=720,yres=1440"];
  };

  users.users.test = {
    isNormalUser = true;
    password = "";
  };
}
