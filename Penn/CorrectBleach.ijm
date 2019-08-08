// Macro written by Dr Andrew Penn
// andy.c.penn@gmail.com
//
// Based on the photobleaching correction of 
// Phair et al. (2004) Methods Enzymol 375:393-414
//
// Before executing this macro, you must:
//   1) Set the current slice to the first slice
//   2) Start ROI Manager and delete any existing ROIs
//   3) Add the first ROI for a non-fluorescent, background region
//   4) Add the second ROI for the whole cell

macro "CorrectBleach" {

    // Set to measure mean intensity values of ROIs
    run("Set Measurements...", "  mean redirect=None decimal=12");

    // Subtract background (BG) mean pixel intensity from each slice
    run("Clear Results");
    i = 1;
    do {
        roiManager("Select", 0);
        run("Set Slice...", "slice="+i);
        run("Measure");
        BG = getResult("Mean",i-1);  // -1 since table uses 0-based numbering
        run("Select None");
        run("Subtract...", "value="+BG+" slice");
        i = i+1;
        run("Next Slice [>]");
    } while(i<=nSlices);

    // Compute initial whole cell (T) mean pixel intensity
    run("Clear Results");
    roiManager("Select", 1);
    run("Set Slice...", "slice=1");
    run("Measure");
    T_initial = getResult("Mean",0);
	print(T_initial);

    // Correct for loss of signal due to bleaching
    run("Clear Results");
    i = 1;
    do {
        roiManager("Select", 1);
        run("Set Slice...", "slice="+i);
        run("Measure");
        SF = T_initial/getResult("Mean",i-1);
		print(SF);
        run("Select None");
        run("Multiply...",  "value="+SF+" slice");
        i = i+1;
        run("Next Slice [>]");
    } while(i<=nSlices);
    //run("Clear Results");
}
