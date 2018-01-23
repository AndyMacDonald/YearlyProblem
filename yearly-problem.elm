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

allOps : List Op
allOps =
  [PLUS, MINUS, TIMES, DIVIDE, EXP]

type OpTree
  = Leaf Int
  | Node Op OpTree OpTree

type alias Candidate =
  { tree : OpTree
  , opCount : Int
  , result : Float
  }

type alias Candidates = Dict.Dict Int Candidate

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
          --[ ol [] (List.map (\s -> li [] [text s]) (digitGroups model.content))
          --[ ol [] (List.map (\s -> li [] [text s]) (List.map (formatTree Nothing) (createTrees model.content)))
          --[ ol [] (List.map (\s -> li [] [text s]) (List.map (toString << evalTree) (createTrees model.content)))
          [ ol [] (createListItems model.content)
          ]
    ]

createListItems : String -> List (Html Msg)
createListItems s =
  let
    c = collectCandidates s
  in
    List.map (\i -> 
                li [] (case Dict.get i c of
                    Nothing -> []
                    Just c -> [text (formatTree Nothing c.tree)]))
              (List.range 1 100)

collectCandidates : String -> Candidates
collectCandidates s = 
  List.foldl collectCandidate Dict.empty (createCandidates s)

createCandidates : String -> List Candidate
createCandidates s =
  List.filterMap candidateFromTree (createTrees s)

createTrees : String -> List OpTree
createTrees =
  treesFromGroups << digitGroups

digitGroups : String -> List String
digitGroups s =
  uniquePermutations s |>
    List.concatMap groupDigits |>
      List.filter (not << hasLeadingZeros)

-- Deduplicate a set of permuations. Not guaranteed to preserve order, but
-- does ensure the first element is the original string (important for preferring
-- solutions with original digit order)
uniquePermutations : String -> List String
uniquePermutations s =
  s :: (permutations s |> Set.fromList |> Set.toList |> List.filter (\a -> a /= s))
    

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

-- Convert number strings to opeator trees
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
    _ :: t -> 
      List.concatMap (treesFromSplitDigits nums) (List.range 1 ((List.length nums) - 1))

treesFromSplitDigits : List Int -> Int -> List OpTree
treesFromSplitDigits nums i =
  let
    left = List.take i nums |> treesFromDigits 
    right = List.drop i nums |> treesFromDigits
  in
    crossMap3 Node allOps left right

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

-- Tree formatting
precidence : Op -> Int
precidence o =
  case o of
    PLUS -> 1
    MINUS -> 1
    TIMES -> 2
    DIVIDE -> 2
    EXP -> 3

commutative : Op -> Bool
commutative o =
  case o of
    MINUS -> False
    DIVIDE -> False
    _ -> True

needParens : Maybe Op -> Op -> Bool
needParens parent child =
  case parent of
    Nothing -> False
    Just p ->
      if (precidence p) == (precidence child) && not (commutative p) then
        True
      else
        precidence p > precidence child

operator : OpTree -> Maybe Op
operator t =
  case t of
    Node op _ _ -> Just op
    Leaf _ -> Nothing

formatOp : Op -> String
formatOp op =
  case op of
    PLUS -> "+"
    MINUS -> "-"
    TIMES -> "*"
    DIVIDE -> "/"
    EXP -> "^"

formatTree : Maybe Op -> OpTree -> String
formatTree parent t =
  case t of
    Leaf i -> toString i
    Node op l r ->
      let
        left = formatTree (Just op) l
        right = formatTree (Just op) r
        parens = needParens parent op
        open = if parens then "(" else ""
        close = if parens then ")" else ""
      in
        String.concat [open, left, formatOp op, right, close]

evalTree : OpTree -> Maybe Float
evalTree t =
  case t of
    Leaf i -> Just (toFloat i)
    Node op l r -> 
      evalTree l
        |> Maybe.andThen (\left ->
          evalTree r
            |> Maybe.andThen (\right ->
                case op of
                  PLUS -> Just (left + right)
                  MINUS -> Just (left - right)
                  TIMES -> Just (left * right)
                  DIVIDE -> 
                    let
                      x = left / right
                    in
                      if isInfinite x then Nothing else Just x 
                  EXP -> 
                    let
                      x = left ^ right
                    in
                      if isInfinite x || isNaN x then Nothing else Just x
              ))

countOps : OpTree -> Int
countOps t =
  case t of
    Leaf _ -> 0
    Node _ l r -> 1 + (countOps l) + (countOps r)

sampleTrees : List OpTree
sampleTrees =
  [ Leaf 17
  , Node PLUS (Leaf 3) (Leaf 4)
  , Node TIMES (Node MINUS (Leaf 2) (Leaf 8)) (Leaf 10)
  ]

-- Candidate management
candidateFromTree : OpTree -> Maybe Candidate
candidateFromTree t =
  let
    opCount = countOps t
  in
    case evalTree t of
      Just f -> Just {tree = t, opCount = opCount, result = f}
      Nothing -> Nothing

collectCandidate : Candidate -> Candidates -> Candidates
collectCandidate c cs =
  let
    i = truncate c.result
  in
    if i >= 1 && i <= 100 && toFloat i == c.result then
      insertCandidate i c cs
    else
      cs    

insertCandidate : Int -> Candidate -> Candidates -> Candidates
insertCandidate i c =
  Dict.update
    i
    (\mc ->
      case mc of
        Nothing -> Just c
        Just cOld ->
          if c.opCount < cOld.opCount then Just c else mc)

sampleCandidates : Candidates
sampleCandidates =
  Dict.empty
    |> insertCandidate 17 {tree = (Leaf 17), opCount = 0, result = 17}
    |> insertCandidate 7 {tree = (Node PLUS (Leaf 3) (Leaf 4)), opCount = 1, result = 7}
    |> insertCandidate -80 {tree = (Node TIMES (Node MINUS (Leaf 2) (Leaf 8)) (Leaf 10)), opCount = 2, result = -80}

-- Utilities
crossMap3 : (a -> b -> c -> d) -> List a -> List b -> List c -> List d
crossMap3 f aList bList cList =
  List.concatMap (\a -> crossMap2 (f a) bList cList) aList

crossMap2 : (a -> b -> c) -> List a -> List b -> List c
crossMap2 f aList bList =
  List.concatMap (\a -> List.map (f a) bList) aList
