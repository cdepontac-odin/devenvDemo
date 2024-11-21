{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  env = {
    GREET = "Devenv";
    DJANGO_DEBUG = "False";
    DJANGO_SETTINGS_MODULE = "report.settings";
    PYTHONUNBUFFERED = 1;
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  };
  # https://devenv.sh/packages/
  packages = [pkgs.git pkgs.glibcLocales];

  services.postgres = {
    package = pkgs.postgresql_15;
    enable = true;
  };
  languages.python = {
    enable = true;
    version = "3.11";
    uv.enable = true;
    uv.sync.allExtras = true;
  };

  pre-commit.hooks = {
    # Formatters & linters
    ## Python
    #ruff.enable = true;
    #mypy.enable = true;
    #black = {
    #  excludes = ["migrations/"];
    #  enable = true;
    #};
    ## Nix
    alejandra.enable = true;
  };

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  enterShell = ''
    hello
  '';

  # https://devenv.sh/tasks/
  tasks = {
    "myproj:setup".exec = ''
      # Create venv if not any
      if [ ! -d .venv ]; then
        uv venv
        source .venv/bin/activate
        uv pip install -r pyproject.toml
      else
        source .venv/bin/activate
      fi
    '';
    "devenv:enterShell".after = ["myproj:setup"];
  };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    python manage.py test
  '';

  # See full reference at https://devenv.sh/reference/options/
  #cachix.enable = false;
}
