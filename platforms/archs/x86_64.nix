{ globals, ... }@inputs: {
  system = "x86_64-linux";
  modules = [ globals ];
  specialArgs = inputs;
}
