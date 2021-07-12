# AutoFollow
Uses PTK to follow leader.
This is still very early in its development but I'm sharing so you can see and use the math if you want.
The math was the frustrating part even though it boiled down to being pretty simple.
ESO directional notation is 0 thru 6.28 (pi*2) which goes from North, West, South, East, then back to North. 
The difficulty was in converting the XY locations of follower and leader into this format so I could then determine which way to turn and how fast.

## Known issues:
* Floods the chat with debug info.
  * Hopefully already corrected.
* Gets snagged on things pretty easily.
  * Not sure this can ever be solved but the follow distance is pretty close.
* Roll dodges more than it should.
  * I may put in a delay to prevent this. It's pretty annoying.

## Want to have:
* Use doors better (or at all, it only worked once).
  * This has been difficult to test.
* Sneak when leader sneaks.
  * Should be easy enough.
* Mount when leader mounts and dismount when close to leader and leader is dismounted.
  * Should be easy enough.
* Mount when leader is over a certain distance.
  * Still mulling this over since it's not really intended for long distance path finding.
  
