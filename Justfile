download:
  curl -SL https://static.wolfgirl.dev/2025-07-29/qemu-aarch64.tar.zst -o qemu-aarch64.tar.zst && \
  zstd -d qemu-aarch64.tar.zst && \
  tar xvf qemu-aarch64.tar

reset:
  tar xvf qemu-aarch64.tar

run:
  qemu-system-aarch64 -M virt \
    -cpu max -smp 2 -m 8192 \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-pci,rng=rng0 \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::8022-:22 \
    -nographic \
    -drive if=pflash,format=raw,file=efi.img,readonly=on \
    -drive if=pflash,format=raw,file=varstore.img \
    -drive if=virtio,format=qcow2,file=qemu.qcow2 \
    # -device virtio-scsi-pci,id=scsi0 -device scsi-cd,drive=cd,bootindex=0 -drive if=none,id=cd,file=nixos-minimal-aarch64-linux.iso

switch:
  nixos-rebuild switch --flake .#qemu-aarch64 --target-host localhost-qemu
