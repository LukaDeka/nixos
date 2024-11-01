{ config, pkgs, inputs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix

      ######## Server configuration ########
      ./../../modules/wireguard.nix  # VPN
      ./../../modules/samba.nix      # TODO: Figure out what to do with Samba
      ./../../modules/seafile.nix    # TODO: Fix Seafile
      ./../../modules/ssh.nix
      ./../../modules/aliases.nix    # BASH aliases
      ./../../modules/extra.nix      # Battery settings, lid close, etc.

      ######## Scripts ########
      ./../../scripts/scripts.nix    # TODO: Separate/modularize scripts

      # ./../../modules/blocky.nix     # DNS server/adblocker TODO: Diagnose why it's not working/switch to Pihole Docker container
      # ./../../modules/fish.nix       # TODO: Learn fish
      # ./../../modules/nginx.nix      
      ./../../modules/caddy.nix
      # ./../../modules/docker.nix     # TODO: Modularize config
    ];

  networking.hostName = "berlin";
  networking.networkmanager.enable = true;
  networking.wireless.enable = false; # Wireless support via wpa_supplicant

  # Rename network interface
  systemd.network.links = {
    "10-eth0" = {
      matchConfig.PermanentMACAddress = "54:e1:ad:6e:4e:d1";
      linkConfig.Name = "eth0";
    };
  };

  # Send email, when RAID drive fails
  boot.swraid.mdadmConf = ''
    MAILADDR=luka.dekanozishvili1@gmail.com
  '';

  nixpkgs.overlays =
  [(final: prev: {
    seafile = pkgs.unstable.seafile;
  })];

  disabledModules = [ "services/networking/seafile.nix" ];

  # List packages installed in system profile. To search, run: nix search [package]
  environment.systemPackages = let
    unstable = inputs.unstable.legacyPackages.${pkgs.system};
  in with pkgs; [
    ######## Must-haves ########
    vim
    neovim
    tmux
    git
    wget
    fzf # TODO: Learn how to use this

    ######## Server programs ########
    # nextcloud29
    # nginx
    # caddy
    # docker
    # docker-compose
    #unstable.seafile-server
    #unstable.seahub


    ######## Monitoring & tools ########
    mdadm
    btop
    acpi 
    ncdu
    iptables
    qrencode

    ######## Etc. ########
    wireguard-tools
    fastfetch
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’
  users.users.luka = {
    isNormalUser = true;
    description = "luka";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Never prompt "wheel" users for a root password; potential security issue!
  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}

