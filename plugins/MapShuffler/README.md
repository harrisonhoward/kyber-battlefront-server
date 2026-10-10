# MapShuffler

This plugin shuffles the map rotation when the server starts, and reshuffles it each time the rotation completes a cycle.\
The map that was just played is never placed first in the new order, so the same map won't be played twice in a row.

Uses the [MapRotation](https://github.com/ArmchairDevelopers/KyberDocs/blob/main/content/docs/pluginref/libraries/maprotation.mdx) plugin library.

## Supported Channel

Any channel with the `MapRotation` library (added in the IG-88 update). If it is unavailable the plugin disables itself.

## Configuration

None. The maps in the rotation come from the server's map rotation (`KYBER_MAP_ROTATION`).
