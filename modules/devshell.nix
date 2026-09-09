{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      name = "nix";
      packages = with pkgs; [
        nixd
        alejandra
        bash-language-server
        prettierd
      ];
    };
  };
}
