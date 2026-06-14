# vhs tape for the Fusion demo GIF.  Render with:  vhs assets/demo.tape
# Produces assets/fusion-demo.gif (illustrative — see assets/demo.sh).

Output assets/fusion-demo.gif

Set Shell "bash"
Set FontSize 21
Set Width 1240
Set Height 760
Set Padding 24
Set Theme "Dracula"

Hide
Type "clear"
Enter
Type "bash assets/demo.sh"
Enter
Sleep 700ms
Show
Sleep 10500ms
