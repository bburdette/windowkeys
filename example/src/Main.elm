port module Main exposing (..)

import Browser
import Browser.Events
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Element.Input as Input
import Json.Decode as JD
import Json.Encode as JE
import WindowKeys


port receiveKeyMsg : (JD.Value -> msg) -> Sub msg


keyreceive =
    receiveKeyMsg <| WindowKeys.receive WkMsg



-- I'll also need this port for sending WindowKeys commands - pretty much just SetWindowKeys for now. skcommand is just a convenience function, see it in action in the usage example above.


port sendKeyCommand : JE.Value -> Cmd msg


skcommand =
    WindowKeys.send sendKeyCommand


showKey : WindowKeys.Key -> String
showKey key =
    (if key.ctrl then
        "ctrl-"

     else
        ""
    )
        ++ (if key.alt then
                "alt-"

            else
                ""
           )
        ++ (if key.shift then
                "shift-"

            else
                ""
           )
        ++ key.key



-- Ellie for this one:
--  https://ellie-app.com/mqMNrkBNnVBa1


type Msgs
    = WkMsg (Result JD.Error WindowKeys.Key)


type alias Model =
    { keysReceived : List WindowKeys.Key }


main =
    Browser.element
        { init =
            \() ->
                ( { keysReceived = [] }
                , skcommand <|
                    WindowKeys.SetWindowKeys
                        [ { key = "s"
                          , ctrl = True
                          , alt = False
                          , shift = False
                          , preventDefault = True
                          }
                        , { key = "x"
                          , ctrl = True
                          , alt = True
                          , shift = False
                          , preventDefault = True
                          }
                        , { key = "Enter"
                          , ctrl = False
                          , alt = False
                          , shift = False
                          , preventDefault = False
                          }
                        ]
                )
        , update = update
        , view = view
        , subscriptions = \_ -> keyreceive
        }


update msg model =
    case msg of
        WkMsg wkmsg ->
            let
                _ =
                    Debug.log "wkmsg" wkmsg
            in
            ( { model
                | keysReceived =
                    case wkmsg of
                        Ok key ->
                            key :: model.keysReceived

                        Err _ ->
                            model.keysReceived
              }
            , Cmd.none
            )


view model =
    layout [ width fill, height fill ] <|
        column [ centerX, centerY ]
            ([ text "allowed keys: Enter, ctrl-s, ctrl-alt-x"
             , text "keys received: "
             ]
                ++ (model.keysReceived
                        |> List.map (\k -> text (showKey k))
                   )
            )
