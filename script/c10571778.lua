--梦游仙境 白兔
-- diy by kotori
-- 必须将这张卡的卡号放到ailce的下一位
local m=10571778
local cm=_G["c"..m]
xpcall(function() require("expansions/script/112") end,function() require("script/112") end)
function cm.initial_effect(c)
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:SetOperation(cm.chechop)
	c:RegisterEffect(e0)
	local e4 = e0:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)

	if not alicea15 then
		alicea15 = {}
        alicea15.global_check=true
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_REMOVE)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        ge1:SetOperation(cm.alicea15op)
        Duel.RegisterEffect(ge1,0)
    end
   
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.alicecon)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,m+1)
	e2:SetTarget(cm.alicetg)
	e2:SetOperation(cm.aliceop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end

function cm.chechop(e,tp,eg,ep,ev,re,r,rp,chk)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end


function cm.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa14,0xa15)
end

function cm.alicecon(e,c)
	if c==nil then return true end
	local cnum =  Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)
	return cnum ==0 or cnum == Duel.GetMatchingGroupCount(cm.cfilter,tp,LOCATION_MZONE,0,nil)
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function cm.thfilter(c)
	return c:IsSetCard(0xa15) and c:IsType(TYPE_MONSTER) or c:IsCode(10571775) and c:IsAbleToHand()
end
function cm.alicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.aliceop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function cm.alicea15op(e,tp,eg,ep,ev,re,r,rp)
	if rp == nil then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cm.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,rp)	
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,rp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsSetCard(0xa15) and not c:IsSetCard(0xa14) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4)
end