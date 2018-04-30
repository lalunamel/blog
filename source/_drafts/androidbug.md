## Constraint Layout Spelunking

## Problem Statement

I've got a button that has enough text in it so that it fills the width of the screen.
When I create constraints with margins on both the left and the right sides of my button, I expect some sort of reasonable behavior.
In this case, I know that adding margins to the left and right of my button should either:
  - Shrink the width of the button and obey the margins
  - Shrink the width of the margins and obey the width 

### Why does my view collapse down to 0 width?

#### Process
- Do something
- It doesnt look good
- Create the same layout in the layout editor
- _that_ works ok??
- put a breakpoint where the constraintset is being applied and inspect the diff between the one created programmatically and the one created via the layout editor
- notice that there are a bunch of constraint properties that are set to 0 in the layout editor that are set to -1 in the programmatically created constraintset
- notice that one of those properties is `widthDefault`
- look up the documentation on that, find that valid values for `widthDefault` (or `constrainDefaultHeight`, it's setter) are `MATCH_CONSTRAINT_WRAP` or `MATCH_CONSTRAINT_SPREAD`
- those values correspond to `1` and `0` respectively
- notice that `-1` is not one of those values, add a line `promptConstraints.constrainDefaultWidth(prompt.id, 0)`
- fixed!
