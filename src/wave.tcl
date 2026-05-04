# wave.tcl: TCL script for GTKWave simulator with signal definitions 
# Author(s): Lukas Kekely (ikekely@fit.vutbr.cz)

gtkwave::/Edit/Insert_Comment "Main Interface"
gtkwave::addSignalsFromList [list clk rst]
gtkwave::addSignalsFromList [list din din_vld din_rdy dout]
gtkwave::addSignalsFromList [list dout_state]
gtkwave::/Edit/Color_Format/Blue
gtkwave::/Edit/Insert_Blank

gtkwave::/Edit/Insert_Comment "Other Signals"
         # <<< TODO: Insert 'gtkwave::addSignalsFromList' for your signals here.

gtkwave::/Edit/UnHighlight_All
gtkwave::/Time/Zoom/Zoom_Best_Fit
