# nix-homelab

## Services

| Service      | Purpose                                              |
| ------------ | ---------------------------------------------------- |
| Jellyfin     | Media server — stream movies and TV                  |
| Jellyseerr   | Request UI for new movies/shows                      |
| Radarr       | Movie library manager + automation                   |
| Sonarr       | TV library manager + automation                      |
| Prowlarr     | Indexer aggregator for Radarr/Sonarr                 |
| Bazarr       | Subtitle fetcher for Radarr/Sonarr                   |
| Transmission | Torrent client                                       |
| Flaresolverr | Cloudflare bypass proxy for indexers                 |
| Homepage     | Dashboard linking all services                       |
| Uptime Kuma  | Service health monitoring                            |
| CouchDB      | Backend for Obsidian LiveSync                        |
| Cloudflared  | Tunnel for public access without opening ports       |
