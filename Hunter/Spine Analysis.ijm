run("Properties...", "channels=1 slices=1 frames=1 unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1");
setTool("multipoint");
print("\\Clear")
roiManager("reset");
run("Select None");
run("Clear Results");

//to set the division factor for pixel length to micrometers for later output measurements
Dialog.create("Pixel Size");
Dialog.addMessage("Enter pixel size");
Dialog.addNumber("Pixel (Microns)",0.06); //0.06 = um per pixel for teaching lab microscope at 60xObjective
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