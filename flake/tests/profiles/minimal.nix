{
  # he's a thicc boi
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
