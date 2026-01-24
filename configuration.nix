{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "fdegmecic-homelab";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Zagreb";

  users.users.fdegmecic = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "media" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTHVwMbydwIudwaoDbeIXdyv9UM0CrfdU5uJvDcUDTA 42947589+fdegmecic@users.noreply.github.com"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = true;
    publish.addresses = true;
  };

  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  users.groups.media = {};

  systemd.tmpfiles.rules = [
    "d /srv/media 0775 root media -"
    "d /srv/media/movies 0775 root media -"
    "d /srv/media/tv 0775 root media -"
    "d /srv/media/downloads 0775 root media -"
    "d /srv/media/downloads/.incomplete 0775 root media -"
    "d /srv/media/downloads/radarr 0775 root media -"
    "d /srv/media/downloads/tv 0775 root media -"
  ];

  services.transmission.group = "media";
  services.radarr.group = "media";
  services.sonarr.group = "media";

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.transmission = {
    enable = true;
    openFirewall = true;
    settings = {
      download-dir = "/srv/media/downloads";
      incomplete-dir = "/srv/media/downloads/.incomplete";
      incomplete-dir-enabled = true;
      rpc-whitelist = "127.0.0.1,192.168.*.*";
      rpc-host-whitelist = "*";
      rpc-bind-address = "0.0.0.0";
    };
  };

  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = "3001";
    };
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  services.bazarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  services.flaresolverr = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [ 22 3001 9091 ];

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    curl
    wget
  ];

  system.stateVersion = "25.11";
}
