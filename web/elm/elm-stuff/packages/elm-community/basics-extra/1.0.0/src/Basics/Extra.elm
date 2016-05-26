module Basics.Extra
    exposing
        ( never
        )

{-| Additional basic functions

@docs never
-}


{-| The empty function.
This converts a value of type
[`Never`](http://package.elm-lang.org/packages/elm-lang/core/latest/Basics#Never)
into a value of any type, which is safe because there are no values of
type `Never`. Useful in certain situations as argument to
[`Task.perform`](http://package.elm-lang.org/packages/elm-lang/core/latest/Task#perform),
[`Cmd.map`](http://package.elm-lang.org/packages/elm-lang/core/latest/Platform-Cmd#map),
[`Html.map`](http://package.elm-lang.org/packages/elm-lang/html/latest/Html-App#map).
-}
never : Never -> a
never n =
    never n
-- If this function is moved to Basics, the following nicer definition
-- using the private Never constructor may be used.  This actually
-- witnesses the emptiness of Never instead of just asserting it:
--
-- never (Never n) =
--     never n
