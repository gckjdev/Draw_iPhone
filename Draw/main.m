    
//  main.m
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}

/*
 
 Release Notes
 
 － 检查所有URL是否正确设置为正式服务器的URL:wq
 
 － 检查广告是否被屏蔽
 
 Info Plist
 － 修改Bundle ID
 － 修改URL Scheme
 － 修改Icon
 － 修改CFChannelID
 - 修改Launch image

 Resource
 － 删除Resource文件
 
 InfoPlist.strings
 － 修改应用名称
 
 Test
 － iPhone
 － iPad
 － iPhone 4.3
 
 注册
 设置
 快速开始
 房间进入
 帮助
 商店购买
*/


// TODO 分享加载bug; 统计分析；



/*
 
 界面
 
 1）入口
 
 2）购买
 
 3）续费
 
 4）详情
 
 5）用户资料（用户详情、avatar view）
 
 5）iPhone5
 
 6）iPad
 
 
 
 效果：
 
 vip会员送花不扣费(ok)
 
 vip会员使用道具免费(ok)
 
 vip会员每月增加金币(ok)
 
 ｖｉｐ会员可创建最高等级为５０级
 
 
 
 画榜：增加ＶＩＰ会员专区显示（按照时间排序）
 
 画家：增加ＶＩＰ会员专区（按照付费有效期长度排序和付费日期排序） expireDate/paymentDate
 
 
 
 任务跳转到VIP
 
 公告跳转到VIP
 
 用户资料跳转到VIP
 
 商店跳转到VIP
 
 画榜：购买会员
 
 画家：购买会员
 
 */


/*
 
 本次画画比赛评委出炉了！由
 
 DS家族负责人 - 🔝DS🔹炫世de蝶
 专业画师 - 🔝DS🔹何休🔹
 
 以及4位低龄大触
 
 中二年Vampire _
 💀OP💫舞者' 羲💀
 fery
 💀OP💫教皇'仔仔💀
 
 共同担任！
 
 本期记者团也空前强大，由小吉杂志的主编💀OP💫退休'双性人格のXYM新月💀共同领衔的豪华记者团名单如下
 
 🔝ds🔹寥星の夫人 🎵木马🔹
 💀OP💫船员•银铃💀
 College•菟菟
 十八自夜
 Painter•阿废
 💀OP💫退休'双性人格のXYM新月💀
 💀OP💫 探险者'小橘子💀
 🍥DR💫❦夢❦⌖
 林巡

 再次感谢支持，报名记者的用户太多，没有报名的下次优先（记得下次报名时候注明一下）
 
 
 Jugde
 
 50fb6f45e4b05bb0f0801a27, 中二年Vampire _
 5108ce40e4b0fcf06b9834b5, 💀OP💫舞者' 羲💀
 51062a87e4b00bd3d109f64c, fery
 50e820b8e4b07039cd227c66, 💀OP💫教皇'仔仔💀
 
 52344605e4b058f58458beb9, 🔝DS🔹何休🔹
 51191487e4b098c397bc56be, 🔝DS🔹炫世de蝶。
 
 Reporters
 
 52c4ef72e4b035f5ca930a12, 🔝ds🔹寥星の夫人 🎵木马🔹
 503a2fe32609ffed65eba6d1, 💀OP💫船员•银铃💀
 516d4d6ee4b0e33f70c1cd7d, College•菟菟
 51d14b08e4b078f0023861df,  十八自夜
 51b1db12e4b08ab7e19c7041, Painter•阿废
 51021f70e4b0a04f9ebc8ed5, 💀OP💫退休'双性人格のXYM新月💀
 51985eb6e4b021ddc794a309, 💀OP💫 探险者'小橘子💀
 51061cfbe4b00bd3d109f23f, 🍥DR💫❦夢❦⌖
 503ab8592609ffed65ebb1bb, 林巡
 
 5152e423e4b0c93e8e1dd00c,  🔝ds🔹芳儿🔹(十二方块)
 51d3f69ee4b020f7419ebc47, 🔝ds🔹溪媛●ω●♪🔹
 
 
 Reporters
 
 52da7069e4b054fc77f8e90a, 『N✿N』极乐
 51e54be2e4b0ebebc23dcdd6, ♠MH🔱族长 🔮熙月冥🌙月酱💫小冥🎶
 50d98e4fe4b0d73d234ee56c, 🔝ds🔹清浅🌀不再接画啦🔹
 

 家族内测即将结束，请升级到8.0版本（或者免费版升级到2.5，大舌头升级到1.5）
 
 8.0版本改进了修复和完善的家族的各项细节功能，欢迎升级使用
 
 以下是家族的规定和详细说明：
 
 家族，之所以命名为家族，而不是小组或者其他名称，就是希望家族能有家的感觉，核心目的是为了聚合互相喜欢或者有共同兴趣的一群人
 
 家族规则：
 
 1）一个用户只可以创建或者加入一个家族；目前创建家族后暂时不能解散，加入家族后可以自由退出；
 
 2）一个用户可以作为多个家族的嘉宾；嘉宾可以参与家族的群聊和论坛发帖；嘉宾目前只能由家族邀请
 
 3）家族拥有自己的论坛、比赛和群聊功能，只有成员和嘉宾才可以使用这些功能
 
 4）家族根据等级，每月支付给系统一定金币（每级别100金币，升一级可多容纳10个成员，目前最高20级别，超过需要特别申请）
 
 5）一个家族可以有多个管理员，管理员由创建者指定，管理员可以申请或者邀请用户加入家族
 
 6）家族内进出自由，但用户主动退出家族需要支付188金币给家族
 
 7）用户可以充值金币给家族，家族也可以转账给用户；

 8）超过150人的家族一般是有问题的，你们真的都互相认识吗？当然这个不是绝对，只是一个建议。
 
 家族管理员说明：
 
 1）创建家族成功后，点击自己的家族进入自己家族首页，然后再点击家族头像，即可进入管理界面；
 
 2）在管理界面中，点击头像、描述等均可编辑相关信息；
 
 3）在管理界面中，点击成员的+号，可以邀请成员（或者通知原先的成员加入）
 
 4）点击右上角的管理功能，可以有额外的选项，自行研究一下
 
 其他：
 
 1）禁止主动要求或者有偿要求家族成员给作品送花，以提升作品的画榜排名或者画画比赛排名
 
 有相关家族问题或者建议请在本帖留言
 
 Month
 5167ffc5e4b0f766701a11d5
 51335a6ae4b0f6620a5e9a1b
 
 
 http://58.215.160.100:8001/api/i?&m1=buyVipCount&uid=4f86469d260958163895b958&app=513819630&gid=Draw&ts=1391423223&mac=G8fF2yjCHDo%2B7eyntp%2BHng%3D%3D&v=8.0

 http://58.215.160.100:8001/api/i?&m1=buyVipCount&uid=4f86469d260958163895b958&app=513819630&gid=Draw&ts=1391423223&mac=G8fF2yjCHDo%2B7eyntp%2BHng%3D%3D&v=8.0
 http://58.215.160.100:8001/api/i?&m1=buyVipCount&uid=4f86469d260958163895b958&app=513819630&gid=Draw&ts=1391423223&mac=G8fF2yjCHDo%2B7eyntp%2BHng%3D%3D&v=8.0
 http://58.215.160.100:8001/api/i?&m1=buyVipCount&uid=4f86469d260958163895b958&app=513819630&gid=Draw&ts=1391423223&mac=G8fF2yjCHDo%2B7eyntp%2BHng%3D%3D&v=8.0
 http://58.215.160.100:8001/api/i?&m1=buyVipCount&uid=4f86469d260958163895b958&app=513819630&gid=Draw&ts=1391423223&mac=G8fF2yjCHDo%2B7eyntp%2BHng%3D%3D&v=8.0

 
 
 Year
 516d4d6ee4b0e33f70c1cd7d
 52b97d94e4b035f5ca9225a9
 51191487e4b098c397bc56be
 50f57a6de4b05bb0f07ed051
 http://58.215.160.100:8001/api/i?&m1=buyVipCount&uid=526606eee4b096116d7fd0d1&app=513819630&gid=Draw&ts=1391426186&mac=BbRY%2FdCMcqiUzlxyDV5%2BEA%3D%3D&v=8.0
 
 
 */
