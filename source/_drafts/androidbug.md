## Constraint Layout Spelunking

- MATCH_CONSTRAINT (or 0dp) on width causes the element's width to be determined by its constraints
- constrainDefaultWidth says the default is MATCH_CONSTRAINT_SPREAD, but the default is actually -1
- the docs for ConstraintSet MATCH_CONSTRAINT_WRAP and MATCH_CONSTRAINT_SPREAD aren't very good 
- When laying out a view in the XML editor, the default height of an element is WRAP_CONTENT (-2). When laying views out programmatically, the default height of an element is not WRAP_CONTENT, but is instead 0. This will cause your view to not show up.

NOTE: break out the height example from the defaultWidth example

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


## Constraint Set from Layout
`constraintSet.mConstraints.values()`

```
alpha = 1.0
applyElevation = false
baselineToBaseline = -1
bottomMargin = 0
bottomToBottom = -1
bottomToTop = -1
circleAngle = 0.0
circleConstraint = -1
circleRadius = 0
constrainedHeight = false
constrainedWidth = false
dimensionRatio = null
editorAbsoluteX = -1
editorAbsoluteY = -1
elevation = 0.0
endMargin = 240
endToEnd = 0
endToStart = -1
goneBottomMargin = -1
goneEndMargin = -1
goneLeftMargin = -1
goneRightMargin = -1
goneStartMargin = -1
goneTopMargin = -1
guideBegin = -1
guideEnd = -1
guidePercent = -1.0
heightDefault = 0
heightMax = 0
heightMin = 0
heightPercent = 1.0
horizontalBias = 0.5
horizontalChainStyle = 0
horizontalWeight = 0.0
leftMargin = 120
leftToLeft = -1
leftToRight = -1
mBarrierDirection = -1
mHeight = -2
mHelperType = -1
mIsGuideline = false
mReferenceIds = null
mViewId = 2131165228
mWidth = 0
orientation = -1
rightMargin = 240
rightToLeft = -1
rightToRight = -1
rotation = 0.0
rotationX = 0.0
rotationY = 0.0
scaleX = 1.0
scaleY = 1.0
startMargin = 120
startToEnd = -1
startToStart = 0
topMargin = 0
topToBottom = -1
topToTop = -1
transformPivotX = NaN
transformPivotY = NaN
translationX = 0.0
translationY = 0.0
translationZ = 0.0
verticalBias = 0.5
verticalChainStyle = 0
verticalWeight = 0.0
visibility = 0
widthDefault = 0
widthMax = 0
widthMin = 0
widthPercent = 1.0
```

## Constraint from Default Programmatic Layout
`constraintSet.mConstraints.values()`

```
alpha = 1.0
applyElevation = false
baselineToBaseline = -1
bottomMargin = -1
bottomToBottom = -1
bottomToTop = -1
circleAngle = 0.0
circleConstraint = -1
circleRadius = 0
constrainedHeight = false
constrainedWidth = false
dimensionRatio = null
editorAbsoluteX = -1
editorAbsoluteY = -1
elevation = 0.0
endMargin = 60
endToEnd = 0
endToStart = -1
goneBottomMargin = -1
goneEndMargin = -1
goneLeftMargin = -1
goneRightMargin = -1
goneStartMargin = -1
goneTopMargin = -1
guideBegin = -1
guideEnd = -1
guidePercent = -1.0
heightDefault = -1
heightMax = -1
heightMin = -1
heightPercent = 1.0
horizontalBias = 0.5
horizontalChainStyle = 0
horizontalWeight = 0.0
leftMargin = -1
leftToLeft = -1
leftToRight = -1
mBarrierDirection = -1
mHeight = 0
mHelperType = -1
mIsGuideline = false
mReferenceIds = null
mViewId = 0
mWidth = 0
orientation = -1
rightMargin = -1
rightToLeft = -1
rightToRight = -1
rotation = 0.0
rotationX = 0.0
rotationY = 0.0
scaleX = 1.0
scaleY = 1.0
startMargin = 30
startToEnd = -1
startToStart = 0
topMargin = -1
topToBottom = -1
topToTop = -1
transformPivotX = NaN
transformPivotY = NaN
translationX = 0.0
translationY = 0.0
translationZ = 0.0
verticalBias = 0.5
verticalChainStyle = 0
verticalWeight = 0.0
visibility = 0
widthDefault = -1
widthMax = -1
widthMin = -1
widthPercent = 1.0
```

## Differences between default XML and programmatic layouts

| Constraint Set from Layout | Constraint from Default Programmatic Layout |                          |
| -------------------------- | ------------------------------------------- | ------------------------ |
| bottomMargin = 0           | bottomMargin = -1                           |                          |
| endMargin = 240            | endMargin = 60                              | Because of pixel density |
| heightDefault = 0          | heightDefault = -1                          |                          |
| heightMax = 0              | heightMax = -1                              |                          |
| heightMin = 0              | heightMin = -1                              |                          |
| leftMargin = 120           | leftMargin = -1                             |                          |
| mHeight = -2               | mHeight = 0                                 | Not sure why this is     |
| rightMargin = 240          | rightMargin = -1                            |                          |
| startMargin = 120          | startMargin = 30                            | Because of pixel density |
| topMargin = 0              | topMargin = -1                              |                          |
| widthDefault = 0           | widthDefault = -1                           |                          |
| widthMax = 0               | widthMax = -1                               |                          |
| widthMin = 0               | widthMin = -1                               |                          |
