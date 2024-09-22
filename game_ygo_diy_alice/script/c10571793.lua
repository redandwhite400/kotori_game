-- 梦游仙境 爱丽丝的奇遇 
-- diy by kotori 
local m=10571793
local cm=_G["c"..m]
xpcall(function() reqire("expansions/script/112") end,function() require("script/112") end)
function cm.initial_effect(c)
	c:EnableReviveLimit()
    aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
    cm.EnableChangeCode(c,10571775,LOCATION_MZONE+LOCATION_GRAVE)    

	-- sp_summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))   
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m)
	e1:SetCost(cm.spcost)
	e1:SetTarget(cm.sptg)
	e1:SetOperation(cm.spop)
	c:RegisterEffect(e1)
	-- dis
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(m,1))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,m+1)
    e2:SetCondition(cm.discon)
    e2:SetCost(cm.discost)
    e2:SetTarget(cm.distg)
    e2:SetOperation(cm.disop)
    c:RegisterEffect(e2)
end

function cm.lcheck(g)
    return g:IsExists(Card.IsLinkSetCard,1,nil,0xa15, 0xa14) 
end

function cm.EnableChangeCode(c,code,location,condition)
	Auxiliary.AddCodeList(c,code)
	local loc=c:GetOriginalType()&TYPE_MONSTER~=0 and LOCATION_MZONE or LOCATION_SZONE
	loc=location or loc
	if condition==nil then condition=Auxiliary.TRUE end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetRange(loc)
	e1:SetCondition(condition)
	e1:SetValue(code)
	c:RegisterEffect(e1)
	return e1
end

function cm.filter(c,e,tp,check)
	return c:IsSetCard(0xa14,0xa15) and c:IsAbleToHand() or c:IsSetCard(0xa14,0xa15) and c:IsType(TYPE_MONSTER) and check and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function cm.cfilter(c)
	return c:IsSetCard(0xa14,0xa15) and c:IsType(TYPE_MONSTER) 
end

function cm.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp, LOCATION_HAND,0, 1, e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end	

function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
        local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,check)
    end	
end

function cm.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,check)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	local b=check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	if tc:IsAbleToHand() and (not b or Duel.SelectOption(tp,1190,1152)==0) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	else
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

function cm.discon(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	return re:IsHasCategory(CATEGORY_REMOVE) 
end

function cm.discost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

function cm.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function cm.disop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateEffect(ev)
end