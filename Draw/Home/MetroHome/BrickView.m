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
#define IMAGE_WIDTH  (ISIPAD ? 60:40)
#define TITLE_LABEL_X (ISIPAD ? 10:5)
#define TITLE_LABEL_Y (ISIPAD ? 10:5)
-(void)initComponent:(CGRect)rect{
    
    //左上角label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_LABEL_X, TITLE_LABEL_Y, self.bounds.size.width, 20)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:self.title];
    [label setFont:AD_BOLD_FONT(23, 13)];
    [label setTextColor:[UIColor whiteColor]];
    
    //中间图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((rect.size.width-IMAGE_WIDTH)/2, (rect.size.height-IMAGE_HEIGHT)/2, IMAGE_HEIGHT, IMAGE_WIDTH)];
    [imageView setImage:self.image];
    
   
    
    //图片描述
    CGFloat x = imageView.frame.origin.x;
    CGFloat y = imageView.frame.size.height+imageView.frame.origin.y;
    UILabel *labelDesc = [[UILabel alloc] initWithFrame:CGRectMake(x, y, IMAGE_WIDTH, IMAGE_HEIGHT/2)];
    [labelDesc setText:_imageTitle];
    [labelDesc setFont:AD_BOLD_FONT(18, 10)];
    [labelDesc setTextColor:[UIColor whiteColor]];
    [labelDesc setBackgroundColor:[UIColor clearColor]];
    
    [self addSubview:label];
    [self addSubview:labelDesc];
    [self addSubview:imageView];
    
    [label release];
    [labelDesc release];
    [imageView release];
    
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
    
    CGFloat labelDescHeight = (isIPad ? 30:15);
    NSString *constrain2 = [NSString stringWithFormat:@"V:[imageView(==%f)]-2-[labelDesc(==%f)]",imageViewHeight,labelDescHeight];
    [constraints addObject:constrain2];
    
    
    // Set constraints.
    for (NSString *string in constraints) {
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:string
                              options:0 metrics:nil
                              views:views]];
    }

    [constraints release];
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