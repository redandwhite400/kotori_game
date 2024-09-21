--唤醒的爱丽丝
-- diy by kotori
local m=10571800
local cm=_G["c"..m]
xpcall(function() require("expansions/script/112") end,function() require("script/112") end)
function cm.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(cm.target)
    e1:SetOperation(cm.activate)
    c:RegisterEffect(e1)
    --neg
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(m,1))
    e2:SetCategory(CATEGORY_NEGATE)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,m)
    e2:SetCondition(cm.negcon)
    e2:SetCost(cm.negcost)
    e2:SetTarget(cm.negtg)
    e2:SetOperation(cm.negop)
    c:RegisterEffect(e2)
end
cm.fusion_effect=true
function cm.filter0(c)
    return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end

function cm.filter1(c,e)
    return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end

function cm.filter2(c,e,tp,m,f,chkf)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0xa14) and (not f or f(c))
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end

function cm.cfilter(c)
    return c:IsCode(10571790)
end

function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local chkf=tp
        local mg1=Duel.GetMatchingGroup(cm.filter0,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,nil)
        local res=Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
        if  Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_MZONE,0,1,nil) then
            local mg2=Duel.GetMatchingGroup(cm.filter0,tp,LOCATION_DECK,0,nil)
            res= res or Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,nil,chkf)
        end
        if not res then
            local ce=Duel.GetChainMaterial(tp)
            if ce~=nil then
                local fgroup=ce:GetTarget()
                local mg3=fgroup(ce,e,tp)
                local mf=ce:GetValue()
                res=Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
            end
        end
        return res
    end
    if  Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_MZONE,0,1,nil) then
        e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_DECKDES)
        e:SetLabel(1)
    else
        e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
        e:SetLabel(0)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end


function cm.activate(e,tp,eg,ep,ev,re,r,rp)
    local chkf=tp
    local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(cm.filter0),tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,nil,e)
    local sg1=Duel.GetMatchingGroup(cm.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
    local mg2 = nil
    local sg2 = nil
    if e:GetLabel() == 1 then
        mg2=Duel.GetMatchingGroup(cm.filter0,tp,LOCATION_DECK,0,nil)
        sg2=Duel.GetMatchingGroup(cm.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,nil,chkf)
    end
    local mg3=nil
    local sg3=nil
    local mg4=nil
    local sg4=nil
    local ce=Duel.GetChainMaterial(tp)
    if ce~=nil then
        if e:GetLabel() == 0 then
            local fgroup=ce:GetTarget()
            mg3=fgroup(ce,e,tp)
            local mf=ce:GetValue()
            sg3=Duel.GetMatchingGroup(cm.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
        end
        if e:GetLabel() == 1 then
            local fgroup=ce:GetTarget()
            mg4=fgroup(ce,e,tp)
            local mf=ce:GetValue()
            sg4=Duel.GetMatchingGroup(cm.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg4,mf,chkf)
        end
    end
    if e:GetLabel() == 0 and (sg1:GetCount()>0 or (sg3~=nil and sg3:GetCount()>0) )then
        local sg=sg1:Clone()
        if sg3 then sg:Merge(sg3) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tg=sg:Select(tp,1,1,nil)
        local tc=tg:GetFirst()
        if sg1:IsContains(tc) and (sg3==nil or not sg3:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
            local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
            tc:SetMaterial(mat1)
            Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            Duel.BreakEffect()
            Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        else
            local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
            local fop=ce:GetOperation()
            fop(ce,e,tp,tc,mat2)
        end
        tc:CompleteProcedure()
    end
    if e:GetLabel() == 1 and (sg1:GetCount()>0 or sg2~=nil and sg2:GetCount()>0 or sg4~=nil and sg4:GetCount()>0) then
        local sg = sg1:Clone()
        if sg2 then sg:Merge(sg2) end
        if sg4 then sg:Merge(sg4) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tg=sg:Select(tp,1,1,nil)
        local tc=tg:GetFirst()
        if sg1:IsContains(tc) and (not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,aux.Stringid(m,0))) and (sg4==nil or not sg4:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then 
            local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
            tc:SetMaterial(mat1)
            Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            Duel.BreakEffect()
            Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        elseif sg2:IsContains(tc) and (sg4==nil or not sg4:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
            local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
            tc:SetMaterial(mat2)
            Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            Duel.BreakEffect()
            Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        else 
            local mat4=Duel.SelectFusionMaterial(tp,tc,mg4,nil,chkf)
            local fop=ce:GetOperation()
            fop(ce,e,tp,tc,mat4)
        end
        tc:CompleteProcedure()
    end
end

function cm.cfilter1(c)
    return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0xa14)
end

function cm.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(cm.cfilter1,tp,LOCATION_MZONE,0,1,nil) and rp == 1-tp 
end

function cm.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
    Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function cm.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function cm.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.SendtoDeck(eg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end