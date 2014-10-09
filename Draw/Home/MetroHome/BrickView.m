//
//  BrickView.m
//  Draw
//
//  Created by ChaoSo on 14-8-7.
//
//

#import "BrickView.h"


@interface BrickView()

@end

@implementation BrickView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setDefault];
        [self initComponent:frame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title imageTitle:(NSString *)imageTitle image:(UIImage*)image
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.title = title;
        self.image = image;
        self.imageTitle = imageTitle;
        
        [self setDefault];
        [self initComponent:frame];
    }
    return self;
}

-(void)setDefault{
    if(self.titleFont==nil){
        self.titleFont = AD_FONT(20, 13);
    }
    if(self.image==nil){
      _image = [UIImage imageNamed:@"xiaoguanka"];
    }
    if(self.imageTitleFont){
        self.titleFont = AD_FONT(20, 13);
    }
    if(_imageTitleColor==nil){
        _imageTitleColor = [UIColor blackColor];
    }
    if(_titleColor==nil){
        _titleColor = [UIColor blackColor];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#define IMAGE_HEIGHT (ISIPAD ? 60:40)
#define IMAGE_WIDTH  (ISIPAD ? 100:100)
#define TITLE_LABEL_X (ISIPAD ? 10:5)
#define TITLE_LABEL_Y (ISIPAD ? 10:5)

#define BRICK_VIEW_BOTTOM_LABEL 2014080901
#define BRICK_VIEW_CENTER_IMAGE 2014080140345
-(void)initComponent:(CGRect)rect{
    
    //左上角label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_LABEL_X, TITLE_LABEL_Y, self.bounds.size.width, 20)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:self.title];
    if([LocaleUtils isChina]||[LocaleUtils isChinese]){
        [label setFont:AD_BOLD_FONT(23, 13)];

    }else{
        [label setFont:AD_BOLD_FONT(21, 11)];
    }
    
        [label setTextColor:[UIColor whiteColor]];
    

    //中间图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((rect.size.width-IMAGE_WIDTH)/2, (rect.size.height-IMAGE_HEIGHT)/2, IMAGE_HEIGHT, IMAGE_WIDTH)];
    [imageView setImage:self.image];
    [imageView setTag:BRICK_VIEW_CENTER_IMAGE];
    

   
    
    //图片描述
    CGFloat x = imageView.frame.origin.x;
    CGFloat y = imageView.frame.size.height+imageView.frame.origin.y;
    UILabel *labelDesc = [[UILabel alloc] initWithFrame:CGRectMake(x, y, IMAGE_WIDTH, IMAGE_HEIGHT/2)];
    [labelDesc setTag:BRICK_VIEW_BOTTOM_LABEL];
    [labelDesc setText:_imageTitle];
    [labelDesc setFont:AD_BOLD_FONT(18, 10)];
    [labelDesc setTextColor:[UIColor whiteColor]];
    [labelDesc setTextAlignment:NSTextAlignmentCenter];
    [labelDesc setBackgroundColor:[UIColor clearColor]];
    
    [self addSubview:label];
    [self addSubview:labelDesc];
    [self addSubview:imageView];
    
    
    
    [labelDesc setTranslatesAutoresizingMaskIntoConstraints:NO];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];

    //constrain
    NSLayoutConstraint *constrain3 = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:imageView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1
                                                                   constant:0];
    [self addConstraint:constrain3];
    
    NSLayoutConstraint *constrain4 = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:imageView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:10];
    [self addConstraint:constrain4];

    
    NSDictionary *views = NSDictionaryOfVariableBindings(label, imageView,labelDesc);
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    CGFloat imageViewHeight = (isIPad ? 60:30);
    NSString *constrain = [NSString stringWithFormat:@"H:[imageView(==%f)]",imageViewHeight];
    [constraints addObject:constrain];
    
    
    // 上下的間隔LabelDesc
    CGFloat labelDescHeight = (isIPad ? 30:15);
    NSString *constrain2 = [NSString stringWithFormat:@"V:[imageView(==%f)]-2-[labelDesc(==%f)]",imageViewHeight,labelDescHeight];
    [constraints addObject:constrain2];
    
    
    //左右的間隔LabelDesc
    NSString *constrain10 = [NSString stringWithFormat:@"H:|-%f-[labelDesc(==%d)]",x,IMAGE_WIDTH];
    [constraints addObject:constrain10];
    
    // Set constraints.
    for (NSString *string in constraints) {
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:string
                              options:0 metrics:nil
                              views:views]];
    }

    [constraints release];
    [label release];
    [labelDesc release];
    [imageView release];
}

- (void)setBottomLabelText:(NSString*)text color:(UIColor*)color
{
    UIView* view = [self viewWithTag:BRICK_VIEW_BOTTOM_LABEL];
    if ([view isKindOfClass:[UILabel class]]){
        [((UILabel*)view) setText:text];
        [((UILabel*)view) setTextColor:color];
    }
}
#define BRICK_VIEW_CENTER_NEW_IMAGE 201408141643
#define NEW_IMAGE_SIZE_WIDTH (ISIPAD ? 110:50)
#define NEW_IMAGE_SIZE_HEIGHT (ISIPAD ? 110:50)
-(void)startAnimationOnImage:(NSArray*)imagesArray{
    
    UIView* imageView = [self viewWithTag:BRICK_VIEW_CENTER_IMAGE];
    imageView.hidden = YES;
    
    UIView *oldImageView = [self viewWithTag:BRICK_VIEW_CENTER_NEW_IMAGE];
    [oldImageView removeFromSuperview];
    
    UIImageView *newImageView = [[UIImageView alloc] init];
    [newImageView setTag:BRICK_VIEW_CENTER_NEW_IMAGE];
    
    newImageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y-NEW_IMAGE_SIZE_HEIGHT+imageView.frame.size.width, NEW_IMAGE_SIZE_WIDTH, NEW_IMAGE_SIZE_HEIGHT);
    if ([imageView isKindOfClass:[UIImageView class]]){
        ((UIImageView*)newImageView).animationImages =  imagesArray;
        
        ((UIImageView*)newImageView).animationDuration = 1.0f;
        
        ((UIImageView*)newImageView).animationRepeatCount = 4;
        
        [((UIImageView*)newImageView) startAnimating];
        
    }
    [self addSubview:newImageView];
    [newImageView release];
}
-(void)stopAnimationOnImage{
    UIView* imageView = [self viewWithTag:BRICK_VIEW_CENTER_NEW_IMAGE];
    
    if ([imageView isKindOfClass:[UIImageView class]]){
        [((UIImageView*)imageView) stopAnimating];
        
    }

}
-(void)unhiddenImage{
    UIView* imageView = [self viewWithTag:BRICK_VIEW_CENTER_IMAGE];
    imageView.hidden = NO;
}


-(void)dealloc{
    [super dealloc];
    [self viewDidUnload];
    [_image release];
    [_imageTitle release];
    [_titleFont release];
    [_imageTitleFont release];
    [_imageTitleColor release];
    [_titleColor release];
    [_title release];
    
}
-(void)viewDidUnload{
    
    _imageTitle = nil;
    _image = nil;
    _title = nil;
}

@end
