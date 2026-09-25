{ ... }:
{
  # Cursor's MCP servers, declared. The package itself lives in
  # hosts/Default/host-packages.nix (code-cursor); this only wires config.
  #
  # agent-brain is the same graphiti server Claude Code (~/.claude.json) and
  # VS Code (../vscode) use: management-1, tailnet-only, full tool set, no
  # auth. One knowledge graph across all three agents.
  #
  # Cursor writes to mcp.json from its settings UI, so -- like VS Code's
  # settings -- it gets a WRITABLE COPY rather than a read-only store symlink.
  # Every `nixos-rebuild switch` resets it to what is declared here, so a
  # server added in the UI is temporary until it is written into this file.
  home-manager.sharedModules = [
    (
      { lib, ... }:
      {
        home.file.".cursor/mcp.json".text = builtins.toJSON {
          mcpServers = {
            agent-brain = {
              url = "https://management-1.tail8cb9b0.ts.net:8443/mcp";
            };
          };
        };

        # Same two-step dance as vscodeUnpinSettings/vscodeMutableSettings:
        # home-manager won't link over last rebuild's plain-file copy, so it
        # goes first; after linking, the symlink becomes a writable copy.
        # The copy step must name linkGeneration explicitly: "after
        # writeBoundary" alone lets the DAG break the tie by name, and
        # "cursor..." sorts before "linkGeneration", so it would run before
        # the link exists. (vscodeMutableSettings only works by sorting later.)
        home.activation = {
          cursorUnpinMcp = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
            p="$HOME/.cursor/mcp.json"
            [ -f "$p" ] && [ ! -L "$p" ] && rm -f "$p"
            true
          '';
          cursorMutableMcp = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
            p="$HOME/.cursor/mcp.json"
            if [ -L "$p" ]; then
              t="$(readlink -f "$p")"
              rm -f "$p"
              install -m 0644 "$t" "$p"
            fi
          '';
        };
      }
    )
  ];
}
