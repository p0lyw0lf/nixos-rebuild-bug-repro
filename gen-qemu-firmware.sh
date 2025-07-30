#!/usr/bin/env bash

set -euo pipefail

# From https://cdn.kernel.org/pub/linux/kernel/people/will/docs/qemu/qemu-arm64-howto.html

if [ ! -f varstore.img ]; then
  truncate -s 64m varstore.img
fi

if [ ! -f efi.img ]; then
  efi_fd="$(dirname $(which qemu-system-aarch64))/../share/qemu/edk2-aarch64-code.fd"
  truncate -s 64m efi.img
  dd if=${efi_fd} of=efi.img conv=notrunc
fi

if [ ! -f qemu.qcow2 ]; then
  qemu-img create -f qcow2 qemu.qcow2 40G
fi
