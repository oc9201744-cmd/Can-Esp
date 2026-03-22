//
//  DrawWindow.m
//  Dolphins
//
//  Created by xbk on 2022/4/24.
//

#include "Dolphins/Obfuscate.h"
#include "Dolphins/utils/module_tools.h"
#import "Dolphins/Module/视图.h"
#include "Dolphins/utils/image_base64.h"
#import "Dolphins/View/OverlayView.h"
//#import "Gzb.h"
#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenWidth [UIScreen mainScreen].bounds.size.width
@implementation mao
ImDrawList *imDrawList;

CGSize screenSize;

using namespace std;



std::vector<PlayerData> playerDataList;
std::vector<MaterialData> materialDataList;
int xWidth =50;
int xtWidth =10;
int hpWidth = 110;
int hpHeight = 4;
int hpHeight1 = 30;
int scWidth = 220;
int scHeight = 110;
int qtWidth = 220;
int qtHeight = 50;

id<MTLTexture> leizhaTexture;
id<MTLTexture> hongzhaTexture;
id<MTLTexture> shouleiTexture;
id<MTLTexture> sldTexture;
id<MTLTexture> ywdTexture;
id<MTLTexture> rspTexture;

id<MTLTexture> countTexture;
id<MTLTexture> count1Texture;
id<MTLTexture> count2Texture;
id<MTLTexture> count3Texture;
id<MTLTexture> count4Texture;
id<MTLTexture> count5Texture;
id<MTLTexture> quanTexture;
id<MTLTexture> playerTexture;
id<MTLTexture> robotTexture;

id<MTLTexture> M416Texture;
id<MTLTexture> M16Texture;
id<MTLTexture> GrozaTexture;
id<MTLTexture> AkmTexture;
id<MTLTexture> SCARTexture;
id<MTLTexture> MK47Texture;
id<MTLTexture> AUGTexture;
id<MTLTexture> M762Texture;
id<MTLTexture> QBZTexture;
id<MTLTexture> leiTexture;
id<MTLTexture> huoTexture;
id<MTLTexture> yanTexture;
id<MTLTexture> shanTexture;
id<MTLTexture> R1895Texture;
id<MTLTexture> P92Texture;
id<MTLTexture> P1911Texture;
id<MTLTexture> P18CTexture;
id<MTLTexture> R45Texture;
id<MTLTexture> SKSTexture;
id<MTLTexture> MINITexture;
id<MTLTexture> MK14Texture;
id<MTLTexture> VSSTexture;
id<MTLTexture> QBUTexture;
id<MTLTexture> SLRTexture;
id<MTLTexture> AWMTexture;
id<MTLTexture> M24Texture;
id<MTLTexture> K98Texture;
id<MTLTexture> MOTexture;
id<MTLTexture> LIANTexture;
id<MTLTexture> GUNTexture;
id<MTLTexture> DAOTexture;
id<MTLTexture> GUOTexture;
id<MTLTexture> UZITexture;
id<MTLTexture> TANGTexture;
id<MTLTexture> VKTTexture;
id<MTLTexture> MP5KTexture;
id<MTLTexture> UMP9Texture;
id<MTLTexture> YNTexture;
id<MTLTexture> DP28Texture;
id<MTLTexture> MG3Texture;
id<MTLTexture> M249Texture;
id<MTLTexture> DBSTexture;
id<MTLTexture> S686Texture;
id<MTLTexture> S12KTexture;

id<MTLTexture> JPTexture;
id<MTLTexture> BBTexture;
id<MTLTexture> jcTexture;
id<MTLTexture> mttTexture;
id<MTLTexture> mtTexture;
id<MTLTexture> myTexture;
id<MTLTexture> R8Texture;
id<MTLTexture> mt3Texture;

id<MTLTexture> m416Texture;
id<MTLTexture> akmTexture;
id<MTLTexture> augTexture;
id<MTLTexture> grozaTexture;
id<MTLTexture> m16Texture;
id<MTLTexture> m24Texture;
id<MTLTexture> m249Texture;
id<MTLTexture> m762Texture;
id<MTLTexture> mg3Texture;
id<MTLTexture> miniTexture;
id<MTLTexture> mk14Texture;
id<MTLTexture> mk47Texture;
id<MTLTexture> scarTexture;
id<MTLTexture> slrTexture;
id<MTLTexture> awmTexture;
id<MTLTexture> dp28Texture;
id<MTLTexture> k98Texture;
id<MTLTexture> vssTexture;
id<MTLTexture> sksTexture;
id<MTLTexture> hzTexture;

id<MTLTexture> ylTexture;
id<MTLTexture> jjbTexture;
id<MTLTexture> ztyTexture;
id<MTLTexture> ylxTexture;
id<MTLTexture> zhenTexture;

id<MTLTexture> b4Texture;
id<MTLTexture> b3Texture;
id<MTLTexture> b6Texture;
id<MTLTexture> b8Texture;

id<MTLTexture> ktTexture;
id<MTLTexture> t3Texture;
id<MTLTexture> j3Texture;
id<MTLTexture> bb3Texture;

id<MTLTexture> tleiTexture;
id<MTLTexture> tyanTexture;
id<MTLTexture> thuoTexture;




- (instancetype)initWithFrame:(ModuleControl*)control {
    self = [super init];
    
    self.moduleControl = control;
    
    screenSize = [UIScreen mainScreen].bounds.size;
    screenSize.width *= [UIScreen mainScreen].nativeScale;
    screenSize.height *= [UIScreen mainScreen].nativeScale;
    
    return self;
}

-(void)drawDrawWindow {
    ImGui::SetNextWindowSize(ImVec2(screenSize.width,screenSize.height));
    ImGui::SetNextWindowPos(ImVec2(0, 0));
    ImGui::Begin("alpha", nullptr, ImGuiWindowFlags_NoBackground | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoInputs | ImGuiWindowFlags_NoMove);
    
    imDrawList = ImGui::GetWindowDrawList();
    
    //拉取一帧的数
    readFrameData(ImVec2(screenSize.width / 2,screenSize.height / 2),playerDataList, materialDataList);
    for (MaterialData materialData:materialDataList) {
            //判断是否在屏幕内
        if (self.moduleControl->playerSwitch.WZWZStatus) {
            if (materialData.name=="[WARNING]GRENADE1") {//警告贴图
                imDrawList->AddImage((__bridge ImTextureID) leizhaTexture, ImVec2(screenSize.width / 2 - leizhaTexture.width / 2, 230), ImVec2(screenSize.width / 2 + leizhaTexture.width / 2, 230 + leizhaTexture.height), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
            }
            if (materialData.name=="[WARNING]RED ZONE") {
                imDrawList->AddImage((__bridge ImTextureID) hongzhaTexture, ImVec2(screenSize.width / 2 - hongzhaTexture.width / 2, 180), ImVec2(screenSize.width / 2 + hongzhaTexture.width / 2, 180 + hongzhaTexture.height), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
            }
            if (materialData.name=="[WARNING]GRENADE1") {
                imDrawList->AddImage((__bridge ImTextureID) sldTexture, ImVec2(materialData.screen.x+190 - qtWidth+1, materialData.screen.y-5 -  qtHeight+1), ImVec2(materialData.screen.x+190 - qtWidth+1 + qtHeight-2 , materialData.screen.y-5 - qtHeight + qtHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
            }
            if (materialData.name=="[WARNING]SMOKE") {
                imDrawList->AddImage((__bridge ImTextureID) ywdTexture, ImVec2(materialData.screen.x+190 - qtWidth+1, materialData.screen.y-5 -  qtHeight+1), ImVec2(materialData.screen.x+190 - qtWidth+1 + qtHeight-2 , materialData.screen.y-5 - qtHeight + qtHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
            }
            if (materialData.name=="[WARNING]MOLOTOV") {
                imDrawList->AddImage((__bridge ImTextureID) rspTexture, ImVec2(materialData.screen.x+190 - qtWidth+1, materialData.screen.y-5 -  qtHeight+1), ImVec2(materialData.screen.x+190 - qtWidth+1 + qtHeight-2 , materialData.screen.y-5 - qtHeight + qtHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
            }
            
            //物品文字
            if (materialData.distance != -100){
                //载具
            if (materialData.name=="Motorcycle") {
                std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
                imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
             }
            if (materialData.name=="Sidecar Motorcycle") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
               imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            if (materialData.name=="Scooter") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
               imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            if (materialData.name=="Buggy") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
               imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            if (materialData.name=="Mirado") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            if (materialData.name=="Dacia") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            if (materialData.name=="UAZ") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            if (materialData.name=="BOAT") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            if (materialData.name=="JET SKI") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            if (materialData.name=="MINI BUS") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            if (materialData.name=="BRDM") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            if (materialData.name=="NIVA") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            if (materialData.name=="SNOWMOBILE") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            if (materialData.name=="SNOWBIKE") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            if (materialData.name=="RONY") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            if (materialData.name=="CoupeRB") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 206, 209), 21, str.c_str());
            }
            //空投盒子
            if (materialData.name=="[DEAD BOX]") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 255, 0), 21, str.c_str());
            }
            if (materialData.name=="DEAD BOX") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 255, 0), 21, str.c_str());
            }
            if (materialData.name=="[AIRDROP]") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 20, 147), 21, str.c_str());
            }
            if (materialData.name=="AIRDROP") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 20, 147), 21, str.c_str());
            }
            if (materialData.name=="FLARE") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 20, 147), 21, str.c_str());
            }
            //狙击枪
            if (materialData.name=="QBU") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="SLR") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="SKS") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="MINI14") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="M24") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="KAR98K") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="MK14") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="MOSIN NAGANT") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="MK12") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="AMR") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="AWM") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            //步枪
            if (materialData.name=="M762") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="SCAR-L") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="M416") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="M16A4") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="MK47") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="G36C") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="QBZ") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="GROZA") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="AUG") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="AKM") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="DP28") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="M249") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="MG3") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="GRENADE") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 127, 80), 21, str.c_str());
            }
            if (materialData.name=="SMOKE") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 127, 80), 21, str.c_str());
            }
            if (materialData.name=="MOLOTOV") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 127, 80), 21, str.c_str());
            }
            if (materialData.name=="ARMOR Lv3") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="BACKPACK Lv3") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="HELMET Lv3") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="PAINKILLER") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 210, 0), 21, str.c_str());
            }
            if (materialData.name=="ADRENALINE") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 210, 0), 21, str.c_str());
            }
            if (materialData.name=="DRINK") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 210, 0), 21, str.c_str());
            }
            if (materialData.name=="FIRST AID KID") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 210, 0), 21, str.c_str());
            }
            if (materialData.name=="MED KIT") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 210, 0), 21, str.c_str());
            }
            if (materialData.name=="GAS CAN") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 210, 0), 21, str.c_str());
            }
            if (materialData.name=="RED DOT") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
               imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(70, 130, 180), 21, str.c_str());
            }
            if (materialData.name=="HOLOGRAPHIC SCOPE") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(70, 130, 180), 21, str.c_str());
            }
            if (materialData.name=="3X") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(70, 130, 180), 21, str.c_str());
            }
            if (materialData.name=="4X") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(70, 130, 180), 21, str.c_str());
            }
            if (materialData.name=="6X") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(70, 130, 180), 21, str.c_str());
            }
            if (materialData.name=="8X") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(70, 130, 180), 21, str.c_str());
            }
            if (materialData.name=="MOLOTOV") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(178, 34, 34), 21, str.c_str());
            }
            if (materialData.name=="SMOKE") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(178, 34, 34), 21, str.c_str());
            }
            if (materialData.name=="GRENADE") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(178, 34, 34), 21, str.c_str());
            }
            if (materialData.name=="RED ZONE") {
               std::string str =  "["+ materialData.name +":" + std::to_string(materialData.distance) + "M]";
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(178, 34, 34), 21, str.c_str());
            }
            } else {
                if (materialData.name=="[DRUG]PAINKILLER") {
                   std::string str = materialData.name;
                    imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
                   imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 210, 0), 21, str.c_str());
                }
                if (materialData.name=="[DRUG]ADRENALINE") {
                   std::string str = materialData.name;
                    imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
                   imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 210, 0), 21, str.c_str());
                }
                if (materialData.name=="[DRUG]DRINK") {
                   std::string str = materialData.name;
                    imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
                   imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 210, 0), 21, str.c_str());
                }
                if (materialData.name=="[DRUG]FIRST AID KIT") {
                   std::string str = materialData.name;
                    imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
                   imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 210, 0), 21, str.c_str());
                }
                if (materialData.name=="[DRUG]MED KIT") {
                   std::string str = materialData.name;
                    imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
                   imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 210, 0), 21, str.c_str());
                }
            if (materialData.name=="[ARMOR]ARMOR Lv3") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[ARMOR]BACKPACK Lv3") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[ARMOR]HELMET Lv3") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[ARMOR]ARMOR Lv2") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[ARMOR]BACKPACK Lv2") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[ARMOR]HELMET Lv2") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[ARMOR]HELMET Lv6") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[ARMOR]VEST Lv6") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[ARMOR]BACKPACK Lv6") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[ARMOR]VEST COBRA Lv6") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[ARMOR]VEST STEEL FRONT Lv6") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[ARMOR]HELMET COBRA Lv6") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[ARMOR]HELMET STEEL FRONT Lv6") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            
            if (materialData.name=="[LOOT]QBU") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]SLR") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]SKS") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]Mini14") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]M24") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]Kar98k") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]Mk14") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]MOSIN NAGANT") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]MK12") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]AMR") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]AWM") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 0, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]M762") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]SCAR-L") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]M416") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]M16A4") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]Mk47") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]G36C") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]QBZ") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]Groza") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]AUG") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]AKM") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]DP28") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]M249") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="[LOOT]MG3") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 69, 0), 21, str.c_str());
            }
            if (materialData.name=="5.56mm") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 255, 0), 21, str.c_str());
            }
            if (materialData.name=="7.62mm") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 255, 0), 21, str.c_str());
            }
            if (materialData.name=="MAGNUM") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 255, 0), 21, str.c_str());
            }
            if (materialData.name=="50BMG") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(0, 255, 0), 21, str.c_str());
            }
            if (materialData.name=="[SCOPE]RED DOT SIGHT") {
               std::string str = materialData.name;
               imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(70, 130, 180), 21, str.c_str());
            }
            if (materialData.name=="[SCOPE]HOLOGRAPHIC SIGHT") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(70, 130, 180), 21, str.c_str());
            }
            if (materialData.name=="[SCOPE]3X") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(70, 130, 180), 21, str.c_str());
            }
            if (materialData.name=="[SCOPE]4X") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(70, 130, 180), 21, str.c_str());
            }
            if (materialData.name=="[SCOPE]6X") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(70, 130, 180), 21, str.c_str());
            }
            if (materialData.name=="[SCOPE]8X") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(70, 130, 180), 21, str.c_str());
            }
            if (materialData.name=="[THROW]GRENADE") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 127, 80), 21, str.c_str());
            }
            if (materialData.name=="[投]SMOKE") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 127, 80), 21, str.c_str());
            }
            if (materialData.name=="[投]MOLOTOV") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 127, 80), 21, str.c_str());
            }
            if (materialData.name=="[PARTS]CHEEK PAD") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[PARTS]BULLET LOOPS") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[PARTS]BULLET LOOPS") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[PARTS]FLASH HIDER") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[PARTS]COMPENSATOR") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[PARTS]SUPPRESSOR") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[PARTS]EXTENTED QUICKDRAW MAGAZINE") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[PARTS]EXTENTED MAGAZINE") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[GRIPS]THUMB GRIP") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[GRIPS]VERTICAL GRIP") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[GRIPS]HALF GRIP") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[PARTS]TACTICAL STOCK") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[PARTS]FLASH HIDER") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[PARTS]COMPENSATOR") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[PARTS]SUPPRESSOR") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[PARTS]EXTENTED QUICKDRAW MAGAZINE") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
            if (materialData.name=="[PARTS]EXTENTED MAGAZINE") {
               std::string str = materialData.name;
                imDrawList->AddTextX(ImVec2(materialData.screen.x+1 - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y+1), ImColor(0, 0, 0, 255), 21, str.c_str());
               imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(str.c_str(), 21) / 2, materialData.screen.y), ImColor(255, 255, 80), 21, str.c_str());
            }
                
            }
        }
        //物品贴图
        if (self.moduleControl->playerSwitch.WZStatus) {
        if (materialData.name=="[WARNING]GRENADE1") {
                imDrawList->AddImage((__bridge ImTextureID) shouleiTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
            }
        if (materialData.name=="UAZ") {
                imDrawList->AddImage((__bridge ImTextureID) JPTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
           }
        if (materialData.name=="Buggy") {
                imDrawList->AddImage((__bridge ImTextureID) BBTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
            }
        if (materialData.name=="Dacia") {
            imDrawList->AddImage((__bridge ImTextureID) jcTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="BOAT") {
            imDrawList->AddImage((__bridge ImTextureID) mttTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="Motorcycle") {
            imDrawList->AddImage((__bridge ImTextureID) mtTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="Scooter") {
            imDrawList->AddImage((__bridge ImTextureID) myTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="CoupeRB") {
            imDrawList->AddImage((__bridge ImTextureID) R8Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="Sidecar Motorcycle") {
            imDrawList->AddImage((__bridge ImTextureID) mt3Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        
        if (materialData.name=="M416") {
            imDrawList->AddImage((__bridge ImTextureID) m416Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="AKM") {
            imDrawList->AddImage((__bridge ImTextureID) akmTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="AUG") {
            imDrawList->AddImage((__bridge ImTextureID) augTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="Groza") {
            imDrawList->AddImage((__bridge ImTextureID) grozaTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="M16A4") {
            imDrawList->AddImage((__bridge ImTextureID) m16Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="M24") {
            imDrawList->AddImage((__bridge ImTextureID) m24Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="M249") {
            imDrawList->AddImage((__bridge ImTextureID) m249Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="M762") {
            imDrawList->AddImage((__bridge ImTextureID) m762Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="MG3") {
            imDrawList->AddImage((__bridge ImTextureID) mg3Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="Mini14") {
            imDrawList->AddImage((__bridge ImTextureID) miniTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="Mk14") {
            imDrawList->AddImage((__bridge ImTextureID) mk14Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="Mk47") {
            imDrawList->AddImage((__bridge ImTextureID) mk47Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="SCAR-L") {
            imDrawList->AddImage((__bridge ImTextureID) scarTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="SLR") {
            imDrawList->AddImage((__bridge ImTextureID) slrTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="AWM") {
            imDrawList->AddImage((__bridge ImTextureID) awmTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="DP28") {
            imDrawList->AddImage((__bridge ImTextureID) dp28Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="Kar98k") {
            imDrawList->AddImage((__bridge ImTextureID) k98Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="SKS") {
            imDrawList->AddImage((__bridge ImTextureID) sksTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="[DEAD BOX]") {
            imDrawList->AddImage((__bridge ImTextureID) hzTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="盒子") {
            imDrawList->AddImage((__bridge ImTextureID) ktTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+17 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+17 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        
        if (materialData.name=="DRINK") {
            imDrawList->AddImage((__bridge ImTextureID) ylTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="PAINKILLER") {
            imDrawList->AddImage((__bridge ImTextureID) ztyTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="FIRST AID KID") {
            imDrawList->AddImage((__bridge ImTextureID) jjbTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="MED KIT") {
            imDrawList->AddImage((__bridge ImTextureID) ylxTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="ADRENALINE") {
            imDrawList->AddImage((__bridge ImTextureID) zhenTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        
        if (materialData.name=="4X") {
            imDrawList->AddImage((__bridge ImTextureID) b4Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="3X") {
            imDrawList->AddImage((__bridge ImTextureID) b3Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="6X") {
            imDrawList->AddImage((__bridge ImTextureID) b6Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="8X") {
            imDrawList->AddImage((__bridge ImTextureID) b8Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="[AIRDROP]") {
            imDrawList->AddImage((__bridge ImTextureID) ktTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="AIRDROP") {
            imDrawList->AddImage((__bridge ImTextureID) ktTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="HELMET Lv3") {
            imDrawList->AddImage((__bridge ImTextureID) t3Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="ARMOR Lv3") {
            imDrawList->AddImage((__bridge ImTextureID) j3Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="BACKPACK Lv3") {
            imDrawList->AddImage((__bridge ImTextureID) bb3Texture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="GRENADE") {
            imDrawList->AddImage((__bridge ImTextureID) tleiTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="SMOKE") {
            imDrawList->AddImage((__bridge ImTextureID) tyanTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        if (materialData.name=="MOLOTOV") {
            imDrawList->AddImage((__bridge ImTextureID) thuoTexture, ImVec2(materialData.screen.x+165 - scWidth+1, materialData.screen.y+10 -  scHeight+1), ImVec2(materialData.screen.x+165 - scWidth+1 + scHeight-2 , materialData.screen.y+10 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        }
        //物品距离——贴图
        //if (materialData.distance != -100) {
                 //std::string str = std::to_string(materialData.distance) + "M";
                //imDrawList->AddTextX(ImVec2(materialData.screen.x-14 - calcTextSize(std::to_string(materialData.distance).c_str(), 22) / 2, materialData.screen.y-4 ), ImColor(255, 255,0), 22, str.c_str());
            //} else {
                 //std::string str = materialData.name + ":";//盒子内物资
                //imDrawList->AddRectFilled({materialData.screen.x - calcTextSize(materialData.name.c_str(), 22) / 2, materialData.screen.y }, {materialData.screen.x + calcTextSize(materialData.name.c_str(), 22) / 2, materialData.screen.y + 22}, ImColor(0, 0, 0, 80), 10.0f);
                //imDrawList->AddTextX(ImVec2(materialData.screen.x - calcTextSize(materialData.name.c_str(), 22) / 2, materialData.screen.y + (22 / 2 - 22 / 2)), ImColor(255, 255, 255), 22, materialData.name.c_str());
            //}
        }
    }
    if (self.moduleControl->mainSwitch.playerStatus) {
        //雷达UI
        if (self.moduleControl->playerSwitch.radarStatus) {
            // Нижний слой, задающий цвет фона внешнего квадрата
imDrawList->AddRectFilled(
    ImVec2(self.moduleControl->playerSwitch.radarCoord.x - 225 * (self.moduleControl->playerSwitch.radarSize / 100),
           self.moduleControl->playerSwitch.radarCoord.y - 225 * (self.moduleControl->playerSwitch.radarSize / 100)),
    ImVec2(self.moduleControl->playerSwitch.radarCoord.x + 225 * (self.moduleControl->playerSwitch.radarSize / 100),
           self.moduleControl->playerSwitch.radarCoord.y + 225 * (self.moduleControl->playerSwitch.radarSize / 100)),
    ImColor(0, 0, 0, 30)
);

// Внешний квадрат
imDrawList->AddRect(
    ImVec2(self.moduleControl->playerSwitch.radarCoord.x - 225 * (self.moduleControl->playerSwitch.radarSize / 100),
           self.moduleControl->playerSwitch.radarCoord.y - 225 * (self.moduleControl->playerSwitch.radarSize / 100)),
    ImVec2(self.moduleControl->playerSwitch.radarCoord.x + 225 * (self.moduleControl->playerSwitch.radarSize / 100),
           self.moduleControl->playerSwitch.radarCoord.y + 225 * (self.moduleControl->playerSwitch.radarSize / 100)),
    ImColor(255, 0, 0),
    0,
    1.0f
);

// Внутренний слой, задающий цвет фона внутреннего квадрата
imDrawList->AddRectFilled(
    ImVec2(self.moduleControl->playerSwitch.radarCoord.x - 110 * (self.moduleControl->playerSwitch.radarSize / 100),
           self.moduleControl->playerSwitch.radarCoord.y - 110 * (self.moduleControl->playerSwitch.radarSize / 100)),
    ImVec2(self.moduleControl->playerSwitch.radarCoord.x + 110 * (self.moduleControl->playerSwitch.radarSize / 100),
           self.moduleControl->playerSwitch.radarCoord.y + 110 * (self.moduleControl->playerSwitch.radarSize / 100)),
    ImColor(0, 128, 128, 30)
);

// Внутренний квадрат
imDrawList->AddRect(
    ImVec2(self.moduleControl->playerSwitch.radarCoord.x - 110 * (self.moduleControl->playerSwitch.radarSize / 100),
           self.moduleControl->playerSwitch.radarCoord.y - 110 * (self.moduleControl->playerSwitch.radarSize / 100)),
    ImVec2(self.moduleControl->playerSwitch.radarCoord.x + 110 * (self.moduleControl->playerSwitch.radarSize / 100),
           self.moduleControl->playerSwitch.radarCoord.y + 110 * (self.moduleControl->playerSwitch.radarSize / 100)),
    ImColor(0, 128, 128),
    0,
    1.0f
);
            
            //T
            imDrawList->AddLine({(float) (self.moduleControl->playerSwitch.radarCoord.x - 225 * (self.moduleControl->playerSwitch.radarSize / 100)), self.moduleControl->playerSwitch.radarCoord.y}, {(float) (self.moduleControl->playerSwitch.radarCoord.x + 225 * (self.moduleControl->playerSwitch.radarSize / 100)), self.moduleControl->playerSwitch.radarCoord.y}, ImColor(0, 200, 0), 1.0f);
            imDrawList->AddLine({self.moduleControl->playerSwitch.radarCoord.x, self.moduleControl->playerSwitch.radarCoord.y}, {self.moduleControl->playerSwitch.radarCoord.x, (float) (self.moduleControl->playerSwitch.radarCoord.y + 225 * (self.moduleControl->playerSwitch.radarSize / 100))}, ImColor(0, 200, 0), 1.0f);
            // \/
ImVec2 rotation = rotateCoord(130, ImVec2(0, 225 * (self.moduleControl->playerSwitch.radarSize / 100)));

// Масштабируем вектор длины, умножив его на коэффициент масштабирования (например, 0.5 для уменьшения длины вдвое)
rotation.x *= 1.31;
rotation.y *= 1.31;

imDrawList->AddLine(
    {self.moduleControl->playerSwitch.radarCoord.x, self.moduleControl->playerSwitch.radarCoord.y},
    {self.moduleControl->playerSwitch.radarCoord.x + rotation.x, self.moduleControl->playerSwitch.radarCoord.y + rotation.y},
    ImColor(200, 0, 0),
    1.0f
);
         
ImVec2 rotation1 = rotateCoord(-130, ImVec2(0, 225 * (self.moduleControl->playerSwitch.radarSize / 100)));

// Масштабируем вектор длины, умножив его на коэффициент масштабирования (например, 0.5 для уменьшения длины вдвое)
rotation1.x *= 1.31;
rotation1.y *= 1.31;

imDrawList->AddLine(
    {self.moduleControl->playerSwitch.radarCoord.x, self.moduleControl->playerSwitch.radarCoord.y},
    {self.moduleControl->playerSwitch.radarCoord.x + rotation1.x, self.moduleControl->playerSwitch.radarCoord.y + rotation1.y},
    ImColor(200, 0, 0),
    1.0f
);
        }
        //清空人数
        int playerCount = 0, robotCount = 0;
        for (PlayerData playerData:playerDataList) {
            //人机数量和真人数量
            ImColor color, color150, fillcolor;
            if (!playerData.robot) {//真人
                if (playerData.visibility) {
                    color = IM_COL32(255, 0, 0, 255);//可见
                    fillcolor = IM_COL32(255, 0, 0, 100);
                } else {
                    color = IM_COL32(255, 255, 0, 255);//IM_COL32(255, 255, 255, 255)
                    fillcolor = IM_COL32(255, 255, 0, 100);
                }
                playerCount += 1;
            } else {
                if (playerData.visibility) {
                    color = IM_COL32(0, 255, 0, 255);//可见
                    fillcolor = IM_COL32(0, 255, 0, 100);
                } else {
                    color = IM_COL32(255, 255, 255, 255);//不可见
                    fillcolor = IM_COL32(255, 255, 255, 100);
                }
                robotCount += 1;
            }
            //雷达UI
            if (self.moduleControl->playerSwitch.radarStatus) {//圆点
                imDrawList->AddCircleFilled({(float) (self.moduleControl->playerSwitch.radarCoord.x + playerData.radar.x * (self.moduleControl->playerSwitch.radarSize / 100)), (float) (self.moduleControl->playerSwitch.radarCoord.y + playerData.radar.y * (self.moduleControl->playerSwitch.radarSize / 100))}, 8, color);
                std::string str = std::to_string(playerData.distance) + "M";//距离
                imDrawList->AddTextX(ImVec2((float) (self.moduleControl->playerSwitch.radarCoord.x + playerData.radar.x * (self.moduleControl->playerSwitch.radarSize / 100) + 12), (float) (self.moduleControl->playerSwitch.radarCoord.y + playerData.radar.y * (self.moduleControl->playerSwitch.radarSize / 100) - 12)), color, 24, str.c_str());
            }
            //判断是否在屏幕内
            if (playerData.screen.x - hpWidth < screenSize.width && playerData.screen.x + hpWidth > 0 && playerData.screen.y > 0 && playerData.screen.y < screenSize.height) {
                if (self.moduleControl->playerSwitch.infoStatus) {
                    //底边边距
             //       int infoBottomMargin = playerData.distance / 7 + 5;
                    if (!playerData.robot) {
                    //血条
                    if (playerData.hp<=1) {//255, 165, 0)
                    imDrawList->AddRectFilled({playerData.screen.x-20 - hpWidth, playerData.screen.y - playerData.size.y-5  - hpHeight}, {playerData.screen.x - hpWidth + (hpWidth * 2) , playerData.screen.y - playerData.size.y-2}, ImColor(255, 165, 0));
                    } else {
                    imDrawList->AddRectFilled({playerData.screen.x-20 - hpWidth, playerData.screen.y - playerData.size.y-5  - hpHeight}, {playerData.screen.x - hpWidth + (hpWidth * 2) * playerData.hp / 100, playerData.screen.y - playerData.size.y-2}, ImColor(255, 0, 0));
                    }//255, 0, 0
                    //血条边框
                    imDrawList->AddRectFilled({playerData.screen.x+120 - xtWidth, playerData.screen.y - playerData.size.y-8 - hpHeight1}, {playerData.screen.x-120 + xtWidth, playerData.screen.y - playerData.size.y-10}, ImColor(49, 108, 91));
                    imDrawList->AddRectFilled({playerData.screen.x-120 - xtWidth, playerData.screen.y - playerData.size.y-8 - hpHeight1}, {playerData.screen.x-90 + xtWidth, playerData.screen.y - playerData.size.y-10}, ImColor(49, 108, 91));
                    //imDrawList->AddRect({playerData.screen.x - xtWidth, playerData.screen.y - playerData.size.y-10  - hpHeight}, {playerData.screen.x + xtWidth, playerData.screen.y - playerData.size.y-10}, ImColor(0, 0, 0, 255),0.0f, 0, 2.0f);
                    //imDrawList->AddRect({playerData.screen.x-20 - xtWidth, playerData.screen.y - playerData.size.y-10  - hpHeight}, {playerData.screen.x-20 + xtWidth, playerData.screen.y - playerData.size.y-10 }, ImColor(0, 0, 0, 255),0.0f, 0, 2.0f);
                    //imDrawList->AddRect({playerData.screen.x-40 - xtWidth, playerData.screen.y - playerData.size.y-10 - hpHeight}, {playerData.screen.x-40 + xtWidth, playerData.screen.y - playerData.size.y-10 }, ImColor(0, 0, 0, 255),0.0f, 0, 2.0f);
                    //名字,对编



                    string str3 = playerData.name;
                    imDrawList->AddTextX(ImVec2(playerData.screen.x+30-hpWidth + hpHeight + 4, playerData.screen.y - playerData.size.y-25  - hpHeight / 2 - 12), ImColor(255, 255, 255, 255), 30, str3.c_str());
                    imDrawList->AddTextX(ImVec2(playerData.screen.x+29-hpWidth + hpHeight + 4, playerData.screen.y - playerData.size.y-25  - hpHeight / 2 - 12), ImColor(255, 255, 255), 30, str3.c_str());



                    std::string str2 = std::to_string(playerData.team);
                    imDrawList->AddTextX(ImVec2(playerData.screen.x-25-hpWidth + hpHeight + 7, playerData.screen.y - playerData.size.y-25  - hpHeight / 2 - 12), ImColor(255, 255, 255, 255), 30, str2.c_str());
                    imDrawList->AddTextX(ImVec2(playerData.screen.x-25-hpWidth + hpHeight + 7, playerData.screen.y - playerData.size.y-25  - hpHeight / 2 - 12), ImColor(255, 255, 255), 30, str2.c_str());



                    string str = std::to_string(playerData.distance) + "M";
                    imDrawList->AddTextX(ImVec2(playerData.bonesData.rknee.x-22 - calcTextSize(std::to_string(playerData.distance).c_str(), 20) / 6, playerData.bonesData.rknee.y+21 - hpHeight ), ImColor(0, 0, 0, 255), 23, str.c_str());
                    imDrawList->AddTextX(ImVec2(playerData.bonesData.rknee.x-23 - calcTextSize(std::to_string(playerData.distance).c_str(), 20) / 6, playerData.bonesData.rknee.y+20 - hpHeight ), ImColor(255, 255, 0), 23, str.c_str());


                } else {
                    if (playerData.hp<=1) {
                    imDrawList->AddRectFilled({playerData.screen.x-20 - hpWidth, playerData.screen.y - playerData.size.y-5  - hpHeight}, {playerData.screen.x - hpWidth + (hpWidth * 2) , playerData.screen.y - playerData.size.y-2}, ImColor(255, 165, 0));
                    } else {
                    imDrawList->AddRectFilled({playerData.screen.x-20 - hpWidth, playerData.screen.y - playerData.size.y-5  - hpHeight}, {playerData.screen.x - hpWidth + (hpWidth * 2) * playerData.hp / 100, playerData.screen.y - playerData.size.y-2}, ImColor(255, 255, 255));
                    }
                    //血条边框
                    imDrawList->AddRectFilled({playerData.screen.x+120 - xtWidth, playerData.screen.y - playerData.size.y-8 - hpHeight1}, {playerData.screen.x-120 + xtWidth, playerData.screen.y - playerData.size.y-10}, ImColor(49, 108, 91));
                    imDrawList->AddRectFilled({playerData.screen.x-120 - xtWidth, playerData.screen.y - playerData.size.y-8 - hpHeight1}, {playerData.screen.x-90 + xtWidth, playerData.screen.y - playerData.size.y-10}, ImColor(49, 108, 91));
                    //imDrawList->AddRect({playerData.screen.x - xtWidth, playerData.screen.y - playerData.size.y-10  - hpHeight}, {playerData.screen.x + xtWidth, playerData.screen.y - playerData.size.y-10}, ImColor(0, 0, 0, 255),0.0f, 0, 2.0f);
                    //imDrawList->AddRect({playerData.screen.x-20 - xtWidth, playerData.screen.y - playerData.size.y-10  - hpHeight}, {playerData.screen.x-20 + xtWidth, playerData.screen.y - playerData.size.y-10 }, ImColor(0, 0, 0, 255),0.0f, 0, 2.0f);
                    //imDrawList->AddRect({playerData.screen.x-40 - xtWidth, playerData.screen.y - playerData.size.y-10 - hpHeight}, {playerData.screen.x-40 + xtWidth, playerData.screen.y - playerData.size.y-10 }, ImColor(0, 0, 0, 255),0.0f, 0, 2.0f);
                    
                    
                    //名字,对编


                    string str3 = playerData.name;
                    imDrawList->AddTextX(ImVec2(playerData.screen.x+30-hpWidth + hpHeight + 4, playerData.screen.y - playerData.size.y-25  - hpHeight / 2 - 12), ImColor(255, 255, 255, 255), 30, str3.c_str());
                    imDrawList->AddTextX(ImVec2(playerData.screen.x+29-hpWidth + hpHeight + 4, playerData.screen.y - playerData.size.y-25  - hpHeight / 2 - 12), ImColor(255, 255, 255), 30, str3.c_str());


                   std::string str2 = std::to_string(playerData.team);
                    imDrawList->AddTextX(ImVec2(playerData.screen.x-25-hpWidth + hpHeight + 7, playerData.screen.y - playerData.size.y-25  - hpHeight / 2 - 12), ImColor(255, 255, 255, 255), 30, str2.c_str());
                    imDrawList->AddTextX(ImVec2(playerData.screen.x-25-hpWidth + hpHeight + 7, playerData.screen.y - playerData.size.y-25  - hpHeight / 2 - 12), ImColor(255, 255, 255), 30, str2.c_str());

                    //距离
                    string str = std::to_string(playerData.distance) + "M";
                    imDrawList->AddTextX(ImVec2(playerData.bonesData.rknee.x-22 - calcTextSize(std::to_string(playerData.distance).c_str(), 20) / 6, playerData.bonesData.rknee.y+21  - hpHeight ), ImColor(0, 0, 0, 255), 23, str.c_str());
                    imDrawList->AddTextX(ImVec2(playerData.bonesData.rknee.x-23 - calcTextSize(std::to_string(playerData.distance).c_str(), 20) / 6, playerData.bonesData.rknee.y+20  - hpHeight ), ImColor(255, 255, 255), 23, str.c_str());

            }
                   //手持武器文字
           if (self.moduleControl->playerSwitch.SCWZStatus) {
                    imDrawList->AddTextX(ImVec2(playerData.screen.x+4 - calcTextSize(playerData.weaponName.c_str(), 20) / 2, playerData.screen.y - playerData.size.y-19  - hpHeight- 32), ImColor(0, 0, 0, 255), 20, playerData.weaponName.c_str());
                    imDrawList->AddTextX(ImVec2(playerData.screen.x+3 - calcTextSize(playerData.weaponName.c_str(), 20) / 2, playerData.screen.y - playerData.size.y-20  - hpHeight- 32), ImColor(255, 255, 255), 20, playerData.weaponName.c_str());
                    
                    imDrawList->AddTextX(ImVec2(playerData.screen.x+4 - calcTextSize(playerData.statusName.c_str(), 20) / 2, playerData.screen.y - playerData.size.y-39  - hpHeight- 32), ImColor(0, 0, 0, 255), 20, playerData.statusName.c_str());
                    imDrawList->AddTextX(ImVec2(playerData.screen.x+3 - calcTextSize(playerData.statusName.c_str(), 20) / 2, playerData.screen.y - playerData.size.y-40  - hpHeight- 32), ImColor(0, 191, 255), 20, playerData.statusName.c_str());
                   
              
           }
                   //手持武器文字
           if (self.moduleControl->playerSwitch.SCWZStatus) {
                    imDrawList->AddTextX(ImVec2(playerData.screen.x+4 - calcTextSize(playerData.weaponName.c_str(), 20) / 2, playerData.screen.y - playerData.size.y-19  - hpHeight- 32), ImColor(0, 0, 0, 255), 27, playerData.weaponName.c_str());
                    imDrawList->AddTextX(ImVec2(playerData.screen.x+3 - calcTextSize(playerData.weaponName.c_str(), 20) / 2, playerData.screen.y - playerData.size.y-20  - hpHeight- 32), ImColor(255, 255, 255), 27, playerData.weaponName.c_str());
                    
                    imDrawList->AddTextX(ImVec2(playerData.screen.x+4 - calcTextSize(playerData.statusName.c_str(), 20) / 2, playerData.screen.y - playerData.size.y-39  - hpHeight- 32), ImColor(0, 0, 0, 255), 27, playerData.statusName.c_str());
                    imDrawList->AddTextX(ImVec2(playerData.screen.x+3 - calcTextSize(playerData.statusName.c_str(), 20) / 2, playerData.screen.y - playerData.size.y-40  - hpHeight- 32), ImColor(0, 191, 255), 27, playerData.statusName.c_str());
                   
              
           }
                    //手持武器贴图
            if (self.moduleControl->playerSwitch.SCStatus) {
                if (playerData.weaponName=="FIST") {
                   imDrawList->AddImage((__bridge ImTextureID) quanTexture, ImVec2(playerData.screen.x+200 - qtWidth+1, playerData.screen.y-30 - playerData.size.y -5 - qtHeight+1), ImVec2(playerData.screen.x+200 - qtWidth+1 + qtHeight-2 , playerData.screen.y-30 - playerData.size.y -5 - qtHeight + qtHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                   }
                if (playerData.weaponName=="[MG]DP28") {
                   imDrawList->AddImage((__bridge ImTextureID) DP28Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[MG]M249") {
                   imDrawList->AddImage((__bridge ImTextureID) M249Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[MG]MG3") {
                   imDrawList->AddImage((__bridge ImTextureID) MG3Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SHOTGUN]S686") {
                   imDrawList->AddImage((__bridge ImTextureID) S686Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SHOTGUN]DBS") {
                   imDrawList->AddImage((__bridge ImTextureID) DBSTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SHOTGUN]S12K") {
                   imDrawList->AddImage((__bridge ImTextureID) S12KTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                     }
                if (playerData.weaponName=="[SMG]Bison") {
                   imDrawList->AddImage((__bridge ImTextureID) YNTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[RIFLE]QBZ") {
                   imDrawList->AddImage((__bridge ImTextureID) QBZTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[RIFLE]M416") {
                   imDrawList->AddImage((__bridge ImTextureID) M416Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[RIFLE]QBU") {
                   imDrawList->AddImage((__bridge ImTextureID) QBUTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SAR]SLR") {
                   imDrawList->AddImage((__bridge ImTextureID) SLRTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SAR]SKS") {
                   imDrawList->AddImage((__bridge ImTextureID) SKSTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SAR]Mini14") {
                   imDrawList->AddImage((__bridge ImTextureID) MINITexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SNIPER]M24") {
                   imDrawList->AddImage((__bridge ImTextureID) M24Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SNIPER]Kar98k") {
                   imDrawList->AddImage((__bridge ImTextureID) K98Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SNIPER]AWM") {
                   imDrawList->AddImage((__bridge ImTextureID) AWMTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SAR]Mk14") {
                   imDrawList->AddImage((__bridge ImTextureID) MK14Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SNIPER]Mosin Nagant") {
                   imDrawList->AddImage((__bridge ImTextureID) MOTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SAR]VSS") {
                   imDrawList->AddImage((__bridge ImTextureID) VSSTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                
                if (playerData.weaponName=="[RIFLE]M762") {
                   imDrawList->AddImage((__bridge ImTextureID) M762Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[RIFLE]SCAR-L") {
                   imDrawList->AddImage((__bridge ImTextureID) SCARTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[RIFLE]M16A4") {
                   imDrawList->AddImage((__bridge ImTextureID) M16Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[RIFLE]Mk47") {
                   imDrawList->AddImage((__bridge ImTextureID) MK47Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[RIFLE]Groza") {
                   imDrawList->AddImage((__bridge ImTextureID) GrozaTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[RIFLE]AUG") {
                   imDrawList->AddImage((__bridge ImTextureID) AUGTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[RIFLE]AKM") {
                   imDrawList->AddImage((__bridge ImTextureID) AkmTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                
                if (playerData.weaponName=="[WARNING]GRENADE1") {
                   imDrawList->AddImage((__bridge ImTextureID) leiTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[WARNING]SMOKE") {
                   imDrawList->AddImage((__bridge ImTextureID) yanTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[WARNING]MOLOTOV") {
                   imDrawList->AddImage((__bridge ImTextureID) huoTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                
                if (playerData.weaponName=="[MELEE]PAN") {
                   imDrawList->AddImage((__bridge ImTextureID) GUOTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                
                if (playerData.weaponName=="[MELEE]SICKLE") {
                   imDrawList->AddImage((__bridge ImTextureID) LIANTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                
                if (playerData.weaponName=="[MELEE]MACHETE") {
                   imDrawList->AddImage((__bridge ImTextureID) DAOTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[MELEE]CROWBAR") {
                   imDrawList->AddImage((__bridge ImTextureID) GUNTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SMG]MP5K") {
                   imDrawList->AddImage((__bridge ImTextureID) MP5KTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SMG]TommyGun") {
                   imDrawList->AddImage((__bridge ImTextureID) TANGTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SMG]UMP9") {
                   imDrawList->AddImage((__bridge ImTextureID) UMP9Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                
                if (playerData.weaponName=="[SMG]Uzi") {
                   imDrawList->AddImage((__bridge ImTextureID) UZITexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[SMG]Vector") {
                   imDrawList->AddImage((__bridge ImTextureID) VKTTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                
                if (playerData.weaponName=="[PISTOL]P92") {
                   imDrawList->AddImage((__bridge ImTextureID) P92Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[PISTOL]P1911") {
                   imDrawList->AddImage((__bridge ImTextureID) P1911Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[PISTOL]R1895") {
                   imDrawList->AddImage((__bridge ImTextureID) R1895Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[PISTOL]P18C") {
                   imDrawList->AddImage((__bridge ImTextureID) P18CTexture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                if (playerData.weaponName=="[PISTOL]R45") {
                   imDrawList->AddImage((__bridge ImTextureID) R45Texture, ImVec2(playerData.screen.x+160 - scWidth+1, playerData.screen.y+2 - playerData.size.y -5 - scHeight+1), ImVec2(playerData.screen.x+160 - scWidth+1 + scHeight-2 , playerData.screen.y+2 - playerData.size.y -5 - scHeight + scHeight-1), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
                }
                
                }
              
                }


//绘制射线
                if (self.moduleControl->playerSwitch.lineStatus) {
                    if (playerData.hp<=1){
                    imDrawList->AddLine(ImVec2(screenSize.width / 2, 120), ImVec2(playerData.screen.x, playerData.screen.y - playerData.size.y-90), ImColor(255,165,0), 2.0f);
                }else{
                    imDrawList->AddLine(ImVec2(screenSize.width / 2, 120), ImVec2(playerData.screen.x, playerData.screen.y - playerData.size.y-90), color, 2.0f);
                }
                }

                //绘制方框
                if (self.moduleControl->playerSwitch.boxStatus) {
                       if (playerData.hp<=1){
                    imDrawList->AddRect({playerData.screen.x - playerData.size.x, playerData.screen.y - playerData.size.y}, {playerData.screen.x + playerData.size.x, playerData.screen.y + playerData.size.y}, ImColor(255,165,0), 10.0f, 0, 2.0f);
                }else{
                    imDrawList->AddRect({playerData.screen.x - playerData.size.x, playerData.screen.y - playerData.size.y}, {playerData.screen.x + playerData.size.x, playerData.screen.y + playerData.size.y}, ImColor(255,165,0), 10.0f, 0, 2.0f);
                }
                }

if (self.moduleControl->playerSwitch.fillStatus) {
                       if (playerData.hp<=1){
imDrawList->AddRectFilled({playerData.screen.x - playerData.size.x, playerData.screen.y - playerData.size.y}, {playerData.screen.x + playerData.size.x, playerData.screen.y + playerData.size.y}, fillcolor , 10.0f, 0);
                }else{
imDrawList->AddRectFilled({playerData.screen.x - playerData.size.x, playerData.screen.y - playerData.size.y}, {playerData.screen.x + playerData.size.x, playerData.screen.y + playerData.size.y}, fillcolor , 10.0f, 0);
                }
                }
                //绘制骨骼
                if (self.moduleControl->playerSwitch.boneStatus) {

                    imDrawList->AddLine({playerData.bonesData.head.x, playerData.bonesData.head.y}, {playerData.bonesData.pit.x, playerData.bonesData.pit.y}, color, 2.0f);//голова > грудь
                    imDrawList->AddLine({playerData.bonesData.pit.x, playerData.bonesData.pit.y}, {playerData.bonesData.pelvis.x, playerData.bonesData.pelvis.y}, color, 2.0f);//грудь > таз
                    
                    imDrawList->AddLine({playerData.bonesData.pit.x, playerData.bonesData.pit.y}, {playerData.bonesData.lcollar.x, playerData.bonesData.lcollar.y}, color, 2.0f);//грудь > левое плечо
                    imDrawList->AddLine({playerData.bonesData.lcollar.x, playerData.bonesData.lcollar.y}, {playerData.bonesData.lelbow.x, playerData.bonesData.lelbow.y}, color,2.0f);//левое плечо > левый локоть
                    imDrawList->AddLine({playerData.bonesData.lelbow.x, playerData.bonesData.lelbow.y}, {playerData.bonesData.lwrist.x, playerData.bonesData.lwrist.y}, color, 2.0f);//левый локоть > левое запястье 
                    
                    imDrawList->AddLine({playerData.bonesData.pit.x, playerData.bonesData.pit.y}, {playerData.bonesData.rcollar.x, playerData.bonesData.rcollar.y}, color, 2.0f);//грудь > правое плечо 
                    imDrawList->AddLine({playerData.bonesData.rcollar.x, playerData.bonesData.rcollar.y}, {playerData.bonesData.relbow.x, playerData.bonesData.relbow.y}, color, 2.0f);//правое плечо > правый локоть
                    imDrawList->AddLine({playerData.bonesData.relbow.x, playerData.bonesData.relbow.y}, {playerData.bonesData.rwrist.x, playerData.bonesData.rwrist.y}, color,2.0f);//правый локоть > правое запястье 
                    
                    imDrawList->AddLine({playerData.bonesData.pelvis.x, playerData.bonesData.pelvis.y}, {playerData.bonesData.lthigh.x, playerData.bonesData.lthigh.y}, color,2.0f);//таз > левое бедро
                    imDrawList->AddLine({playerData.bonesData.lthigh.x, playerData.bonesData.lthigh.y}, {playerData.bonesData.lknee.x, playerData.bonesData.lknee.y}, color, 2.0f);//левое бедро > левое колено 
                    imDrawList->AddLine({playerData.bonesData.lknee.x, playerData.bonesData.lknee.y}, {playerData.bonesData.lankle.x, playerData.bonesData.lankle.y}, color, 2.0f);//левое колено > левая ступня
                    
                    imDrawList->AddLine({playerData.bonesData.pelvis.x, playerData.bonesData.pelvis.y}, {playerData.bonesData.rthigh.x, playerData.bonesData.rthigh.y}, color, 2.0f);//таз > правое бедро
                    imDrawList->AddLine({playerData.bonesData.rthigh.x, playerData.bonesData.rthigh.y}, {playerData.bonesData.rknee.x, playerData.bonesData.rknee.y}, color, 2.0f);//правое бедро > правое колено 
                    imDrawList->AddLine({playerData.bonesData.rknee.x, playerData.bonesData.rknee.y}, {playerData.bonesData.rankle.x, playerData.bonesData.rankle.y}, color, 2.0f);//правое колено > правая ступня
                }
                } else if (self.moduleControl->playerSwitch.backStatus) {//背敌预警
                ImVec2 backAngle = rotateCoord(playerData.angle,ImVec2(320, 0));
                
                ImVec2 backAngle1 = rotateCoord(playerData.angle, ImVec2(325, 0));
                
                ImVec2 triangle1;
                triangle1 = rotateCoord(playerData.angle - 90, ImVec2(30, 0));
                triangle1.x += screenSize.width / 2 + backAngle.x;
                triangle1.y += screenSize.height / 2 + backAngle.y;

                ImVec2 triangle;
                triangle = rotateCoord(playerData.angle, ImVec2(40, 0));
                triangle.x += screenSize.width / 2 + backAngle.x;
                triangle.y += screenSize.height / 2 + backAngle.y;

                ImVec2 triangle2;
                triangle2 = rotateCoord(playerData.angle + 90, ImVec2(30, 0));
                triangle2.x += screenSize.width / 2 + backAngle.x;
                triangle2.y += screenSize.height / 2 + backAngle.y;
                    
                if(playerData.hp<=1){
                imDrawList->AddTriangleFilled(triangle1, triangle, triangle2, ImColor(255,165,0));//三角形
                imDrawList->AddTriangle(triangle1, triangle, triangle2, ImColor(0, 0, 0, 255),2);
                }else{
                imDrawList->AddTriangleFilled(triangle1, triangle, triangle2, color);//三角形
                imDrawList->AddTriangle(triangle1, triangle, triangle2, ImColor(0, 0, 0, 255),2);
                }
                std::string str = std::to_string(playerData.distance);
                if (!playerData.robot) {//真人
                    if (color == ImColor(255, 255, 0)) {
                        imDrawList->AddTextX(ImVec2(screenSize.width / 2+1.5 + backAngle1.x - calcTextSize(str.c_str(), 40) / 2, screenSize.height / 2 + backAngle.y - 14.5), ImColor(0, 0, 0, 255), 30, str.c_str());
                        imDrawList->AddTextX(ImVec2(screenSize.width / 2 + backAngle1.x - calcTextSize(str.c_str(), 40) / 2, screenSize.height / 2 + backAngle.y - 16), ImColor(255, 0, 0), 30, str.c_str());
                    } else {
                        imDrawList->AddTextX(ImVec2(screenSize.width / 2+1.5 + backAngle1.x - calcTextSize(str.c_str(), 40) / 2, screenSize.height / 2 + backAngle.y - 14.5), ImColor(0, 0, 0, 255), 30, str.c_str());
                        imDrawList->AddTextX(ImVec2(screenSize.width / 2 + backAngle1.x - calcTextSize(str.c_str(), 40) / 2, screenSize.height / 2 + backAngle.y - 16), ImColor(255, 255, 0), 30, str.c_str());
                    
                    }
                } else {
                    if (color == ImColor(0, 255, 0)) {
                        imDrawList->AddTextX(ImVec2(screenSize.width / 2+1.5 + backAngle.x - calcTextSize(str.c_str(), 40) / 2, screenSize.height / 2 + backAngle.y - 14.5), ImColor(0, 0, 0, 255), 36, str.c_str());
                        imDrawList->AddTextX(ImVec2(screenSize.width / 2 + backAngle.x - calcTextSize(str.c_str(), 40) / 2, screenSize.height / 2 + backAngle.y - 16), ImColor(255, 255, 255), 36, str.c_str());
                    } else {
                        imDrawList->AddTextX(ImVec2(screenSize.width / 2+1.5 + backAngle.x - calcTextSize(str.c_str(), 40) / 2, screenSize.height / 2 + backAngle.y - 14.5), ImColor(0, 0, 0, 255), 36, str.c_str());
                        imDrawList->AddTextX(ImVec2(screenSize.width / 2 + backAngle.x - calcTextSize(str.c_str(), 40) / 2, screenSize.height / 2 + backAngle.y - 16), ImColor(0, 255, 0), 36, str.c_str());
                    }
                }
            }
        }
        //绘制人数
        
        /*
        imDrawList->AddImage((__bridge ImTextureID) count4Texture, ImVec2(screenSize.width / 2 - count4Texture.width / 2, 60), ImVec2(screenSize.width / 2 + count4Texture.width / 2, 60 + count4Texture.height), ImVec2(0.0f, 0.0f), ImVec2(1.0f, 1.0f));
        */
   if (playerCount == 0 && robotCount == 0) {
    
    const char* safeText = "SAFE";
    float textWidth = calcTextSize(safeText, 70);

    imDrawList->AddTextX(
        ImVec2(screenSize.width / 2 - textWidth / 2 + 2, 100 + 2),
        ImColor(0,0,0,255),
        70,
        safeText
    );

    imDrawList->AddTextX(
        ImVec2(screenSize.width / 2 - textWidth / 2, 100),
        ImColor(0,255,0),
        70,
        safeText
    );

} else {

    std::string playerText = "Player : " + std::to_string(playerCount);
    std::string botText = "Bot : " + std::to_string(robotCount);

    float playerWidth = calcTextSize(playerText.c_str(), 70);
    float botWidth = calcTextSize(botText.c_str(), 70);

    float totalWidth = playerWidth + 60 + botWidth;
    float startX = screenSize.width / 2 - totalWidth / 2;

    // PLAYER TEXT
    imDrawList->AddTextX(
        ImVec2(startX + 2, 100 + 2),
        ImColor(0,0,0,255),
        70,
        playerText.c_str()
    );

    imDrawList->AddTextX(
        ImVec2(startX, 100),
        ImColor(255,0,0),
        70,
        playerText.c_str()
    );

    // BOT TEXT
    float botX = startX + playerWidth + 60;

    imDrawList->AddTextX(
        ImVec2(botX + 2, 100 + 2),
        ImColor(0,0,0,255),
        70,
        botText.c_str()
    );

    imDrawList->AddTextX(
        ImVec2(botX, 100),
        ImColor(0,255,0),
        70,
        botText.c_str()
    );
}
   }
        if (self.moduleControl->mainSwitch.aimbotStatus) {
        if (self.moduleControl->aimbotController.showAimbotRadius) {
            //自瞄圆圈
            imDrawList->AddCircle(ImVec2(screenSize.width / 2, screenSize.height / 2), self.moduleControl->aimbotController.aimbotRadius, ImColor(0, 255, 255), 0, 1.0f);
        }
    }
             
             
    
         ImGui::End();
}

-(void)initImageTexture: (id<MTLDevice>)device {
    NSData *countData = [[NSData alloc] initWithBase64EncodedString:countDataBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    countTexture = [self loadImageTexture : device : (void*)[countData bytes] : [countData length]];
    
    NSData *countData1 = [[NSData alloc] initWithBase64EncodedString:countData1Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    count1Texture = [self loadImageTexture : device : (void*)[countData1 bytes] : [countData1 length]];
    
    NSData *countData2 = [[NSData alloc] initWithBase64EncodedString:countData2Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    count2Texture = [self loadImageTexture : device : (void*)[countData2 bytes] : [countData2 length]];
    
    NSData *countData3 = [[NSData alloc] initWithBase64EncodedString:countData3Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    count3Texture = [self loadImageTexture : device : (void*)[countData3 bytes] : [countData3 length]];
    
    NSData *countData4 = [[NSData alloc] initWithBase64EncodedString:countData4Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    count4Texture = [self loadImageTexture : device : (void*)[countData4 bytes] : [countData4 length]];
    
    NSData *countData5 = [[NSData alloc] initWithBase64EncodedString:countData5Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    count5Texture = [self loadImageTexture : device : (void*)[countData5 bytes] : [countData5 length]];
    
    NSData *quan = [[NSData alloc] initWithBase64EncodedString:quanBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    quanTexture = [self loadImageTexture : device : (void*)[quan bytes] : [quan length]];
    
    NSData *shoulei = [[NSData alloc] initWithBase64EncodedString:shouleiBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    shouleiTexture = [self loadImageTexture : device : (void*)[shoulei bytes] : [shoulei length]];
    
    NSData *playerData = [[NSData alloc] initWithBase64EncodedString:playerDataBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    playerTexture = [self loadImageTexture : device : (void*)[playerData bytes] : [playerData length]];
    
    NSData *robotData = [[NSData alloc] initWithBase64EncodedString:robotDataBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    robotTexture = [self loadImageTexture : device : (void*)[robotData bytes] : [robotData length]];
    //手持武器
    NSData *M416 = [[NSData alloc] initWithBase64EncodedString:M416Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    M416Texture = [self loadImageTexture : device : (void*)[M416 bytes] : [M416 length]];
    
    NSData *M16 = [[NSData alloc] initWithBase64EncodedString:M16Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    M16Texture = [self loadImageTexture : device : (void*)[M16 bytes] : [M16 length]];

    NSData *Groza = [[NSData alloc] initWithBase64EncodedString:GrozaBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    GrozaTexture = [self loadImageTexture : device : (void*)[Groza bytes] : [Groza length]];

    NSData *Akm = [[NSData alloc] initWithBase64EncodedString:AkmBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    AkmTexture = [self loadImageTexture : device : (void*)[Akm bytes] : [Akm length]];

    NSData *SCAR = [[NSData alloc] initWithBase64EncodedString:SCARBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    SCARTexture = [self loadImageTexture : device : (void*)[SCAR bytes] : [SCAR length]];

    NSData *MK47 = [[NSData alloc] initWithBase64EncodedString:MK47Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    MK47Texture = [self loadImageTexture : device : (void*)[MK47 bytes] : [MK47 length]];

    NSData *AUG = [[NSData alloc] initWithBase64EncodedString:AUGBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    AUGTexture = [self loadImageTexture : device : (void*)[AUG bytes] : [AUG length]];

    NSData *M762 = [[NSData alloc] initWithBase64EncodedString:M762Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    M762Texture = [self loadImageTexture : device : (void*)[M762 bytes] : [M762 length]];
    
    NSData *QBZ = [[NSData alloc] initWithBase64EncodedString:QBZBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    QBZTexture = [self loadImageTexture : device : (void*)[QBZ bytes] : [QBZ length]];
    
    NSData *lei = [[NSData alloc] initWithBase64EncodedString:leiBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    leiTexture = [self loadImageTexture : device : (void*)[lei bytes] : [lei length]];
  
    NSData *huo = [[NSData alloc] initWithBase64EncodedString:huoBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    huoTexture = [self loadImageTexture : device : (void*)[huo bytes] : [huo length]];

    NSData *yan = [[NSData alloc] initWithBase64EncodedString:yanBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    yanTexture = [self loadImageTexture : device : (void*)[yan bytes] : [yan length]];

    NSData *shan = [[NSData alloc] initWithBase64EncodedString:shanBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    shanTexture = [self loadImageTexture : device : (void*)[shan bytes] : [shan length]];

    NSData *R1895 = [[NSData alloc] initWithBase64EncodedString:R1895Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    R1895Texture = [self loadImageTexture : device : (void*)[R1895 bytes] : [R1895 length]];

    NSData *P92 = [[NSData alloc] initWithBase64EncodedString:P92Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    P92Texture = [self loadImageTexture : device : (void*)[P92 bytes] : [P92 length]];

    NSData *P1911 = [[NSData alloc] initWithBase64EncodedString:P1911Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    P1911Texture = [self loadImageTexture : device : (void*)[P1911 bytes] : [P1911 length]];

    NSData *P18C = [[NSData alloc] initWithBase64EncodedString:P18CBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    P18CTexture = [self loadImageTexture : device : (void*)[P18C bytes] : [P18C length]];

    NSData *R45 = [[NSData alloc] initWithBase64EncodedString:R45Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    R45Texture = [self loadImageTexture : device : (void*)[R45 bytes] : [R45 length]];
 
    NSData *SKS = [[NSData alloc] initWithBase64EncodedString:SKSBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    SKSTexture = [self loadImageTexture : device : (void*)[SKS bytes] : [SKS length]];

    NSData *MINI = [[NSData alloc] initWithBase64EncodedString:MINIBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    MINITexture = [self loadImageTexture : device : (void*)[MINI bytes] : [MINI length]];

    NSData *MK14 = [[NSData alloc] initWithBase64EncodedString:MK14Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    MK14Texture = [self loadImageTexture : device : (void*)[MK14 bytes] : [MK14 length]];

    NSData *VSS = [[NSData alloc] initWithBase64EncodedString:VSSBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    VSSTexture = [self loadImageTexture : device : (void*)[VSS bytes] : [VSS length]];

    NSData *QBU = [[NSData alloc] initWithBase64EncodedString:QBUBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    QBUTexture = [self loadImageTexture : device : (void*)[QBU bytes] : [QBU length]];

    NSData *SLR = [[NSData alloc] initWithBase64EncodedString:SLRBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    SLRTexture = [self loadImageTexture : device : (void*)[SLR bytes] : [SLR length]];

    NSData *AWM = [[NSData alloc] initWithBase64EncodedString:AWMBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    AWMTexture = [self loadImageTexture : device : (void*)[AWM bytes] : [AWM length]];

    NSData *K98 = [[NSData alloc] initWithBase64EncodedString:K98Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    K98Texture = [self loadImageTexture : device : (void*)[K98 bytes] : [K98 length]];

    NSData *MO = [[NSData alloc] initWithBase64EncodedString:MOBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    MOTexture = [self loadImageTexture : device : (void*)[MO bytes] : [MO length]];

    NSData *LIAN = [[NSData alloc] initWithBase64EncodedString:LIANBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    LIANTexture = [self loadImageTexture : device : (void*)[LIAN bytes] : [LIAN length]];

    NSData *GUN = [[NSData alloc] initWithBase64EncodedString:GUNBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    GUNTexture = [self loadImageTexture : device : (void*)[GUN bytes] : [GUN length]];
 
    NSData *DAO = [[NSData alloc] initWithBase64EncodedString:DAOBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    DAOTexture = [self loadImageTexture : device : (void*)[DAO bytes] : [DAO length]];

    NSData *GUO = [[NSData alloc] initWithBase64EncodedString:GUOBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    GUOTexture = [self loadImageTexture : device : (void*)[GUO bytes] : [GUO length]];

    NSData *UZI = [[NSData alloc] initWithBase64EncodedString:UZIBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UZITexture = [self loadImageTexture : device : (void*)[UZI bytes] : [UZI length]];

    NSData *TANG = [[NSData alloc] initWithBase64EncodedString:TANGBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    TANGTexture = [self loadImageTexture : device : (void*)[TANG bytes] : [TANG length]];

    NSData *VKT = [[NSData alloc] initWithBase64EncodedString:VKTBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    VKTTexture = [self loadImageTexture : device : (void*)[VKT bytes] : [VKT length]];

    NSData *MP5K = [[NSData alloc] initWithBase64EncodedString:MP5KBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    MP5KTexture = [self loadImageTexture : device : (void*)[MP5K bytes] : [MP5K length]];

    NSData *UMP9 = [[NSData alloc] initWithBase64EncodedString:UMP9Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UMP9Texture = [self loadImageTexture : device : (void*)[UMP9 bytes] : [UMP9 length]];

    NSData *YN = [[NSData alloc] initWithBase64EncodedString:YNBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    YNTexture = [self loadImageTexture : device : (void*)[YN bytes] : [YN length]];
    
    NSData *M24 = [[NSData alloc] initWithBase64EncodedString:M24Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    M24Texture = [self loadImageTexture : device : (void*)[M24 bytes] : [M24 length]];

    NSData *DP28 = [[NSData alloc] initWithBase64EncodedString:DP28Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    DP28Texture = [self loadImageTexture : device : (void*)[DP28 bytes] : [DP28 length]];

    NSData *MG3 = [[NSData alloc] initWithBase64EncodedString:MG3Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    MG3Texture = [self loadImageTexture : device : (void*)[MG3 bytes] : [MG3 length]];

    NSData *M249 = [[NSData alloc] initWithBase64EncodedString:M249Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    M249Texture = [self loadImageTexture : device : (void*)[M249 bytes] : [M249 length]];

    NSData *DBS = [[NSData alloc] initWithBase64EncodedString:DBSBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    DBSTexture = [self loadImageTexture : device : (void*)[DBS bytes] : [DBS length]];

    NSData *S686 = [[NSData alloc] initWithBase64EncodedString:S686Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    S686Texture = [self loadImageTexture : device : (void*)[S686 bytes] : [S686 length]];

    NSData *S12K = [[NSData alloc] initWithBase64EncodedString:S12KBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    S12KTexture = [self loadImageTexture : device : (void*)[S12K bytes] : [S12K length]];

    //载具
    NSData *JP = [[NSData alloc] initWithBase64EncodedString:JPBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    JPTexture = [self loadImageTexture : device : (void*)[JP bytes] : [JP length]];

    NSData *BB = [[NSData alloc] initWithBase64EncodedString:BBBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    BBTexture = [self loadImageTexture : device : (void*)[BB bytes] : [BB length]];

    NSData *jc = [[NSData alloc] initWithBase64EncodedString:jcBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    jcTexture = [self loadImageTexture : device : (void*)[jc bytes] : [jc length]];
    
    NSData *mtt = [[NSData alloc] initWithBase64EncodedString:mttBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    mttTexture = [self loadImageTexture : device : (void*)[mtt bytes] : [mtt length]];
    
    NSData *mt = [[NSData alloc] initWithBase64EncodedString:mtBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    mtTexture = [self loadImageTexture : device : (void*)[mt bytes] : [mt length]];
    
    NSData *my = [[NSData alloc] initWithBase64EncodedString:myBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    myTexture = [self loadImageTexture : device : (void*)[my bytes] : [my length]];
    
    NSData *R8 = [[NSData alloc] initWithBase64EncodedString:R8Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    R8Texture = [self loadImageTexture : device : (void*)[R8 bytes] : [R8 length]];
    
    NSData *mt3 = [[NSData alloc] initWithBase64EncodedString:mt3Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    mt3Texture = [self loadImageTexture : device : (void*)[mt3 bytes] : [mt3 length]];
    
    NSData *m416 = [[NSData alloc] initWithBase64EncodedString:m416Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    m416Texture = [self loadImageTexture : device : (void*)[m416 bytes] : [m416 length]];

    NSData *akm = [[NSData alloc] initWithBase64EncodedString:akmBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    akmTexture = [self loadImageTexture : device : (void*)[akm bytes] : [akm length]];
    
    NSData *aug = [[NSData alloc] initWithBase64EncodedString:augBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    augTexture = [self loadImageTexture : device : (void*)[aug bytes] : [aug length]];
    
    NSData *groza = [[NSData alloc] initWithBase64EncodedString:grozaBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    grozaTexture = [self loadImageTexture : device : (void*)[groza bytes] : [groza length]];
    
    NSData *m16 = [[NSData alloc] initWithBase64EncodedString:m16Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    m16Texture = [self loadImageTexture : device : (void*)[m16 bytes] : [m16 length]];
    
    NSData *m24 = [[NSData alloc] initWithBase64EncodedString:m24Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    m24Texture = [self loadImageTexture : device : (void*)[m24 bytes] : [m24 length]];
    
    NSData *m249 = [[NSData alloc] initWithBase64EncodedString:m249Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    m249Texture = [self loadImageTexture : device : (void*)[m249 bytes] : [m249 length]];
    
    NSData *m762 = [[NSData alloc] initWithBase64EncodedString:m762Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    m762Texture = [self loadImageTexture : device : (void*)[m762 bytes] : [m762 length]];
    
    NSData *mg3 = [[NSData alloc] initWithBase64EncodedString:mg3Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    mg3Texture = [self loadImageTexture : device : (void*)[mg3 bytes] : [mg3 length]];
    
    NSData *mini = [[NSData alloc] initWithBase64EncodedString:miniBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    miniTexture = [self loadImageTexture : device : (void*)[mini bytes] : [mini length]];
    
    NSData *mk14 = [[NSData alloc] initWithBase64EncodedString:mk14Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    mk14Texture = [self loadImageTexture : device : (void*)[mk14 bytes] : [mk14 length]];
    
    NSData *mk47 = [[NSData alloc] initWithBase64EncodedString:mk47Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    mk47Texture = [self loadImageTexture : device : (void*)[mk47 bytes] : [mk47 length]];
    
    NSData *scar = [[NSData alloc] initWithBase64EncodedString:scarBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    scarTexture = [self loadImageTexture : device : (void*)[scar bytes] : [scar length]];
    
    NSData *slr = [[NSData alloc] initWithBase64EncodedString:slrBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    slrTexture = [self loadImageTexture : device : (void*)[slr bytes] : [slr length]];
    
    NSData *awm = [[NSData alloc] initWithBase64EncodedString:awmBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    awmTexture = [self loadImageTexture : device : (void*)[awm bytes] : [awm length]];
    
    NSData *dp28 = [[NSData alloc] initWithBase64EncodedString:dp28Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    dp28Texture = [self loadImageTexture : device : (void*)[dp28 bytes] : [dp28 length]];
    
    NSData *k98 = [[NSData alloc] initWithBase64EncodedString:k98Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    k98Texture = [self loadImageTexture : device : (void*)[k98 bytes] : [k98 length]];
    
    NSData *vss = [[NSData alloc] initWithBase64EncodedString:vssBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    vssTexture = [self loadImageTexture : device : (void*)[vss bytes] : [vss length]];
    
    NSData *sks = [[NSData alloc] initWithBase64EncodedString:sksBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    sksTexture = [self loadImageTexture : device : (void*)[sks bytes] : [sks length]];
    
    NSData *hz = [[NSData alloc] initWithBase64EncodedString:hzBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    hzTexture = [self loadImageTexture : device : (void*)[hz bytes] : [hz length]];
    
    
    NSData *yl = [[NSData alloc] initWithBase64EncodedString:ylBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    ylTexture = [self loadImageTexture : device : (void*)[yl bytes] : [yl length]];

    NSData *jjb = [[NSData alloc] initWithBase64EncodedString:jjbBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    jjbTexture = [self loadImageTexture : device : (void*)[jjb bytes] : [jjb length]];
    
    NSData *zty = [[NSData alloc] initWithBase64EncodedString:ztyBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    ztyTexture = [self loadImageTexture : device : (void*)[zty bytes] : [zty length]];
    
    NSData *zhen = [[NSData alloc] initWithBase64EncodedString:zhenBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    zhenTexture = [self loadImageTexture : device : (void*)[zhen bytes] : [zhen length]];
    
    NSData *ylx = [[NSData alloc] initWithBase64EncodedString:ylxBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    ylxTexture = [self loadImageTexture : device : (void*)[ylx bytes] : [ylx length]];
    
    NSData *b4 = [[NSData alloc] initWithBase64EncodedString:b4Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    b4Texture = [self loadImageTexture : device : (void*)[b4 bytes] : [b4 length]];

    NSData *b3 = [[NSData alloc] initWithBase64EncodedString:b3Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    b3Texture = [self loadImageTexture : device : (void*)[b3 bytes] : [b3 length]];

    NSData *b6 = [[NSData alloc] initWithBase64EncodedString:b6Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    b6Texture = [self loadImageTexture : device : (void*)[b6 bytes] : [b6 length]];

    NSData *b8 = [[NSData alloc] initWithBase64EncodedString:b8Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    b8Texture = [self loadImageTexture : device : (void*)[b8 bytes] : [b8 length]];

    NSData *kt = [[NSData alloc] initWithBase64EncodedString:ktBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    ktTexture = [self loadImageTexture : device : (void*)[kt bytes] : [kt length]];

    NSData *t3 = [[NSData alloc] initWithBase64EncodedString:t3Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    t3Texture = [self loadImageTexture : device : (void*)[t3 bytes] : [t3 length]];

    NSData *j3 = [[NSData alloc] initWithBase64EncodedString:j3Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    j3Texture = [self loadImageTexture : device : (void*)[j3 bytes] : [j3 length]];

    NSData *bb3 = [[NSData alloc] initWithBase64EncodedString:bb3Base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    bb3Texture = [self loadImageTexture : device : (void*)[bb3 bytes] : [bb3 length]];

    NSData *tlei = [[NSData alloc] initWithBase64EncodedString:tleiBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    tleiTexture = [self loadImageTexture : device : (void*)[tlei bytes] : [tlei length]];

    NSData *tyan = [[NSData alloc] initWithBase64EncodedString:tyanBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    tyanTexture = [self loadImageTexture : device : (void*)[tyan bytes] : [tyan length]];

    NSData *thuo = [[NSData alloc] initWithBase64EncodedString:thuoBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    thuoTexture = [self loadImageTexture : device : (void*)[thuo bytes] : [thuo length]];

    NSData *leizha = [[NSData alloc] initWithBase64EncodedString:leizhaBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    leizhaTexture = [self loadImageTexture : device : (void*)[leizha bytes] : [leizha length]];

    NSData *hongzha = [[NSData alloc] initWithBase64EncodedString:hongzhaBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    hongzhaTexture = [self loadImageTexture : device : (void*)[hongzha bytes] : [hongzha length]];

    NSData *sld = [[NSData alloc] initWithBase64EncodedString:sldBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    sldTexture = [self loadImageTexture : device : (void*)[sld bytes] : [sld length]];

    NSData *ywd = [[NSData alloc] initWithBase64EncodedString:ywdBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    ywdTexture = [self loadImageTexture : device : (void*)[ywd bytes] : [ywd length]];

    NSData *rsp = [[NSData alloc] initWithBase64EncodedString:rspBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    rspTexture = [self loadImageTexture : device : (void*)[rsp bytes] : [rsp length]];


}

-(id<MTLTexture>)loadImageTexture:(id<MTLDevice>)device :(void*) imageData :(size_t) fileDataSize {
    int width, height;
    unsigned char *pixels = stbi_load_from_memory((stbi_uc const *)imageData, (int)fileDataSize, &width, &height, NULL, 4);

    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                                 width:(NSUInteger)width
                                                                                                height:(NSUInteger)height
                                                                                             mipmapped:NO];
    textureDescriptor.usage = MTLTextureUsageShaderRead;
    textureDescriptor.storageMode = MTLStorageModeShared;
    id<MTLTexture> texture = [device newTextureWithDescriptor:textureDescriptor];
    [texture replaceRegion:MTLRegionMake2D(0, 0, (NSUInteger)width, (NSUInteger)height) mipmapLevel:0 withBytes:pixels bytesPerRow:(NSUInteger)width * 4];
    
    return texture;
}


@end
