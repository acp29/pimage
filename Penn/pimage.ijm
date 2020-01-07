macro "PrepareImages" {

	// Protocol dialog
	showMessageWithCancel("Protocol: Prepare images","Summary of protocol steps:\n"+
										  			 "1: Dialog to load raw red image\n"+
										  			 "2: Dialog to load raw green image\n"+
												   	 "3: Manual alignment of red and green image planes\n"+
										   			 "4: Prompt to continue with protocol when user completes alignment\n"+
										   			 "Warning: Pressing OK will close all open images and reset ROI manager")
	close("*");
	roiManager("reset");
	run("Clear Results");
	setBatchMode("true");
	setOption("ScaleConversions",true)
	print("\\Clear")

	// Load the Homer1c-tdTomato (red) and SEP-GluN1 (green) images
	path_red = File.openDialog("Load red image");
	open(path_red);
	w = getWidth();
    h = getHeight();
    path = getDirectory("image");
	if (bitDepth() == 24) {
		rename("1");
		run("Split Channels");
		close("1 (green)");
		close("1 (blue)");
	}
	if (bitDepth() > 8) {
		run("8-bit");
	}
	run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
	run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
	path_green = File.openDialog("Load green image");
	open(path_green);
	if ( (w != getWidth()) || (h != getHeight()) ) {
		exit("Images must have the same dimenions");
	}
	if (path != getDirectory("image")) {
		exit("Images must come from the same directory");
	}
		if (bitDepth() == 24) {
		rename("2");
		run("Split Channels");
		close("2 (red)");
		close("2 (blue)");
	}
	if (bitDepth() > 8) {
		run("8-bit");
	}
	run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
	run("Remove Outliers...", "radius=2 threshold=50 which=Dark");

	// Perform image alignment
	run("Images to Stack", "name=Stack title=[] use");
	// Add a third slice at the end of the stack
	setSlice(2);
	run("Add Slice");
	// Convert to 8-bit and then convert stack to RGB
	run("Stack to RGB");
	run("Enhance Contrast...", "saturated=0 normalize");
	close("Stack");
	run("ROI Manager...");
	run("Align RGB planes");
	setBatchMode("false");
	setTool("polygon");
	waitForUser("Alignment","1. Adjust alignment of the images using Align RGB window controls.\n"+
							"2. Draw polygon around an area of background and press the key 't'.\n"+
							"3. Draw polygon around the cell of interest and press the key 't'.\n"+
							"4. Close the Align RGB window and click OK in this dialog.\n");

	// Subtract uneven background
	//run("Subtract Background...", "rolling=500 separate");

    // Split channels
	setBatchMode("true");
	run("Split Channels");
	close("Stack (RGB) (blue)");

	// Save images
	selectWindow("Stack (RGB) (red)");
	run("Subtract Background...", "rolling=500 separate"); // Subtract uneven background
	red_fname = File.getName(path_red);
	i =  lastIndexOf(red_fname,".");
    red_fname = substring(red_fname,0,i);
	saveAs("Tiff",path+red_fname+"_red");
	selectWindow("Stack (RGB) (green)");
	green_fname = File.getName(path_green);
	i =  lastIndexOf(green_fname,".");
    green_fname = substring(green_fname,0,i);
	saveAs("Tiff",path+green_fname+"_green");

	// Combine regions of interest
	selectWindow(red_fname+"_red.tif");
    roiManager("Select",newArray(0,1));  // Select background and whole-cell ROI
    roiManager("Combine");               // Combine ROI selections
    roiManager("Add");                   // Add combined selection to ROI manager
    run("Select All");

	// Save ROIs
	roiManager("Deselect");
	roiManager("Save", path+"/prepROI.zip");

}

macro "PrepareImages_48bit_Color" {

	// Protocol dialog
	showMessageWithCancel("Protocol: Prepare images","Summary of protocol steps:\n"+
										  			 "1: Dialog to load raw red image\n"+
										  			 "2: Dialog to load raw green image\n"+
												   	 "3: Manual alignment of red and green image planes\n"+
										   			 "4: Prompt to continue with protocol when user completes alignment\n"+
										   			 "Warning: Pressing OK will close all open images and reset ROI manager")
	close("*");
	roiManager("reset");
	run("Clear Results");
	setBatchMode("true");
	setOption("ScaleConversions",true)
	print("\\Clear")

	// Load the Homer1c-tdTomato (red) and SEP-GluN1 (green) images
	path_red = File.openDialog("Load red image");
	run("Bio-Formats Importer", "open=[path_red] color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
    rename("temp");
    run("Hyperstack to Stack");
    run("Stack to RGB");
	w = getWidth();
    h = getHeight();
    path = getDirectory("image");
	if (bitDepth() == 24) {
		rename("1");
		run("Split Channels");
		close("1 (green)");
		close("1 (blue)");
	}
	if (bitDepth() > 8) {
		run("8-bit");
	}
	run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
	run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
	selectWindow("temp");
    close();
	path_green = File.openDialog("Load green image");
	run("Bio-Formats Importer", "open=[path_green] color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
    rename("temp");
    run("Hyperstack to Stack");
    run("Stack to RGB");
	if ( (w != getWidth()) || (h != getHeight()) ) {
		exit("Images must have the same dimenions");
	}
	if (path != getDirectory("image")) {
		exit("Images must come from the same directory");
	}
		if (bitDepth() == 24) {
		rename("2");
		run("Split Channels");
		close("2 (red)");
		close("2 (blue)");
	}
	if (bitDepth() > 8) {
		run("8-bit");
	}
	run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
	run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
	selectWindow("temp");
    close();

	// Perform image alignment
	run("Images to Stack", "name=Stack title=[] use");
	// Add a third slice at the end of the stack
	setSlice(2);
	run("Add Slice");
	// Convert to 8-bit and then convert stack to RGB
	run("Stack to RGB");
	run("Enhance Contrast...", "saturated=0 normalize");
	close("Stack");
	run("ROI Manager...");
	run("Align RGB planes");
	setBatchMode("false");
	setTool("polygon");
	waitForUser("Alignment","1. Adjust alignment of the images using Align RGB window controls.\n"+
							"2. Draw polygon around an area of background and press the key 't'.\n"+
							"3. Draw polygon around the cell of interest and press the key 't'.\n"+
							"4. Close the Align RGB window and click OK in this dialog.\n");

	// Subtract uneven background
	//run("Subtract Background...", "rolling=500 separate");

    // Split channels
	setBatchMode("true");
	run("Split Channels");
	close("Stack (RGB) (blue)");

	// Save images
	selectWindow("Stack (RGB) (red)");
	run("Subtract Background...", "rolling=500 separate"); // Subtract uneven background
	red_fname = File.getName(path_red);
	i =  lastIndexOf(red_fname,".");
    red_fname = substring(red_fname,0,i);
	saveAs("Tiff",path+red_fname+"_red");
	selectWindow("Stack (RGB) (green)");
	green_fname = File.getName(path_green);
	i =  lastIndexOf(green_fname,".");
    green_fname = substring(green_fname,0,i);
	saveAs("Tiff",path+green_fname+"_green");

	// Combine regions of interest
	selectWindow(red_fname+"_red.tif");
    roiManager("Select",newArray(0,1));  // Select background and whole-cell ROI
    roiManager("Combine");               // Combine ROI selections
    roiManager("Add");                   // Add combined selection to ROI manager
    run("Select All");

	// Save ROIs
	roiManager("Deselect");
	roiManager("Save", path+"/prepROI.zip");

}

macro "SpineFluorMeasure" {

	// Protocol dialog
	showMessageWithCancel("Protocol: Measure synaptic/total SEP-GluN1 fluorescence","Summary of protocol steps:\n"+
										  			 "1: Dialog to load prepared red image\n"+
										  			 "2: Dialog to load prepared green image\n"+
										  			 "3: Dialog to load prepROI.zip\n"+
												   	 "4: Specify radius of Gaussian filter\n"+
										   			 "5: Specify radius of Median filter\n"+
										   			 "Warning: Pressing OK will close all open images and reset ROI manager");
	close("*");
	roiManager("reset");
	run("Clear Results");
	setBatchMode("true");
	setOption("ScaleConversions",true)
	print("\\Clear")

	// Load the Homer1c-tdTomato (red) and SEP-GluN1 (green) images
	path_red = File.openDialog("Load red image");
	open(path_red);
	w = getWidth();
    h = getHeight();
	path = getDirectory("image");
    path_green = File.openDialog("Load green image");
	open(path_green);
	if ( (w != getWidth()) || (h != getHeight()) ) {
		exit("Images must have the same dimenions");
	}
	if (path != getDirectory("image")) {
		exit("Images must come from the same directory");
	}
	red_fname = File.getName(path_red);
	green_fname = File.getName(path_green);

	// Load prepROI
	path_roi = File.openDialog("Load prepROI.zip");
	roiManager("Open",path_roi);

    // Crop ROIs in red image
    selectWindow(red_fname);
    roiManager("Select",2);
    run("Copy");
    newImage('cell',"8-bit black",w,h,1);
    roiManager("Select",2);
    run("Paste");
    run("Select All");

	// Perform local thresholding and create mask and ROI of cell
	selectWindow('cell');
	roiManager("Select",0);
	run("Set Measurements...", "mean redirect=None decimal=9");
	run("Measure");
	bg = getResult("Mean",0);
	roiManager("Select",2);
	run("Subtract...","value="+bg);
	run("Enhance Contrast", "saturated=0.0");
	run("Apply LUT");
    run("Gaussian Blur...");
    run("Auto Local Threshold", "method=Phansalkar radius=15 parameter_1=0 parameter_2=0 white");
	run("Median...", "radius=10"); // Despeckle
	run("Create Selection");
    run("Make Inverse");
    roiManager("Add");
    run("Select All");

	// Use median filter and global thresholding to create mask and ROI of synapses
	selectWindow(red_fname);
	roiManager("Select",1);
    run("Copy");
    run("Select None");
    newImage("original","8-bit black",w,h,1);
    roiManager("Select",1);
    run("Paste");
    newImage("filtered","8-bit black",w,h,1);
    roiManager("Select",1);
    run("Paste");
    run("Median...");
    imageCalculator("Subtract create", "original","filtered");
	close("original");
	close("filtered");
    roiManager("Select",1);
    run("Threshold...");
	setThreshold(0,255);
    call("ij.plugin.frame.ThresholdAdjuster.setMode", "B&W");
    waitForUser("Alignment","Manually adjust global threshold then press OK");
    run("Convert to Mask");
    run("Median...","radius=1"); // Despeckle
	run("Create Selection");
    run("Make Inverse");
	roiManager("Add");
	rename("synapses");
    run("Select None");

	// Combine synapse and cell ROI for total ROI
	selectWindow(red_fname);
	roiManager("Select",4);
    roiManager("Select",newArray(3,4));
    roiManager("Combine");
    roiManager("Add");
    run("Select None");

	// Calculate relative spine fluorescence of green signal
	selectWindow(green_fname);
	run("Clear Results");
	run("Set Measurements...", "mean standard redirect=None decimal=9");
	roiManager("Select",4); // synapse ROI
	run("Measure");
	roiManager("Select",5); // total ROI
	run("Measure");
	roiManager("Select",0); // background ROI
	run("Measure");
	a = getResult("Mean",0);      // Mean synapse fluorescence
	b = getResult("Mean",1);      // Mean total cell fluorescence
	c = getResult("Mean",2);      // Mean background fluorescence
	d = getResult("StdDev",2);  // Stanard deviation background fluorescence
	z = (a-c)/d;
	//print("Signal-to-noise ratio = "+maxOf(a,b)/c);
	//print("Synapse/Total fluorescence ratio = "+(a-c)/(b-c));
	print("Synaptic fluorescence = "+a);
	print("Total cell fluorescence = "+b);
	print("Background fluorescence = "+c+" +/- "+d);
	print("Z-score = "+z);
    run("Select None");

	// Save images
	i =  lastIndexOf(red_fname,".");
    red_fname = substring(red_fname,0,i);
	selectWindow("cell");
	saveAs("Tiff",path+red_fname+"_cell");
	selectWindow("synapses");
	saveAs("Tiff",path+red_fname+"_synapses");

	// Save ROIs
	roiManager("Deselect");
	roiManager("Save", path+"/spineFluorROI.zip");

	// Save log
	selectWindow("Log");
	saveAs("Text",path+"summary.txt");

	// Clear up
	setBatchMode("false");
}

macro "SpineMorphMeasure" {

	run("Properties...", "channels=1 slices=1 frames=1 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1");
	setTool("multipoint");
	print("\\Clear")
	roiManager("reset");
	run("Select None");
	run("Clear Results");

	//to set the division factor for pixel length to micrometers for later output measurements
	Dialog.create("Pixel Size");
	Dialog.addMessage("Enter pixel size");
	Dialog.addNumber("Pixel (Microns)",0.06); //0.06 = um per pixel for teaching lab microscope at 40xObjective
	Dialog.show();
	p = Dialog.getNumber();

	//to define the straight line of dendrite and create a line along the dendtrite
	waitForUser( "Pause","Draw Line Points");
	run("Measure");
	x1 = getResult("X",0);
	y1 = getResult("Y",0);
	x2 = getResult("X",1);
	y2 = getResult("Y",1);
	roiManager("Add");
	roiManager("Show All");
	makeLine(x1, y1, x2, y2);
	roiManager("add");
	run("Clear Results");

	//to define dendrite diameter
	setTool("line");
	waitForUser( "Pause","Draw Line across dendrite diameter");
	roiManager("add");
	run("Measure");
	t = getResult("Length",0);
	Diam = t*p
	run("Clear Results");

	//to define spine location coordinates
	setTool("multipoint");
	waitForUser( "Pause","Select Spines");
	roiManager("add");
	run("Measure");
	n = nResults;
	i=1;
	count=0;
	do {
		x = getResult("X",i-1);
		y = getResult("Y",i-1);
		Dm = (y1-y2)/(x1-x2);
		Dc = y1-((Dm)*x1);
		Sm = -(1/Dm);
		Sc = y-(Sm*x);
		Xint = -(Dc-Sc)/(Dm-Sm);
		Yint = (Dm*Xint)+Dc;
		if ((Xint > minOf(x1,x2)) && (Xint < maxOf(x1,x2))) {
		    makeLine(x, y, Xint, Yint);
		    roiManager("add");
		    z = sqrt(pow(x-Xint,2)+pow(y-Yint,2));
		    if (((z*p)-(0.5*Diam))>0) {
		    	print((z*p)-(0.5*Diam));
		    } else {
		    	print ("0");
		    }
		    count = count+1;
		}
		i = i+1;
	} while(i<=n);

	//Calculate spine density
	d = count/(sqrt(pow(x1-x2,2)+pow(y1-y2,2))*p);
	print(d);
	run("Clear Results");

	//Saving ROI .zip file
	Dialog.create("Save ROI File");
	Dialog.addMessage("Enter ROI File Name (without extension)");
	Dialog.addString("ROI File Name", "Add a File Name for the ROI set");
	Dialog.show();
	ROIname = Dialog.getString();
	name = getTitle();
	dir = getDirectory("image");
	path = dir+name;
	ROIpath = dir+ROIname;
	saveAs("Tiff", path);
	roiManager("Deselect");
	roiManager("Save", ROIpath+".zip");
}
