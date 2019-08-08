// Macro written by Dr Andrew Penn
// andy.c.penn@gmail.com
//
// Take differences of consecutive slices in a stack
//

macro "StackDiff" {

    // Duplicate stack twice
    run("Duplicate...", "title=temp1 duplicate");
    run("Duplicate...", "title=temp2 duplicate");

    // Delete first slice from one stack
    selectWindow("temp1");
    setSlice(1);
    run("Delete Slice");

    // Delete last slice from the other stack
    selectWindow("temp2");
    setSlice(nSlices);
    run("Delete Slice");
    setSlice(1);

    // Slice-by-Slice subtraction of the temporary stacks
    imageCalculator("Subtract create stack", "temp1","temp2");

    // Delete temporary stacks
    selectWindow("temp1");
    close();
    selectWindow("temp2");
    close();

}
