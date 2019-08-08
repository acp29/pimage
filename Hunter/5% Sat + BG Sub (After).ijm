run("Clear Results");
run("8-bit");
run("Enhance Contrast", "saturated=0.05");
run("Apply LUT");
waitForUser( "Pause","Select Background ROI");
run("Measure");
x = getResult("Mean",0);
run("Select All");
run("Subtract...", "value=" + x);
