import Html exposing (Html, div, input, li, ol, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Dict
import Set

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

type OpTree
  = Leaf Int
  | Node Op Int Int

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
          [ ol [] (List.map (\s -> li [] [text s]) (digitGroups model.content))
          ]
    ]

digitGroups : String -> List String
digitGroups s =
  uniquePermutations s |>
    List.concatMap groupDigits |>
      List.filter (not << hasLeadingZeros)

-- Deduplicate a set of permuations. Not guaranteed to preserve order
uniquePermutations : String -> List String
uniquePermutations s =
  permutations s |> Set.fromList |> Set.toList

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

-- For a numerical string, return a list containing all the ways
-- the string can be split. Each entry is a string of comma separated groups
groupDigits : String -> List String
groupDigits s =
  if String.length s == 1 then
    s :: []
  else
    case String.uncons s of
      Nothing -> []
      Just (first, rest) ->
        let
          restGroups = groupDigits rest
          g1 = List.map (\s -> String.cons first s) restGroups
          g2 = List.map (\s -> String.cons ',' s |> String.cons first) restGroups
        in
          List.append g1 g2

hasLeadingZeros : String -> Bool
hasLeadingZeros s =
  String.split "," s |>
    List.any (\x ->
      case String.uncons x of
        Nothing -> False
        Just (c, s) -> c == '0' && String.length s > 0
      )

treesFromGroups : List String -> List OpTree
treesFromGroups groups =
  List.map numsFromString groups |>  -- List List (Result String Int)
    List.filter noStringErrors |>
      List.concatMap (treesFromDigits << resultToInt) -- List Optree

treesFromDigits : List Int -> List OpTree
treesFromDigits nums =
  case nums of
    [] -> [] -- should never happen
    h :: [] -> List.singleton (Leaf h)
    _ :: t -> []

    --(naiveTree s) :: []

naiveTree : List Int -> OpTree
naiveTree nums =
  Leaf 0

numsFromString : String -> List (Result String Int)
numsFromString s =
  String.split "," s |>
    List.map String.toInt

noStringErrors : List (Result String Int) -> Bool
noStringErrors =
  not << List.any (\n -> case n of
                          Ok _ -> False
                          Err _ -> True)

resultToInt : List (Result String Int) -> List Int
resultToInt =
  List.map (\n -> case n of
                    Ok i -> i
                    Err _ -> 0) -- Filter out errors before so this is never reached
