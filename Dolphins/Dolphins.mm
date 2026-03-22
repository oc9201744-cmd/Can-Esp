if (moduleControl.mainSwitch.playerStatus) {
    for (auto staticPlayerData : staticData.playerDataList) {
        // KENDİNİ ATLA (çift güvenlik)
        if (staticPlayerData.addr == staticData.selfAddr) continue;
        
        ImVec3 objectCoord;
        memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
        
        // ... devam eden kod ...
        
        uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
        if (meshAddr) {
            uintptr_t humanAddr = meshAddr + PubgOffset::ObjectParam::MeshParam::HumanOffset;
            uintptr_t boneAddr = memoryTools.readPtr(meshAddr + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 48;
            
            FullSkeletonBones skeleton = GetFullSkeleton(pov, screenSize, humanAddr, boneAddr);
            
            if (skeleton.isValid) {
                playerData.bonesData.head = skeleton.head;
                playerData.bonesData.pit = skeleton.neck;
                playerData.bonesData.pelvis = skeleton.spine3;
                playerData.bonesData.lcollar = skeleton.leftShoulder;
                playerData.bonesData.rcollar = skeleton.rightShoulder;
                playerData.bonesData.lelbow = skeleton.leftElbow;
                playerData.bonesData.relbow = skeleton.rightElbow;
                playerData.bonesData.lwrist = skeleton.leftWrist;
                playerData.bonesData.rwrist = skeleton.rightWrist;
                playerData.bonesData.lthigh = skeleton.leftHip;
                playerData.bonesData.rthigh = skeleton.rightHip;
                playerData.bonesData.lknee = skeleton.leftKnee;
                playerData.bonesData.rknee = skeleton.rightKnee;
                playerData.bonesData.lankle = skeleton.leftAnkle;
                playerData.bonesData.rankle = skeleton.rightAnkle;
            } else {
                // Skeleton geçersiz, boş verileri atla (çizim yapma)
                // İstersen burada log tut
            }
        }
        playerDataList.push_back(playerData);
    }
}