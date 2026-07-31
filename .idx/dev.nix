# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  # Which nixpkgs chann el to use.
  channel = "stable-24.05"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.jdk21
    pkgs.unzip
    pkgs.gh
    pkgs.mariadb
    pkgs.cmake
    pkgs.ninja
    pkgs.pkg-config
    pkgs.clang
    pkgs.gtk3
    pkgs.flyctl
    pkgs.htop
  ];
  # Sets environment variables in the workspace
  env = {
    CLAUDE_CODE_OAUTH_TOKEN = "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";
  };
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];
    workspace = {
      onCreate = {
        install-claude-code = "npm install -g @anthropic-ai/claude-code";
      };
      # To run something each time the workspace is (re)started, use the `onStart` hook
      onStart = {
        install-claude-code = "npm install -g @anthropic-ai/claude-code";
        start-backend = "cd backend && ./start_backend.sh";
      };
    };
    # Enable previews and customize configuration
    previews = {
      enable = true;
      previews = {
        web = {
          command = ["flutter" "run" "--machine" "-d" "web-server" "--web-hostname" "0.0.0.0" "--web-port" "$PORT"];
          manager = "flutter";
        };
        android = {
          command = ["flutter" "run" "--machine" "-d" "android" "-d" "localhost:5555"];
          manager = "flutter";
        };
      };
    };
  };
}
