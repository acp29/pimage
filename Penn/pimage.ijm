

macro "red fix" {

	roiManager("reset");
	run("Clear Results");
	setBatchMode("true");
	setOption("ScaleConversions",true)
	print("\\Clear")

	// Load the Homer1c-tdTomato (red) and SEP-GluN1 (green) images
	path_red = File.openDialog("Load raw red image");
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
		

	// Subtract uneven background
	//run("Subtract Background...", "rolling=500 separate");

	
	// Save images
	selectWindow("_AVG_stack_r.tif");
	run("Subtract Background...", "rolling=500 sliding"); // Subtract uneven background
	red_fname = File.getName(path_red);
	i =  lastIndexOf(red_fname,".");
	red_fname = substring(red_fname,0,i);
	saveAs("Tiff",path+red_fname+"_red");
	
	}

macro "Multiloader" {

// Protocol dialog
	showMessageWithCancel("Protocol: Multiloader","Summary of protocol steps:\n"+
					"BEFORE STARTING: ensure red and green raw data subfolders are within a folder labelled with condition/coverslip/neuron number e.g. C456Yc2_1\n"+
					"1: Dialog to choose a directory - select folder containing red and green raw data subfolders\n"+
					"2: Dialog to load red image sequence\n"+
					"3: Dialog to load green image sequence\n"+
					"Press OK on this dialog to begin")
	close("*");

dir=getDirectory("Choose a Directory"); 
print(dir); 
File.makeDirectory(dir); 

path_red = File.openDialog("Load first image in red image sequence");
run("Image Sequence...", "open=[path_red]");
run("Z Project...", "projection=[Average Intensity]");

// Save images as stack

red_name = File.getName(path_red);
	selectWindow("AVG_Pos0");
	saveAs("Tiff",dir+"_AVG_stack_r");

path_green = File.openDialog("Load first image in green image sequence");
run("Image Sequence...", "open=[path_green]");
run("Z Project...", "projection=[Average Intensity]");

// Save image as stack

green_name = File.getName(path_green);
	selectWindow("AVG_Pos0");
	saveAs("Tiff",dir+"_AVG_stack_g");
}


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
	path_red = File.openDialog("Load raw red image");
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

	
	path_green = File.openDialog("Load raw green image");
	open(path_green);
	if ( (w != getWidth()) || (h != getHeight()) ) {
		exit("Images must have the same dimensions");
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
							"2. Draw polygon around the cell of interest and press the key 't'.\n"+
							"3. Close the Align RGB window and click OK in this dialog.\n");
							

	// Subtract uneven background
	//run("Subtract Background...", "rolling=500 separate");

	// Split channels
	setBatchMode("true");
	run("Split Channels");
	close("Stack (RGB) (blue)");
    // Duplicate green and red images
	selectWindow("Stack (RGB) (green)");
	run("Duplicate...", " ");
	selectWindow("Stack (RGB) (red)");
	run("Duplicate...", " ");

	// Create background green and red images
	selectWindow("Stack (RGB) (green)-1");
	run("Subtract Background...", "rolling=500 create sliding"); // create file for subtract uneven background with sliding paraboloid
	green_fname = File.getName(path_green);
	i =  lastIndexOf(green_fname,".");
	green_fname = substring(green_fname,0,i);
	saveAs("Tiff",path+green_fname+"_green_background");
	selectWindow("Stack (RGB) (red)-1");
	run("Subtract Background...", "rolling=500 create sliding"); // create file for subtract uneven background with sliding paraboloid
	red_fname = File.getName(path_red);
	i =  lastIndexOf(red_fname,".");
	red_fname = substring(red_fname,0,i);
	saveAs("Tiff",path+red_fname+"_red_background");

	// Save images
	selectWindow("Stack (RGB) (red)");
	run("Subtract Background...", "rolling=500 sliding"); // Subtract uneven background
	red_fname = File.getName(path_red);
	i =  lastIndexOf(red_fname,".");
	red_fname = substring(red_fname,0,i);
	saveAs("Tiff",path+red_fname+"_red");
	selectWindow("Stack (RGB) (green)");
	run("Subtract Background...", "rolling=500 sliding"); // Subtract uneven background
	green_fname = File.getName(path_green);
	i =  lastIndexOf(green_fname,".");
	green_fname = substring(green_fname,0,i);
	saveAs("Tiff",path+green_fname+"_green");

	// Save ROI
	run("Select All");
	roiManager("Deselect");
	roiManager("Save", path+"/prepROI.zip");
}


macro "SpineFluorMeasure" {

	// Protocol dialog
	showMessageWithCancel("Protocol: Measure synaptic/total SEP-GluN1 fluorescence","Summary of protocol steps:\n"+
										  			 "1: Dialog to load prepared red image\n"+
										  			 "2: Dialog to load prepared green image\n"+
										  			 "3: Dialog to load red background image\n"+
										  			 "4: Dialog to load green background image\n"+
										  			 "5: Dialog to load prepROI.zip\n"+
										   			 "6: Specify radius of Median filter\n"+
										   			 "Warning: Pressing OK will close all open images and reset ROI manager");
	close("*");
	roiManager("reset");
	run("Clear Results");
	setBatchMode("true");
	setOption("ScaleConversions",true)
	print("\\Clear")

	// Load the Homer1c-tdTomato (red) and SEP-GluN1 (green) images
	path_red = File.openDialog("Load prepared red image");
	open(path_red);
	w = getWidth();	
	h = getHeight();
	path = getDirectory("image");
	path_green = File.openDialog("Load prepared green image");
	open(path_green);
	if ( (w != getWidth()) || (h != getHeight()) ) {
		exit("Images must have the same dimenions");
	}
	if (path != getDirectory("image")) {
		exit("Images must come from the same directory");
	}

	red_fname = File.getName(path_red);
	green_fname = File.getName(path_green);

		// Load the Homer1c-tdTomato (red) and SEP-GluN1 (green) background images
	path_red_bkgnd = File.openDialog("Load red background image");
	open(path_red_bkgnd);
	w = getWidth();	
	h = getHeight();
	path = getDirectory("image");
	path_green_bkgnd = File.openDialog("Load green background image");
	open(path_green_bkgnd);
	if ( (w != getWidth()) || (h != getHeight()) ) {
		exit("Images must have the same dimenions");
	}
	if (path != getDirectory("image")) {
		exit("Images must come from the same directory");
	}
	green_bkgnd_fname = File.getName(path_green_bkgnd);
	red_bkgnd_fname = File.getName(path_red_bkgnd);

	// Load prepROI
	path_roi = File.openDialog("Load prepROI.zip");
	roiManager("Open",path_roi);

	// Use median filter and global thresholding to create mask and ROI of synapses
	selectWindow(red_fname);
	roiManager("Select",0);
	run("Copy");
	run("Select None");
	newImage("original","8-bit black",w,h,0);
	roiManager("Select",0);
	run("Paste");
	newImage("filtered","8-bit black",w,h,0);
	roiManager("Select",0);
	run("Paste");
	run("Median...");
	imageCalculator("Subtract create", "original","filtered");
	close("original");
	close("filtered");
	roiManager("Select",0);
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

	// Calculate relative spine fluorescence of green signal
	selectWindow(green_fname);
	run("Clear Results");
	run("Set Measurements...", "mean standard redirect=None decimal=9");
	roiManager("Select",1); // synapse ROI on green background-subtracted image
	run("Measure");
	selectWindow(green_bkgnd_fname);
	roiManager("Select",1); // synapse ROI on green background image
	run("Measure");
	a = getResult("Mean",0);      // Mean synapse green fluorescence
	b = getResult("Mean",1);      // Mean background green fluorescence
	c = getResult("StdDev",1);  // Standard deviation background green fluorescence
	z = (a-b)/c;
	print("Synaptic green fluorescence = "+a);
	print("Background green fluorescence = "+b+" +/- "+c);
	print("Z-score (green) = "+z);
	run("Select None");

	// Calculate relative spine fluorescence of red signal
	selectWindow(red_fname);
	run("Clear Results");
	run("Set Measurements...", "mean standard redirect=None decimal=9");
	roiManager("Select",1); // synapse ROI on red background-subtracted image
	run("Measure");
	selectWindow(red_bkgnd_fname);
	roiManager("Select",1); // synapse ROI on red background image
	run("Measure");
	a = getResult("Mean",0);      // Mean synapse red fluorescence
	b = getResult("Mean",1);      // Mean background red fluorescence
	c = getResult("StdDev",1);  // Standard deviation background red fluorescence
	z = (a-b)/c;
	print("Synaptic red fluorescence = "+a);
	print("Background red fluorescence = "+b+" +/- "+c);
	print("Z-score (red) = "+z);
	run("Select None");

	// Save mask of synapses
	i =  lastIndexOf(red_fname,".");
	red_fname = substring(red_fname,0,i);
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

	// Load the Homer1c-tdTomato (red) images
	path_red = File.openDialog("Load prepared red image");
	open(path_red);
	w = getWidth();	
	h = getHeight();
	path = getDirectory("image");

	run("Properties...", "channels=1 slices=1 frames=1 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1");
	setTool("multipoint");
	print("\\Clear")
	roiManager("reset");
	run("Select None");
	run("Clear Results");

	//to set the division factor for pixel length to micrometers for later output measurements
	Dialog.create("Pixel Size");
	Dialog.addMessage("Enter pixel size");
	Dialog.addNumber("Pixel (Microns)",0.103); //0.103 = um per pixel for Axiovert lab microscope at 63xObjective
	Dialog.show();
	p = Dialog.getNumber();

	//to define the straight line of dendrite and create a line along the dendtrite
	waitForUser( "Pause","Draw Line Points at either end of dendrite area");
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
     l = (sqrt(pow(x1-x2,2)+pow(y1-y2,2))*p);
	d = count/l;
     print(d+" - d");
     print(l+" - l");
	run("Clear Results");

	//Saving ROI .zip file
	Dialog.create("Save ROI File");
	Dialog.addMessage("Enter ROI File Name (without extension)");
	Dialog.addString("ROI File Name", "Add a File Name for the ROI set");
	Dialog.show();
	ROIname = Dialog.getString();
	name = getTitle();
	dir = getDirectory("image");
	path = dir+name+ROIname;
	ROIpath = dir+ROIname;
	saveAs("Tiff", path);
	roiManager("Deselect");
	roiManager("Save", ROIpath+".zip");

	//Saving data Log
	selectWindow("Log");
	saveAs("Text",path);
}
