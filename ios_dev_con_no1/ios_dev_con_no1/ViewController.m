//
//  ViewController.m
//  ios_dev_con_no1
//
//  Created by 北野 剛史 on 12/08/17.
//  Copyright (c) 2012年 北野 剛史. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *albumImage = [info objectForKey:UIImagePickerControllerEditedImage];
    beforeImageView.image = albumImage;
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerController:(UIImagePickerController*)picker
       didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo{
    
    [self dismissModalViewControllerAnimated:YES];  // モーダルビューを閉じる
    
    // 渡されてきた画像をフォトアルバムに保存する
    UIImageWriteToSavedPhotosAlbum(
                                   image, self, @selector(targetImage:didFinishSavingWithError:contextInfo:),
                                   NULL);	
}


-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(actionSheet.tag == FilterTypeOpenGL) {
        /*
        switch (buttonIndex) {
            case 0:
                afterImageView.image = [self getImageForGL:beforeImageView.image shaderName:@"sepia"];
                break;
            case 1:
                afterImageView.image = [self getImageForGL:beforeImageView.image shaderName:@"gray"];
                break;
            default:
                break;
        }
         */
        
    } else if(actionSheet.tag == FilterTypeCoreImage) {
        switch (buttonIndex) {
            case 0:
                afterImageView.image = [self getSepiaImageForCI:beforeImageView.image];
                break;
            case 1:
                afterImageView.image = [self getGrayImageForCI:beforeImageView.image];
                break;
            default:
                break;
        }
        
    } else {
        switch (buttonIndex) {
            case 0:
                afterImageView.image = [self getEdgeForVI:beforeImageView.image];
                break;
            case 1:
                afterImageView.image = [self getEmbossForVI:beforeImageView.image];
                break;
            default:
                break;
        }
        
    }
    
}

-(IBAction)getPicture:(id)sender{
    UIImagePickerController *ipc = [[[UIImagePickerController alloc] init] autorelease];
    ipc.delegate = self;
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.allowsEditing = YES;
    [self presentModalViewController:ipc animated:YES];
}

-(IBAction)doGLFilter:(id)sender{
    [self showActionSheet:FilterTypeOpenGL btnList:@[@"セピア", @"グレイスケール"]];
}
-(IBAction)doCIFilter:(id)sender{
    
    [self showActionSheet:FilterTypeCoreImage btnList:@[@"セピア", @"グレイスケール"]];
}
-(IBAction)doVIFilter:(id)sender{
    [self showActionSheet:FilterTypevImage btnList:@[@"エッジ", @"エンボス"]];
}

-(void)showActionSheet:(int)tag btnList:(NSArray*)btnList{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.title = @"選択してください。";
    actionSheet.tag = tag;
    for(NSString *btnTitle in btnList) {
        [actionSheet addButtonWithTitle:btnTitle];
    }
    [actionSheet addButtonWithTitle:@"キャンセル"];
    actionSheet.cancelButtonIndex = [btnList count];
    [actionSheet showInView:self.view];
}


#pragma mark filter
//要CoreImage フレームワーク
-(UIImage*)getSepiaImageForCI:(UIImage*)image{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *ciFilter = [CIFilter filterWithName:@"CISepiaTone"
                                    keysAndValues:kCIInputImageKey, ciImage,
                                    @"inputIntensity", @0.8,
                                    nil
                                    ];
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ciContext createCGImage:[ciFilter outputImage] fromRect:[[ciFilter outputImage] extent]];
    UIImage* afterImage = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return afterImage;
}

-(UIImage*)getGrayImageForCI:(UIImage*)image{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *ciFilter = [CIFilter filterWithName:@"CIColorMonochrome" //フィルター名
                                    keysAndValues:kCIInputImageKey, ciImage,
                            @"inputColor", [CIColor colorWithRed:0.75 green:0.75 blue:0.75],                          @"inputIntensity", [NSNumber numberWithFloat:1.0],
                          nil
                          ];
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ciContext createCGImage:[ciFilter outputImage] fromRect:[[ciFilter outputImage] extent]];
    UIImage* afterImage = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return afterImage;
}

static int16_t edge_kernel[9] = {
    -1, -1, -1,
    -1, 8, -1,
    -1, -1, -1
};

static int16_t emboss_kernel[9] = {
	-2, 0, 0,
	0, 1, 0,
	0, 0, 2
};

//要Accelerate Frame
- (UIImage *)getEdgeForVI:(UIImage*)image
{
	const size_t width = image.size.width;
	const size_t height = image.size.height;
	const size_t bytesPerRow = width * 4;
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, space, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(space);
	if (!bmContext)
		return nil;
    
	CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, image.CGImage);
    
	UInt8* data = (UInt8*)CGBitmapContextGetData(bmContext);
	if (!data)
	{
		CGContextRelease(bmContext);
		return nil;
	}
    
    const size_t n = sizeof(UInt8) * width * height * 4;
    void* outt = malloc(n);
    vImage_Buffer src = {data, height, width, bytesPerRow};
    vImage_Buffer dest = {outt, height, width, bytesPerRow};
    
    vImageConvolve_ARGB8888(&src, &dest, NULL, 0, 0, edge_kernel, 3, 3, 1,0, kvImageCopyInPlace);
    
    memcpy(data, outt, n);
    CGImageRef edgedImageRef = CGBitmapContextCreateImage(bmContext);
    UIImage* edged = [UIImage imageWithCGImage:edgedImageRef];
    
    CGImageRelease(edgedImageRef);
    free(outt);
    CGContextRelease(bmContext);
    
    return edged;
}

- (UIImage *)getEmbossForVI:(UIImage*)image
{
	const size_t width = image.size.width;
	const size_t height = image.size.height;
	const size_t bytesPerRow = width * 4;
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, space, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(space);
	if (!bmContext)
		return nil;
    
	CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, image.CGImage);
    
	UInt8* data = (UInt8*)CGBitmapContextGetData(bmContext);
	if (!data)
	{
		CGContextRelease(bmContext);
		return nil;
	}
    
    const size_t n = sizeof(UInt8) * width * height * 4;
    void* outt = malloc(n);
    vImage_Buffer src = {data, height, width, bytesPerRow};
    vImage_Buffer dest = {outt, height, width, bytesPerRow};
    
    vImageConvolve_ARGB8888(&src, &dest, NULL, 0, 0, emboss_kernel, 3, 3, 1, NULL, kvImageCopyInPlace);
    
    memcpy(data, outt, n);
    
    free(outt);
    
	CGImageRef embossImageRef = CGBitmapContextCreateImage(bmContext);
	UIImage* emboss = [UIImage imageWithCGImage:embossImageRef];
    
	CGImageRelease(embossImageRef);
	CGContextRelease(bmContext);
    
	return emboss;
}

@end
