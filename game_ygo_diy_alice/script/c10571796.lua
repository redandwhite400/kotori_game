-- 梦游仙境 
-- diy by kotori
local m=10571796
local cm=_G["c"..m]
xpcall(function() require("expansions/script/112") end,function() require("script/112") end)
function cm.initial_effect(c)
    if not cm.global_check then
        cm.global_check=true
        local ge1 = Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_TO_DECK)
        ge1:SetOperation(cm.gloop)
        Duel.RegisterEffect(ge1, 0)
    end
    -- activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(cm.conactivate)
    e1:SetOperation(cm.activate)
    c:RegisterEffect(e1)
    -- addatk
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TO_DECK)
    e2:SetOperation(cm.addop)
    c:RegisterEffect(e2)
    -- limit
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CANNOT_ACTIVATE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(1,0)
    e3:SetValue(cm.actlimit)
    c:RegisterEffect(e3)
    -- to deck
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_REMOVE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetOperation(cm.tdop)
    c:RegisterEffect(e4)
end

function cm.gloop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    while tc do
        Duel.RegisterFlagEffect(tp,m+2,RESET_PHASE+PHASE_END,0,1)
        tc=eg:GetNext() 
    end
end
function cm.actfilter(c)
    return c:IsSetCard(0xa15) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() or c:IsCode(10571775) and c:IsAbleToHand()
end

function cm.conactivate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp, m) == 0 then
        e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
        return true
    else 
        e:SetCategory(nil)
        return true
    end
end

function cm.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp, m) > 0 then return end
    local g=Duel.GetMatchingGroup(cm.actfilter,tp,LOCATION_DECK,0,nil)
    if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
        Duel.RegisterFlagEffect(tp, m, RESET_PHASE+PHASE_END,0,1)
    end
end

function cm.addop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp, m+1) > 0  then return end
    if Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
        local c = e:GetHandler()
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCategory(CATEGORY_ATKCHANGE)
        e1:SetTarget(cm.atktg)
        e1:SetTargetRange(LOCATION_MZONE,0)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(cm.atkval)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        Duel.RegisterFlagEffect(tp, m+1, RESET_PHASE+PHASE_END,0,1)
    end
end

function cm.atkval(tp)
    return Duel.GetFlagEffect(tp, m+2)*200 
end

function cm.atktg(e,c)
    return c:IsSetCard(0xa14)
end
function cm.actlimit(e,re,tp)
    return re:GetActivateLocation()==LOCATION_REMOVED 
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    local tg=eg:Filter(cm.tdfilter,nil,tp)
    if tg:GetCount() ==0 then return end
    Duel.SendtoDeck(tg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
end

function cm.tdfilter(c, tp)
    return c:IsAbleToDeck() and c:IsLocation(LOCATION_REMOVED) and c:GetOwner() == tp
end