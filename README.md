# graphPON

![](https://raw.githubusercontent.com/yasuoza/graphPON/master/images/graphPON%20iOS/App%20Icon%20%5BRounded%5D/Icon-60@3x.png)

## Screens

![](https://raw.githubusercontent.com/yasuoza/graphPON/master/images/screenshot.png)

## HACK

- Register your application at https://api.iijmio.jp/mobile/d/.
- Copy `configuration.plist.example` to `configuration.plist`

        cp graphPON/{configuration.plist.example,configuration.plist}

- Replace `CLIENT_KEY` and `OAUTH_CALLBACK_URI` with your application configuration in `configuration.plist`.
- Use [Carthage](https://github.com/Carthage/Carthage) to resolve dependencies.

        carthage bootstrap
