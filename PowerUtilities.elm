module PowerUtilities exposing (..)

import Dict exposing (Dict, get)
import Maybe exposing (Maybe)
import FormsModel exposing (..)
import ModelDB exposing (..)
import String

powerDict : Model -> List (Model -> Power) -> Dict String Power
powerDict m l =
  let toTuple p = ((p m).name, p m) in
    Dict.fromList (List.map toTuple l)


powerlookup : Model -> String -> (Model -> Dict String Power) -> List Power
powerlookup m key list = case (getResponse m key) of
  Nothing -> []
  Just choice -> case (get choice (list m)) of
    Nothing -> []
    Just power -> [power]


powerChoiceField m name key list =
  DropdownField { name=name, del=False, key=key, choices=[""] ++ (Dict.keys (list m)) }


quickPower : String -> Slot -> Freq -> Int -> Int -> Int -> PowerStyle -> Model -> Power
quickPower name slot freq range area damage col m =
        {name = name,
         text = overtext m (String.filter (\x -> (x /= ' ')) name),
         slot = slot,
         freq = freq,
         range = range,
         area = area,
         damage = damage,
         styl = col
       }

quickSpecial name m = quickPower name Special None 0 0 0 White m

atLevel : Model -> Int -> a -> List a 
atLevel m level ab = if ((getLevel m) >= level) then [ab] else []

atLevelList m level ab = if ((getLevel m) >= level) then ab else []
