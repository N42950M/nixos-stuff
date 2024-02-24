# WTF IS THIS LOL
{ pkgs ? import <nixpkgs> {} }:
(pkgs.buildFHSUserEnv {
  name = "python";
  targetPkgs = pkgs: (with pkgs; [
    python311
    python311Packages.pip
    virtualenv
    libxkbcommon
    libGL
    libglibutil
    glib
    glibc
    fontconfig
    xorg.libX11
    zlib
    freetype
    zstd
    dbus
    libkrb5
  ]);
  runScript = "bash";
}
).env
