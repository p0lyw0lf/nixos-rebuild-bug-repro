{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    age
    just
    nixos-rebuild
    qemu
    ssh-to-age
    zstd
  ];

  env = { };

  shellHook = ''

  '';
}
