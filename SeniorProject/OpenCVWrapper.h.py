#
#  OpenCVWrapper.h
#  SeniorProject
#
#  Created by Sigh on 2/8/18.
#  Copyright © 2018 Sigh. All rights reserved.
#

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject
+(NSString *) openCVVersionString

+(UIImage *) makeGrayFromImage:(UIImage *)image

+(UIImage *) invertFromImage:(UIImage *)image
    
+(UIImage *) sharpenFromImage:(UIImage *)image

+(UIImage *) antiColorFromImage:(UIImage *)image
    
+(UIImage *) sculptingFromImage:(UIImage *)image
    
+(UIImage *) wavingFromImage:(UIImage *)image

+(UIImage *) denoisingFromImage:(UIImage *)image

+(UIImage *) edgeDetectingFromImage:(UIImage *)image

+(UIImage *) gaussianBlurFromImage:(UIImage *)image size:(int)size sigma:(double) sigma

+(UIImage *) deconvolutionLucyRichardsonFromImage:(UIImage *)image iteration:(int)num_iterations sigmaG:(double)sigmaG

+(UIImage *) wienerFromImage:(UIImage *)image diameter:(int)diameter k:(double)k angle:(double)angle

+(UIImage *) convolutionFromImage:(UIImage *)image len:(double)len angle:(double)angle iteration:(int)i

+(UIImage *) test:(UIImage *)grayImage

@end
