{ globals, ... }@inputs: {
  system = "aarch64-linux";
  modules = [ globals ];
  specialArgs = inputs;
};
