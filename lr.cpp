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
        cv::GaussianBlur( Y, reBlurred, cv::Size(winSize,winSize), sigmaG, sigmaG );//applying Gaussian filter
        reBlurred.setTo(FLT_EPSILON , reBlurred <= 0);
        
        // 2)
        cv::divide(wI, reBlurred, imR);
        imR = imR + FLT_EPSILON;
        
        // 3)
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