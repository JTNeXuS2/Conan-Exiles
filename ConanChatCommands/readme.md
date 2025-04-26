#### Для ванильных серверов
    Позволяет логировать игровой чат в канал дискорда
    Чат команды !sethome / !home /!kit_name
#### For vannila server
    Allows logging of game chat to discord channel
    Chat Command !sethome / !home /!kit_name

#####  ===== Setup ===== 
request [python 3.10+](https://www.python.org/downloads/) 

execute

    python.exe -m pip install --upgrade pip
    pip install python-valve
    pip install mcrcon
    pip install python-dotenv
    pip install mysql-connector
or run 

    install.cmd

fill via notepad config in 

    .env

edit kits in CCC_DataBase.db via DB Browser for SQLite


support syntax kit command

 combo line command (recommended)

    spawnitem 1000 1|spawnitem 1002 2|spawnitem 1003 3|testfifo 0 Выдано
multi line command

    TeleportPlayer 0 0 0
    testfifo 0 Ready
Launch via

    !Start.cmd


P.S
to change lang notifications , change the contents of the loc(arg) block in ConanChatCommands.py:

#### more info \ Больше информации
##### [Рус Admins Discord](https://discord.gg/tf2KeZF8RF)
##### [Eng Admins Discord](https://discord.gg/admins-united-conan-278275567088828417)

## find me on [![Discord](https://discordapp.com/api/guilds/626106205122592769/widget.png?style=shield)](https://discord.gg/qYmBmDR)
### Donate
##### [yoomoney](https://yoomoney.ru/to/4100116619431314)
https://fkwallet.io  ID: F7202415841873335
##### [boosty](https://boosty.to/_illidan_)

