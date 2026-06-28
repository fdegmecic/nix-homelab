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
    extraGroups = [ "wheel" "networkmanager" "media" "docker" ];
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

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
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

  services.couchdb = {
    enable = true;
    bindAddress = "0.0.0.0";
    adminUser = "admin";
    extraConfig = {
      chttpd = {
        enable_cors = "true";
        max_http_request_size = "4294967296";
      };
      cors = {
        origins = "app://obsidian.md, capacitor://localhost, http://localhost";
        credentials = "true";
        methods = "GET, PUT, POST, HEAD, DELETE";
        headers = "accept, authorization, content-type, origin, referer";
      };
    };
  };

  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    allowedHosts = "fdegmecic-homelab.local:8082,192.168.100.71:8082,localhost:8082";
    services = [
      {
        "Media" = [
          { "Jellyfin" = { href = "http://fdegmecic-homelab.local:8096"; description = "Watch movies & TV"; }; }
          { "Jellyseerr" = { href = "http://fdegmecic-homelab.local:5055"; description = "Request content"; }; }
        ];
      }
      {
        "Downloads" = [
          { "Radarr" = { href = "http://fdegmecic-homelab.local:7878"; description = "Movies"; }; }
          { "Sonarr" = { href = "http://fdegmecic-homelab.local:8989"; description = "TV Shows"; }; }
          { "Prowlarr" = { href = "http://fdegmecic-homelab.local:9696"; description = "Indexers"; }; }
          { "Transmission" = { href = "http://fdegmecic-homelab.local:9091"; description = "Torrent client"; }; }
          { "Bazarr" = { href = "http://fdegmecic-homelab.local:6767"; description = "Subtitles"; }; }
        ];
      }
      {
        "System" = [
          { "Uptime Kuma" = { href = "http://fdegmecic-homelab.local:3001"; description = "Monitoring"; }; }
          { "CouchDB" = { href = "http://fdegmecic-homelab.local:5984/_utils"; description = "Obsidian Sync"; }; }
        ];
      }
    ];
    settings = {
      title = "fdegmecic Homelab";
      background = "https://images.unsplash.com/photo-1502790671504-542ad42d5189?auto=format&fit=crop&w=2560&q=80";
      cardBlur = "sm";
      theme = "dark";
      color = "slate";
      headerStyle = "clean";
    };
  };

  systemd.services.cloudflared-tunnel = {
    description = "Cloudflare Tunnel";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "/bin/sh -c '${pkgs.cloudflared}/bin/cloudflared tunnel run --token $(cat /etc/cloudflared/token)'";
      Restart = "always";
      RestartSec = "5s";
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 3001 5984 9091 ];

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    curl
    wget
    cloudflared
    yt-dlp
    ffmpeg
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.package = pkgs.docker_29;

  system.stateVersion = "25.11";
}
