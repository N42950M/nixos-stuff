let
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  packages = [
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.certifi
      python-pkgs.colorama
      python-pkgs.pysocks
      python-pkgs.requests
      python-pkgs.requests-futures
      python-pkgs.stem
      python-pkgs.torrequest
      python-pkgs.pandas
      python-pkgs.openpyxl
      python-pkgs.exrex
    ]))
  ];
}
