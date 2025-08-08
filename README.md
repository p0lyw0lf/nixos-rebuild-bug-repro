# Reproducing A Bug In `nixos-rebuild`

The bug: `nixos-rebuild` has trouble in the reexec step when deploying to
target hosts of a different architecture than the build host; it seems to run
that step on the build host instead of the target host, and also with
`nixos-rebuild-ng`?

These instructions will walk through getting an aarch64 VM running on an x86_64
machine to reproduce this bug.

## 1. Get A aarch64 NixOS Install

If you trust me, run:

```
just download
```

to use a version I've prepared ahead of time. This will download the following
files into your current directory:

+ `qemu.qcow2`: the virtual machine's hard drive
+ `efi.img`: the virtual machine's bootloader
+ `varstore.img`: the virtual machine's EFI variable storage 

Otherwise, run

```
./gen-qemu-firmware.sh
```

to generate these files fresh, download a Minimal NixOS ISO from
<https://nixos.org/download/>, uncomment the line regarding CDs in the
Justfile, and follow the [Installation Guide][1] in the following step.

## 2. Set Up Your aarch64 NixOS Install

Use

```
just run
```

to run the qemu VM. This creates an SSH server accessible at port 8022 on your
host machine. You will have to copy you ssh key inside the VM manually, goes
something like:

```
echo "ssh-ed25519 AAA..." >> /root/.ssh/authorized_keys
```

once you're logged in, where "ssh-ed25519 AAA..." is the output of

```
cat ~/.ssh/id_ed25519.pub
```

on your host machine.

The default root password inside the VM is root.

## 3. Run `nixos-rebuild`

Run

```
just switch
```

to run `nixos-rebuild` targeting the VM with a config that should be identical
to what it has built fresh from just being installed. This should trigger the
bug.

What the bug looks like is output like:

```
/nix/store/wc80xdvck636v0yr74nawpy26n27z7w6-nixos-rebuild-ng-0.0.0/bin/.nixos-rebuild-wrapped: /nix/store/wc80xdvck636v0yr74nawpy26n27z7w6-nixos-rebuild-ng-0.0.0/bin/nixos-rebuild: line 3: syntax error near unexpected token `lambda'
/nix/store/wc80xdvck636v0yr74nawpy26n27z7w6-nixos-rebuild-ng-0.0.0/bin/.nixos-rebuild-wrapped: /nix/store/wc80xdvck636v0yr74nawpy26n27z7w6-nixos-rebuild-ng-0.0.0/bin/nixos-rebuild: line 3: `import sys;import site;import functools;sys.argv[0] = '/nix/store/wc80xdvck636v0yr74nawpy26n27z7w6-nixos-rebuild-ng-0.0.0/bin/nixos-rebuild';functools.reduce(lambda k, p: site.addsitedir(p, k), ['/nix/store/wc80xdvck636v0yr74nawpy26n27z7w6-nixos-rebuild-ng-0.0.0/lib/python3.13/site-packages'], site._init_pathinfo());'
```

Inspecting these store paths manually, we find that they are for an aarch64
environment, yet are running on an x86_64 host (somehow??), breaking
catastrophically at some point. Inspecting the VM, we can confirm these store
paths never make it there.

I do not know why `nixos-rebuild` did a re-exec of `nixos-rebuild-ng`, nor why
that re-exec is for entirely the wrong architecture, but I guess that's why
it's a bug :P

NOTE: fortunately, it seems this bug doesn't trigger on latest nixos-unstable,
just the one before I ran `nix flake update`? Anyways, keeping this up for
posterity just in case :)

[1]: https://nixos.wiki/wiki/NixOS_Installation_Guide
