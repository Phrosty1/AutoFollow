# AutoFollow
Uses PTK to follow leader.
This is still very early in its development but I'm sharing so you can see and use the math if you want.
The math was the frustrating part even though it boiled down to being pretty simple.
ESO directional notation is 0 thru 6.28 (pi*2) which goes from North, West, South, East, then back to North. 
The difficulty was in converting the XY locations of follower and leader into this format so I could then determine which way to turn and how fast.

## Known issues:
* Floods the chat with debug info.
  * Has a flag now, defaulted to true.
* Inconsistent follow distance across zones and subzones.
  * Attempted to implement tracking of recent walk speeds, hopefully this helps.
* Roll dodges more than it should.
  * Included a timer and holding indicator so it only hits Forward if already pressing it or hasn't released it in the last second.

## Want to have:
* Use doors better (or at all, it only worked once).
  * Working much better now, not sure why it keeps trying to scan when the reticle reaches a door.
* Sneak when leader sneaks.
  * Seems to be working.
* Mount when leader mounts and dismount when close to leader and leader is dismounted.
  * Seems to be working! I'm still mulling having you dismount when leader is reached though.
* Mount when leader is over a certain distance.
  * It can't hurt to try to do this when I get the distance smoothed out.
* Make better breadcrumbs for when leader goes thru the door. Also, make spaced breadcrumbs every few feet for when crouching so the crouched path is followed. Maybe make them whenever leader is not in support range. Then clear the breadcrumbs when the leader is close enough to avoid unnecessary wandering.
  * Barely started.
