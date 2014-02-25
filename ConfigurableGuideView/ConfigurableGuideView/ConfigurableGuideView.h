//
//  GuideView.h
//  ConfigurableAnimation
//
//  Created by huji on 9/6/13.
//  Copyright (c) 2013 BaiduLBSMapClient. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Guide_Config_Tag_Key @"tag"
#define Guide_Config_Action_Key @"action"
#define Guide_Config_Params_Key @"params"

@protocol ConfigurableGuideViewDelegate <NSObject>
-(void)ObjectClick:(NSDictionary*)click;
@end

/*
 plist格式说明:
{
    direction:BOOL //方向,1标示横滚，0标示竖滚
    length:number  //距离轴的总长度
    pagecount:number //一共有多少页，当指定该值，则忽略length值
    objects:  //动画object的集合，视图中的前后顺序由objects中的先后顺序决定
        (
            {
                imagename:string  //动画的图片名，必选
                type:number  //该object的类型，缺省默认值为0图片类型，1为按钮类型
                click:  //如果type类型为按钮
                    {
                        tag:string  //标识
                        action:string  //动作，exit表示退出当前页面
                        params:  //参数
                            {}
                    }
                mappoints:  //映射点集合
                    (
                        {
                            coord:float  //距离轴上得位置
                            pcoord:int  //距离轴上得位置的页标示，当指定该值，会忽略coord的值
                            position:float,float  //该距离轴位置状态下的图片位置，必选
                            alpha:float  //该距离轴位置状态下的alpha值，缺省默认值为1.0
                            rotate:float  //该距离轴位置状态下的rotate值，缺省默认值为0.0
                            scale:float  //缺省值为1.0
                        }
                        ...
                    )
                triggers:  //触发器集合
                    (
                        {  //触发器
                            coord:float  //距离轴上触发的位置
                            reverseto:number  //相反触发的index，如果注明为某个触发的相反触发，那么只有当该被指明触发被执行后，本触发才执行
                            triggercount:number  //触发发生的次数，默认为1次，0次表示无限次
                            triggerdirection:bool  //触发的方向，默认是正方向
                            duration:float  //触发动画的执行时间
                            position:float,float  //触发到新的位置点
                            alpha:float  //触发到新的alpha值
                            rotate:float  //触发到新的旋转值
                            scale:float  //触发到新的缩放值
                            repeatcount:number  //图片动画重复次数，默认为0，0是不重复
                            delay:number   //触发执行的延迟执行时间，默认为0
                            trigger:    //嵌套触发器，该触发器会在上一级触发器完成以后继续执行
                                {}
                        }
                    )
                images:  //动画图片集合
                    (
                        {
                            coord:number  //距离抽上触发的位置
                            duration:number  //图片动画间隔时间
                            repeatcount:number  //图片动画重复次数，默认为0，0是无限次
                            imagenames:  //动画图片的图片集合
                                (
                                    string,  //图片名
                                )
                        }
                    )
                
            }
            ...
        )
}
 */
@interface ConfigurableGuideView : UIView<UIScrollViewDelegate>
@property (nonatomic,weak) id<ConfigurableGuideViewDelegate> delegate;
-(id)initWithFrame:(CGRect)frame config:(NSDictionary*)config;
-(id)initWithFrame:(CGRect)frame plistName:(NSString*)name;
@end
