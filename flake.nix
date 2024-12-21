{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      # TODO: remove as soon as 0.11 is in nixpkgs
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { ... }@inputs:
    let
      globals = {
        ghName = "lcwllmr";
        ghEmail = "159539641+lcwllmr@users.noreply.github.com";
      };

      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
      ];
    in
    {
      nixosConfigurations = {
        dpt5810 = import ./hosts/dpt5810 { inherit inputs globals overlays; };
      };
    };
}
