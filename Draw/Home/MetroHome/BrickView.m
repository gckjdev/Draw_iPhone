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
-(void)initComponent:(CGRect)rect{
    
    //左上角label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.bounds.size.width, 20)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:self.title];
    [label setFont:self.titleFont];
    
    //中间图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((rect.size.width-IMAGE_WIDTH)/2, (rect.size.height-IMAGE_HEIGHT)/2, IMAGE_HEIGHT, IMAGE_WIDTH)];
    [imageView setImage:self.image];
    
    //图片描述
    CGFloat x = imageView.frame.size.width+imageView.frame.origin.x;
    CGFloat y = imageView.frame.size.height+imageView.frame.origin.y;
    UILabel *labelDesc = [[UILabel alloc] initWithFrame:CGRectMake(x, y+5, IMAGE_WIDTH, IMAGE_HEIGHT)];
    [labelDesc setText:_imageTitle];
    [labelDesc setFont:_imageTitleFont];
    
    [self addSubview:label];
    [self addSubview:labelDesc];
    [self addSubview:imageView];
    
    
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
