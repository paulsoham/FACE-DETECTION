//
//  ViewController.m
//  FaceDetection_Test
//
//  Created by Photon Infotech on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


////////////////////////Another way to rezise/////////////////////////////////////////////
/*
//Resize image and keep aspect ratio
-(UIImage *)resizeImage:(UIImage *)image {
	//int w = image.size.width;
   // int h = image.size.height; 
	
	CGImageRef imageRef = [image CGImage];
	
	int width, height;
	
	//int destWidth = 320;
	//int destHeight = 360;
    int destWidth = 320;
	int destHeight = 460;
//	if(w > h){
//		width = destWidth;
//		height = h*destWidth/w;
//	} else {
//		height = destHeight;
//		width = w*destHeight/h;
//	}
    width = destWidth;
    height = destHeight;

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
	CGContextRef bitmap;
	bitmap = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
	
	if (image.imageOrientation == UIImageOrientationLeft) {
		CGContextRotateCTM (bitmap, M_PI/2);
		CGContextTranslateCTM (bitmap, 0, -height);
		
	} else if (image.imageOrientation == UIImageOrientationRight) {
		CGContextRotateCTM (bitmap, -M_PI/2);
		CGContextTranslateCTM (bitmap, -width, 0);
		
	} else if (image.imageOrientation == UIImageOrientationUp) {
		
	} else if (image.imageOrientation == UIImageOrientationDown) {
		CGContextTranslateCTM (bitmap, width,height);
		CGContextRotateCTM (bitmap, -M_PI);
		
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return result;	
}*/
///////////////////////////////////////////////////////



- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}
- (void)albumButtonPressed:(UIButton *)button
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	imagePicker.delegate = self;
	[self presentModalViewController:imagePicker animated:YES];	
    
}
- (void)cameraButtonPressed:(UIButton *)button
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
	imagePicker.delegate = self;
	[self presentModalViewController:imagePicker animated:YES];	
    
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    ;
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	// Access the uncropped image from info dictionary
	capturedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
           
    
	// Save image
   // UIImageWriteToSavedPhotosAlbum(capturedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
	[picker release];
    [self dismissModalViewControllerAnimated:YES];

    [self faceDetector]; 

}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
     
    capturedImage=[[UIImage alloc]init];
    
    button1=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame=CGRectMake(80, 255, 162, 53);
    [button1 setTitle:@"CAMERA" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(cameraButtonPressed:) forControlEvents: UIControlEventTouchUpInside];      
    [self.view addSubview:button1];
    
    button2=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame=CGRectMake(80, 340, 162, 53);
    [button2 setTitle:@"ALBUM" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(albumButtonPressed:) forControlEvents: UIControlEventTouchUpInside];      
    [self.view addSubview:button2];

}
-(void)faceDetector
{  
    button1.hidden=YES;
    button2.hidden=YES;

    NSLog(@"original width==>>%f",capturedImage.size.width);
    NSLog(@"original height==>>%f",capturedImage.size.height);
    
    ///////////////////////////////Another way to rezise//////////////////////////////////////
    //UIImage * img =[self resizeImage:capturedImage];
    //////////////////////////////////////////////////////////////////////////////////////////
    
    UIImage * img =[self imageWithImage:capturedImage scaledToSize:CGSizeMake(320, 460)];

    // Load the picture for face detection
   //  UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"3.jpg"]];
      

    
    NSLog(@"resized width==>>%f",img.size.width);
    NSLog(@"resized height==>>%f",img.size.height);
    
    
    images = [[UIImageView alloc] initWithImage:img];
    
    
    // Draw the face detection image
    [self.view addSubview:images];
    
    // Execute the method used to markFaces in background
    [self performSelectorInBackground:@selector(markFaces:) withObject:images];
    
    // flip image on y-axis to match coordinate system used by core image
    [images setTransform:CGAffineTransformMakeScale(1, -1)];
    
    // flip the entire window to make everything right side up
    [self.view setTransform:CGAffineTransformMakeScale(1, -1)];
    
    
    UIButton * button3=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button3.frame=CGRectMake(80, 10, 162, 35);
    [button3 setTitle:@"CLEAR" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(buttonToClear) forControlEvents:UIControlEventTouchUpInside];      
    [self.view addSubview:button3];
    button3.transform=CGAffineTransformMakeScale(1, -1);

    
}
-(void)buttonToClear{
    
    NSArray *subviews = [self.view subviews];
    for (UIView *viewObj in subviews) {
       // NSLog(@"subclass==>>%@",[viewObj class]);
    }
    
    NSArray *array = self.view.subviews;
	//NSLog(@"Number of views : %d",[array count]);
	for (int i=1; i<[array count]; i++) {
		UIView *v = [array objectAtIndex:i];
		[v removeFromSuperview];
	}
    button1=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame=CGRectMake(80, 255, 162, 53);
    [button1 setTitle:@"CAMERA" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(cameraButtonPressed:) forControlEvents: UIControlEventTouchUpInside];      
    [self.view addSubview:button1];
    button1.transform=CGAffineTransformMakeScale(1, -1);

    button2=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame=CGRectMake(80, 340, 162, 53);
    [button2 setTitle:@"ALBUM" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(albumButtonPressed:) forControlEvents: UIControlEventTouchUpInside];      
    [self.view addSubview:button2];
    button2.transform=CGAffineTransformMakeScale(1, -1);

        
}
-(void)markFaces:(UIImageView *)facePicture
{
    // draw a CI image with the previously loaded face detection picture
    CIImage* image = [CIImage imageWithCGImage:facePicture.image.CGImage];
    
    // create a face detector - since speed is not an issue we'll use a high accuracy
    // detector
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace 
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    // create an array containing all the detected faces from the detector    
    NSArray* features = [detector featuresInImage:image];
    
    // we'll iterate through every detected face.  CIFaceFeature provides us
    // with the width for the entire face, and the coordinates of each eye
    // and the mouth if detected.  Also provided are BOOL's for the eye's and
    // mouth so we can check if they already exist.
    for(CIFaceFeature* faceFeature in features)
    {
        // get the width of the face
        CGFloat faceWidth = faceFeature.bounds.size.width;
        
        // create a UIView using the bounds of the face
        UIView* faceView = [[UIView alloc] initWithFrame:faceFeature.bounds];
        
        // add a border around the newly created UIView
        faceView.layer.borderWidth = 1;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        
        // add the new view to create a box around the face
        [self.view addSubview:faceView];
        
        if(faceFeature.hasLeftEyePosition)
        {
            // create a UIView with a size based on the width of the face
            UIView* leftEyeView = [[UIView alloc] initWithFrame:CGRectMake(faceFeature.leftEyePosition.x-faceWidth*0.15, faceFeature.leftEyePosition.y-faceWidth*0.15, faceWidth*0.3, faceWidth*0.3)];
            // change the background color of the eye view
            [leftEyeView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            // set the position of the leftEyeView based on the face
            [leftEyeView setCenter:faceFeature.leftEyePosition];
            // round the corners
            leftEyeView.layer.cornerRadius = faceWidth*0.15;
            // add the view to the window
            [self.view addSubview:leftEyeView];
        }
        
        if(faceFeature.hasRightEyePosition)
        {
            // create a UIView with a size based on the width of the face
            UIView* leftEye = [[UIView alloc] initWithFrame:CGRectMake(faceFeature.rightEyePosition.x-faceWidth*0.15, faceFeature.rightEyePosition.y-faceWidth*0.15, faceWidth*0.3, faceWidth*0.3)];
            // change the background color of the eye view
            [leftEye setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            // set the position of the rightEyeView based on the face
            [leftEye setCenter:faceFeature.rightEyePosition];
            // round the corners
            leftEye.layer.cornerRadius = faceWidth*0.15;
            // add the new view to the window
            [self.view addSubview:leftEye];
        }
        
        if(faceFeature.hasMouthPosition)
        {
            // create a UIView with a size based on the width of the face
            UIView* mouth = [[UIView alloc] initWithFrame:CGRectMake(faceFeature.mouthPosition.x-faceWidth*0.2, faceFeature.mouthPosition.y-faceWidth*0.2, faceWidth*0.4, faceWidth*0.4)];
            // change the background color for the mouth to green
            [mouth setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.3]];
            // set the position of the mouthView based on the face
            [mouth setCenter:faceFeature.mouthPosition];
            // round the corners
            mouth.layer.cornerRadius = faceWidth*0.2;
            // add the new view to the window
            [self.view addSubview:mouth];
        }
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation = UIInterfaceOrientationPortrait);
}

@end
