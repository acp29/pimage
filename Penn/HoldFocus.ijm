// Macro written by Dr Andrew Penn
// andy.c.penn@gmail.com
//
// Selects the slice in each time frame of a 4D image or hyperstack 
// that minimizes the sum of absolute pixel intensity differences 
// between images in consecutive frames and creates a stack of the 
// resulting images. The current slice is used as the reference slice 
// in the first time frame. This macro can be used to minimize z-drift.
// Correct for xy-drift (and crop off blank edges) before executing 
// this algorithm.
//
// Requires ImageJ version 1.48c or above

macro "HoldFocus" {

    // Initialize macro
    run("Clear Results");
    run("Select None");

    // Get stack information
    if (Stack.isHyperstack==0) {
        exit("The active window must be a hyperstack");
    }
    stack_old = getImageID;
    title = getTitle;
    Stack.getPosition(channel,slice,frame)
    if (frame!=1) {
        exit("The current stack position must be a slice in the first frame");
    }
    Stack.getDimensions(width,height,channels,slices,frames)
    stack_new = 0;

    // Set measurements to integrated density (sum of pixel intensity)
    run("Set Measurements...", "  integrated redirect=None decimal=0");

    // Initialize printing of results
    print("HoldFocus: Optimal slice index for each time frame:");

    // Set initial value of k to the current slice
    k = slice;
    print(k);

    // Copy the image from slice k of frame 1 to a new image stack
    selectImage(stack_old);
    Stack.setPosition(channel,k,1)
    run("Copy");
    newImage("Focused_C"+channel+"_"+title, "16-bit", width, height, 1);
    run("Paste");
    stack_new=getImageID;

    // Initialize loop counters for slices (i) and time frames (j)
    i = 1;
    j = 1;

    // Loop through all time frames
    do {

        // Create a temporary array for the measurement results
        temp = newArray();

        // Create temporary image of slice k in frame j
        selectImage(stack_old);
        Stack.setPosition(channel,k,j)
        run("Copy");
        newImage("img1.tif", "16-bit", width, height, 1);
        run("Paste");

        // Loop through all slices in frame j+1
        do {

             // Create temporary image of slice i in frame j+1
             selectImage(stack_old);
             Stack.setPosition(channel,i,j+1);
             run("Copy");
             newImage("img2.tif", "16-bit", width, height, 1);
             run("Paste");

             // Calculate difference image
             imageCalculator("Difference create", "img1.tif","img2.tif");

             // Measure absolute sum of differences
             selectWindow("Result of img1.tif");
             run("Measure");

             // Store result in temporary array
             temp = Array.concat(temp,getResult("IntDen",i-1));

             // Close surplus images
             close();
             selectWindow("img2.tif");
             close();

             // Increase slice counter i
             i = i+1;

        } while(i<=slices);

        // Find the slice in frame j+1 that minimizes the absolute difference 
        // compared to slice k in frame j
        ans = Array.findMinima(temp,1);
        k = ans[0]+1;  // Add one since arrays use zero-based numbering
        print(k);

        // Copy image from optimal slice k in frame j+1 and add as a new slice 
        selectImage(stack_old);
        Stack.setPosition(channel,k,j+1);
        run("Copy");
        selectImage(stack_new);
        run("Add Slice");
        run("Paste");

        // Close surplus images and clear results
        selectWindow("img1.tif");
        close();
        run("Clear Results");
 
        // Reset or step-up loop counters
        i = 1;
        j = j+1;

    } while(j<frames);

}
