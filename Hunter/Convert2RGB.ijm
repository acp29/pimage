// Convert loaded red and green RGB images into a single RGB image
// Combine both red and green images into stack
run("Images to Stack", "name=Stack title=[] use");
run("Clear Results");
// Check if first slice is red or green
setSlice(1);
setRGBWeights(1.0, 0.0, 0.0);
run("Measure");
r = getResult("Mean",0)
setRGBWeights(0.0, 1.0, 0.0);
run("Measure");
g = getResult("Mean",1)
// Reverse order of slices if the first slice is a green image 
if (g == maxOf(r,g))
    run("Reverse");
else
    // Do nothing

run("Clear Results");
// Add a third slice at the end of the stack
setSlice(2);
run("Add Slice");
// Convert to 8-bit and then convert stack to RGB
run("8-bit");
run("Stack to RGB");

