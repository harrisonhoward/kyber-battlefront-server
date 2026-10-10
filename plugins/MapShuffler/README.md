# MapShuffler

This plugin shuffles the map rotation when the server starts, and reshuffles it each time the rotation completes a cycle.\
The same map is never played twice in a row, including the same map in a different mode (e.g. Yavin in conquest then galactic assault).

Uses the [MapRotation](https://github.com/ArmchairDevelopers/KyberDocs/blob/main/content/docs/pluginref/libraries/maprotation.mdx) plugin library.

## Supported Channel

`stable`

## Configuration

None. The maps in the rotation come from the server's map rotation (`KYBER_MAP_ROTATION`).
