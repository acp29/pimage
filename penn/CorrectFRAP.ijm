// Macro written by Dr Andrew Penn
// andy.c.penn@gmail.com
//
// Performs all but the last step of the double normalization procedure  
// of Robert Phair to correct FRAP time lapse images for photobleaching. 
// See Phair et al. (2004) Methods Enzymol 375:393-414
//
// Before executing this macro, you must:
//   1) Set the current slice to the first post-bleach image
//   2) Start ROI Manager and delete any existing ROIs
//   3) Add the first ROI for a non-fluorescent, background region
//   4) Add the second ROI for the whole cell

macro "CorrectFRAP" {

    // Compute and store the last prebleach slice number
    prebleach = getSliceNumber()-1;

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

    // Compute prebleach whole cell (T) mean pixel intensity
    run("Clear Results");
    roiManager("Select", 1);
    run("Set Slice...", "slice="+prebleach);
    run("Measure");
    Tprebleach = getResult("Mean",0);

    // Correct for loss of signal due to bleaching
    run("Clear Results");
    i = 1;
    do {
        roiManager("Select", 1);
        run("Set Slice...", "slice="+i);
        run("Measure");
        SF = Tprebleach/getResult("Mean",i-1);
        run("Select None");
        run("Multiply...",  "value="+SF+" slice");
        i = i+1;
        run("Next Slice [>]");
    } while(i<=nSlices);
    run("Clear Results");
}
