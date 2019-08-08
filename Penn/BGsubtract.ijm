// Macro written by Dr Andrew Penn
// andy.c.penn@gmail.com
//
// Performs all but the last step of the double normalization procedure
// of Robert Phair to correct FRAP time lapse images for photobleaching.
// See Phair et al. (2004) Methods Enzymol 375:393-414
//
// Before executing this macro, you must:
//   1) Start ROI Manager and delete any existing ROIs
//   3) Add the ROI for a non-fluorescent, background region

macro "BGsubtract" {

    // Set to measure mean intensity values of ROIs
    run("Set Measurements...", "  mean redirect=None decimal=12");

    // Subtract background (BG) mean pixel intensity from each slice in the stack
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
    setSlice(1);

}
