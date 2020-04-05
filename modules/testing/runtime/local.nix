{ lib, config, pkgs, ... }:

with lib;

let
  testing = config.testing;

  script = pkgs.writeScript "run-local-k8s-tests-${testing.name}.sh" ''
    #!${pkgs.runtimeShell}

    set -e

    KUBECONFIG=''${KUBECONFIG:-~/.kube/config}
    SKOPEOARGS=""

    while (( "$#" )); do
      case "$1" in
        --kubeconfig)
          KUBECONFIG=$2
          shift 2
          ;;
        --skopeo-args)
          SKOPEOARGS=$2
          shift 2
          ;;
      esac
    done

    echo "--> copying docker images to registry"
    ${testing.docker.copyScript} $SKOPEOARGS

    echo "--> running tests"
    ${testing.testScript} --kube-config=$KUBECONFIG
  '';
in {
  options.testing.runtime.local = {
    script = mkOption {
      type = types.package;
      description = "Runtime script";
    };

    docker = {
      registryUrl = mkOption {
        type = types.str;
        description = "Docker registry url";
      };

      copyScript = mkOption {
        type = types.package;
        description = "Script used to copy docker images";
      };
    };
    copyImages = mkOption {
      type = types.package;
      description = "Script used to copy docker images";
    };

    registryUrl = mkOption {
      type = types.str;
      description = "Registry url to copy docker images";
    };
  };

  config.testing.runtime.local.script = script;
}
