{
  perSystem = {pkgs, ...}: rec {
    devShells.default = pkgs.mkShell {
      name = "nix";
      packages = with pkgs; [
        # Nix
        nixd
        alejandra
        bash-language-server
        prettierd
      ];
    };
  };
}
