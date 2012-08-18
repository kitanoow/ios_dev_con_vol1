//
//  ViewController.h
//  ios_dev_con_no1
//
//  Created by 北野 剛史 on 12/08/17.
//  Copyright (c) 2012年 北野 剛史. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <QuartzCore/CAEAGLLayer.h>
#import <GLKit/GLKit.h>
enum {
    FilterTypeOpenGL,
    FilterTypeCoreImage,
    FilterTypevImage,
};

#define TEX_SIZE		/*256*/512//1024
#define IMG_W			/*192*/480//1280
#define IMG_H			/*144*/320//720


#define VERTEX_ARRAY	0
#define TEXCOORD_ARRAY	1
#define COLOR_Array     2


#define PI_OVER_180	 0.017453292519943295769236907684886

@interface ViewController : UIViewController
<
UINavigationControllerDelegate
,UIImagePickerControllerDelegate
,UIActionSheetDelegate
>
{
    IBOutlet UIImageView *beforeImageView;
    IBOutlet UIImageView *afterImageView;

    

    // OpenGL用
    EAGLContext *context;
    GLuint *frameData;
    size_t gFrameWidth;
    size_t gFrameHeight;
    GLint framebufferWidth;
    GLint framebufferHeight;
    GLuint defaultFramebuffer, colorRenderbuffer;
    GLuint m_ui32Vbo;
	unsigned int m_ui32VertexStride;
    GLuint program;
    int sampler2dlocation;
	GLuint texture;
    
    IBOutlet GLKView* _glkView;
    GLKView* _glkView2;

}


-(IBAction)getPicture:(id)sender;

-(IBAction)doGLFilter:(id)sender;
-(IBAction)doCIFilter:(id)sender;
-(IBAction)doVIFilter:(id)sender;

@end
