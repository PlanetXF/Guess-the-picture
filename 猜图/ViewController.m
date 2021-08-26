//
//  ViewController.m
//  猜图
//
//  Created by 谢飞 on 2021/8/9.
//

#import "ViewController.h"
#import "CZQuestion.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imgViewBgr;

@property (nonatomic, strong) UILabel *lbIndex;

@property (nonatomic, strong) UIButton *btnCoin;

@property (nonatomic, strong) UILabel *lbTitle;

@property (nonatomic, strong) UIButton *btnImg;
//提示按钮
@property (nonatomic, strong) UIButton *btnProm;
//查看大图按钮
@property (nonatomic, strong) UIButton *btnMag;
//帮助按钮
@property (nonatomic, strong) UIButton *btnHelp;
//下一题
@property (nonatomic, strong) UIButton *btnNext;

@property (nonatomic, strong) NSArray *questions;
//初始值为0
@property (nonatomic, assign) int index;

//记录图片原始的frame
@property (nonatomic, assign) CGRect imgFrame;
//引用阴影按钮
@property (nonatomic, weak) UIButton *cover;

@property (nonatomic, strong) UIView *viewAnswer;

@property (nonatomic, strong) UIView *viewAnswerOpt;

@property (nonatomic, assign) int time;

@end

@implementation ViewController

//懒加载数据
- (NSString *)questions
{
    if (_questions == nil) {
        //加载数据
        //1.拿到路径
        NSString *path = [[NSBundle mainBundle] pathForResource:@"questions.plist" ofType:nil];
        //2.根据路径创建字典数组
        NSArray *arrayDict = [NSArray arrayWithContentsOfFile:path];
        //3.创建一个可变数组
        NSMutableArray *arrayModel = [NSMutableArray array];
        
        
        //遍历字典数组，根据数组创建模型
        for (NSDictionary *dict in arrayDict) {
            CZQuestion *model = [CZQuestion questionWithDict:dict];
            [arrayModel addObject:model];
        }
        _questions = arrayModel;
    }
    return _questions;
}

//修改状态栏的颜色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    //将状态栏的颜色改为白色
    return UIStatusBarStyleLightContent;
}
//隐藏状态栏，这个方法已经弃用了
- (BOOL)preferredStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //1.设置背景图
    self.imgViewBgr = [[UIImageView alloc] init];
    self.imgViewBgr.frame = CGRectMake(0, 0, 390, 844);
//    self.imgViewBgr.backgroundColor = [UIColor redColor];
    self.imgViewBgr.image = [UIImage imageNamed:@"bj"];
    [self.view addSubview:self.imgViewBgr];
    
    //2.添加图片索引
    self.lbIndex = [[UILabel alloc] init];
    self.lbIndex.text = @"1/8";
    self.lbIndex.textColor = [UIColor whiteColor];
//    self.lbIndex.backgroundColor = [UIColor redColor];
    self.lbIndex.textAlignment = NSTextAlignmentCenter;
    self.lbIndex.frame = CGRectMake(95, 50, 200, 25);
    [self.view addSubview:self.lbIndex];
    
    //3.添加金币按钮
    self.btnCoin = [[UIButton alloc] init];
//    self.btnCoin.backgroundColor = [UIColor whiteColor];
    [self.btnCoin setTitle:@"1000" forState:UIControlStateNormal];
    self.btnCoin.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.btnCoin setImage:[UIImage imageNamed:@"coin"] forState:UIControlStateNormal];
    //禁止有交互作用
    self.btnCoin.userInteractionEnabled = NO;
    self.btnCoin.frame = CGRectMake(240, 30, 135, 25);
    [self.view addSubview:self.btnCoin];
    
    //4.设置图片标题
    self.lbTitle = [[UILabel alloc] init];
    [self.view addSubview:self.lbTitle];
    self.lbTitle.frame = CGRectMake(45, 80, 300, 50);
    self.lbTitle.text = @"标题";
    //调整标签字体大小
    self.lbTitle.font = [UIFont systemFontOfSize:20];
    //设置标签字体颜色
    self.lbTitle.textColor = [UIColor whiteColor];
    self.lbTitle.textAlignment = NSTextAlignmentCenter;
    
    //5.设置中间的图片按钮框
    self.btnImg = [[UIButton alloc] init];
    [self.view addSubview:self.btnImg];
    self.btnImg.backgroundColor = [UIColor whiteColor];
    [self.btnImg setImage:[UIImage imageNamed:@"people-cls"] forState:UIControlStateNormal];
    //设置按钮上图片的内边距
    self.btnImg.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    //禁止高亮时调整图片
    self.btnImg.adjustsImageWhenHighlighted = NO;
    self.btnImg.frame = CGRectMake(95, 140, 200, 200);
    [self.btnImg addTarget:self action:@selector(btnImgClick) forControlEvents:UIControlEventTouchUpInside];
    
    //6.提示按钮
    self.btnProm = [[UIButton alloc] init];
    [self.view addSubview:self.btnProm];
    self.btnProm.frame = CGRectMake(0, 180, 70, 36);
    //在按钮上添加图片
    [self.btnProm setImage:[UIImage imageNamed:@"icon_tip"] forState:UIControlStateNormal];
    //给按钮添加背景图片
    [self.btnProm setBackgroundImage:[UIImage imageNamed:@"btn_left"] forState:UIControlStateNormal];
    //高亮状态下的背景图
    [self.btnProm setBackgroundImage:[UIImage imageNamed:@"btn_left_highlighted"] forState:UIControlStateHighlighted];
    //添加提示按钮点击事件
    [self.btnProm addTarget:self action:@selector(btnPromClick) forControlEvents:UIControlEventTouchUpInside];
    [self.btnProm setTitle:@"提示" forState:UIControlStateNormal];
    
    
    //7.帮助按钮
    self.btnHelp = [[UIButton alloc] init];
    [self.view addSubview:self.btnHelp];
    self.btnHelp.frame = CGRectMake(0, 264, 70, 36);
    [self.btnHelp setImage:[UIImage imageNamed:@"icon_help"] forState:UIControlStateNormal];
    [self.btnHelp setBackgroundImage:[UIImage imageNamed:@"btn_left"] forState:UIControlStateNormal];
    //高亮状态下的背景图
    [self.btnHelp setBackgroundImage:[UIImage imageNamed:@"btn_left_highlighted"] forState:UIControlStateHighlighted];
    [self.btnHelp setTitle:@"帮助" forState:UIControlStateNormal];
    
    //8.放大图片
    self.btnMag = [[UIButton alloc] init];
    [self.view addSubview:self.btnMag];
    self.btnMag.frame = CGRectMake(320, 180, 70, 36);
    [self.btnMag setImage:[UIImage imageNamed:@"icon_img"] forState:UIControlStateNormal];
    [self.btnMag setBackgroundImage:[UIImage imageNamed:@"btn_right"] forState:UIControlStateNormal];
    //高亮状态下的背景图
    [self.btnMag setBackgroundImage:[UIImage imageNamed:@"btn_right_highlighted"] forState:UIControlStateHighlighted];
    [self.btnMag setTitle:@"放大" forState:UIControlStateNormal];
    //给放大图片注册一个单击事件
    [self.btnMag addTarget:self action:@selector(btnMagClick) forControlEvents:UIControlEventTouchUpInside];
    
    //9.下一题
    self.btnNext = [[UIButton alloc] init];
    [self.view addSubview:self.btnNext];
    self.btnNext.frame = CGRectMake(320, 264, 70, 36);
    [self.btnNext setBackgroundImage:[UIImage imageNamed:@"btn_right"] forState:UIControlStateNormal];
    //高亮状态下的背景图
    [self.btnNext setBackgroundImage:[UIImage imageNamed:@"btn_right_highlighted"] forState:UIControlStateHighlighted];
    [self.btnNext setTitle:@"下一题" forState:UIControlStateNormal];
    //注册一个单击事件
    [self.btnNext addTarget:self action:@selector(btnNextClick) forControlEvents:UIControlEventTouchUpInside];
    
    //10.答案框按钮
    self.viewAnswer = [[UIView alloc] init];
    [self.view addSubview:self.viewAnswer];
    self.viewAnswer.frame = CGRectMake(0, 390, 390, 50);
//    self.viewAnswer.backgroundColor = [UIColor yellowColor];
    
    //11.答案选择区按钮
    self.viewAnswerOpt = [[UIView alloc] init];
    [self.view addSubview:self.viewAnswerOpt];
    self.viewAnswerOpt.frame = CGRectMake(0, 470, 390, 374);
    self.viewAnswerOpt.backgroundColor = [UIColor blueColor];
    
    self.index = -1;
    [self nextQuestion];
}

//提示按钮事件方法
- (void)btnPromClick
{
    //判断当前的分数
    NSString *str = self.btnCoin.currentTitle;
    int score = str.intValue;
    //如果当前的分数够100再减，不够直接充值
    if (score >= 100) {
        //1.分数减100
        [self addScore:-100];
    } else {
        UIAlertController *alertBalance = [UIAlertController alertControllerWithTitle:@"提示" message:@"金币不足，请充值" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //不充值
        }];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //弹出充值框
            UIAlertController *alertRecharge = [UIAlertController alertControllerWithTitle:@"充值" message:@"请输入您要充值的数额" preferredStyle:UIAlertControllerStyleAlert];
            [alertRecharge addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确认充值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //将充值的数额添加到余额中
                [alertRecharge dismissViewControllerAnimated:YES completion:^{
                    int rechargeAmount = alertRecharge.textFields[0].text.intValue;
                    [self addScore:rechargeAmount];
                }];
            }];
            [alertRecharge addAction:cancel];
            [alertRecharge addAction:ok];
            [self presentViewController:alertRecharge animated:YES completion:nil];
        }];
        [alertBalance addAction:cancel];
        [alertBalance addAction:ok];
        [self presentViewController:alertBalance animated:YES completion:nil];
    }
    
    //2.把所有的答案按钮清空，即调用答案按钮的点击事件
//    for (UIButton *btn in self.viewAnswer.subviews) {
//        [self btnAnswerClick:btn];
//    }
    
    //3.拿到当前的答案按钮的输入字符串
//    NSMutableString *userInput = [NSMutableString string];
//    for (UIButton *btnAnswer in self.viewAnswer.subviews) {
//        [userInput appendString:btnAnswer.currentTitle];
//    }

//    NSLog(@"%@",userInput);
    CZQuestion *model = self.questions[self.index];
    NSString *strAnswer = model.answer;
    //获取第一个空按钮的下标
    int btnIndex;
    int i = 0;
    for (UIButton *btn in self.viewAnswer.subviews) {
        if (!btn.currentTitle) {
            btnIndex = i;
            break;
        }
        i ++;
    }
    //获取本次需要提示的字符
    NSString *strChar = [strAnswer substringWithRange:NSMakeRange(btnIndex, 1)];
    for (UIButton *btn in self.viewAnswerOpt.subviews) {
        if ([btn.currentTitle isEqualToString:strChar]) {
            [self optionButtonClick:btn];
            break;
        }
    }
}

//点击下一题
- (void)btnNextClick
{
    [self nextQuestion];
}
//点击图片变大缩小
- (void)btnImgClick
{
    if (self.cover == nil) {
        [self btnMagClick];
    }else{
        [self zoomImage];
    }
}

//点击放大图片
- (void)btnMagClick
{
    //记录一下图片原始的大小
    self.imgFrame = self.btnImg.frame;
    //1.创建一个和self.view一样的按钮，把这个按钮作为阴影
    UIButton *btnCover = [[UIButton alloc] init];
    [self.view addSubview:btnCover];
    //设置按钮大小 x=0 y=0 大小和view一样大
    btnCover.frame = self.view.bounds;
    btnCover.backgroundColor = [UIColor blackColor];
    //注册一个单击事件
    [btnCover addTarget:self action:@selector(zoomImage) forControlEvents:UIControlEventTouchUpInside];
    //设置透明度
    btnCover.alpha = 0;
    
    //2.把图片设置到阴影的上面
    //把图片控件设置到最上层
    [self.view bringSubviewToFront:self.btnImg];
    //赋值给cover属性，cover属性不为nil的时候,说明当前为大图模式
    self.cover = btnCover;
    
    //3.通过动画的方式把图片放大
    CGFloat imgW = self.view.frame.size.width;
    CGFloat imgH = imgW;
    CGFloat imgX = 0;
    CGFloat imgY = (self.view.frame.size.height - imgH) * 0.5;
    [UIView animateWithDuration:2 animations:^{
        btnCover.alpha = 0.6;
        self.btnImg.frame = CGRectMake(imgX, imgY, imgW, imgH);
    }];
}
- (void)zoomImage
{
    //1.设置按钮还原
//    self.btnImg.frame = self.imgFrame;
//    //2.阴影按钮透明度变成零
//
//    //3.移除阴影
//    [self.cover removeFromSuperview];
    [UIView animateWithDuration:0.7 animations:^{
            //1.设置按钮还原
            self.btnImg.frame = self.imgFrame;
            //2.让阴影按钮的透明度还原
            self.cover.alpha = 0;
        } completion:^(BOOL finished) {
            //3.移除阴影
            [self.cover removeFromSuperview];
            //当图片变小之后，赋值为nil
            self.cover = nil;
        }];
}

//下一题按钮的点击功能
- (void)nextQuestion
{
    //1.索引值加一
    self.index ++;
    //恢复提示按钮
    self.btnProm.userInteractionEnabled = YES;
    //判断索引是否越界，若越界则提示用户答题完毕
    if (self.index == self.questions.count) {
        //弹出框
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"操作提示" message:@"恭喜通关" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        }];
        UIAlertAction *repeat = [UIAlertAction actionWithTitle:@"再来一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //重新来一遍
            self.index = -1;
            self.time = 0;
            [self nextQuestion];
        }];
        [alertView addAction:repeat];
//        [alertView addAction:ok];
        [self presentViewController:alertView animated:YES completion:nil];
        return;
    }
    //2.得到对应索引的模型数据
//    NSLog(@"g");
    CZQuestion *model = self.questions[self.index];
//    NSLog(@"%@",model.answer);
    //3.把模型数据设置到界面对应的控件上
    [self settingDat:model];
    
    //4.动态创建答案按钮
    [self makeAnswerButtons:model];
    //5.动态创建“带选项按钮”
    [self makeOptionButton:model];
    
    
    
    
}

//动态创建选项按钮
- (void)makeOptionButton:(CZQuestion *)model
{
    //0.创建按钮的时候设置可以与用户交互
    self.viewAnswerOpt.userInteractionEnabled = YES;
    //1.先清除待选按钮view中所有的子控件
    [self.viewAnswerOpt.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //2.获取当前题目的待选文字的数组
    NSArray *words = model.options;
    
    CGFloat optionW = 35;
    CGFloat optionH = 35;
    //每个按钮之间的距离
    CGFloat margin = 10;
    //按钮的列数
    int columns = 7;
    //每行0按钮距离最左边的距离
    CGFloat marginLeft = (self.viewAnswerOpt.frame.size.width - columns * optionW - (columns - 1) * margin) * 0.5;
    
    
    //3.根据文字循环创建按钮
    for (int i = 0; i < words.count; i++ ) {
        //创建一个按钮
        UIButton *btnOpt = [[UIButton alloc] init];
        //每个按钮添加一个tag值
        btnOpt.tag = i;
        //设置按钮背景
        [btnOpt setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
        //设置按钮的文字
        [btnOpt setTitle:words[i] forState:UIControlStateNormal];
        //设置文字颜色
        [btnOpt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        //计算当前的按钮的列的索引和行的索引
        int colIdx = i % columns;
        int rowIdx = i / columns;
        
        CGFloat optionX = marginLeft + colIdx * (optionW + margin);
        CGFloat optionY = 0 + rowIdx * (optionH + margin);
        
        //设置按钮frame
        btnOpt.frame = CGRectMake(optionX, optionY, optionW, optionH);
        
        [self.viewAnswerOpt addSubview:btnOpt];
        
        //为待选按钮创建单击事件
        [btnOpt addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
//    NSLog(@"gg");

}
//待选按钮点击事件
- (void)optionButtonClick:(UIButton *)sender
{
    //1.隐藏当前被点击的按钮
    sender.hidden = YES;
    //2.当前被点击的按钮上的文字显示在第一个答案按钮上
    //    NSString *text = [sender titleForState:UIControlStateNormal];//获取指定状态下的文字
    NSString *text = sender.currentTitle;//获取按钮的当前状态下的文字
    
    for (UIButton *answerBtn in self.viewAnswer.subviews) {
        if (answerBtn.currentTitle == nil) {
            //设置tag值
            answerBtn.tag = sender.tag;
            [answerBtn setTitle:text forState:UIControlStateNormal];
            break;
        }
    }
    
    //3.判断答案按钮是否已经停填满了
    
    BOOL isFull = YES;
    //保存用户输入的字符串
    NSMutableString *userInput = [NSMutableString string];
    for (UIButton *btnAnswer in self.viewAnswer.subviews) {
        if (btnAnswer.currentTitle == nil) {
            isFull = NO;
            break;
        } else {
            //如果当前按钮上有文字，就进行拼接
            [userInput appendString:btnAnswer.currentTitle];
        }
    }
    //4.如果答案按钮填满了，那么判断用户点击输入的答案是否与标准答案一致
    //若答案已满，待选区不可点
    if (isFull) {
        self.viewAnswerOpt.userInteractionEnabled = NO;
        //获取当前题目的正确答案
         CZQuestion *model = self.questions[self.index];
        if ([model.answer isEqualToString:userInput]) {
            //答案正确.一致答案变蓝
            [self setAnswerButtonTitleColor:[UIColor blueColor]];
            //答案正确后就禁用提示按钮
            self.btnProm.userInteractionEnabled = NO;
            //0.5秒后跳转下一题
            [self performSelector:@selector(nextQuestion) withObject:nil afterDelay:0.5];
            //加100分
            [self addScore:100];
        } else {
            //答案错误，变红
            [self setAnswerButtonTitleColor:[UIColor redColor]];
        }
    }
}


//计算分数
- (void)addScore:(int)score
{
    //1.获取按钮的分值
    NSString *str = self.btnCoin.currentTitle;
    //2.把这个分数转换成数值类型
    int currentScore = str.intValue;
    //3.对这个分数进行操作
    currentScore = currentScore + score;
    if (currentScore < 0) {
        currentScore = 0;
    }
    //4.把这个分数设置给按钮
    [self.btnCoin setTitle:[NSString stringWithFormat:@"%d", currentScore] forState:UIControlStateNormal];
    
}

//循环答案按钮变其颜色
- (void)setAnswerButtonTitleColor:(UIColor *)color
{
    //遍历每一个按钮，设置文字颜色
    for (UIButton *btnAnswer in self.viewAnswer.subviews) {
        [btnAnswer setTitleColor:color forState:UIControlStateNormal];
    }
}


//根据模型设置数据
- (void)settingDat:(CZQuestion *)model
{
    //3.把模型数据设置到界面对应的控件上
    self.lbIndex.text = [NSString stringWithFormat:@"%d/%ld",self.index + 1,self.questions.count];
    self.lbTitle.text = model.title;
    [self.btnImg setImage:[UIImage imageNamed:model.icon] forState:UIControlStateNormal];
    
    //4.到达最后一题禁用按钮
    self.btnNext.enabled = (self.index != self.questions.count - 1);
    
}

- (void)makeAnswerButtons:(CZQuestion *)model
{
    //5.动态创建答案按钮
    
    //先清除上一题的按钮
//    while (self.viewAnswer.subviews.firstObject) {
//        [self.viewAnswer.subviews.firstObject removeFromSuperview];
//    }
    
    //让数组中的每个元素执行同样一个方法
    [self.viewAnswer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //获取当前答案的文字个数
    NSInteger len = model.answer.length;
    
    //设置按钮的大小
    CGFloat margin = 10;//按钮之间的间距
    CGFloat answerW = 35;
    CGFloat answerH = 35;
    CGFloat answerY = 0;
    CGFloat marginLeft = (self.viewAnswer.frame.size.width - answerW * len - (len - 1) * margin) * 0.5;
    //循环创建文字按钮
    
    for (int i = 0; i < len ; i ++) {
        //创建按钮
        UIButton *btnAnswer = [[UIButton alloc] init];
        //添加按钮的背景图
        [btnAnswer setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
        [btnAnswer setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
        //计算按钮的X的值
        CGFloat answerX = (marginLeft + i * (answerW + margin));
        btnAnswer.frame = CGRectMake(answerX, answerY, answerW, answerH);
        [btnAnswer setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //把答案按钮加到答案视图上
        [self.viewAnswer addSubview:btnAnswer];
        
        //为答案按钮添加单击事件
        [btnAnswer addTarget:self action:@selector(btnAnswerClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)btnAnswerClick:(UIButton *)sender
{
    
    //启用答案选择区
    self.viewAnswerOpt.userInteractionEnabled = YES;
    //1.在答案选择区将对点击的文字显现出来
    for (UIButton *optBtn in self.viewAnswerOpt.subviews) {
//        if ([sender.currentTitle isEqualToString:optBtn.currentTitle]) {
//            optBtn.hidden = NO;
//            break;
        if (sender.tag == optBtn.tag) {
            optBtn.hidden = NO;
            break;
        }
    }
    //2.把点击的答案按钮上的文字设置为nil
    [sender setTitle:nil forState:UIControlStateNormal];
    //3.把其他按钮的颜色设置为黑色
    [self setAnswerButtonTitleColor:[UIColor blackColor]];
    

}
@end
