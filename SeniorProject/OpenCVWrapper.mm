//
//  OpenCVWrapper.m
//  SeniorProject
//
//  Created by Sigh on 2/8/18.
//  Copyright © 2018 Sigh. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/core/core_c.h>
#import <opencv2/core/cvdef.h>
#import <opencv2/highgui/highgui_c.h>
#import "OpenCVWrapper.h"

@implementation OpenCVWrapper
+(NSString *) openCVVersionString
{
    return [NSString stringWithFormat:@"OpenCV Version is %s", CV_VERSION];
}
+(UIImage *) makeGrayFromImage:(UIImage *)image
{
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    if(imageMat.channels() == 1) return image;
    
    cv::Mat grayMat;
    cv::cvtColor(imageMat, grayMat, CV_BGR2GRAY);
    
    return MatToUIImage(grayMat);
}
    
+(UIImage *) invertFromImage:(UIImage *)image
{
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    cv::Mat invertMat;
    invertMat = imageMat;
    
    for(int j = 0;j<invertMat.rows;j++){
        for(int i = 0;i<invertMat.cols * invertMat.channels();i++){
            invertMat.at<cv::Vec3b>(j,i)[0] = 254 - invertMat.at<cv::Vec3b>(j,i)[0];
            invertMat.at<cv::Vec3b>(j,i)[1] = 254 - invertMat.at<cv::Vec3b>(j,i)[1];
            invertMat.at<cv::Vec3b>(j,i)[2] = 254 - invertMat.at<cv::Vec3b>(j,i)[2];
        }
    }
    
    return MatToUIImage(invertMat);
    
}
    
+(UIImage *) antiColorFromImage:(UIImage *)image
{
    
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    cv::Mat antiColorMat;
    cv::threshold (imageMat, antiColorMat, 70, 255, CV_THRESH_BINARY_INV);
    
    return MatToUIImage(antiColorMat);

}
    
+(UIImage *) sharpenFromImage:(UIImage *)image
{
        
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
        
    cv::Mat sharpenMat;
    cv::GaussianBlur(imageMat, sharpenMat, cv::Size(0, 0), 50);
    cv::addWeighted(imageMat, 1.5, sharpenMat, -0.5, 0, sharpenMat);
    return MatToUIImage(sharpenMat);
}
    
+(UIImage *) sculptingFromImage:(UIImage *)image
{
        
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
        
    cv::Mat sculptingMat;
    sculptingMat = imageMat;
    int width = sculptingMat.cols;
    int height = sculptingMat.rows;
    size_t step = sculptingMat.step;
    int channel = sculptingMat.channels();
    uchar* data = (uchar* )sculptingMat.data;
    for(int i=0;i<width-1;i++)
    {
        for(int j=0;j<height-1;j++)
        {
            for(int k=0;k<channel;k++)
            {
                int temp = data[j*step+i*channel+k]-data[(j+1)*step+(i+1)*channel+k]+128;
                if(temp>255)
                {
                    data[j*step+i*channel+k]=255;
                }
                else if(temp<0)
                {
                    data[j*step+i*channel+k]=0;
                }
                else
                {
                    data[j*step+i*channel+k]=temp;
                }
            }
        }
    }
    
    return MatToUIImage(sculptingMat);
}

+(UIImage *) wavingFromImage:(UIImage *)image
{
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    cv::Mat wavingMat;
    wavingMat = imageMat;
    int width = wavingMat.cols;
    int height = wavingMat.rows;
    size_t step = wavingMat.step;
    int channel = wavingMat.channels();
    uchar* data = (uchar* )wavingMat.data;
    int sign=-1;
    for(int i=0;i<height;i++)
    {
        int cycle=10;
        int margin=(i%cycle);
        if((i/cycle)%2==0)
        {
            sign=-1;
        }
        else
        {
            sign=1;
        }
        if(sign==-1)
        {
            margin=cycle-margin;
            for(int j=0;j<width-margin;j++)
            {
                for(int k=0;k<channel;k++)
                {
                    data[i*step+j*channel+k]=data[i*step+(j+margin)*channel+k];
                }
            }
        }
        else if(sign==1)
        {
            for(int j=0;j<width-margin;j++)
            {
                for(int k=0;k<channel;k++)
                {
                    data[i*step+j*channel+k]=data[i*step+(j+margin)*channel+k];
                }
            }
        }
    }
    return MatToUIImage(wavingMat);
}

+(UIImage *) denoisingFromImage:(UIImage *)image
{
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    cv::Mat denoisedMat;
    if(imageMat.channels() == 1){
        cv::fastNlMeansDenoising(imageMat, denoisedMat);
    }else{
        cv::fastNlMeansDenoisingColored(imageMat, denoisedMat);
    }
    
    return MatToUIImage(denoisedMat);
}

+(UIImage *) edgeDetectingFromImage:(UIImage *)image
{
    cv::Mat grayMat;
    UIImageToMat(image, grayMat);
    
    cv::Mat edge;
    cv::Mat draw;
    cv::Canny( grayMat, edge, 50, 150, 3);
    
    edge.convertTo(draw, CV_8U);
    
    return MatToUIImage(draw);
}

+(UIImage *) gaussianBlurFromImage:(UIImage *)image size:(int)size sigma:(double) sigma
{
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    cv::Mat gaussianMat;
    cv::GaussianBlur(imageMat, gaussianMat, cv::Size(size, size), sigma);
    
    return MatToUIImage(gaussianMat);
}

IplImage* CreateIplImageFromUIImage(UIImage *image)
{
    // Getting CGImage from UIImage
    CGImageRef imageRef = image.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Creating temporal IplImage for drawing
    IplImage *iplimage = cvCreateImage(
                                       cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4
                                       );
    // Creating CGContext for temporal IplImage
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    iplimage->imageData, iplimage->width, iplimage->height,
                                                    iplimage->depth, iplimage->widthStep,
                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
                                                    );
    // Drawing CGImage to CGContext
    CGContextDrawImage(
                       contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef
                       );
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Creating result IplImage
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}

UIImage* UIImageFromIplImage(IplImage *image)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Allocating the buffer for CGImage
    NSData *data =
    [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((CFDataRef)data);
    // Creating CGImage from chunk of IplImage
    CGImageRef imageRef = CGImageCreate(
                                        image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault
                                        );
    // Getting UIImage from CGImage
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}



void Recomb(cv::Mat &src, cv::Mat &dst)
{
    int cx = src.cols >> 1;
    int cy = src.rows >> 1;
    cv::Mat tmp;
    tmp.create(src.size(), src.type());
    src(cv::Rect(0, 0, cx, cy)).copyTo(tmp(cv::Rect(cx, cy, cx, cy)));
    src(cv::Rect(cx, cy, cx, cy)).copyTo(tmp(cv::Rect(0, 0, cx, cy)));
    src(cv::Rect(cx, 0, cx, cy)).copyTo(tmp(cv::Rect(0, cy, cx, cy)));
    src(cv::Rect(0, cy, cx, cy)).copyTo(tmp(cv::Rect(cx, 0, cx, cy)));
    dst = tmp;
}

void convolveDFT(cv::Mat& A, cv::Mat& B, cv::Mat& C)
{
    // reallocate the output array if needed
    C.create(abs(A.rows - B.rows) + 1, abs(A.cols - B.cols) + 1, A.type());
    cv::Size dftSize;
    // compute the size of DFT transform
    dftSize.width = cv::getOptimalDFTSize(A.cols + B.cols - 1);
    dftSize.height = cv::getOptimalDFTSize(A.rows + B.rows - 1);
    // allocate temporary buffers and initialize them with 0's
    cv::Mat tempA(dftSize, A.type(), cv::Scalar::all(0));
    cv::Mat tempB(dftSize, B.type(), cv::Scalar::all(0));
    // copy A and B to the top-left corners of tempA and tempB, respectively
    cv::Mat roiA(tempA, cv::Rect(0, 0, A.cols, A.rows));
    A.copyTo(roiA);
    cv::Mat roiB(tempB, cv::Rect(0, 0, B.cols, B.rows));
    B.copyTo(roiB);
    // now transform the padded A & B in-place;
    // use "nonzeroRows" hint for faster processing
    dft(tempA, tempA, 0, A.rows);
    
    dft(tempB, tempB, 0, A.rows);
    
    // multiply the spectrums;
    // the function handles packed spectrum representations well
    mulSpectrums(tempA, tempB, tempA, 0);
    // transform the product back from the frequency domain.
    // Even though all the result rows will be non-zero,
    // you need only the first C.rows of them, and thus you
    // pass nonzeroRows == C.rows
    
    dft(tempA, tempA, cv::DFT_INVERSE + cv::DFT_SCALE);
    // now copy the result back to C.
    C = tempA(cv::Rect((dftSize.width - A.cols) / 2, (dftSize.height - A.rows) / 2, A.cols, A.rows)).clone();
    // all the temporary buffers will be deallocated automatically
}

//----------------------------------------------------------
// Compute Re and Im planes of FFT from Image
//----------------------------------------------------------
void ForwardFFT(cv::Mat &Src, cv::Mat *FImg)
{
    int M = cv::getOptimalDFTSize(Src.rows);
    int N = cv::getOptimalDFTSize(Src.cols);
    cv::Mat padded;
    copyMakeBorder(Src, padded, 0, M - Src.rows, 0, N - Src.cols, cv::BORDER_CONSTANT, cv::Scalar::all(0));
    cv::Mat planes[] = { cv::Mat_<double>(padded), cv::Mat::zeros(padded.size(), CV_64FC1) };
    cv::Mat complexImg;
    cv::merge(planes, 2, complexImg);
    cv::dft(complexImg, complexImg);
    cv::split(complexImg, planes);
    // crop result
    planes[0] = planes[0](cv::Rect(0, 0, Src.cols, Src.rows));
    planes[1] = planes[1](cv::Rect(0, 0, Src.cols, Src.rows));
    FImg[0] = planes[0].clone();
    FImg[1] = planes[1].clone();
}
//----------------------------------------------------------
// Compute image from Re and Im parts of FFT
//----------------------------------------------------------
void InverseFFT(cv::Mat *FImg, cv::Mat &Dst)
{
    cv::Mat complexImg;
    cv::merge(FImg, 2, complexImg);
    cv::dft(complexImg, complexImg, cv::DFT_INVERSE + cv::DFT_SCALE);
    cv::split(complexImg, FImg);
    Dst = FImg[0];
}
//----------------------------------------------------------
// wiener Filter
//----------------------------------------------------------

+(UIImage *) wienerFromImage:(UIImage *)image diameter:(int)diameter k:(double)k angle:(double)angle
{
    cv::Mat src;
    UIImageToMat(image, src);
    std::vector<cv::Mat> spl;
    split(src,spl);
    
    // Create an zero pixel image for filling purposes - will become clear later
    // Also create container images for B G R channels as colour images
    cv::Mat empty_image = cv::Mat::zeros(src.rows, src.cols, CV_8UC1);
    cv::Mat result_red(src.rows, src.cols, CV_8UC3); // notice the 3 channels here!
    cv::Mat result_green(src.rows, src.cols, CV_8UC3); // notice the 3 channels here!
    cv::Mat result_blue(src.rows, src.cols, CV_8UC3); // notice the 3 channels here!
    
    // Create red channel
    spl[0] = wienerFromImageImpl(spl[0], diameter, k, angle);
    cv::Mat in1[] = { spl[0], empty_image, empty_image };
    int from_to1[] = { 0,0, 1,1, 2,2 };
    cv::mixChannels( in1, 3, &result_red, 1, from_to1, 3 );
    
    // Create green channel
    spl[1] = wienerFromImageImpl(spl[1], diameter, k, angle);
    cv::Mat in2[] = { empty_image, spl[1], empty_image };
    int from_to2[] = { 0,0, 1,1, 2,2 };
    cv::mixChannels( in2, 3, &result_green, 1, from_to2, 3 );
    
    // Create blue channel
    spl[2] = wienerFromImageImpl(spl[2], diameter, k, angle);
    cv::Mat in3[] = { empty_image, empty_image, spl[2]};
    int from_to3[] = { 0,0, 1,1, 2,2 };
    cv::mixChannels( in3, 3, &result_blue, 1, from_to3, 3 );
    
    std::vector<cv::Mat> array_to_merge;
    cv::cvtColor(result_blue, result_blue, CV_BGR2GRAY);
    cv::cvtColor(result_green, result_green, CV_BGR2GRAY);
    cv::cvtColor(result_red, result_red, CV_BGR2GRAY);
    
    array_to_merge.push_back(result_red*5.0);
    array_to_merge.push_back(result_green);
    array_to_merge.push_back(result_blue*2.0);
    
    
    cv::Mat color;
    
    cv::merge(array_to_merge, color);
    
    /*cv::Mat bgr[3];
    bgr[0] = result_blue;
    bgr[1] = result_green;
    bgr[2] = result_red;
    
    cv::Mat color;
    cv::merge(bgr, 3, color);*/
    return MatToUIImage(color);
    //return MatToUIImage(wienerFromImageImpl(result_blue, diameter, k, angle));
}


cv::Mat wienerFromImageImpl(cv::Mat src, int diameter, double k, double angle)
{
    cv::Mat dst;
    cv::Mat _h;
    if(angle == 0 ||angle == 90||angle == 180||angle == 270||angle == 360){
        angle = angle+1;
    }
    genaratePsf(_h, diameter, angle);
    
    //---------------------------------------------------
    // Small epsilon to avoid division by zero
    //---------------------------------------------------
    const double eps = 1E-8;
    //---------------------------------------------------
    int ImgW = src.size().width;
    int ImgH = src.size().height;
    //--------------------------------------------------
    cv::Mat Yf[2];
    ForwardFFT(src, Yf);
    //--------------------------------------------------
    cv::Mat h = cv::Mat::zeros(ImgH, ImgW, CV_64FC1);
    
    int padx = h.cols - _h.cols;
    int pady = h.rows - _h.rows;
    
    copyMakeBorder(_h, h, pady / 2, pady - pady / 2, padx / 2, padx - padx / 2, cv::BORDER_CONSTANT, cv::Scalar::all(0));
    
    cv::Mat Hf[2];
    ForwardFFT(h, Hf);
    
    
    //--------------------------------------------------
    cv::Mat Fu[2];
    Fu[0] = cv::Mat::zeros(ImgH, ImgW, CV_64FC1);
    Fu[1] = cv::Mat::zeros(ImgH, ImgW, CV_64FC1);
    
    std::complex<double> a;
    std::complex<double> b;
    std::complex<double> c;
    
    double Hf_Re;
    double Hf_Im;
    double Phf;
    double hfz;
    double hz;
    double A;
    
    for (int i = 0; i < h.rows; i++)
    {
        for (int j = 0; j < h.cols; j++)
        {
            //if(i!=359&&j!=320){
                Hf_Re = Hf[0].at<double>(i, j);
                Hf_Im = Hf[1].at<double>(i, j);
                Phf = Hf_Re*Hf_Re + Hf_Im*Hf_Im;
                hfz = (Phf < eps)*eps;
                hz = (h.at<double>(i, j) > 0);
                A = Phf / (Phf + hz + k);
                a = std::complex<double>(Yf[0].at<double>(i, j), Yf[1].at<double>(i, j));
                b = std::complex<double>(Hf_Re + hfz, Hf_Im + hfz);
                c = a / b; // Deconvolution :) other work to avoid division by zero
                Fu[0].at<double>(i, j) = (c.real()*A);
                Fu[1].at<double>(i, j) = (c.imag()*A);
            //}
        }
    }
    InverseFFT(Fu, dst);
    Recomb(dst, dst);
    
    //print(dst);
    
    dst.convertTo(dst, CV_8U);

    return dst;
}

+(UIImage *) test:(UIImage *)image
{
    /*cv::Mat src;
    UIImageToMat(image, src);
    cv::Mat dst;
    cv::Mat bgr[3];
    cv::split(src, bgr);
    dst = bgr[0];
    dst.convertTo(dst, CV_8U);
    return MatToUIImage(dst);*/
    return image;
}



/*+(UIImage *) WienerFromImage:(UIImage *)grayImage noiseVariance:(double)noiseVariance Size:(int)size
{
    cv::Mat1b dst;
    cv::Mat1b src;
    UIImageToMat(grayImage, src);
    if (size % 2 == 0){
        size += 1;
    }
    WienerFilterImpl(src, dst, noiseVariance, cv::Size(size,size));
    return MatToUIImage(dst);
    
}

+(UIImage *) WienerFromImage:(UIImage *)grayImage Size:(int)size
{
    cv::Mat1b dst;
    cv::Mat1b src;
    UIImageToMat(grayImage, src);
    
    if (size % 2 == 0){
        size += 1;
    }
    
    WienerFilterImpl(src, dst, -1, cv::Size(size,size));
    return MatToUIImage(dst);
    
}*/

/*double WienerFilterImpl(const cv::Mat& src, cv::Mat& dst, double noiseVariance, const cv::Size& block)
{*/
    
    /*assert(("Invalid block dimensions", block.width % 2 == 1 && block.height % 2 == 1 && block.width > 1 && block.height > 1));
    assert(("src and dst must be one channel grayscale images", src.channels() == 1, dst.channels() == 1));*/
    
    /*int h = src.rows;
    int w = src.cols;
    
    dst = cv::Mat1b(h, w);

    cv::Mat1d means, sqrMeans, variances;
    cv::Mat1d avgVarianceMat;
    
    cv::boxFilter(src, means, CV_64F, block, cv::Point(-1, -1), true, cv::BORDER_REPLICATE);
    cv::sqrBoxFilter(src, sqrMeans, CV_64F, block, cv::Point(-1, -1), true, cv::BORDER_REPLICATE);
    
    cv::Mat1d means2 = means.mul(means);
    variances = sqrMeans - (means.mul(means));
    
    if (noiseVariance < 0){
        // I have to estimate the noiseVariance
        reduce(variances, avgVarianceMat, 1, CV_REDUCE_SUM, -1);
        reduce(avgVarianceMat, avgVarianceMat, 0, CV_REDUCE_SUM, -1);
        noiseVariance = avgVarianceMat(0, 0) / (h*w);
    }
    
    for (int r = 0; r < h; ++r){
        // get row pointers
        uchar const * const srcRow = src.ptr<uchar>(r);
        uchar * const dstRow = dst.ptr<uchar>(r);
        double * const varRow = variances.ptr<double>(r);
        double * const meanRow = means.ptr<double>(r);
        for (int c = 0; c < w; ++c) {
            dstRow[c] = cv::saturate_cast<uchar>(
                                             meanRow[c] + cv::max(0., varRow[c] - noiseVariance) / cv::max(varRow[c], noiseVariance) * (srcRow[c] - meanRow[c])
                                             );
        }
    
    }
    
    print(dst);
    return noiseVariance;
}*/

void LucyRichardsonImpl(int j, int &iteration, cv::Mat &T1, cv::Mat &T2, cv::Mat &tmpMat1, cv::Mat &tmpMat2, cv::Mat &J1, cv::Mat &J2, double &lambda, cv::Mat &Y, cv::Mat &reBlurred, double &sigmaG, cv::Mat &imR, cv::Mat &wI, int &winSize)
{
    if(j<iteration)
    {
        if (j>1)
        {
            // calculation of lambda
            multiply(T1, T2, tmpMat1);
            multiply(T2, T2, tmpMat2);
            lambda=sum(tmpMat1)[0] / (sum( tmpMat2)[0]+FLT_EPSILON);
            // calculation of lambda
        }
        
        Y = J1 + lambda * (J1-J2);
        Y.setTo(0, Y < 0);
        
        // 1)
        reBlurred = Y;
        genaratePsf(reBlurred, 22, -2);
        //cv::GaussianBlur( Y, reBlurred, cv::Size(winSize,winSize), sigmaG, sigmaG );//applying Gaussian filter
        reBlurred.setTo(FLT_EPSILON , reBlurred <= 0);
        
        // 2)
        cv::divide(wI, reBlurred, imR);
        imR = imR + FLT_EPSILON;
        
        // 3)
        genaratePsf(imR, 22, -2);
        //cv::GaussianBlur( imR, imR, cv::Size(winSize,winSize), sigmaG, sigmaG );//applying Gaussian filter
        
        // 4)
        J2 = J1.clone();
        cv::multiply(Y, imR, J1);
        
        T2 = T1.clone();
        T1 = J1 - Y;
        
        LucyRichardsonImpl(++j,iteration,T1,T2,tmpMat1,tmpMat2,J1,J2,lambda,Y,reBlurred,sigmaG,imR,wI,winSize);
    }
}

+(UIImage *) deconvolutionLucyRichardsonFromImage:(UIImage *)image iteration:(int)num_iterations sigmaG:(double)sigmaG
{
    // Lucy-Richardson Deconvolution Function
    // input-1 img: NxM matrix image
    // input-2 num_iterations: number of iterations
    // input-3 sigma: sigma of point spread function (PSF)
    // output result: deconvolution result
    
    // Window size of PSF
    int winSize = 8 * sigmaG ;
    if (winSize % 2 == 0){
        winSize += 1;
    }
    
    cv::Mat img;
    UIImageToMat(image, img);
    img.convertTo(img, CV_64F);
    //cv::normalize(img, img, 0, 1, cv::NORM_MINMAX);
    
    
    // Initializations
    cv::Mat Y = img.clone();
    cv::Mat J1 = img.clone();
    cv::Mat J2 = img.clone();
    cv::Mat wI = img.clone();
    cv::Mat imR = img.clone();
    cv::Mat reBlurred = img.clone();
    
    cv::Mat T1, T2, tmpMat1, tmpMat2;
    
    T1 = cv::Mat(img.rows,img.cols, CV_64F, 0.0);
    T2 = cv::Mat(img.rows,img.cols, CV_64F, 0.0);
    
    // Lucy-Rich. Deconvolution CORE
    
    double lambda = 0;
    
    //LucyRichardsonImpl(0,num_iterations,T1,T2,tmpMat1,tmpMat2,J1,J2,lambda,Y,reBlurred,sigmaG,imR,wI,winSize);

    for(int j = 0; j < num_iterations; j++)
    {
        if (j>1) {
            // calculation of lambda
            multiply(T1, T2, tmpMat1);
            multiply(T2, T2, tmpMat2);
            lambda=sum(tmpMat1)[0] / (sum( tmpMat2)[0]+FLT_EPSILON);
            // calculation of lambda
        }
        
        Y = J1 + lambda * (J1-J2);
        Y.setTo(0, Y < 0);
        
        // 1)
        //reBlurred = Y;
        //genaratePsf(reBlurred, 22, -2);
        cv::GaussianBlur( Y, reBlurred, cv::Size(winSize,winSize), sigmaG, sigmaG );//applying Gaussian filter
        reBlurred.setTo(FLT_EPSILON , reBlurred <= 0);
        
        // 2)
        cv::divide(wI, reBlurred, imR);
        imR = imR + FLT_EPSILON;
        
        // 3)
        //genaratePsf(imR, 22, -2);
        cv::GaussianBlur( imR, imR, cv::Size(winSize,winSize), sigmaG, sigmaG );//applying Gaussian filter
        
        // 4)
        J2 = J1.clone();
        cv::multiply(Y, imR, J1);
        
        T2 = T1.clone();
        T1 = J1 - Y;
    }
    
    // output
    cv::Mat result;
    result = J1.clone();
    result.convertTo(result, CV_8U);
    return MatToUIImage(result);
}

+(UIImage *) convolutionFromImage:(UIImage *)image len:(double)len angle:(double)angle iteration:(int)i
{
    cv::Mat img;
    UIImageToMat(image, img);
    img.convertTo(img, CV_8UC1);
    cv::Mat _h;
    /*float data[3][3] = {{0.05f,0.05f,0.05f},{0.045454546f,0.045454546f,0.045454546f},{0.05f,0.05f,0.05f}};
    _h = cv::Mat(3, 3, CV_32F, &data);*/
    if(angle == 0 ||angle == 90||angle == 180||angle == 270||angle == 360){
        angle = angle+1;
    }
    genaratePsf(_h, len, angle);
    cv::Mat est;
    est = img.clone();
    cv::filter2D(img, est, -1, _h);
    /*for(int k = 1; k<=i; k++){
        cv::Mat dst;
        cv::Mat D;
        cv::Mat M;
        cv::filter2D(est, dst, -1, _h);
        dst.setTo(FLT_EPSILON , dst <= 0);
        cv::divide(img, dst, D);
        D = D + FLT_EPSILON;
        cv::filter2D(D, M, -1, _h);
        cv::multiply(est, M, est);
    }*/
    est.convertTo(est, CV_8U);
    
    return MatToUIImage(est);
}

void genaratePsf(cv::Mat &psf, double len,double angle)
{
    double half=len/2;
    double alpha = (angle-floor(angle/ 180) *180) /180* CV_PI;
    double cosalpha = cos(alpha);
    double sinalpha = sin(alpha);
    int xsign;
    if (cosalpha < 0)
    {
        xsign = -1;
    }
    else
    {
        if (angle == 90)
        {
            xsign = 0;
        }
        else
        {
            xsign = 1;
        }
    }
    int psfwdt = 1;
    int sx = (int)fabs(half*cosalpha + psfwdt*xsign - len* FLT_EPSILON);
    int sy = (int)fabs(half*sinalpha + psfwdt - len* FLT_EPSILON);
    cv::Mat_<double> psf1(sy, sx, CV_64F);
    cv::Mat_<double> psf2(sy * 2, sx * 2, CV_64F);
    int row = 2 * sy;
    int col = 2 * sx;
    /*为减小运算量，先计算一半大小的PSF*/
    for (int i = 0; i < sy; i++)
    {
        double* pvalue = psf1.ptr<double>(i);
        for (int j = 0; j < sx; j++)
        {
            pvalue[j] = i*fabs(cosalpha) - j*sinalpha;
            
            double rad = sqrt(i*i + j*j);
            if (rad >= half && fabs(pvalue[j]) <= psfwdt)
            {
                double temp = half - fabs((j + pvalue[j] * sinalpha) / cosalpha);
                pvalue[j] = sqrt(pvalue[j] * pvalue[j] + temp*temp);
            }
            pvalue[j] = psfwdt + FLT_EPSILON - fabs(pvalue[j]);
            if (pvalue[j] < 0)
            {
                pvalue[j] = 0;
            }
        }
    }
    /*将模糊核矩阵扩展至实际大小*/
    for (int i = 0; i < sy; i++)
    {
        double* pvalue1 = psf1.ptr<double>(i);
        double* pvalue2 = psf2.ptr<double>(i);
        for (int j = 0; j < sx; j++)
        {
            pvalue2[j] = pvalue1[j];
        }
    }
    
    for (int i = 0; i < sy; i++)
    {
        for (int j = 0; j < sx; j++)
        {
            psf2[2 * sy -1 - i][2 * sx -1 - j] = psf1[i][j];
            psf2[sy + i][j] = 0;
            psf2[i][sx + j] = 0;
        }
    }
    /*保持图像总能量不变，归一化矩阵*/
    double sum = 0;
    for (int i = 0; i < row; i++)
    {
        for (int j = 0; j < col; j++)
        {
            sum+= psf2[i][j];
        }
    }
    psf2 = psf2 / sum;
    if (cosalpha>0)
    {
        flip(psf2, psf2, 0);
    }
    
    //cout << "psf2=" << psf2 << endl;
    psf = psf2;
}
@end
