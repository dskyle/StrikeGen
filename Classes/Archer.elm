module Classes.Archer exposing (classArcher)

import ModelDB exposing (..)
import FormsModel exposing (..)
import PowerUtilities exposing (..)
import Dict exposing (Dict)


classArcher : Class
classArcher =
    { name = "Archer"
    , classPowerList = powers
    , classForms = forms
    , classPowerBlocks = \m -> []
    , modifyBasicMelee = Just archerBasicMelee
    , modifyBasicRange = Just archerBasicRange
    , modifyRally = Nothing
    , modifyCharge = Nothing
    , modifyHP = Nothing
    , classFeats = [ "Fast Archer" ]
    }

{-| Modifier for ranged attacks which double range if Sniper selected
-}
sniperDouble : Model -> Int -> Int
sniperDouble m i =
    case (getResponse m "archer-feature") of
        Just "Sniper" ->
            i * 2

        _ ->
            i


archerBasicMelee : Model -> Power -> Power
archerBasicMelee m p =
    { p | damage = atWillDamage m }


archerBasicRange : Model -> Power -> Power
archerBasicRange m p =
    { p | damage = atWillDamage m, range = sniperDouble m 10 }


atWillDamage : Model -> Int
atWillDamage m =
    if (getLevel m < 5) then
        2
    else
        3

aim : Model -> Power
aim =
    quickPower "Aim" Attack AtWill 0 0 0 Green


flare : Model -> Power
flare m =
    (quickPower "Flare" Attack AtWill (sniperDouble m 10) 0 (atWillDamage m) Green) m

pinDown : Model -> Power
pinDown m =
    { name = "Pin Down"
    , text = overtext m "PinDown"
    , slot = Attack
    , freq = AtWill
    , range = (sniperDouble m 10)
    , area = 0
    , damage = (atWillDamage m)
    , styl = Green
    }

areaDenial : Model -> Power
areaDenial m =
    { name = "Area Denial"
    , text = overtext m "AreaDenial"
    , slot = Attack
    , freq = AtWill
    , range = (sniperDouble m 10)
    , area = 0
    , damage = (atWillDamage m)
    , styl = Green
    }

trickArrow : Model -> Power
trickArrow m =
    (quickPower "Trick Arrow" Attack Encounter (sniperDouble m 10) 0 3 Purple) m

bullseye : Model -> Power
bullseye =
    (quickPower "Bullseye" Attack Encounter 0 0 0 Purple)

extraTrickArrow : Model -> Power
extraTrickArrow m =
    (quickSpecial "Extra Trick Arrow" m)

legShot : Model -> Power
legShot m =
    (quickPower "Leg Shot" Attack Encounter (sniperDouble m 10) 0 3 Purple) m

surprisingShot : Model -> Power
surprisingShot m =
    (quickPower "Surprising Shot" Attack Encounter (sniperDouble m 10) 0 3 Purple) m

splitTheirArrow : Model -> Power
splitTheirArrow =
    quickPower "Split Their Arrow" Reaction Encounter 0 0 0 Purple

youCantHide : Model -> Power
youCantHide =
    quickPower "You Can't Hide" Attack Encounter 0 0 0 Purple

superTrickArrow : Model -> Power
superTrickArrow m =
    (quickPower "Super Trick Arrow" Attack Encounter (sniperDouble m 10) 0 4 Purple) m

l1encounters : Model -> Dict String Power
l1encounters m =
    powerDict m [ trickArrow, bullseye ]

l1encpower : Model -> List Power
l1encpower m =
    powerlookup m "archer-enc1" l1encounters

l3encounters : Model -> Dict String Power
l3encounters m =
    powerDict m [ extraTrickArrow, legShot, surprisingShot, splitTheirArrow ]

l3encpower : Model -> List Power
l3encpower m =
    powerlookup m "archer-enc3" l3encounters

l7encounters : Model -> Dict String Power
l7encounters m =
    powerDict m [ youCantHide, superTrickArrow ]

l7encpower : Model -> List Power
l7encpower m =
    powerlookup m "archer-enc7" l7encounters

specials : Model -> List Power
specials m =
    case (getResponse m "archer-feature") of
        Just "Sniper" ->
            [ quickSpecial "Sniper" m ]
                ++ atLevel m 5 (quickSpecial "Steady Sniper" m)
                ++ atLevel m 9 (quickSpecial "Sharpshooting Sniper" m)

        Just "Blitzer" ->
            [ quickSpecial "Blitzer" m ]
                ++ atLevel m 5 (quickSpecial "Bloody Blitzer" m)
                ++ atLevel m 9 (quickSpecial "Lightning Blitzer" m)

        Just "Sentinel" ->
            if (getLevel m < 5) then
                [ quickSpecial "Sentinel" m ]
            else
                []
                    ++ atLevel m 5 (quickSpecial "Sharp Sentinel" m)
                    ++ atLevel m 9 (quickSpecial "Snapshot Sentinel" m)

        _ ->
            []

powers : Model -> List Power
powers m =
    specials m
        ++ [ aim m, flare m, pinDown m, areaDenial m ]
        ++ l1encpower m
        ++ (atLevelList m 3 (l3encpower m))
        ++ (atLevelList m 7 (l7encpower m))
        ++ if (hasFeat m "Fast Archer") then
            [ quickSpecial "Fast Archer" m ]
           else
            []

forms : Model -> List Form
forms m =
    [ Form False
        "Archer"
        ([ DropdownField { name = "Feature", del = False, key = "archer-feature", choices = [ "", "Sniper", "Blitzer", "Sentinel" ] }
         , powerChoiceField m "Encounter:" "archer-enc1" l1encounters
         ]
            ++ (atLevel m 3 (powerChoiceField m "Encounter:" "archer-enc3" l3encounters))
            ++ (atLevel m 7 (powerChoiceField m "Encounter:" "archer-enc7" l7encounters))
        )
    ]
