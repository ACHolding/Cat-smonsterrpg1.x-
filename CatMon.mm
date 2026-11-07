#import <Cocoa/Cocoa.h>
#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <string>
#include <vector>

static constexpr int SW=640, SH=480;
static const char* MAP[]={
"####################",
"#....gggg....gg....#",
"#....gggg....gg....#",
"#.................g#",
"#..####.....####...#",
"#..#..#.....#..#...#",
"#..####.....####...#",
"#..................#",
"#ggg.....gggg......#",
"#ggg.....gggg......#",
"#..............ggg.#",
"#.....####.....ggg.#",
"#.....#..#.........#",
"#.....####.........#",
"####################"};
struct Creature { std::string name; int hp,maxhp,attack; NSColor* color; };
@interface GameView : NSView { @public
 int px,py,steps,balls,scene,selection,enemyHP,enemyMax,enemyAttack,playerHP,playerMax,level,turns;
 double accumulator; BOOL held[4]; std::string message; std::string enemyName; NSColor* enemyColor;
}
-(void)tick:(NSTimer*)timer;
@end
@implementation GameView
-(BOOL)acceptsFirstResponder{return YES;}
-(instancetype)initWithFrame:(NSRect)frame { if((self=[super initWithFrame:frame])) { px=3;py=7;steps=0;balls=8;scene=0;selection=0;playerMax=32;playerHP=32;level=5;turns=0;message="Welcome to CATMON! Press ENTER."; for(int i=0;i<4;i++)held[i]=NO; } return self; }
-(void)rect:(CGFloat)x :(CGFloat)y :(CGFloat)w :(CGFloat)h :(NSColor*)color { [color setFill]; NSRectFill(NSMakeRect(x,SH-y-h,w,h)); }
-(void)label:(NSString*)str :(CGFloat)x :(CGFloat)y :(CGFloat)size :(NSColor*)color { NSDictionary* attrs=@{NSFontAttributeName:[NSFont fontWithName:@"Menlo-Bold" size:size]?:[NSFont boldSystemFontOfSize:size],NSForegroundColorAttributeName:color}; [str drawAtPoint:NSMakePoint(x,SH-y-size-2) withAttributes:attrs]; }
-(NSColor*)ink {return [NSColor colorWithCalibratedRed:.13 green:.23 blue:.17 alpha:1];}
-(NSColor*)light {return [NSColor colorWithCalibratedRed:.80 green:.91 blue:.64 alpha:1];}
-(void)panel:(NSString*)str { [self rect:16 :370 :608 :96:[self ink]]; [self rect:22 :376 :596 :84:[self light]]; [self label:str :36 :389 :17:[self ink]]; }
-(void)encounter { const char* names[]={"MOSSLET","EMBEROO","BUBBLIT","SPARKIT"}; int n=arc4random_uniform(4); enemyName=names[n]; enemyMax=18+arc4random_uniform(13);enemyHP=enemyMax;enemyAttack=3+n;enemyColor=@[[NSColor colorWithCalibratedRed:.25 green:.55 blue:.27 alpha:1],[NSColor orangeColor],[NSColor cyanColor],[NSColor yellowColor]][n];scene=2;selection=0;message="A wild "+enemyName+" appeared!"; }
-(void)move:(int)dx :(int)dy { int nx=px+dx,ny=py+dy; if(nx<0||nx>=20||ny<0||ny>=15||MAP[ny][nx]=='#')return;px=nx;py=ny;steps++;if(MAP[py][px]=='g'&&arc4random_uniform(100)<23){[self encounter];return;}message="Explore the grass. Find and capture creatures!"; }
-(void)enemyTurn { if(enemyHP<=0)return; int dmg=std::max(1,enemyAttack-static_cast<int>(arc4random_uniform(3)));playerHP=std::max(0,playerHP-dmg);if(playerHP==0){scene=3;message="Your partner fainted! Press R to rest.";}else message=""+enemyName+" hit for "+std::to_string(dmg)+" damage!"; }
-(void)action { if(scene==0){scene=1;message="Explore the grass. Find and capture creatures!";return;}if(scene==3){scene=1;px=3;py=7;playerHP=playerMax;message="Rested at home. Ready again!";return;}if(scene!=2)return;
 if(selection==0){int dmg=5+arc4random_uniform(7)+level/2;enemyHP=std::max(0,enemyHP-dmg);if(enemyHP==0){scene=1;level++;playerMax+=2;playerHP=std::min(playerMax,playerHP+7);message="Victory! Your partner grew stronger!";}else{message="Your partner dealt "+std::to_string(dmg)+" damage!";[self enemyTurn];}}
 else if(selection==1){if(balls<=0){message="No capture orbs left!";return;}balls--;double chance=.20+.72*(1.0-double(enemyHP)/enemyMax);if(arc4random_uniform(1000)<chance*1000){scene=1;level++;message="Captured "+enemyName+"! Your team grows!";}else{message="The capture orb broke!";[self enemyTurn];}}
 else if(selection==2){playerHP=std::min(playerMax,playerHP+12);message="Your partner recovered 12 HP!";[self enemyTurn];}
 else {if(arc4random_uniform(100)<80){scene=1;message="Got away safely!";}else{message="Couldn't escape!";[self enemyTurn];}} }
-(void)keyDown:(NSEvent*)event {NSString*k=[event.charactersIgnoringModifiers lowercaseString];if(!k.length)return;unichar c=[k characterAtIndex:0];if(c==27){scene=0;message="Welcome to CATMON! Press ENTER.";}else if(c=='\r'||c==' '){[self action];}else if(c=='r'&&scene==3){[self action];}else if(scene==1){if(c==NSLeftArrowFunctionKey||c=='a')[self move:-1 :0];if(c==NSRightArrowFunctionKey||c=='d')[self move:1 :0];if(c==NSUpArrowFunctionKey||c=='w')[self move:0 :-1];if(c==NSDownArrowFunctionKey||c=='s')[self move:0 :1];}else if(scene==2){if(c==NSLeftArrowFunctionKey||c=='a')selection=(selection+3)%4;if(c==NSRightArrowFunctionKey||c=='d')selection=(selection+1)%4;if(c==NSUpArrowFunctionKey||c=='w')selection=(selection+2)%4;if(c==NSDownArrowFunctionKey||c=='s')selection=(selection+2)%4;}[self setNeedsDisplay:YES];}
-(void)tick:(NSTimer*)timer {[self setNeedsDisplay:YES];}
-(void)drawRect:(NSRect)dirty { [self rect:0 :0 :SW :SH:[self ink]];[self rect:8 :8 :624 :464:[self light]];
 if(scene==0){[self label:@"CATMON" :167 :90 :62:[self ink]];[self label:@"POCKET ADVENTURE 0.1" :164 :171 :22:[self ink]];[self label:@"C++ / APPLE SILICON" :184 :227 :19:[self ink]];[self label:@"ENTER - START" :220 :295 :21:[self ink]];[self label:@"(C) AC KONDO 1999-2026" :155 :405 :16:[self ink]];return;}
 if(scene==1||scene==3){for(int y=0;y<15;y++)for(int x=0;x<20;x++){char t=MAP[y][x];NSColor* col=t=='#'?[self ink]:(t=='g'?[NSColor colorWithCalibratedRed:.43 green:.67 blue:.36 alpha:1]:[self light]);[self rect:x*32 :y*24 :32 :24 :col];if(t=='g'){[self rect:x*32+8 :y*24+6 :4 :12:[self ink]];[self rect:x*32+18 :y*24+3 :4 :12:[self ink]];}if(t=='#'){[self rect:x*32+4 :y*24+4 :24 :3:[self light]];}}[self rect:px*32+8 :py*24+2 :16 :20:[NSColor colorWithCalibratedRed:.84 green:.27 blue:.27 alpha:1]];[self rect:px*32+10 :py*24+3 :12 :5:[self ink]];[self panel:[NSString stringWithUTF8String:message.c_str()]];[self label:[NSString stringWithFormat:@"HP %d/%d   LV %d   ORBS %d",playerHP,playerMax,level,balls] :28 :12 :17:[self light]];return;}
 if(scene==2){[self label:[NSString stringWithFormat:@"WILD %s",enemyName.c_str()] :40 :25 :24:[self ink]];[self label:[NSString stringWithFormat:@"HP %d/%d",enemyHP,enemyMax] :40 :57 :20:[self ink]];[self rect:42 :90 :std::max(0,enemyHP)*220/enemyMax :12:[self ink]];[self rect:390 :110 :110 :85:enemyColor];[self rect:413 :132 :15 :12:[self ink]];[self rect:462 :132 :15 :12:[self ink]];[self label:@"YOUR PARTNER" :45 :225 :23:[self ink]];[self label:[NSString stringWithFormat:@"HP %d/%d  LV %d",playerHP,playerMax,level] :45 :255 :20:[self ink]];[self rect:95 :295 :100 :60:[NSColor colorWithCalibratedRed:.35 green:.5 blue:.7 alpha:1]];[self panel:[NSString stringWithUTF8String:message.c_str()]];NSArray* options=@[@"ATTACK",@"CAPTURE",@"HEAL",@"RUN"];for(int i=0;i<4;i++){int x=34+(i%2)*170,y=390+(i/2)*31;[self label:[NSString stringWithFormat:@"%@%@",selection==i?@"> ":@"  ",options[i]] :x :y :16:[self ink]];} }
}
@end
@interface GameDelegate:NSObject<NSApplicationDelegate>@property(strong)NSWindow* window;@property(strong)GameView* game;@property(strong)NSTimer* timer;@end
@implementation GameDelegate
-(void)applicationDidFinishLaunching:(NSNotification*)n {NSRect frame=NSMakeRect(0,0,SW,SH);self.window=[[NSWindow alloc]initWithContentRect:frame styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable backing:NSBackingStoreBuffered defer:NO];[self.window setTitle:@"CatMon 0.1 — Apple Silicon"] ;[self.window center];self.game=[[GameView alloc]initWithFrame:frame];[self.window setContentView:self.game];[self.window makeKeyAndOrderFront:nil];[self.window makeFirstResponder:self.game];self.timer=[NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self.game selector:@selector(tick:) userInfo:nil repeats:YES];}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender{return YES;}
@end
int main(int argc,char**argv){@autoreleasepool{[NSApplication sharedApplication];[NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];GameDelegate*delegate=[GameDelegate new];[NSApp setDelegate:delegate];[NSApp activateIgnoringOtherApps:YES];[NSApp run];}return 0;}
