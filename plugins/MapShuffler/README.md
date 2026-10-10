# MapShuffler

This plugin shuffles the map rotation when the server starts, and reshuffles it each time the rotation completes a cycle.\
It tries to avoid playing the same map twice in a row, including the same map in a different mode (e.g. Yavin in conquest then galactic assault). This is best effort: if no such order is found after 20 shuffles, which only happens when most of the rotation is one map, the last shuffle is used and a warning is logged.

Uses the [MapRotation](https://github.com/ArmchairDevelopers/KyberDocs/blob/main/content/docs/pluginref/libraries/maprotation.mdx) plugin library.

## Supported Channel

Requires KYBER v2.0.0-beta10 or newer. Use `ver/beta10` until the `stable` channel serves v2.0.0-beta10 (it currently serves v2.0.0-beta8).

`ver/beta10`, `stable`

## Configuration

None. The maps in the rotation come from the server's map rotation (`KYBER_MAP_ROTATION`).
