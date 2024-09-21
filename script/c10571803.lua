--梦游仙境 升变
-- diy by kotori
local m=10571803
local cm=_G["c"..m]
xpcall(function() require("expansions/script/112") end,function() require("script/112") end)
function cm.initial_effect(c)
    --to deck
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(cm.contg)
    e1:SetTarget(cm.tdtg)
    e1:SetOperation(cm.activate)
    c:RegisterEffect(e1)

    --set s/t
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_GRAVE_ACTION)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,m+1)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCost(cm.sstcost)
    e2:SetTarget(cm.ssttg)
    e2:SetOperation(cm.sstop)
    c:RegisterEffect(e2)
end

function cm.tdfilter(c)
    return c:IsAbleToDeck()
end
function cm.td2filter(c)
    return c:IsFaceup() and c:IsSetCard(0xa14)
end
function cm.contg(e,tp)    
    return tp == Duel.GetTurnPlayer() or Duel.IsExistingMatchingCard(cm.td2filter,tp,LOCATION_ONFIELD,0,1,nil)
end
function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)    
    if chk==0 then return Duel.IsExistingMatchingCard(cm.tdfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
end

function cm.activate(e,tp,eg,ep,ev,re,r,rp,chk)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cm.tdfilter),tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoDeck(g,nil,POS_FACEUP,REASON_EFFECT)
    end
end

function cm.sstcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
    Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function cm.filter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xa14) and c:IsSSetable()
end

function cm.ssttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil) end
end

function cm.sstop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
    if tc then Duel.SSet(tp,tc) end
end