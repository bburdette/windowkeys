port module Main exposing (..)

import Json.Decode as JD
import Json.Encode as JE
import Browser
import Browser.Events
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Element.Font as Font
import Element.Input as Input
import WindowKeys


port receiveKeyMsg : (JD.Value -> msg) -> Sub msg

keyreceive =
    receiveKeyMsg <| WindowKeys.receive WkMsg

-- I'll also need this port for sending WindowKeys commands - pretty much just SetWindowKeys for now. skcommand is just a convenience function, see it in action in the usage example above.

port sendKeyCommand : JE.Value -> Cmd msg

skcommand =
    WindowKeys.send sendKeyCommand




-- Ellie for this one:  
--  https://ellie-app.com/kSZPrk5BCRNa1

type Msgs
    = EnterCell Int
    | LeaveCell Int
    | WkMsg (Result JD.Error WindowKeys.Key)


type alias Model =
    { highlightRow : Maybe Int }


main =
    Browser.element
        { init = \() -> ( { highlightRow = Nothing }, 
            skcommand <|
            WindowKeys.SetWindowKeys
                [ { key = "s"
                  , ctrl = True
                  , alt = False
                  , shift = False
                  , preventDefault = True }
                , { key = "Enter"
                  , ctrl = False
                  , alt = False
                  , shift = False
                  , preventDefault = False }
                ] )
        , update = update
        , view = view
        , subscriptions = \_ -> keyreceive
        }


update msg model =
    let _ = Debug.log "msg" msg in
    case msg of
        EnterCell row ->
            ( { model | highlightRow = Just row }, Cmd.none )

        LeaveCell row ->
            ( { model | highlightRow = Just row }, Cmd.none )

        WkMsg wkmsg ->
            let _ = Debug.log "wkmsg" wkmsg in
            ( model, Cmd.none )


cellevents =
    \mbhr row evts ->
        evts
            ++ [ onMouseEnter (EnterCell row), onMouseLeave (LeaveCell row) ]
            ++ (if mbhr == Just row then
                    [ Background.color (Element.rgb 255 0 0) ]

                else
                    []
               )


view model =
    layout [ width fill, height fill ] <|
        table [ width fill, height fill, spacing 1 ] <|
            { data =
                List.indexedMap (\i s -> ( i, s ++ String.fromInt i )) <|
                    List.repeat 50 "test"
            , columns =
                [ { header = el [ Background.color (rgb 0.9 0.9 0) ] <| text ("table header, row = " ++ (Maybe.map String.fromInt model.highlightRow |> Maybe.withDefault "none"))
                  , width = fill
                  , view = \( i, s ) -> el (cellevents model.highlightRow i [ padding 3 ]) <| text s
                  }
                , { header = el [ Background.color (rgb 0.9 0.9 0) ] <| text "table header"
                  , width = fill
                  , view = \( i, s ) -> el (cellevents model.highlightRow i [ padding 3 ]) <| text s
                  }
                , { header = el [ Background.color (rgb 0.9 0.9 0) ] <| text "table header"
                  , width = fill
                  , view = \( i, s ) -> el (cellevents model.highlightRow i [ padding 3 ]) <| text s
                  }
                ]
            }
