let
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  packages = [
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.pyqt6
      python-pkgs.ffmpeg-python
      python-pkgs.opencv4
      python-pkgs.pillow
    ]))
  ];
}
