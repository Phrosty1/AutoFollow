-- For menu & data
AutoFollow = {}
local ADDON_NAME = "AutoFollow"
AutoFollowSavedVariables = AutoFollowSavedVariables or {}
AutoFollow.savedVars = AutoFollowSavedVariables
AutoFollow.savedVars.log = {}
local ptk = LibPixelControl
local GetGameTimeMilliseconds = GetGameTimeMilliseconds
local verbose = false -- true -- false

local pi = math.pi
local targetUnitTag, targetUnitName
local ms_time = GetGameTimeMilliseconds()
local function dmsg(txt)
   if verbose then
      local str = (GetGameTimeMilliseconds() - ms_time) .. ") " .. txt
      d(str)
      ms_time = GetGameTimeMilliseconds()
   end
end
local IsGameCameraUIModeActive = IsGameCameraUIModeActive
local IsCrouching = function() return (GetUnitStealthState("player") ~= STEALTH_STATE_NONE) end
local function dump(o)
   if type(o) == "table" then
      local s = "{"
      for k,v in pairs(o) do
         if type(k) ~= "number" then k = "'"..k.."'" end
         s = s .. "["..k.."]=" .. dump(v) .. ","
      end
      return s .. "}"
   elseif type(o) == "string" then
      return "'"..tostring(o).."'"
   else
      return tostring(o)
   end
end
local function ternary(cond, ifTrue, ifFalse) if cond then return ifTrue else return ifFalse end end
local function GetUnitDetails(unitTag)
   local unit = nil
   if DoesUnitExist(unitTag) then
      unit = {}
      unit.unitPower = {}
      unit.unitPower.curHealth, unit.unitPower.maxHealth = GetUnitPower(unitTag, POWERTYPE_HEALTH)
      unit.unitPower.curMagicka, unit.unitPower.maxMagicka = GetUnitPower(unitTag, POWERTYPE_MAGICKA)
      unit.unitPower.curStamina, unit.unitPower.maxStamina = GetUnitPower(unitTag, POWERTYPE_STAMINA)
      unit.isActivelyEngaged = IsUnitActivelyEngaged(unitTag) -- * IsUnitActivelyEngaged(*string* _unitTag_) ** _Returns:_ *bool* _isActivelyEngaged_
      local numBuffs = GetNumBuffs(unitTag)
      unit.buffs = {}
      if (numBuffs > 0) then
         for i = 1, numBuffs do
            local x = {}
            x.buffName, x.timeStarted, x.timeEnding, x.buffSlot, x.stackCount, x.iconFilename, x.buffType, x.effectType, x.abilityType, x.statusEffectType, x.abilityId, x.canClickOff, x.castByPlayer
                  = GetUnitBuffInfo(unitTag, i) -- * GetUnitBuffInfo(*string* _unitTag_, *luaindex* _buffIndex_) ** _Returns:_ *string* _buffName_, *number* _timeStarted_, *number* _timeEnding_, *integer* _buffSlot_, *integer* _stackCount_, *textureName* _iconFilename_, *string* _buffType_, *[BuffEffectType|#BuffEffectType]* _effectType_, *[AbilityType|#AbilityType]* _abilityType_, *[StatusEffectType|#StatusEffectType]* _statusEffectType_, *integer* _abilityId_, *bool* _canClickOff_, *bool* _castByPlayer_
            unit.buffs[x.buffName] = x
         end
      end

      local extras = {}
      unit.extras = extras
      extras.DoesUnitExist = dump({DoesUnitExist(unitTag)}) -- * DoesUnitExist(*string* _unitTag_) ** _Returns:_ *bool* _exists_
      extras.GetRawUnitName = dump({GetRawUnitName(unitTag)}) -- * GetRawUnitName(*string* _unitTag_) ** _Returns:_ *string* _rawName_
      extras.GetUnitDisplayName = dump({GetUnitDisplayName(unitTag)}) -- * GetUnitDisplayName(*string* _unitTag_) ** _Returns:_ *string* _displayName_
      extras.GetUnitGender = dump({GetUnitGender(unitTag)}) -- * GetUnitGender(*string* _unitTag_) ** _Returns:_ *[Gender|#Gender]* _gender_
      extras.GetUnitClass = dump({GetUnitClass(unitTag)}) -- * GetUnitClass(*string* _unitTag_) ** _Returns:_ *string* _className_
      extras.GetUnitClassId = dump({GetUnitClassId(unitTag)}) -- * GetUnitClassId(*string* _unitTag_) ** _Returns:_ *integer* _classId_
      extras.GetUnitChampionPoints = dump({GetUnitChampionPoints(unitTag)}) -- * GetUnitChampionPoints(*string* _unitTag_) ** _Returns:_ *integer* _championPoints_
      extras.GetUnitEffectiveChampionPoints = dump({GetUnitEffectiveChampionPoints(unitTag)}) -- * GetUnitEffectiveChampionPoints(*string* _unitTag_) ** _Returns:_ *integer* _championPoints_
      extras.CanUnitGainChampionPoints = dump({CanUnitGainChampionPoints(unitTag)}) -- * CanUnitGainChampionPoints(*string* _unitTag_) ** _Returns:_ *bool* _canGainChampionPoints_
      extras.GetUnitEffectiveLevel = dump({GetUnitEffectiveLevel(unitTag)}) -- * GetUnitEffectiveLevel(*string* _unitTag_) ** _Returns:_ *integer* _level_
      extras.GetUnitZone = dump({GetUnitZone(unitTag)}) -- * GetUnitZone(*string* _unitTag_) ** _Returns:_ *string* _zoneName_
      extras.GetUnitWorldPosition = dump({GetUnitWorldPosition(unitTag)}) -- * GetUnitWorldPosition(*string* _unitTag_) ** _Returns:_ *integer* _zoneId_, *integer* _worldX_, *integer* _worldY_, *integer* _worldZ_
      extras.GetUnitRawWorldPosition = dump({GetUnitRawWorldPosition(unitTag)}) -- * GetUnitRawWorldPosition(*string* _unitTag_) ** _Returns:_ *integer* _zoneId_, *integer* _worldX_, *integer* _worldY_, *integer* _worldZ_
      extras.IsUnitWorldMapPositionBreadcrumbed = dump({IsUnitWorldMapPositionBreadcrumbed(unitTag)}) -- * IsUnitWorldMapPositionBreadcrumbed(*string* _unitTag_) ** _Returns:_ *bool* _isBreadcrumb_
      extras.GetUnitXP = dump({GetUnitXP(unitTag)}) -- * GetUnitXP(*string* _unitTag_) ** _Returns:_ *integer* _exp_
      extras.GetUnitXPMax = dump({GetUnitXPMax(unitTag)}) -- * GetUnitXPMax(*string* _unitTag_) ** _Returns:_ *integer* _maxExp_
      extras.IsUnitChampion = dump({IsUnitChampion(unitTag)}) -- * IsUnitChampion(*string* _unitTag_) ** _Returns:_ *bool* _isChampion_
      extras.IsUnitUsingVeteranDifficulty = dump({IsUnitUsingVeteranDifficulty(unitTag)}) -- * IsUnitUsingVeteranDifficulty(*string* _unitTag_) ** _Returns:_ *bool* _isVeteranDifficulty_
      extras.IsUnitBattleLeveled = dump({IsUnitBattleLeveled(unitTag)}) -- * IsUnitBattleLeveled(*string* _unitTag_) ** _Returns:_ *bool* _isBattleLeveled_
      extras.IsUnitChampionBattleLeveled = dump({IsUnitChampionBattleLeveled(unitTag)}) -- * IsUnitChampionBattleLeveled(*string* _unitTag_) ** _Returns:_ *bool* _isChampBattleLeveled_
      extras.GetUnitBattleLevel = dump({GetUnitBattleLevel(unitTag)}) -- * GetUnitBattleLevel(*string* _unitTag_) ** _Returns:_ *integer* _battleLevel_
      extras.GetUnitChampionBattleLevel = dump({GetUnitChampionBattleLevel(unitTag)}) -- * GetUnitChampionBattleLevel(*string* _unitTag_) ** _Returns:_ *integer* _champBattleLevel_
      extras.GetUnitDrownTime = dump({GetUnitDrownTime(unitTag)}) -- * GetUnitDrownTime(*string* _unitTag_) ** _Returns:_ *number* _startTime_, *number* _endTime_
      extras.IsUnitInGroupSupportRange = dump({IsUnitInGroupSupportRange(unitTag)}) -- * IsUnitInGroupSupportRange(*string* _unitTag_) ** _Returns:_ *bool* _result_
      extras.GetUnitType = dump({GetUnitType(unitTag)}) -- * GetUnitType(*string* _unitTag_) ** _Returns:_ *integer* _type_
      extras.CanUnitTrade = dump({CanUnitTrade(unitTag)}) -- * CanUnitTrade(*string* _unitTag_) ** _Returns:_ *bool* _canTrade_
      extras.IsUnitGrouped = dump({IsUnitGrouped(unitTag)}) -- * IsUnitGrouped(*string* _unitTag_) ** _Returns:_ *bool* _isGrouped_
      extras.IsUnitGroupLeader = dump({IsUnitGroupLeader(unitTag)}) -- * IsUnitGroupLeader(*string* _unitTag_) ** _Returns:_ *bool* _isGroupLeader_
      extras.IsGroupMemberInSameWorldAsPlayer = dump({IsGroupMemberInSameWorldAsPlayer(unitTag)}) -- * IsGroupMemberInSameWorldAsPlayer(*string* _unitTag_) ** _Returns:_ *bool* _isInSameWorld_
      extras.IsGroupMemberInSameInstanceAsPlayer = dump({IsGroupMemberInSameInstanceAsPlayer(unitTag)}) -- * IsGroupMemberInSameInstanceAsPlayer(*string* _unitTag_) ** _Returns:_ *bool* _isInSameInstance_
      extras.IsUnitSoloOrGroupLeader = dump({IsUnitSoloOrGroupLeader(unitTag)}) -- * IsUnitSoloOrGroupLeader(*string* _unitTag_) ** _Returns:_ *bool* _isSoloOrGroupLeader_
      extras.IsUnitFriend = dump({IsUnitFriend(unitTag)}) -- * IsUnitFriend(*string* _unitTag_) ** _Returns:_ *bool* _isOnFriendList_
      extras.IsUnitIgnored = dump({IsUnitIgnored(unitTag)}) -- * IsUnitIgnored(*string* _unitTag_) ** _Returns:_ *bool* _isIgnored_
      extras.IsUnitPlayer = dump({IsUnitPlayer(unitTag)}) -- * IsUnitPlayer(*string* _unitTag_) ** _Returns:_ *bool* _isPlayer_
      extras.IsUnitPvPFlagged = dump({IsUnitPvPFlagged(unitTag)}) -- * IsUnitPvPFlagged(*string* _unitTag_) ** _Returns:_ *bool* _isPvPFlagged_
      extras.IsUnitAttackable = dump({IsUnitAttackable(unitTag)}) -- * IsUnitAttackable(*string* _unitTag_) ** _Returns:_ *bool* _attackable_
      extras.IsUnitJusticeGuard = dump({IsUnitJusticeGuard(unitTag)}) -- * IsUnitJusticeGuard(*string* _unitTag_) ** _Returns:_ *bool* _isJusticeGuard_
      extras.IsUnitInvulnerableGuard = dump({IsUnitInvulnerableGuard(unitTag)}) -- * IsUnitInvulnerableGuard(*string* _unitTag_) ** _Returns:_ *bool* _isInvulnerableGuard_
      extras.IsUnitLivestock = dump({IsUnitLivestock(unitTag)}) -- * IsUnitLivestock(*string* _unitTag_) ** _Returns:_ *bool* _isLivestock_
      extras.GetUnitAlliance = dump({GetUnitAlliance(unitTag)}) -- * GetUnitAlliance(*string* _unitTag_) ** _Returns:_ *integer* _alliance_
      extras.GetUnitBattlegroundAlliance = dump({GetUnitBattlegroundAlliance(unitTag)}) -- * GetUnitBattlegroundAlliance(*string* _unitTag_) ** _Returns:_ *[BattlegroundAlliance|#BattlegroundAlliance]* _battlegroundAlliance_
      extras.GetUnitRace = dump({GetUnitRace(unitTag)}) -- * GetUnitRace(*string* _unitTag_) ** _Returns:_ *string* _race_
      extras.GetUnitRaceId = dump({GetUnitRaceId(unitTag)}) -- * GetUnitRaceId(*string* _unitTag_) ** _Returns:_ *integer* _raceId_
      extras.IsUnitFriendlyFollower = dump({IsUnitFriendlyFollower(unitTag)}) -- * IsUnitFriendlyFollower(*string* _unitTag_) ** _Returns:_ *bool* _isFollowing_
      extras.GetUnitReaction = dump({GetUnitReaction(unitTag)}) -- * GetUnitReaction(*string* _unitTag_) ** _Returns:_ *[UnitReactionType|#UnitReactionType]* _unitReaction_
      extras.GetUnitAvARankPoints = dump({GetUnitAvARankPoints(unitTag)}) -- * GetUnitAvARankPoints(*string* _unitTag_) ** _Returns:_ *integer* _AvARankPoints_
      extras.GetUnitAvARank = dump({GetUnitAvARank(unitTag)}) -- * GetUnitAvARank(*string* _unitTag_) ** _Returns:_ *integer* _rank_, *integer* _subRank_
      extras.GetUnitReactionColor = dump({GetUnitReactionColor(unitTag)}) -- * GetUnitReactionColor(*string* _unitTag_) ** _Returns:_ *number* _red_, *number* _green_, *number* _blue_
      extras.IsUnitInCombat = dump({IsUnitInCombat(unitTag)}) -- * IsUnitInCombat(*string* _unitTag_) ** _Returns:_ *bool* _isInCombat_
      extras.IsUnitActivelyEngaged = dump({IsUnitActivelyEngaged(unitTag)}) -- * IsUnitActivelyEngaged(*string* _unitTag_) ** _Returns:_ *bool* _isActivelyEngaged_
      extras.IsUnitDead = dump({IsUnitDead(unitTag)}) -- * IsUnitDead(*string* _unitTag_) ** _Returns:_ *bool* _isDead_
      extras.IsUnitReincarnating = dump({IsUnitReincarnating(unitTag)}) -- * IsUnitReincarnating(*string* _unitTag_) ** _Returns:_ *bool* _isReincarnating_
      extras.IsUnitDeadOrReincarnating = dump({IsUnitDeadOrReincarnating(unitTag)}) -- * IsUnitDeadOrReincarnating(*string* _unitTag_) ** _Returns:_ *bool* _isDead_
      extras.IsUnitSwimming = dump({IsUnitSwimming(unitTag)}) -- * IsUnitSwimming(*string* _unitTag_) ** _Returns:_ *bool* _isSwimming_
      extras.IsUnitFalling = dump({IsUnitFalling(unitTag)}) -- * IsUnitFalling(*string* _unitTag_) ** _Returns:_ *bool* _isFalling_
      extras.IsUnitInAir = dump({IsUnitInAir(unitTag)}) -- * IsUnitInAir(*string* _unitTag_) ** _Returns:_ *bool* _isInAir_
      extras.IsUnitResurrectableByPlayer = dump({IsUnitResurrectableByPlayer(unitTag)}) -- * IsUnitResurrectableByPlayer(*string* _unitTag_) ** _Returns:_ *bool* _isResurrectable_
      extras.IsUnitBeingResurrected = dump({IsUnitBeingResurrected(unitTag)}) -- * IsUnitBeingResurrected(*string* _unitTag_) ** _Returns:_ *bool* _isBeingResurrected_
      extras.DoesUnitHaveResurrectPending = dump({DoesUnitHaveResurrectPending(unitTag)}) -- * DoesUnitHaveResurrectPending(*string* _unitTag_) ** _Returns:_ *bool* _hasResurrectPending_
      extras.GetUnitStealthState = dump({GetUnitStealthState(unitTag)}) -- * GetUnitStealthState(*string* _unitTag_) ** _Returns:_ *integer* _stealthState_
      extras.GetUnitDisguiseState = dump({GetUnitDisguiseState(unitTag)}) -- * GetUnitDisguiseState(*string* _unitTag_) ** _Returns:_ *integer* _disguiseState_
      extras.GetUnitHidingEndTime = dump({GetUnitHidingEndTime(unitTag)}) -- * GetUnitHidingEndTime(*string* _unitTag_) ** _Returns:_ *number* _endTime_
      extras.IsUnitOnline = dump({IsUnitOnline(unitTag)}) -- * IsUnitOnline(*string* _unitTag_) ** _Returns:_ *bool* _isOnline_
      extras.IsUnitInspectableSiege = dump({IsUnitInspectableSiege(unitTag)}) -- * IsUnitInspectableSiege(*string* _unitTag_) ** _Returns:_ *bool* _isInspectableSiege_
      extras.IsUnitInDungeon = dump({IsUnitInDungeon(unitTag)}) -- * IsUnitInDungeon(*string* _unitTag_) ** _Returns:_ *bool* _isInDungeon_
      extras.IsUnitGuildKiosk = dump({IsUnitGuildKiosk(unitTag)}) -- * IsUnitGuildKiosk(*string* _unitTag_) ** _Returns:_ *bool* _isGuildKiosk_
      extras.GetUnitGuildKioskOwner = dump({GetUnitGuildKioskOwner(unitTag)}) -- * GetUnitGuildKioskOwner(*string* _unitTag_) ** _Returns:_ *integer* _ownerGuildId_
      extras.GetUnitCaption = dump({GetUnitCaption(unitTag)}) -- * GetUnitCaption(*string* _unitTag_) ** _Returns:_ *string* _caption_
      extras.GetUnitSilhouetteTexture = dump({GetUnitSilhouetteTexture(unitTag)}) -- * GetUnitSilhouetteTexture(*string* _unitTag_) ** _Returns:_ *string* _icon_
      extras.GetUnitBankAccessBag = dump({GetUnitBankAccessBag(unitTag)}) -- * GetUnitBankAccessBag(*string* _unitTag_) ** _Returns:_ *[Bag|#Bag]:nilable* _bankBag_
      extras.GetAllUnitAttributeVisualizerEffectInfo = dump({GetAllUnitAttributeVisualizerEffectInfo(unitTag)}) -- * GetAllUnitAttributeVisualizerEffectInfo(*string* _unitTag_) ** _Uses variable returns..._ ** _Returns:_ *[UnitAttributeVisual|#UnitAttributeVisual]* _unitAttributeVisual_, *[DerivedStats|#DerivedStats]* _statType_, *[Attributes|#Attributes]* _attributeType_, *[CombatMechanicType|#CombatMechanicType]* _powerType_, *number* _value_, *number* _maxValue_
      extras.GetUnitDifficulty = dump({GetUnitDifficulty(unitTag)}) -- * GetUnitDifficulty(*string* _unitTag_) ** _Returns:_ *[UIMonsterDifficulty|#UIMonsterDifficulty]* _difficult_
      extras.GetUnitTitle = dump({GetUnitTitle(unitTag)}) -- * GetUnitTitle(*string* _unitTag_) ** _Returns:_ *string* _title_
      extras.GetNumBuffs = dump({GetNumBuffs(unitTag)}) -- * GetNumBuffs(*string* _unitTag_) ** _Returns:_ *integer* _numBuffs_
      extras.GetMapPlayerPosition = dump({GetMapPlayerPosition(unitTag)}) -- * GetMapPlayerPosition(*string* _unitTag_) ** _Returns:_ *number* _normalizedX_, *number* _normalizedZ_, *number* _heading_, *bool* _isShownInCurrentMap_
      extras.GetMapPing = dump({GetMapPing(unitTag)}) -- * GetMapPing(*string* _unitTag_) ** _Returns:_ *number* _normalizedX_, *number* _normalizedY_
      extras.CanJumpToGroupMember = dump({CanJumpToGroupMember(unitTag)}) -- * CanJumpToGroupMember(*string* _unitTag_) ** _Returns:_ *bool* _canJump_, *[JumpToPlayerResult|#JumpToPlayerResult]* _result_
      extras.GetGroupIndexByUnitTag = dump({GetGroupIndexByUnitTag(unitTag)}) -- * GetGroupIndexByUnitTag(*string* _unitTag_) ** _Returns:_ *luaindex* _sortIndex_
      extras.IsGroupMemberInRemoteRegion = dump({IsGroupMemberInRemoteRegion(unitTag)}) -- * IsGroupMemberInRemoteRegion(*string* _unitTag_) ** _Returns:_ *bool* _inRemoteRegion_
      extras.GetGroupMemberSelectedRole = dump({GetGroupMemberSelectedRole(unitTag)}) -- * GetGroupMemberSelectedRole(*string* _unitTag_) ** _Returns:_ *[LFGRole|#LFGRole]* _role_
      extras.GenerateUnitNameTooltipLine = dump({GenerateUnitNameTooltipLine(unitTag)}) -- * GenerateUnitNameTooltipLine(*string* _unitTag_) ** _Returns:_ *string* _text_, *[InterfaceColorType|#InterfaceColorType]* _interfaceColorType_, *integer* _color_
      extras.GetUnitLevel = dump({GetUnitLevel(unitTag)}) -- * GetUnitLevel(*string* _unitTag_) ** _Returns:_ *integer* _level_
      extras.GetUnitName = dump({GetUnitName(unitTag)}) -- * GetUnitName(*string* _unitTag_) ** _Returns:_ *string* _name_
      extras.GetUnitZoneIndex = dump({GetUnitZoneIndex(unitTag)}) -- * GetUnitZoneIndex(*string* _unitTag_) ** _Returns:_ *luaindex:nilable* _zoneIndex_
   end
   return unit
end

function AutoFollow:Initialize()
   ZO_CreateStringId("SI_BINDING_NAME_".."FOLLOW_LEADER", "Follow Leader")
   ZO_CreateStringId("SI_BINDING_NAME_".."FOLLOW_TEST", "Follow Test")
   --AutoFollow.savedVars = ZO_SavedVars:NewAccountWide("AutoFollowSavedVariables", 1, nil, {})
end

local function GetGroupLeaderUnitTag()
   for i=1,GROUP_SIZE_MAX do
      local tmpTag = GetGroupUnitTagByIndex(i)
      if tmpTag ~= nil then
         if IsUnitSoloOrGroupLeader(tmpTag) then
            if not AreUnitsEqual(tmpTag, "player") then
               return tmpTag
            end
         end
      end
   end
   return nil
end
local function GetDirAndDist(fromX, fromY, toX, toY)
   local diffX = (fromX-toX)
   local diffY = (fromY-toY)
   local dir
   if diffY > 0 then
      dir = math.atan(diffX/diffY)
   else
      dir = math.atan(diffX/diffY) + pi
   end
   return dir, zo_sqrt((diffX * diffX) + (diffY * diffY))
end
local function ClearNavigation()
   dmsg("ClearNavigation")
   targetUnitTag = nil
   targetUnitName = nil
   EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME)
   ptk.SetIndOff(ptk.VM_MOVE_LEFT)
   ptk.SetIndOff(ptk.VM_MOVE_10_LEFT)
   ptk.SetIndOff(ptk.VM_MOVE_RIGHT)
   ptk.SetIndOff(ptk.VM_MOVE_10_RIGHT)
   ptk.SetIndOff(ptk.VK_W)
   ptk.SetIndOff(ptk.VK_SHIFT)
end
local function MoveToTarget()
   if targetUnitTag == nil then
      ClearNavigation()
      return nil
   end

   local targetChangedMaps = IsUnitWorldMapPositionBreadcrumbed(targetUnitTag) -- * IsUnitWorldMapPositionBreadcrumbed(*string* _unitTag_) ** _Returns:_ *bool* _isBreadcrumb_

   local targetX, targetY, targetHeading, targetOnSamePlayerMap = GetMapPlayerPosition(targetUnitTag) -- * GetMapPlayerPosition(*string* _unitTag_) ** _Returns:_ *number* _normalizedX_, *number* _normalizedZ_, *number* _heading_, *bool* _isShownInCurrentMap_
   if targetUnitTag == "test" then
      targetX = 0.59061920642853
      targetY = 0.39418733119965
   end
   local playerX, playerY, playerHeading = GetMapPlayerPosition("player") -- * GetMapPlayerPosition(*string* _unitTag_) ** _Returns:_ *number* _normalizedX_, *number* _normalizedZ_, *number* _heading_, *bool* _isShownInCurrentMap_
   local playerCamHeading = GetPlayerCameraHeading() -- math.abs(playerHeading - math.pi * 2) + GetPlayerCameraHeading()
   local indLookLeft, indLookQuickLeft, indLookRight, indLookQuickRight, indMoveForward, indRunForward, indUseDoor
   dmsg("---------------")
   local targetDirection, targetDistance = GetDirAndDist(playerX, playerY, targetX, targetY)
   local turnDirection = ((pi+(playerCamHeading-targetDirection))%(pi*2))-pi
   local turnPower = math.abs(turnDirection)
   dmsg(("playerX:"..tostring(playerX)).." "..("playerY:"..tostring(playerY)).." "..("dir:"..tostring(playerCamHeading)))
   dmsg(("(playerX-targetX):"..tostring(playerX-targetX)).." "..("(playerY-targetY):"..tostring(playerY-targetY)))
   dmsg("targetDistance:"..tostring(targetDistance))
   dmsg("targetDirection:"..tostring(targetDirection))
   dmsg("turnDirection:"..tostring(turnDirection))
   dmsg("targetOnSamePlayerMap:"..tostring(targetOnSamePlayerMap))
   dmsg("targetChangedMaps:"..tostring(targetChangedMaps))

   local curAction, curInteractableName, curInteractBlocked, curIsOwned, curAdditionalInfo, curContextualInfo, curContextualLink, curIsCriminalInteract
   local personalSpace = 0.02
   if targetChangedMaps then
      personalSpace = 0.003
      if targetDistance < 0.01 then -- Close enough to consider a door
         curAction, curInteractableName, curInteractBlocked, curIsOwned, curAdditionalInfo, curContextualInfo, curContextualLink, curIsCriminalInteract = GetGameCameraInteractableActionInfo()
         local reticleString = " - "..tostring(curAction).."/"..tostring(curInteractableName)
                     .."/"..ternary(curInteractBlocked, "Blocked", "NotBlocked")
                     .."/"..ternary(CanInteractWithItem(), "CanInteract", "CanNotInteract")
                     .."/"..ternary(IsInteracting(), "IsInteracting", "IsNotInteracting")
                     .."/"..ternary(IsPlayerTryingToMove(), "TryingToMove", "NotTryingToMove")
         dmsg(reticleString)
         if curAction ~= nil and not curInteractBlocked and not IsInteracting() and CanInteractWithItem() then
            indUseDoor = true
         end
      end

   end

   if targetDistance > personalSpace then
      if not IsGameCameraUIModeActive() then
         if indUseDoor then
         else
            if turnPower < 0.01 then
            elseif turnPower < 0.1 then
               if turnDirection < 0 then indLookLeft = true else indLookRight = true end
            else
               if turnDirection < 0 then indLookQuickLeft = true else indLookQuickRight = true end
            end
            local targetMountedState = GetTargetMountedStateInfo(targetUnitName) -- * GetTargetMountedStateInfo(*string* _characterOrDisplayName_) ** _Returns:_ *[MountedState|#MountedState]* _mountedState_, *bool* _isRidingGroupMount_, *bool* _hasFreePassengerSlot_
            local targetIsMounted = (targetMountedState==MOUNTED_STATE_MOUNT_RIDER)
            if turnPower < pi/4 then -- only consider moving forward if not facing away from target
               indMoveForward = true
               if targetDistance > 0.03 and turnPower < pi/8 then indRunForward = true end
            end
         end
      end
   end

   if indLookLeft then ptk.SetIndOn(ptk.VM_MOVE_LEFT) else ptk.SetIndOff(ptk.VM_MOVE_LEFT) end
   if indLookQuickLeft then ptk.SetIndOn(ptk.VM_MOVE_10_LEFT) else ptk.SetIndOff(ptk.VM_MOVE_10_LEFT) end
   if indLookRight then ptk.SetIndOn(ptk.VM_MOVE_RIGHT) else ptk.SetIndOff(ptk.VM_MOVE_RIGHT) end
   if indLookQuickRight then ptk.SetIndOn(ptk.VM_MOVE_10_RIGHT) else ptk.SetIndOff(ptk.VM_MOVE_10_RIGHT) end
   if indMoveForward then ptk.SetIndOn(ptk.VK_W) else ptk.SetIndOff(ptk.VK_W) end
   if indRunForward then ptk.SetIndOn(ptk.VK_SHIFT) else ptk.SetIndOff(ptk.VK_SHIFT) end
   if indUseDoor then ptk.SetIndOnFor(ptk.VK_E, 20) end

end

function AutoFollow:FollowLeaderStart()
   if targetUnitTag == nil then
      targetUnitTag = GetGroupLeaderUnitTag()
      if targetUnitTag == nil then targetUnitTag = "test" targetUnitName = "test" end -- REMOVE
      if targetUnitTag ~= nil then
         targetUnitName = GetUnitName(targetUnitTag)
         d("Follow Unit ON - "..tostring(targetUnitName))
         EVENT_MANAGER:RegisterForUpdate(ADDON_NAME, 10, MoveToTarget)
         MoveToTarget()
      end
   else
      d("Follow Unit OFF")
      ClearNavigation()
   end
end
function AutoFollow:FollowLeaderStop() end
function AutoFollow:SingleCheck()
   AutoFollow.FollowLeaderStart()
   ClearNavigation()
end


-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function AutoFollow.OnAddOnLoaded(event, addonName) -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
   if addonName == ADDON_NAME then AutoFollow:Initialize() end
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, AutoFollow.OnAddOnLoaded)


-----------------------------------------
local thingsWhichAreNotADoor = {["Merris"] = true, ["Elric"] = true,}

local settingMouseFollowAlways = false
local settingDistScanForDoor = .001
local settingDistHoldFromTarget = .02
local scanDirection = nil
local targetIsCrouching = nil
local playerIsCrouching = nil
local targetIsMounted = nil

local msLastUseDoor = 0
local msLastMoveForward = 0
local msLastCheckCrouch = 0
local msLastCheckMount = 0
local function MoveToTargetAlt()
   if targetUnitTag == nil then
      ClearNavigation()
      return nil
   end
   local now = GetGameTimeMilliseconds()
   local indLookLeft, indLookQuickLeft, indLookRight, indLookQuickRight, indMoveForward, indRunForward
   local indUseDoor, indToggleCrouch, indToggleMount
   if not IsGameCameraUIModeActive() then
      local playerX, playerY, playerHeading = GetMapPlayerPosition("player") -- * GetMapPlayerPosition(*string* _unitTag_) ** _Returns:_ *number* _normalizedX_, *number* _normalizedZ_, *number* _heading_, *bool* _isShownInCurrentMap_
      local targetX, targetY, targetHeading, targetOnSamePlayerMap = GetMapPlayerPosition(targetUnitTag) -- * GetMapPlayerPosition(*string* _unitTag_) ** _Returns:_ *number* _normalizedX_, *number* _normalizedZ_, *number* _heading_, *bool* _isShownInCurrentMap_
      --local targetChangedMaps = IsUnitWorldMapPositionBreadcrumbed(targetUnitTag) -- * IsUnitWorldMapPositionBreadcrumbed(*string* _unitTag_) ** _Returns:_ *bool* _isBreadcrumb_

      if targetHeading ~= 0 then -- hacky way to consider if target is a player
         if now > msLastCheckCrouch + 500 then
            local targetWasCrouching = targetIsCrouching
            targetIsCrouching = (GetUnitStealthState(targetUnitTag) ~= STEALTH_STATE_NONE)
            playerIsCrouching = (GetUnitStealthState("player") ~= STEALTH_STATE_NONE)
            if targetWasCrouching and not targetIsCrouching and playerIsCrouching then indToggleCrouch = true end
            if targetIsCrouching and not playerIsCrouching then indToggleCrouch = true playerIsCrouching = true end
            msLastCheckCrouch = now
         end
         if now > msLastCheckMount + 1000 then
            local targetMountedState = GetTargetMountedStateInfo(targetUnitName) -- * GetTargetMountedStateInfo(*string* _characterOrDisplayName_) ** _Returns:_ *[MountedState|#MountedState]* _mountedState_, *bool* _isRidingGroupMount_, *bool* _hasFreePassengerSlot_
            targetIsMounted = (targetMountedState==PLAYER_MOUNTED_STATE_MOUNT_RIDER or targetMountedState==MOUNTED_STATE_MOUNT_RIDER)
            playerIsMounted = IsMounted() -- * IsMounted() ** _Returns:_ *bool* _mounted_
            if targetIsMounted and not playerIsMounted then indToggleMount = true end
            msLastCheckMount = now
         end
      end

      local playerCamHeading = GetPlayerCameraHeading()
      local targetDirection, targetDistance = GetDirAndDist(playerX, playerY, targetX, targetY)
      local turnDirection = (((pi+(playerCamHeading-targetDirection))%(pi*2))-pi)
      local turnPower = math.abs(turnDirection)

      local indLookToTarget, indScanForDoor, indMoveToTarget
      if targetOnSamePlayerMap then
         if settingMouseFollowAlways then
            indLookToTarget = true
         elseif targetDistance > settingDistHoldFromTarget
            indLookToTarget = true
            indMoveToTarget = true
         end
      else
         if targetDistance > settingDistScanForDoor then
            indLookToTarget = true
         else
            indScanForDoor = true
         end
      end
      if indScanForDoor then
         local curAction, curInteractableName, curInteractBlocked, curIsOwned, curAdditionalInfo, curContextualInfo, curContextualLink, curIsCriminalInteract = GetGameCameraInteractableActionInfo()
         if curAction ~= nil and curInteractableName ~= nil and not thingsWhichAreNotADoor[curInteractableName] then
            indUseDoor = true
            scanDirection = nil
         else
            if turnPower > pi/8 then scanDirection = ternary((turnDirection < 0), "left", "right") end
            if scanDirection == "left" then indLookQuickLeft = true else indLookQuickRight = true end
         end
      elseif indLookToTarget then
         if turnPower < 0.1 then
            if turnDirection < 0 then indLookLeft = true else indLookRight = true end
         else
            if turnDirection < 0 then indLookQuickLeft = true else indLookQuickRight = true end
         end
      end
      if indMoveToTarget then
         if turnPower < pi/4 then
            indMoveForward = true
            --if targetDistance > 0.03 and turnPower < pi/8 then indRunForward = true end
            if not playerIsCrouching and targetDistance > turnPower and turnPower < pi/8 then indRunForward = true end
            -- * GetAdvancedStatValue(*[AdvancedStatDisplayType|#AdvancedStatDisplayType]* _statType_) ** _Returns:_ *[AdvancedStatDisplayFormat|#AdvancedStatDisplayFormat]* _displayFormat_, *integer:nilable* _flatValue_, *number:nilable* _percentValue_
            -- ADVANCED_STAT_DISPLAY_TYPE_SPRINT_SPEED
            --if GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_SPRINT_SPEED) then end
         end
      end
   end
   if indLookLeft then ptk.SetIndOn(ptk.VM_MOVE_LEFT) else ptk.SetIndOff(ptk.VM_MOVE_LEFT) end
   if indLookQuickLeft then ptk.SetIndOn(ptk.VM_MOVE_10_LEFT) else ptk.SetIndOff(ptk.VM_MOVE_10_LEFT) end
   if indLookRight then ptk.SetIndOn(ptk.VM_MOVE_RIGHT) else ptk.SetIndOff(ptk.VM_MOVE_RIGHT) end
   if indLookQuickRight then ptk.SetIndOn(ptk.VM_MOVE_10_RIGHT) else ptk.SetIndOff(ptk.VM_MOVE_10_RIGHT) end
   if indMoveForward and now > msLastMoveForward + 1000 then ptk.SetIndOn(ptk.VK_W) msLastMoveForward = now else ptk.SetIndOff(ptk.VK_W) end
   if indRunForward then ptk.SetIndOn(ptk.VK_SHIFT) else ptk.SetIndOff(ptk.VK_SHIFT) end
   if indUseDoor and now > msLastUseDoor + 300 then ptk.SetIndOnFor(ptk.VK_E, 20) msLastUseDoor = now end
   if indToggleCrouch then ptk.SetIndOnFor(ptk.VK_CONTROL, 20) end
   if indToggleMount then ptk.SetIndOnFor(ptk.VK_H, 20) end
   --if indToggleMount then ptk.UseAction(ptk.GetAction("TOGGLE_MOUNT")) end

--* GetActionBindingInfo(*luaindex* _layerIndex_, *luaindex* _categoryIndex_, *luaindex* _actionIndex_, *luaindex* _bindingIndex_) ** _Returns:_ *[KeyCode|#KeyCode]* _keyCode_, *[KeyCode|#KeyCode]* _mod1_, *[KeyCode|#KeyCode]* _mod2_, *[KeyCode|#KeyCode]* _mod3_, *[KeyCode|#KeyCode]* _mod4_

end

local tESOtoPixelBinary = {[KEY_0] = VK_0,}
local tBindsByActionName = {}
function KeybindsSave()
   local logTextArr = {}
   local saveTable = {}
   saveTable.BindTable = {}
   local layers = GetNumActionLayers()
   local GetActionLayerCategoryInfo = GetActionLayerCategoryInfo
   local GetActionInfo = GetActionInfo
   local GetActionBindingInfo = GetActionBindingInfo
   for layer = 1, layers, 1 do
      layerName,numcat = GetActionLayerInfo(layer)
      -- d(layer..":"..name..":  " ..numcat)
      saveTable.BindTable[layer] = {}
      saveTable.BindTable[layer].Name = layerName
      saveTable.BindTable[layer].LayerNumber = layer
      saveTable.BindTable[layer].NumberOfCategories= numcat
      saveTable.BindTable[layer].Category = {}
      for cat = 1, numcat, 1 do
         catName, numactions = GetActionLayerCategoryInfo(layer,cat)
         -- d(name..":"..catName..":  "..numactions)
         saveTable.BindTable[layer].Category[cat] = {}
         saveTable.BindTable[layer].Category[cat].Name = catName
         saveTable.BindTable[layer].Category[cat].NumActions = numactions
         saveTable.BindTable[layer].Category[cat].Actions = {}
         for action = 1, numactions, 1 do
            actionName, isRebindable, isHidden = GetActionInfo(layer,cat,action)
            -- d(actionName..":  "..tostring(isRebindable).." | "..tostring(isHidden))
            saveTable.BindTable[layer].Category[cat].Actions[action] = {}
            saveTable.BindTable[layer].Category[cat].Actions[action].Name = actionName
            saveTable.BindTable[layer].Category[cat].Actions[action].isRebindable = isRebindable
            saveTable.BindTable[layer].Category[cat].Actions[action].isHidden = isHidden
            saveTable.BindTable[layer].Category[cat].Actions[action].Keys = {}
            for index = 1, 4 do
               keycode, keymod1, keymod2, keymod3, keymod4 = GetActionBindingInfo(layer,cat,action,index)
               saveTable.BindTable[layer].Category[cat].Actions[action].Keys[index] = {}
               saveTable.BindTable[layer].Category[cat].Actions[action].Keys[index].KeyCode = keycode
               saveTable.BindTable[layer].Category[cat].Actions[action].Keys[index].KeyMod1 = keymod1
               saveTable.BindTable[layer].Category[cat].Actions[action].Keys[index].KeyMod2 = keymod2
               saveTable.BindTable[layer].Category[cat].Actions[action].Keys[index].KeyMod3 = keymod3
               saveTable.BindTable[layer].Category[cat].Actions[action].Keys[index].KeyMod4 = keymod4
               --logTextArr[tostring(layer)..","..tostring(cat)..","..tostring(action)..","..tostring(index)]
               --    = tostring(keycode)..","..tostring(keymod1)..","..tostring(keymod2)..","..tostring(keymod3)..","..tostring(keymod4)
               --      ..","..tostring(layerName)..","..tostring(catName)..","..tostring(actionName)..","..tostring(isRebindable)..","..tostring(isHidden)
               local arrIdx = "CallSecureProtected(BindKeyToAction, "..tostring(layer)..","..tostring(cat)..","..tostring(action)..","..tostring(index)..", "..tostring(keycode)..","..tostring(keymod1)..","..tostring(keymod2)..","..tostring(keymod3)..","..tostring(keymod4)..")"
               if not isRebindable then arrIdx = "--"..arrIdx end
               logTextArr[arrIdx]
                  = tostring(layer)..","..tostring(cat)..","..tostring(action)..","..tostring(index)
                     ..","..tostring(keycode)..","..tostring(keymod1)..","..tostring(keymod2)..","..tostring(keymod3)..","..tostring(keymod4)
                     ..","..tostring(layerName)..","..tostring(catName)..","..tostring(actionName)..","..tostring(isRebindable)..","..tostring(isHidden)
            end
         end
      end
   end
   --logTextArr["layer"..",".."cat"..",".."action"..",".."index"]
   --    = "keycode"..",".."keymod1"..",".."keymod2"..",".."keymod3"..",".."keymod4"
   --      ..",".."layerName"..",".."catName"..",".."actionName"..",".."isRebindable"..",".."isHidden"
   --CallSecureProtected("BindKeyToAction", layer, cat, action, index, keycode, keymod1, keymod2, keymod3, keymod4) -- LayerIndex,CategoryIndex,ActionIndex,BindIndex(1-4),KeyCode,Modx4
   --AHKVacuum.savedVars.logText = logTextArr
end
