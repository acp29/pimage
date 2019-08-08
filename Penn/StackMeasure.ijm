macro "StackMeasure" {
    run("Select None");
    run("Set Slice...", "slice="+1);
    run("Set Measurements...", "  mean redirect=None decimal=3");
    run("Clear Results");
    i = 1;
    do {
        run("Restore Selection");
        run("Measure");
        i = i+1;
        run("Select None");
        run("Next Slice [>]");
    } while(i<=nSlices);
    run("Restore Selection");
}
