//
//  CZQuestion.m
//  猜图
//
//  Created by 谢飞 on 2021/8/9.
//

#import "CZQuestion.h"

@implementation CZQuestion

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.answer = dict[@"answer"];
        self.title = dict[@"title"];
        self.icon = dict[@"icon"];
        self.options = dict[@"options"];
    }
    return self;
}
+ (instancetype)questionWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
@end
