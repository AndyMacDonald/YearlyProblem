import Html exposing (Html, div, input, li, ol, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Dict

main =
  Html.beginnerProgram
    { model = model
    , view = view
    , update = update
    }



-- MODEL
type Op
  = PLUS
  | MINUS
  | TIMES
  | DIVIDE
  | EXP

type alias Precedence = Dict.Dict Op Int

type alias Associative = Dict.Dict Op Bool

type alias Model =
  { content : String
  }


model : Model
model =
  Model ""



-- UPDATE


type Msg
  = Change String

update : Msg -> Model -> Model
update msg model =
  case msg of
    Change newContent ->
      { model | content = newContent }



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ input [ type_ "number", placeholder "Year", onInput Change ] []
    , div [] 
          [ ol [] (List.map (\s -> li [] [text s]) (permutations model.content))
          ]
    ]

-- Take a string and return list containing all permutations of that string
permutations : String -> List String
permutations s =
  permuteIter (String.length s |> factorial) 0 s

permuteIter : Int -> Int -> String -> List String
permuteIter total count s =
  if total == count
  then
    []
  else
    let
      c2 = count + 1
      right = maxFactBase c2 (String.length s)
      left = if right % 2 == 0 then
          0
        else
          (c2 % (factorial (right + 1))) // (factorial right) - 1
      s2 = swap s left right
    in
      s :: permuteIter total c2 s2

factorial : Int -> Int
factorial n =
  List.product (List.range 1 n)

-- given a number n, find the largest i such that n % i! == 0
-- second argument is initial value for i
maxFactBase : Int -> Int -> Int
maxFactBase n i =
  if i == 1 then
    1
  else
    if n % (factorial i) == 0 then
      i
    else
      maxFactBase n (i - 1)

swap : String -> Int -> Int -> String
swap s l r =
  String.concat [String.slice 0 l s, 
                 String.slice r (r+1) s, 
                 String.slice (l+1) r s, 
                 String.slice l (l+1) s, 
                 String.slice (r+1) (String.length s) s]
