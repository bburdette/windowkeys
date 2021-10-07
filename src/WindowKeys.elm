module WindowKeys exposing (Key, WindowKeyCmd(..), receive, send, encodeKey, decodeKey)

{-| This WindowKeys Elm module lets you encode and decode messages to pass to javascript,
where the actual key event listening will take place. See the README for more.

@docs Key
@docs WindowKeyCmd
@docs decodeKey
@docs encodeKey
@docs receive
@docs send
-}

import Json.Decode as JD
import Json.Encode as JE

{-| Key struct - both outgoing "SetWindowKeys" and incoming keypress messages. -}
type alias Key =
    { key : String
    , ctrl : Bool
    , alt : Bool
    , shift : Bool
    , preventDefault : Bool
    }

{-| Only one WindowKeyCmd for now, SetWindowKeys.  Use an empty list to stop all key messages. -}
type WindowKeyCmd
    = SetWindowKeys (List Key)


type alias WindowKeyMsg =
    Key

{-| Key struct to json -}
encodeKey : Key -> JE.Value
encodeKey key =
    JE.object
        [ ( "key", JE.string key.key )
        , ( "ctrl", JE.bool key.ctrl )
        , ( "alt", JE.bool key.alt )
        , ( "shift", JE.bool key.shift )
        , ( "preventDefault", JE.bool key.preventDefault )
        ]

{-| json to Key struct -}
decodeKey : JD.Decoder Key
decodeKey =
    JD.map5 Key
        (JD.field "key" JD.string)
        (JD.field "ctrl" JD.bool)
        (JD.field "alt" JD.bool)
        (JD.field "shift" JD.bool)
        (JD.field "preventDefault" JD.bool)

{-| WindowKeyCmd to json -}
encodeCmd : WindowKeyCmd -> JE.Value
encodeCmd c =
    case c of
        SetWindowKeys keys ->
            JE.object
                [ ( "cmd", JE.string "SetWindowKeys" )
                , ( "keys", JE.list encodeKey keys )
                ]



{-| use send to make a convenience function, like so:

    port sendKeyCommand : JE.Value -> Cmd msg
    wksend =
       WindowKey.send sendKeyCommand

then you can call (makes a Cmd):

    wksend <|
        SetWindowKeys
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
            ]
-}
send : (JE.Value -> Cmd msg) -> WindowKeyCmd -> Cmd msg
send portfn wsc =
    portfn (encodeCmd wsc)



{-| make a subscription function with receive and a port, like so:

    port receiveKeyMsg : (JD.Value -> msg) -> Sub msg
    keyreceive =
        receiveKeyMsg <| WindowKey.receive WsMsg

Where WkMsg is defined in your app like this:

    type Msg
        = WkMsg (Result JD.Error WindowKey.WindowKeyMsg)
        | <other message types>

then in your application subscriptions:

    subscriptions =
       \_ -> keyreceive
-}
receive : (Result JD.Error WindowKeyMsg -> msg) -> (JD.Value -> msg)
receive toKeyMsg =
    \v ->
        JD.decodeValue decodeKey v
            |> toKeyMsg
