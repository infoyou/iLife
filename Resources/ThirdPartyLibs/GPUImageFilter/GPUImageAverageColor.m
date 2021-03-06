#import "GPUImageAverageColor.h"

NSString *const kGPUImageColorAveragingVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 uniform float texelWidth;
 uniform float texelHeight;
 
 varying vec2 upperLeftInputTextureCoordinate;
 varying vec2 upperRightInputTextureCoordinate;
 varying vec2 lowerLeftInputTextureCoordinate;
 varying vec2 lowerRightInputTextureCoordinate;
 
 void main()
 {
     gl_Position = position;
     
     upperLeftInputTextureCoordinate = inputTextureCoordinate.xy + vec2(-texelWidth, -texelHeight);
     upperRightInputTextureCoordinate = inputTextureCoordinate.xy + vec2(texelWidth, -texelHeight);
     lowerLeftInputTextureCoordinate = inputTextureCoordinate.xy + vec2(-texelWidth, texelHeight);
     lowerRightInputTextureCoordinate = inputTextureCoordinate.xy + vec2(texelWidth, texelHeight);
 }
 );

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageColorAveragingFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 uniform sampler2D inputImageTexture;
 
 varying highp vec2 outputTextureCoordinate;
 
 varying highp vec2 upperLeftInputTextureCoordinate;
 varying highp vec2 upperRightInputTextureCoordinate;
 varying highp vec2 lowerLeftInputTextureCoordinate;
 varying highp vec2 lowerRightInputTextureCoordinate;
 
 void main()
 {
     highp vec4 upperLeftColor = texture2D(inputImageTexture, upperLeftInputTextureCoordinate);
     highp vec4 upperRightColor = texture2D(inputImageTexture, upperRightInputTextureCoordinate);
     highp vec4 lowerLeftColor = texture2D(inputImageTexture, lowerLeftInputTextureCoordinate);
     highp vec4 lowerRightColor = texture2D(inputImageTexture, lowerRightInputTextureCoordinate);
     
     gl_FragColor = 0.25 * (upperLeftColor + upperRightColor + lowerLeftColor + lowerRightColor);
 }
);
#else
NSString *const kGPUImageColorAveragingFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 
 varying vec2 outputTextureCoordinate;
 
 varying vec2 upperLeftInputTextureCoordinate;
 varying vec2 upperRightInputTextureCoordinate;
 varying vec2 lowerLeftInputTextureCoordinate;
 varying vec2 lowerRightInputTextureCoordinate;
 
 void main()
 {
     vec4 upperLeftColor = texture2D(inputImageTexture, upperLeftInputTextureCoordinate);
     vec4 upperRightColor = texture2D(inputImageTexture, upperRightInputTextureCoordinate);
     vec4 lowerLeftColor = texture2D(inputImageTexture, lowerLeftInputTextureCoordinate);
     vec4 lowerRightColor = texture2D(inputImageTexture, lowerRightInputTextureCoordinate);
     
     gl_FragColor = 0.25 * (upperLeftColor + upperRightColor + lowerLeftColor + lowerRightColor);
 }
);
#endif

@implementation GPUImageAverageColor

@synthesize colorAverageProcessingFinishedBlock = _colorAverageProcessingFinishedBlock;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithVertexShaderFromString:kGPUImageColorAveragingVertexShaderString fragmentShaderFromString:kGPUImageColorAveragingFragmentShaderString]))
    {
        return nil;
    }
    
    texelWidthUniform = [filterProgram uniformIndex:@"texelWidth"];
    texelHeightUniform = [filterProgram uniformIndex:@"texelHeight"];
    
    stageTextures = [[NSMutableArray alloc] init];
    stageFramebuffers = [[NSMutableArray alloc] init];
    stageSizes = [[NSMutableArray alloc] init];
    
    __unsafe_unretained GPUImageAverageColor *weakSelf = self;
    [self setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime frameTime) {
        [weakSelf extractAverageColorAtFrameTime:frameTime];
    }];

    return self;
}

- (void)dealloc;
{
    if (rawImagePixels != NULL)
    {
        free(rawImagePixels);
    }
}

#pragma mark -
#pragma mark Manage the output texture

- (void)initializeOutputTextureIfNeeded;
{
    if (inputTextureSize.width < 1.0)
    {
        return;
    }
    
    // Create textures for each level
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];

        NSUInteger numberOfReductionsInX = floor(log(inputTextureSize.width) / log(4.0));
        NSUInteger numberOfReductionsInY = floor(log(inputTextureSize.height) / log(4.0));
//        DLog(@"Reductions in X: %d, y: %d", numberOfReductionsInX, numberOfReductionsInY);
        
        NSUInteger reductionsToHitSideLimit = MIN(numberOfReductionsInX, numberOfReductionsInY);
//        DLog(@"Total reductions: %d", reductionsToHitSideLimit);
        for (NSUInteger currentReduction = 0; currentReduction < reductionsToHitSideLimit; currentReduction++)
        {
//            CGSize currentStageSize = CGSizeMake(ceil(inputTextureSize.width / pow(4.0, currentReduction + 1.0)), ceil(inputTextureSize.height / pow(4.0, currentReduction + 1.0)));
            CGSize currentStageSize = CGSizeMake(floor(inputTextureSize.width / pow(4.0, currentReduction + 1.0)), floor(inputTextureSize.height / pow(4.0, currentReduction + 1.0)));
            if ( (currentStageSize.height < 2.0) || (currentStageSize.width < 2.0) )
            {
                // A really small last stage seems to cause significant errors in the average, so I abort and leave the rest to the CPU at this point
                break;
//                currentStageSize.height = 2.0; // TODO: Rotate the image to account for this case, which causes FBO construction to fail
            }
            
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
            [stageSizes addObject:[NSValue valueWithCGSize:currentStageSize]];
#else
            [stageSizes addObject:[NSValue valueWithSize:NSSizeFromCGSize(currentStageSize)]];
#endif

            GLuint textureForStage;
            glGenTextures(1, &textureForStage);
            glBindTexture(GL_TEXTURE_2D, textureForStage);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, self.outputTextureOptions.minFilter);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, self.outputTextureOptions.magFilter);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, self.outputTextureOptions.wrapS);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, self.outputTextureOptions.wrapT);
            [stageTextures addObject:[NSNumber numberWithInt:textureForStage]];
            
//            DLog(@"At reduction: %d size in X: %f, size in Y:%f", currentReduction, currentStageSize.width, currentStageSize.height);
        }
    });
}

- (void)deleteOutputTexture;
{
    if ([stageTextures count] == 0)
    {
        return;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        NSUInteger numberOfStageTextures = [stageTextures count];
        for (NSUInteger currentStage = 0; currentStage < numberOfStageTextures; currentStage++)
        {
            GLuint currentTexture = [[stageTextures objectAtIndex:currentStage] intValue];
            glDeleteTextures(1, &currentTexture);
        }
        
        [stageTextures removeAllObjects];
        [stageSizes removeAllObjects];
    });
}

#pragma mark -
#pragma mark Managing the display FBOs

- (void)recreateFilterFBO
{
    cachedMaximumOutputSize = CGSizeZero;
    [self destroyFilterFBO];    
    [self deleteOutputTexture];
    [self initializeOutputTextureIfNeeded];
    
    [self setFilterFBO];
}

- (void)createFilterFBOofSize:(CGSize)currentFBOSize;
{
    // Create framebuffers for each level
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        glActiveTexture(GL_TEXTURE1);
        
        NSUInteger numberOfStageFramebuffers = [stageTextures count];
        for (NSUInteger currentStage = 0; currentStage < numberOfStageFramebuffers; currentStage++)
        {
            GLuint currentFramebuffer;
            glGenFramebuffers(1, &currentFramebuffer);
            glBindFramebuffer(GL_FRAMEBUFFER, currentFramebuffer);
            [stageFramebuffers addObject:[NSNumber numberWithInt:currentFramebuffer]];
            
            GLuint currentTexture = [[stageTextures objectAtIndex:currentStage] intValue];
            glBindTexture(GL_TEXTURE_2D, currentTexture);
            
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
            CGSize currentFramebufferSize = [[stageSizes objectAtIndex:currentStage] CGSizeValue];
#else
            NSSize currentFramebufferSize = [[stageSizes objectAtIndex:currentStage] sizeValue];
#endif
            
//            DLog(@"FBO stage size: %f, %f", currentFramebufferSize.width, currentFramebufferSize.height);
            glTexImage2D(GL_TEXTURE_2D,
                         0,
                         self.outputTextureOptions.internalFormat,
                         (int)currentFramebufferSize.width,
                         (int)currentFramebufferSize.height,
                         0,
                         self.outputTextureOptions.format,
                         self.outputTextureOptions.type,
                         0);
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, currentTexture, 0);
            GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
            
            NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
        }
    });
    
//    [self notifyTargetsAboutNewOutputTexture];
}

- (void)destroyFilterFBO;
{
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        NSUInteger numberOfStageFramebuffers = [stageFramebuffers count];
        for (NSUInteger currentStage = 0; currentStage < numberOfStageFramebuffers; currentStage++)
        {
            GLuint currentFramebuffer = [[stageFramebuffers objectAtIndex:currentStage] intValue];
            glDeleteFramebuffers(1, &currentFramebuffer);
        }
        
        [stageFramebuffers removeAllObjects];
    });
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture;
{
    if (self.preventRendering)
    {
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];

    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);

    GLuint currentTexture = sourceTexture;
    
    NSUInteger numberOfStageFramebuffers = [stageFramebuffers count];
    for (NSUInteger currentStage = 0; currentStage < numberOfStageFramebuffers; currentStage++)
    {
        GLuint currentFramebuffer = [[stageFramebuffers objectAtIndex:currentStage] intValue];
        glBindFramebuffer(GL_FRAMEBUFFER, currentFramebuffer);
        
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        CGSize currentStageSize = [[stageSizes objectAtIndex:currentStage] CGSizeValue];
#else
        NSSize currentStageSize = [[stageSizes objectAtIndex:currentStage] sizeValue];
#endif
        glViewport(0, 0, (int)currentStageSize.width, (int)currentStageSize.height);

        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, currentTexture);
        
        glUniform1i(filterInputTextureUniform, 2);
        
        glUniform1f(texelWidthUniform, 0.5 / currentStageSize.width);
        glUniform1f(texelHeightUniform, 0.5 / currentStageSize.height);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

        currentTexture = [[stageTextures objectAtIndex:currentStage] intValue];

//        NSUInteger totalBytesForImage = (int)currentStageSize.width * (int)currentStageSize.height * 4;
//        GLubyte *rawImagePixels2 = (GLubyte *)malloc(totalBytesForImage);
//        glReadPixels(0, 0, (int)currentStageSize.width, (int)currentStageSize.height, GL_RGBA, GL_UNSIGNED_BYTE, rawImagePixels2);
//        CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rawImagePixels2, totalBytesForImage, NULL);
//        CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();
//
//        CGFloat currentRedTotal = 0.0f, currentGreenTotal = 0.0f, currentBlueTotal = 0.0f, currentAlphaTotal = 0.0f;
//        NSUInteger totalNumberOfPixels = totalBytesForImage / 4;
//        
//        for (NSUInteger currentPixel = 0; currentPixel < totalNumberOfPixels; currentPixel++)
//        {
//            currentRedTotal += (CGFloat)rawImagePixels2[(currentPixel * 4)] / 255.0f;
//            currentGreenTotal += (CGFloat)rawImagePixels2[(currentPixel * 4) + 1] / 255.0f;
//            currentBlueTotal += (CGFloat)rawImagePixels2[(currentPixel * 4 + 2)] / 255.0f;
//            currentAlphaTotal += (CGFloat)rawImagePixels2[(currentPixel * 4) + 3] / 255.0f;
//        }
//        
//        DLog(@"Stage %d average image red: %f, green: %f, blue: %f, alpha: %f", currentStage, currentRedTotal / (CGFloat)totalNumberOfPixels, currentGreenTotal / (CGFloat)totalNumberOfPixels, currentBlueTotal / (CGFloat)totalNumberOfPixels, currentAlphaTotal / (CGFloat)totalNumberOfPixels);
//
//        
//        CGImageRef cgImageFromBytes = CGImageCreate((int)currentStageSize.width, (int)currentStageSize.height, 8, 32, 4 * (int)currentStageSize.width, defaultRGBColorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaLast, dataProvider, NULL, NO, kCGRenderingIntentDefault);
//
//        UIImage *imageToSave = [UIImage imageWithCGImage:cgImageFromBytes];
//        
//        NSData *dataForPNGFile = UIImagePNGRepresentation(imageToSave);
//        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        
//        NSString *imageName = [NSString stringWithFormat:@"AverageLevel%d.png", currentStage];
//        NSError *error = nil;
//        if (![dataForPNGFile writeToFile:[documentsDirectory stringByAppendingPathComponent:imageName] options:NSAtomicWrite error:&error])
//        {
//            return;
//        }
    }
}

- (void)prepareForImageCapture;
{
    preparedToCaptureImage = YES;
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    inputRotation = kGPUImageNoRotation;
}

- (void)extractAverageColorAtFrameTime:(CMTime)frameTime;
{
    // we need a normal color texture for averaging the color values
    NSAssert(self.outputTextureOptions.internalFormat == GL_RGBA, @"The output texture internal format for this filter must be GL_RGBA.");
    NSAssert(self.outputTextureOptions.type == GL_UNSIGNED_BYTE, @"The type of the output texture of this filter must be GL_UNSIGNED_BYTE.");
    
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGSize finalStageSize = [[stageSizes lastObject] CGSizeValue];
#else
    NSSize finalStageSize = [[stageSizes lastObject] sizeValue];
#endif
    NSUInteger totalNumberOfPixels = round(finalStageSize.width * finalStageSize.height);
    
    if (rawImagePixels == NULL)
    {
        rawImagePixels = (GLubyte *)malloc(totalNumberOfPixels * 4);
    }

    glReadPixels(0, 0, (int)finalStageSize.width, (int)finalStageSize.height, GL_RGBA, GL_UNSIGNED_BYTE, rawImagePixels);
    
    NSUInteger redTotal = 0, greenTotal = 0, blueTotal = 0, alphaTotal = 0;
    NSUInteger byteIndex = 0;
    for (NSUInteger currentPixel = 0; currentPixel < totalNumberOfPixels; currentPixel++)
    {
        redTotal += rawImagePixels[byteIndex++];
        greenTotal += rawImagePixels[byteIndex++];
        blueTotal += rawImagePixels[byteIndex++];
        alphaTotal += rawImagePixels[byteIndex++];
    }
    
    CGFloat normalizedRedTotal = (CGFloat)redTotal / (CGFloat)totalNumberOfPixels / 255.0;
    CGFloat normalizedGreenTotal = (CGFloat)greenTotal / (CGFloat)totalNumberOfPixels / 255.0;
    CGFloat normalizedBlueTotal = (CGFloat)blueTotal / (CGFloat)totalNumberOfPixels / 255.0;
    CGFloat normalizedAlphaTotal = (CGFloat)alphaTotal / (CGFloat)totalNumberOfPixels / 255.0;
    
    if (_colorAverageProcessingFinishedBlock != NULL)
    {
        _colorAverageProcessingFinishedBlock(normalizedRedTotal, normalizedGreenTotal, normalizedBlueTotal, normalizedAlphaTotal, frameTime);
    }
}

@end
