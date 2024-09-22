-- 爱丽丝的梳妆
-- diy by kotori
local m=10571806
local cm=_G["c"..m]
xpcall(function() require("expansions/script/112") end,function() require("script/112") end)
function cm.initial_effect(c)
    --active
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    -- grave
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(m,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,m)
    e1:SetTarget(cm.thtg)
    e1:SetOperation(cm.thop)
    c:RegisterEffect(e1)
    --draw
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_DECK)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,m)
    e2:SetCondition(cm.drcon)
    e2:SetTarget(cm.drtg)
    e2:SetOperation(cm.drawop)
    c:RegisterEffect(e2)
    -- not target
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_ONFIELD,0)
    e3:SetCondition(cm.ntcon)
    e3:SetTarget(aux.TargetBoolFunction(cm.nttg))
    e3:SetValue(1)
    c:RegisterEffect(e3)
    -- not desotry
    local e4=e3:Clone()
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetTarget(aux.TargetBoolFunction(cm.ndtg))
    c:RegisterEffect(e4)
end

function cm.filter(c)
    return c:IsSetCard(0xa14,0xa15) and c:IsAbleToGrave()
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

function cm.drcon(e,tp,eg,ep,ev,re,r,rp,chk)
    if eg:GetCount() == 0 then return false 
    else
        return true
    end
end

function cm.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function cm.drawop(e,tp,eg,ep,ev,re,r,rp,chk)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end

function cm.cfilter1(c)
    return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0xa14)
end

function cm.ntcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(cm.cfilter1,tp,LOCATION_ONFIELD,0,1,nil,tp)
end

function cm.nttg(c)
    return c:IsSetCard(0xa15) and c:IsFaceup()
    
end

function cm.ndtg(c)
    return c:IsSetCard(0xa14) and c:IsFaceup()
end