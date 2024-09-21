-- 童话公主 爱丽丝
-- diy by kotori
local m=10571775
local cm=_G["c"..m]
local cmalicetable = {{}, {}} 
xpcall(function() require("expansions/script/112") end,function() require("script/112") end)
local function valueExists(subTable, value)  
	for _, v in ipairs(subTable) do  
		if v == value then  
			return true  
		end  
	end  
	return false  
end   

function cm.initial_effect(c)  

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))   
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,m)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(cm.realicetg)
	e1:SetOperation(cm.realiceop)
	c:RegisterEffect(e1)
	local e4=e1:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)

	local e2=Effect.CreateEffect(c)  
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,m+1)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(cm.alicecon)
	e2:SetTarget(cm.alicetg)
	e2:SetOperation(cm.aliceop)
	c:RegisterEffect(e2)

	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_GRAVE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xa14,0xa15))
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	if not cm.global_check then 
		cm.global_check = True 
		local e5 = Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e5:SetCode(EVENT_PHASE+PHASE_END)
		e5:SetCondition(cm.alicetanbelcon)
		e5:SetOperation(cm.alicetanbelop)
		Duel.RegisterEffect(e5,0)

		local e0 = Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_CHAINING)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e0:SetOperation(cm.checkop)
		Duel.RegisterEffect(e0,0)
	end
end


function cm.alicetanbelcon(e,tp,eg,ep,ev,re,r,rp,chk)
	if   next(cmalicetable[1]) == nil and next(cmalicetable[2]) == nil then
		return false
	end  
	return true
end

function cm.alicetanbelop(e,tp,eg,ep,ev,re,r,rp,chk)
	cmalicetable = {{}, {}} 
end

function cm.filter(c,tp,check)
	if tp == nil then return end
	return c:IsSetCard(0xa14,0xa15)  and c:IsAbleToHand()   and not 
	 valueExists(cmalicetable[tp+1],c:GetOriginalCode()) and c:GetCode() ~= check
end

function cm.realicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local check = e:GetHandler():GetOriginalCode()
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_DECK,0,1,nil,tp,check) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function cm.realiceop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end 

function cm.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not rc:IsRelateToEffect(re)  or valueExists(cmalicetable[tp+1], rc:GetOriginalCode()) then return end
	table.insert(cmalicetable[tp+1], rc:GetOriginalCode())
end


function cm.alicecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end

function cm.alicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function cm.aliceop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	if tc:IsLocation(LOCATION_GRAVE) and tc:IsRelateToChain() and  Duel.GetMZoneCount(tp) > 0 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
