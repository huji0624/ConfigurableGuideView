//
//  GuideView.m
//  ConfigurableAnimation
//
//  Created by huji on 9/6/13.
//  Copyright (c) 2013 BaiduLBSMapClient. All rights reserved.
//

#import "ConfigurableGuideView.h"
#import <QuartzCore/QuartzCore.h>

#define Guide_Config_Direction_Key @"direction"
#define Guide_Config_Objects_Key @"objects"
#define Guide_Config_Length_Key @"length"
#define Guide_Config_PageCount_Key @"pagecount"
#define Guide_Config_Type_Key @"type"
#define Guide_Config_ImageName_Key @"imagename"
#define Guide_Config_ImageNames_Key @"imagenames"
#define Guide_Config_Triggers_Key @"triggers"
#define Guide_Config_Images_Key @"images"
#define Guide_Config_Trigger_Key @"trigger"
#define Guide_Config_MapPoints_Key @"mappoints"
#define Guide_Config_Coordinate_Key @"coord"
#define Guide_Config_PageCoordinate_Key @"pcoord"
#define Guide_Config_Position_Key @"position"
//#define Guide_Config_Size_Key @"size"
#define Guide_Config_Alpha_Key @"alpha"
#define Guide_Config_Rotate_Key @"rotate"
#define Guide_Config_Scale_Key @"scale"
#define Guide_Config_Click_Key @"click"
#define Guide_Config_Duration_Key @"duration"
#define Guide_Config_Delay_Key @"delay"
//#define Guide_Config_Repeat_Key @"repeat"
#define Guide_Config_RepeatCount_Key @"repeatcount"
#define Guide_Config_TriggerCount_Key @"triggercount"
#define Guide_Config_TriggerDirection_Key @"triggerdirection"
#define Guide_Config_ReverseTo_Key @"reverseto"

typedef enum {
    GuideObjectType_Image = 0,
    GuideObjectType_Button
} GuideObjectType;

@interface GuideViewConfig : NSObject
@property (nonatomic,assign) BOOL direction;//YES x;NO y
@property (nonatomic,assign) CGFloat length;
@property (nonatomic,assign) NSInteger pageCount;
@property (nonatomic,strong) NSArray *objects;
@end

@implementation GuideViewConfig

@end

@interface GuideTrigger : NSObject

@property (nonatomic,assign) BOOL triggered;

@property (nonatomic,assign) NSInteger reverseTo;
@property (nonatomic,assign) BOOL trigDirection;//YES为正方向，NO为反方向
@property (nonatomic,assign) NSInteger triggerCount;//默认1次，0为无限次
@property (nonatomic,assign) NSInteger repeatCount;
@property (nonatomic,assign) CGFloat delay;
@property (nonatomic,assign) CGFloat duration;
@property (nonatomic,assign) CGFloat coordinate;
@property (nonatomic,assign) CGPoint position;
@property (nonatomic,assign) CGFloat alpha;
@property (nonatomic,assign) CGFloat scale;
@property (nonatomic,assign) CGFloat rotate;
@property (nonatomic,strong) GuideTrigger *trigger;
@end
@implementation GuideTrigger
- (id)init
{
    self = [super init];
    if (self) {
        self.triggered=NO;
        self.trigDirection=YES;
        self.triggerCount=1;
        self.repeatCount=0;
        self.alpha = 1.0f;
        self.rotate = 0.0f;
        self.scale = 1.0f;
        self.delay = 0.0f;
        self.reverseTo=-1;
    }
    return self;
}
@end

@interface GuideImages : NSObject
@property (nonatomic,assign) CGFloat coordinate;
@property (nonatomic,assign) CGFloat duration;
@property (nonatomic,assign) NSUInteger repeatCount;
@property (nonatomic,strong) NSMutableArray *images;

@property (nonatomic,assign) BOOL trigged;
@end
@implementation GuideImages
- (id)init
{
    self = [super init];
    if (self) {
        self.trigged=NO;
    }
    return self;
}
-(NSMutableArray *)images{
    if (_images == nil) {
        _images = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return _images;
}
@end

@interface GuidePoint : NSObject
@property (nonatomic,assign) CGFloat coordinate;
@property (nonatomic,assign) CGPoint position;
@property (nonatomic,assign) CGSize size;
@property (nonatomic,assign) CGFloat alpha;
@property (nonatomic,assign) CGFloat rotate;
@property (nonatomic,assign) CGFloat scale;
@end
@implementation GuidePoint
- (id)init
{
    self = [super init];
    if (self) {
        self.alpha = 1.0f;
        self.rotate = 0.0f;
        self.scale = 1.0f;
    }
    return self;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"coor:%f %@",self.coordinate,NSStringFromCGPoint(self.position)];
}
@end

@interface GuideObject : NSObject
@property (nonatomic,assign) GuideObjectType type;
@property (nonatomic,strong) NSString *imageName;
@property (nonatomic,strong) NSDictionary *click;
@property (nonatomic,strong) NSMutableArray *mapPoints;
@property (nonatomic,strong) NSMutableArray *triggers;
@property (nonatomic,strong) NSMutableArray *images;

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) UIView *view;
@property (nonatomic,assign) CGPoint moveRange;

-(void)addMapPoint:(GuidePoint*)point;
@end

@implementation GuideObject
-(void)addMapPoint:(GuidePoint *)point{
    if (self.mapPoints.count==0) {
        [self.mapPoints addObject:point];
        self.moveRange = CGPointMake(point.coordinate, point.coordinate);
        return;
    }
    
    int insertIndex = 0;
    
    for (int i = 0 ; i<self.mapPoints.count; i++) {
        GuidePoint *p_ = [self.mapPoints objectAtIndex:i];
        if (point.coordinate<p_.coordinate) {
            insertIndex = i;
            if (point.coordinate<self.moveRange.x) {
                CGPoint mr = self.moveRange;
                mr.x = point.coordinate;
                self.moveRange = mr;
            }
            break;
        }else{
            if (i==self.mapPoints.count-1) {
                insertIndex = i+1;
                CGPoint mr = self.moveRange;
                mr.y = point.coordinate;
                self.moveRange = mr;
                break;
            }
        }
    }
    
    [self.mapPoints insertObject:point atIndex:insertIndex];
}
-(NSMutableArray *)mapPoints{
    if (_mapPoints == nil) {
        _mapPoints = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _mapPoints;
}
-(NSMutableArray *)triggers{
    if (_triggers == nil) {
        _triggers = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _triggers;
}
-(NSMutableArray *)images{
    if (_images == nil) {
        _images = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _images;
}
@end



@implementation ConfigurableGuideView{
    UIScrollView *_scrollView;
    GuideViewConfig *configobj;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame plistName:(NSString *)name{
    NSString *myPlistFilePath = [[NSBundle mainBundle] pathForResource:name ofType: @"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:myPlistFilePath];
    if (!dic) {
        NSLog(@"can not find the plist file.");
        return nil;
    }
    self = [self initWithFrame:frame config:dic];
    if (self) {
        
    }
    return self;
}

-(void)dealloc{
    _scrollView.delegate=nil;
}

-(id)initWithFrame:(CGRect)frame config:(NSDictionary *)config{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self parseConfig:config];
        
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = YES;
        _scrollView.showsVerticalScrollIndicator = YES;
        [self addSubview:_scrollView];
        
        CGSize contentSize_ = _scrollView.bounds.size;
        if (configobj.direction) {
            if (configobj.length>0) {
                contentSize_.width = configobj.length;
            }else{
                contentSize_.width = configobj.pageCount * _scrollView.bounds.size.width;
            }
        }else{
            if (configobj.length>0) {
                contentSize_.height = configobj.length;
            }else{
                contentSize_.height = configobj.pageCount * _scrollView.bounds.size.height;
            }
        }
        _scrollView.contentSize = contentSize_;
        
        if (configobj.pageCount>0) {
            _scrollView.pagingEnabled = YES;
        }
        
        [self buildObjects:configobj.objects];
    }
    return self;
}

-(void)parseConfig:(NSDictionary*)config{
    configobj = [[GuideViewConfig alloc] init];
    GuideViewConfig *gvc = configobj;
    gvc.direction = [[config objectForKey:Guide_Config_Direction_Key] boolValue];
    gvc.pageCount = [[config objectForKey:Guide_Config_PageCount_Key] intValue];
    gvc.length = [[config objectForKey:Guide_Config_Length_Key] floatValue];
    
    NSMutableArray *gvcObjects = [NSMutableArray arrayWithCapacity:10];
    
    NSArray *objects = [config objectForKey:Guide_Config_Objects_Key];
    for (NSDictionary *obj in objects) {
        GuideObject *guideobj_ = [[GuideObject alloc] init];
        GuideObjectType type = [[obj objectForKey:Guide_Config_Type_Key] intValue];
        
        guideobj_.type = type;
        guideobj_.imageName = [obj objectForKey:Guide_Config_ImageName_Key];
        guideobj_.image = [UIImage imageNamed:guideobj_.imageName];
        guideobj_.click = [obj objectForKey:Guide_Config_Click_Key];
        
        NSArray *mps = [obj objectForKey:Guide_Config_MapPoints_Key];
        for (NSDictionary *gpdic in mps) {
            GuidePoint *gp = [self parsePoint:gpdic obj:guideobj_];
            
            [guideobj_ addMapPoint:gp];
        }
        
        NSArray *triggers = [obj objectForKey:Guide_Config_Triggers_Key];
        for (NSDictionary *trigger_ in triggers) {
            GuideTrigger *trig = [self parseTrigger:trigger_ obj:guideobj_];
            [guideobj_.triggers addObject:trig];
        }
        
        NSArray *imagesarray = [obj objectForKey:Guide_Config_Images_Key];
        for (NSDictionary *imagesdic in imagesarray) {
            GuideImages *images = [self parseImages:imagesdic obj:guideobj_];
            [guideobj_.images addObject:images];
        }
        
        [gvcObjects addObject:guideobj_];
    }
    gvc.objects = gvcObjects;
}

-(GuideImages*)parseImages:(NSDictionary*)imagesdic obj:(GuideObject*)guideobj{
    GuideImages *images = [[GuideImages alloc] init];
    images.images = [imagesdic objectForKey:Guide_Config_ImageNames_Key];
    
    NSNumber *num = [imagesdic objectForKey:Guide_Config_Coordinate_Key];
    if (num) {
        images.coordinate = num.floatValue;
    }
    
    NSNumber *duration = [imagesdic objectForKey:Guide_Config_Duration_Key];
    if (duration) {
        images.duration = [duration floatValue];
    }
    
    num = [imagesdic objectForKey:Guide_Config_RepeatCount_Key];
    if (num) {
        images.repeatCount = num.intValue;
    }
    
    return images;
}

-(GuideTrigger*)parseTrigger:(NSDictionary*)triggerdic obj:(GuideObject*)guideobj{
    GuideTrigger *trigger_ = [[GuideTrigger alloc] init];
    
    GuidePoint *p = [guideobj.mapPoints objectAtIndex:0];
    
    NSNumber *num = [triggerdic objectForKey:Guide_Config_Coordinate_Key];
    if (num) {
        trigger_.coordinate = num.floatValue;
    }
    
    NSString *ps_ = [triggerdic objectForKey:Guide_Config_Position_Key];
    if (ps_) {
        trigger_.position = [self pointFromString:ps_];
    }else{
        trigger_.position = p.position;
    }
    NSNumber *as_ = [triggerdic objectForKey:Guide_Config_Alpha_Key];
    if (as_) {
        CGFloat al = [as_ floatValue];
        trigger_.alpha = al;
    }else{
        trigger_.alpha = p.alpha;
    }
    NSNumber *rs_ = [triggerdic objectForKey:Guide_Config_Rotate_Key];
    if (rs_) {
        CGFloat ro = [rs_ floatValue];
        trigger_.rotate = ro;
    }else{
        trigger_.rotate = p.rotate;
    }
    NSNumber *sc_ = [triggerdic objectForKey:Guide_Config_Scale_Key];
    if (sc_) {
        trigger_.scale = [sc_ floatValue];
    }else{
        trigger_.scale = p.scale;
    }
    NSNumber *duration = [triggerdic objectForKey:Guide_Config_Duration_Key];
    if (duration) {
        trigger_.duration = [duration floatValue];
    }
    NSNumber *repeat = [triggerdic objectForKey:Guide_Config_RepeatCount_Key];
    if (repeat) {
        trigger_.repeatCount = [repeat intValue];
    }
    NSNumber *triggerDirection = [triggerdic objectForKey:Guide_Config_TriggerDirection_Key];
    if (triggerDirection) {
        trigger_.trigDirection = [triggerDirection boolValue];
        if (trigger_.trigDirection==NO) {
            trigger_.triggered=YES;
        }
    }
    NSNumber *triggerCount = [triggerdic objectForKey:Guide_Config_TriggerCount_Key];
    if (triggerCount) {
        if ([triggerCount intValue]==0) {
            trigger_.triggerCount = -1;
        }else{
            trigger_.triggerCount = [triggerCount intValue];
        }
    }
    NSNumber *delay = [triggerdic objectForKey:Guide_Config_Delay_Key];
    if (delay) {
        trigger_.delay = [delay floatValue];
    }
    NSNumber *reverseTo = [triggerdic objectForKey:Guide_Config_ReverseTo_Key];
    if (reverseTo) {
        trigger_.reverseTo = [reverseTo intValue];
    }
    
    NSDictionary *intrig = [triggerdic objectForKey:Guide_Config_Trigger_Key];
    if (intrig) {
        trigger_.trigger = [self parseTrigger:intrig obj:guideobj];
    }
    return trigger_;
}

-(GuidePoint*)parsePoint:(NSDictionary*)gpdic obj:(GuideObject*)guideobj{
    GuidePoint *gp = [[GuidePoint alloc] init];
    NSNumber *pn = [gpdic objectForKey:Guide_Config_PageCoordinate_Key];
    if (pn) {
        if (configobj.direction) {
            gp.coordinate = self.bounds.size.width*[pn intValue];
        }else{
            gp.coordinate = self.bounds.size.height*[pn intValue];
        }
    }else{
        NSNumber *num = [gpdic objectForKey:Guide_Config_Coordinate_Key];
        if (num) {
            gp.coordinate = num.floatValue;
        }else{
            NSLog(@"no %@ in the point",Guide_Config_Coordinate_Key);
            return nil;
        }
    }

    NSString *ps_ = [gpdic objectForKey:Guide_Config_Position_Key];
    if (ps_) {
        gp.position = [self pointFromString:ps_];
    }else{
        NSLog(@"no %@ in the point",Guide_Config_Position_Key);
        return nil;
    }
//    NSString *ss_ = [gpdic objectForKey:Guide_Config_Size_Key];
//    if (ss_) {
//        CGPoint p = [self pointFromString:ss_];
//        gp.size = CGSizeMake(p.x, p.y);
//    }else{
//        gp.size = guideobj.image.size;
//    }
    NSString *as_ = [gpdic objectForKey:Guide_Config_Alpha_Key];
    if (as_) {
        CGFloat al = [as_ floatValue];
        gp.alpha = al;
    }
    NSString *rs_ = [gpdic objectForKey:Guide_Config_Rotate_Key];
    if (rs_) {
        CGFloat ro = [rs_ floatValue];
        gp.rotate = ro;
    }
    NSString *sc_ = [gpdic objectForKey:Guide_Config_Scale_Key];
    if (sc_) {
        gp.scale = [sc_ floatValue];
    }
    return gp;
}

-(CGPoint)pointFromString:(NSString*)string{
    CGPoint p;
    NSArray *fs = [string componentsSeparatedByString:@","];
    if (fs.count==2) {
        p.x = [[fs objectAtIndex:0] floatValue];
        p.y = [[fs objectAtIndex:1] floatValue];
    }else{
        NSLog(@"parse point error. [%@]",string);
    }
    
    return p;
}

-(void)buildObjects:(NSArray*)objs{
    int i = 0 ;
    for (GuideObject *obj in objs) {
        UIView *view = nil;
        if (obj.type == GuideObjectType_Image) {
            UIImageView *iv = [[UIImageView alloc] initWithImage:obj.image];
            [self insertSubview:iv belowSubview:_scrollView];
            
            if (obj.images.count>0) {
                GuideImages *images = [obj.images objectAtIndex:0];
                
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:images.images.count];
                for (NSString *iname in images.images) {
                    [array addObject:[UIImage imageNamed:iname]];
                }
                iv.animationImages = array;
                iv.animationDuration = images.duration;
                iv.animationRepeatCount = images.repeatCount;
                
                if (images.coordinate==0) {
                    [iv startAnimating];
                    images.trigged = YES;
                }
            }
            
            view = iv;
        }else if (obj.type == GuideObjectType_Button){
            UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
            [bt setImage:obj.image forState:UIControlStateNormal];
            [bt addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:bt];
            bt.frame = CGRectMake(0, 0, obj.image.size.width, obj.image.size.height);
            bt.tag = i;
            view = bt;
        }
        GuidePoint *p = obj.mapPoints.count>0?[obj.mapPoints objectAtIndex:0]:nil;
        if (p) {
            view.center = p.position;
            CGAffineTransform tran = CGAffineTransformMakeRotation(p.rotate);
            tran = CGAffineTransformScale(tran, p.scale, p.scale);
            view.transform = tran;
            obj.view = view;
        }
        i++;
    }
}

-(void)buttonClick:(id)sender{
    UIButton *bt = sender;
    GuideObject *obj = nil;
    if (bt.tag<configobj.objects.count) {
        obj = [configobj.objects objectAtIndex:bt.tag];
        [self.delegate ObjectClick:obj.click];
    }else{
        NSLog(@"click object not found");
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat index = 0;
    if (configobj.direction) {
        index = scrollView.contentOffset.x;
    }else{
        index = scrollView.contentOffset.y;
    }

    NSArray *objs = configobj.objects;
    for (GuideObject *obj in objs) {
        
        for (GuideImages *images in obj.images) {
            if (images.trigged==NO&&index>=images.coordinate) {
                if ([obj.view isKindOfClass:[UIImageView class]]) {
                    UIImageView *iv = (UIImageView*)obj.view;
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:images.images.count];
                    for (NSString *iname in images.images) {
                        [array addObject:[UIImage imageNamed:iname]];
                    }
                    iv.animationDuration=images.duration;
                    iv.animationImages=array;
                    iv.animationRepeatCount=images.repeatCount;
                    [iv startAnimating];
                    images.trigged=YES;
                }
            }
        }
        
        if (index>=obj.moveRange.x&&index<obj.moveRange.y) {
            [self moveObject:obj index:index];
        }
        
        for (GuideTrigger *trigger_ in obj.triggers) {
            
            GuideTrigger *reverse = nil;
            if (trigger_.reverseTo>=0&&trigger_.reverseTo<=obj.triggers.count-1) {
                reverse = [obj.triggers objectAtIndex:trigger_.reverseTo];
            }
            
            if (reverse&&reverse.triggered==NO) {
                continue;
            }
            
            if (trigger_.trigDirection) {
                if (trigger_.triggered==NO&&index>=trigger_.coordinate&&(trigger_.triggerCount>0||trigger_.triggerCount==-1)) {
                    [self triggerTrigger:obj trigger:trigger_];
                }else if (trigger_.triggered==YES&&index<trigger_.coordinate){
                    trigger_.triggered=NO;
                }
            }else{
                if (trigger_.triggered==NO&index<=trigger_.coordinate&&(trigger_.triggerCount>0||trigger_.triggerCount==-1)) {
                    [self triggerTrigger:obj trigger:trigger_];
                }else if (trigger_.triggered==YES&&index>trigger_.coordinate){
                    trigger_.triggered=NO;
                }
            }
        }
    }
}

-(void)triggerTrigger:(GuideObject*)obj trigger:(GuideTrigger*)trigger{
    trigger.triggered = YES;
    
    if (trigger.triggerCount>0) {
        trigger.triggerCount = trigger.triggerCount-1;
    }
    
    UIViewAnimationOptions opt = 0;
    if (trigger.repeatCount>0) {
        opt = UIViewAnimationOptionRepeat;
    }
    [UIView animateWithDuration:trigger.duration delay:trigger.delay options:opt animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        obj.view.alpha = trigger.alpha;
        
        CGAffineTransform tran = CGAffineTransformMakeRotation(trigger.rotate);
        tran = CGAffineTransformScale(tran, trigger.scale, trigger.scale);
        obj.view.transform = tran;
        
        obj.view.center = trigger.position;
    } completion:^(BOOL finished){
        if (finished) {
            if (trigger.trigger) {
                [self triggerTrigger:obj trigger:trigger.trigger];
            }
        }
        
    }];
}

-(void)moveObject:(GuideObject*)obj index:(CGFloat)index{
    if (obj.mapPoints.count>=2) {
        for (int i=0 ; i<obj.mapPoints.count-1; i++) {
            GuidePoint *p_ = [obj.mapPoints objectAtIndex:i];
            GuidePoint *next_ = [obj.mapPoints objectAtIndex:i+1];
            if (index>=p_.coordinate&&index<next_.coordinate) {

                CGFloat per = (index-p_.coordinate)/(next_.coordinate-p_.coordinate);
                
//                CGFloat towidth = p_.size.width + per*(next_.size.width - p_.size.width);
//                CGFloat toheight = p_.size.height + per*(next_.size.height - p_.size.height);
//                obj.view.frame = CGRectMake(0, 0, towidth, toheight);

                CGFloat scale = p_.scale + per*(next_.scale - p_.scale);
                
                CGFloat tox = p_.position.x*(1-per) + per*next_.position.x;
                CGFloat toy = p_.position.y*(1-per) + per*next_.position.y;
                obj.view.center = CGPointMake(tox, toy);
                
                CGFloat torotate = p_.rotate + per*(next_.rotate - p_.rotate);
                CGAffineTransform tran = CGAffineTransformMakeRotation(torotate);
                tran = CGAffineTransformScale(tran, scale, scale);
                if (!CGAffineTransformEqualToTransform(obj.view.transform, tran)) {
                    obj.view.transform = tran;
                }
            
                CGFloat toalpha = p_.alpha + per*(next_.alpha - p_.alpha);
                if (toalpha!=obj.view.alpha) {
                    obj.view.alpha = toalpha;
                }
            }
        }
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

@end
