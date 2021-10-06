# WindowKeys

This package provides a way to subscribe to keyPress events for certain keys, at the window level of the DOM.
I wrote it to have a way to get reliable keyPress events for shortcut key combinations, like "ctrl-s".

Its pretty similar to what you get with Browser.onKeyPress, except that you only get events for keys you've
specified.  Also - key point - you can tell if to 'preventDefault' on those keyPress events too,
something that Browser.onKeyPress does not provide.

You can do something similar to this by adding a key event listener to your topmost html div element.  But sometimes
that element loses focus, and then you don't get your shortcut events anymore.

Better to subscribe to key events at the 'window' level.

### Usage example:

I want to get a keyPress event for the Enter key, and for ctrl-s.  For Enter, I want to allow normal Enter key events
too; but for ctrl-s I want to prevent the normal browser event, which prompts the user to save the current page to a file.

To do that I issue this Cmd from my `init` function:


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
            ]

So one key has preventDefault specified, and the other not.

This - along with some port wrangling - will cause me to get `WkMsg WindowKeys.Key` messages delivered
to my `update` function, and from there I can route them to the current page/dialog/whatever.

### Elm Setup

I declare this port and make a 'keyreceive' Sub to go in my subscriptions.

    port receiveKeyMsg : (JD.Value -> msg) -> Sub msg

    keyreceive =
        receiveKeyMsg <| WindowKeys.receive WkMsg

I'll also need this port for sending WindowKeys commands - pretty much just SetWindowKeys for now.  `skcommand`
is just a convenience function, see it in action in the usage example above.

    port sendKeyCommand : JE.Value -> Cmd msg

    skcommand =
        WindowKeys.send sendKeyCommand

And finally in my Msg type I add the WkMsg:

    type Msg
        = WkMsg (Result JD.Error WindowKeys.Key)
        | <more message declarations>

### Javascript Setup

There are two js functions needed - one recieves the list of keys from elm and stores them in the `windowkeys` var.

The other function is a keyboard event handler you attach to `window`.  It checks `windowkeys` and sends
events to Elm.

Both functions are defined in the following script, which is in file form [here](https://github.com/bburdette/windowkeys/blob/f54ea442a148956311fc44bfeeb8ba0a97e223d6/windowkey.js).


    <script>
        // this will contain the keys we're monitoring.
        let windowkeys = {};

        // wire up your sendKeyCommand port in elm to this function:
        //    app.ports.sendKeyCommand.subscribe(sendKeyCommand);
        function sendKeyCommand( kc ) {
          // console.log("sendKeyCommand", kc);

          if (kc.cmd == "SetWindowKeys") {
            windowkeys = {};
            for (let i = 0; i < kc.keys.length; i++) {
              k = kc.keys[i];
              if (!windowkeys[k.key]) {
                windowkeys[k.key] = {};
              }
              if (!windowkeys[k.key][k.ctrl]) {
                windowkeys[k.key][k.ctrl] = {};
              }
              if (!windowkeys[k.key][k.ctrl][k.alt]) {
                windowkeys[k.key][k.ctrl][k.alt] = {};
              }
              if (!windowkeys[k.key][k.ctrl][k.alt][k.shift]) {
                windowkeys[k.key][k.ctrl][k.alt][k.shift] = {};
              }
              windowkeys[k.key] [k.ctrl] [k.alt] [k.shift] = k.preventDefault
            }   
          }
        }

        // add this line after your elm app init.
        // window.addEventListener( "keydown", keycheck, false );
        function keycheck(e) {
          try {
            let pd = windowkeys[e.key][e.ctrlKey][e.altKey][e.shiftKey];
            if (pd) {
              e.preventDefault();
            }
            // console.log("key found: ", e.key, " preventdefault: ", pd);

            app.ports.receiveKeyMsg.send({ key : e.key
                                         , ctrl : e.ctrlKey
                                         , alt : e.altKey
                                         , shift : e.shiftKey
                                         , preventDefault : pd});
          } catch (error)
          {
           // console.log("key not found: ", e.key);
          }
        }
    </script>

Put the above in your index.html or in a js file for import if you like (without the <script> tags).

Then after your elm app initialization, you'll need to add a port subscription and an event listener, like so:

    <script>
      var app = Elm.Main.init( { node: document.getElementById("elm") });
      // Add these two lines!
      app.ports.sendKeyCommand.subscribe(sendKeyCommand);
      window.addEventListener( "keydown", keycheck, false );
    </script>


