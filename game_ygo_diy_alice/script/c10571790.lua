-- 梦游仙境 苏醒的爱丽丝
-- diy by kotori
local m=10571790
local cm=_G["c"..m]
xpcall(function() require("expansions/script/112") end,function() require("script/112") end)

function cm.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcCode4(c,10571775,10571778,10571782,10571787,true,true)
	cm.AddContactFusionProcedure(c,c.IsAbleToDeckOrExtraAsCost,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,aux.tdcfop(c))
	local e0 = Effect.CreateEffect(c)
	-- TO DECK
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,m)
	e1:SetCondition(cm.tdcon)
	e1:SetTarget(cm.tdtg)
    e1:SetOperation(cm.tdop)
	c:RegisterEffect(e1)
	-- search or sp_summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))   
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,m)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(cm.sptg)
	e2:SetOperation(cm.spop)
	c:RegisterEffect(e2)
end

function cm.cfp(c)
	c.IsSummonType = SUMMON_TYPE_FUSION
	return aux.tdcfop(c)
end

function cm.td1filter(c)
	local a = c:IsAbleToDeck() or c:IsAbleToExtra()
	local b = not c:IsSetCard(0xa14) or c:IsFacedown()
	return  a and b
end

function cm.td2filter(c)
	return  Card.IsAbleToDeck(c) or Card.IsAbleToExtra(c) 
end

function cm.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_FUSION) or c:GetFlagEffect(m) > 0
end


function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(cm.td1filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,e:GetHandler())
	local g2=Duel.GetMatchingGroup(cm.td2filter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,e:GetHandler())
	if chk==0 then return g1:GetCount()>0 or g2:GetCount()>0 end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,g1:GetCount(),tp,LOCATION_ONFIELD+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,g2:GetCount(),1-tp,LOCATION_ONFIELD+LOCATION_GRAVE)
	
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(cm.td1filter),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,aux.ExceptThisCard(e))
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(cm.td2filter),tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,aux.ExceptThisCard(e))
	local g = Group.__add(g1, g2)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end

--
function cm.AddContactFusionProcedure(c,filter,self_location,opponent_location,mat_operation,...)
	self_location=self_location or 0
	opponent_location=opponent_location or 0
	local operation_params={...}
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(Auxiliary.ContactFusionCondition(filter,self_location,opponent_location))
	e2:SetTarget(Auxiliary.ContactFusionTarget(filter,self_location,opponent_location))
	e2:SetOperation(cm.ContactFusionOperation(mat_operation,operation_params))
	c:RegisterEffect(e2)
	return e2
end
function cm.ContactFusionOperation(mat_operation,operation_params)
	return	function(e,tp,eg,ep,ev,re,r,rp,c)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				mat_operation(g,table.unpack(operation_params))
				g:DeleteGroup()
				c:RegisterFlagEffect(m, RESET_EVENT+RESET_TOGRAVE+RESET_REMOVE+RESET_TODECK+RESET_LEAVE+RESET_OVERLAY+RESET_MSCHANGE,0,1)
			end
end
function cm.filter(c,e,tp,check)
	return c:IsSetCard(0xa14,0xa15) and c:IsAbleToHand() or c:IsSetCard(0xa14,0xa15) and c:IsType(TYPE_MONSTER) and check and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function cm.cfilter(c)
	return c:IsSetCard(0xa14,0xa15) and c:IsType(TYPE_MONSTER) 
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
        local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
    end
end

function cm.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	local b=check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	if tc:IsAbleToHand() and (not b or Duel.SelectOption(tp,1190,1152)==0) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	else
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end