//
//  ViewController.h
//  FaceDetection_Test
//
//  Created by Photon Infotech on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

@interface ViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    UIImageView* images ;
    UIImage * capturedImage;
    UIButton * button1;
    UIButton * button2;

}
-(void)faceDetector;
-(UIImage *)resizeImage:(UIImage *)image;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
