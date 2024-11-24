#!/usr/bin/python3
import asyncio
import sqlite3
import os
from glob import glob
from dotenv import load_dotenv
import re
import requests
import json
import time
from datetime import datetime, timedelta
import shutil
import sys

from valve.rcon import RCON, RCONMessageError, RCONAuthenticationError, RCONCommunicationError, RCONMessage, RCONTimeoutError
import socket
#import valve.source.a2s

load_dotenv()
kits = []
cases_kits = []
nick=home_name=kit_name=timer=get_kit=''

db_name = os.getenv('db_name', 'CCC_DataBase.db')
log_dir = os.getenv('log_dir', r'C:\CONAN\Server\Saved\Logs')
server_name = os.getenv('server_name', 'Server Name In Discord')
rcon_ip, rcon_port = os.getenv('rcon', '127.0.0.1:25000').split(':')
rcon_pass = os.getenv('rcon_pass', 'RconPassword')
chat_web_hook = os.getenv('chat_web_hook', None)
prefix = os.getenv('prefix', '!')
#chat_web_hook = None

def loc(arg):
    global nick, kit_name, home_name, timer, get_kit
    messages = {
        "welcome_back": f' \\"				{nick}				" С возвращением!',
        "cooldown": f'\\"				кулдаун {timer}				" "{get_kit}" уже использован.',
        "for_single_used": f' \\"							{get_kit}							" Для разового использования!',
        "return_notfound": f"Точка возвращения {home_name} не найдена.",
        "bed_notfound": f"Ошибка Не найдена кровать или подстилка!",
        "kit_end": f"{kit_name} Кит выполнен.",
        "set_home": f"Точка возврата установлена.",
        "help_button": f"""
">> !help - это окно"
">> !sethome - отвязать от кровати и сохранить точку возврата"
">> !home - телепорт на сохраненную точку"
">> !home bed - телепорт на кровать"
">> !start - стартовый набор"
">> !start2 - тестовый набор"
""",
        "help": f"""
\\"          !help          " это окно
\\"          !sethome          " отвязать от кровати и сохранить точку возврата
\\"          !home          " телепорт на сохраненную точку
\\"          !home bed          " телепорт на кровать
\\"          !start          " стартовый набор
\\"          !start2          " тестовый набор
"""
    }
    return messages.get(arg, "string not found")


def check_db():
    database_structure = {
        'Kits': {
            'columns': ['kit_name', 'commands', 'cd', 'useonce'],
            'unique': ['kit_name']
        },
        'AccountCD': {
            'columns': ['platform_id', 'player_name', 'kit_name', 'cooldown_date'],
            'unique': ['platform_id', 'kit_name']
        },
        'SetHome': {
            'columns': ['platform_id', 'player_name', 'home_name', 'x', 'y', 'z'],
            'unique': ['platform_id', 'home_name']
        }
    }
    if not os.path.exists(db_name):
        conn = sqlite3.connect(db_name)
        print(f'Create DB: {db_name}')
    else:
        conn = sqlite3.connect(db_name)
        print(f'Found DB: {db_name}')
    cursor = conn.cursor()
    for table_name, structure in database_structure.items():
        columns = structure['columns']
        unique_columns = structure['unique']
        column_defs = ', '.join([f"{col} TEXT" for col in columns])

        unique_constraint = ''
        if unique_columns:
            unique_constraint = f", UNIQUE({', '.join(unique_columns)})"
        cursor.execute(f"""
            CREATE TABLE IF NOT EXISTS {table_name} (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                {column_defs}
                {unique_constraint}
            )
        """)
        cursor.execute(f"PRAGMA table_info({table_name})")
        existing_columns = [column[1] for column in cursor.fetchall()]

        for column in columns:
            if column not in existing_columns:
                cursor.execute(f"ALTER TABLE {table_name} ADD COLUMN {column} TEXT")
                print(f'add: {column} in table {table_name}')

    conn.commit()

    # Создание уникального индекса для комбинации колонок, если он не существует
    for table_name, structure in database_structure.items():
        unique_columns = structure['unique']
        if len(unique_columns) > 1:  # Проверяем, что есть более одной колонки для уникального индекса
            index_name = f"idx_{table_name}_" + "_".join(unique_columns)
            cursor.execute(f"""
                CREATE UNIQUE INDEX IF NOT EXISTS {index_name} ON {table_name} ({', '.join(unique_columns)})
            """)
    conn.commit()
    conn.close()

def get_kits():
    global kits
    conn = sqlite3.connect(db_name)
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Kits")
    kits = cursor.fetchall()
    conn.close()

def send_rcon_command(host, port, rcon_password, command, raise_errors=False, num_retries=4, timeout=3):
    try:
        port = int(port)
    except ValueError:
        return "Port connection Error"
    for attempt in range(num_retries):
        try:
            with RCON((host, port), rcon_password, timeout=timeout) as rcon:
                RCONMessage.ENCODING = "utf-8"
                return rcon(command)
        except KeyError:
            raise RconError('Incorrect rcon password')
        except (socket.error, socket.timeout, RCONMessageError, RCONAuthenticationError) as e:
            if attempt == num_retries - 1:
                if raise_errors:
                    raise RconError(str(e))
                return "Connection error"
            print("Repeat connect to RCON")
    return "Max retries reached"

### MAIN Function
async def watch_log_file(directory):
    log_file_path = os.path.join(directory, 'ConanSandbox.log')
    if not os.path.isfile(log_file_path):
        print("No log file found. Exiting!!!.")
        return

    file_position = os.path.getsize(log_file_path)
    print("Conan Chat Commands watch log start!\n")
    ### MAIN Cycle
    while True:
        try:
            # Проверка наличия update.py
            update_file_path = os.path.join('update.py')
            #print(f"update_file_path {update_file_path}")
            if os.path.exists(update_file_path):
                # Переименование update.py в ConanChatCommands.py
                target_file_path = os.path.join('ConanChatCommands.py')
                shutil.move(update_file_path, target_file_path)
                print("Updated ConanChatCommands.py from update.py. Restarting...")
                # Перезапуск программы
                #os.execv(sys.executable, ['python'] + sys.argv)
                sys.exit(0)

            # Проверка на случай, если файл был очищен
            current_size = os.path.getsize(log_file_path)
            if current_size < file_position:
                print("Log file has been cleared. Resetting file position.")
                file_position = 0

            with open(log_file_path, 'r', encoding='utf-8') as file:
                file.seek(file_position)
                lines = file.readlines()
                file_position = file.tell()

            for line in lines:
                process_line(line)

        except Exception as e:
            print(f"watch_log_file Error: {e}")
            await asyncio.sleep(5)
            continue
        await asyncio.sleep(1)
def find_latest_file(directory):
    log_file_path = os.path.join(directory, 'ConanSandbox.log')
    try:
        if os.path.isfile(log_file_path):
            return log_file_path
    except Exception as e:
        print(f"Error checking log file {log_file_path}: {e}")
    print(f'Log {log_file_path} NOT FOUND.')
    return None

def chat_to_dis(player_nick, message):
    def escape_markdown(text):
        markdown_chars = ['\\', '*', '_', '~', '`', '>', '|']
        for char in markdown_chars:
            text = text.replace(char, '\\' + char)
        return text
    def truncate_message(text, max_length=2000):
        return text if len(text) <= max_length else text[:max_length-3] + '...'
    player_nick = escape_markdown(player_nick)
    message = escape_markdown(message)
    message = truncate_message(message)
    parts = message.split("^^&&", 1)
    text = parts[1] if len(parts) > 1 else parts[0]
    formatted_message = f"**{server_name}**:**{player_nick}**: {text}"
    data = {"content": formatted_message}
    response = requests.post(chat_web_hook, json=data)
    if response.status_code != 204:
        print(f"Error sending message to Discord: {response.status_code} - {response.text}")

def process_line(line):
    global nick
    try:
        if 'ChatWindow:' not in line or '[Pippi]PippiChat' in line:
            if '[Pippi]PippiChat' in line:
                print(f"PIPPI chat not support {line}")
            return
        content = line.split('ChatWindow:')[1].strip()
        match = re.search(r'^(.*?) said: (.+?)$', content)
        if not match:
            return
        character_match = re.search(r'Character (.+?)\s*\(uid', match.group(1).strip())
        if not character_match:
            return

        nick = character_match.group(1).strip()
        message = match.group(2).strip()
        uid_match = re.search(r'uid (\d+)', content)
        player_match = re.search(r'player (\d+)', content)
        #print(f' nick: {nick}\n uid: {uid_match.group(1) if uid_match else None}\n player: {player_match.group(1) if player_match else None}\n message: {message}\n')

        ### Send message to discord
        if chat_web_hook is not None:
            chat_to_dis(nick, message)
        ### Find Call kit
        if message.startswith(f'{prefix}'):
            global kits, get_kit
            get_kit = ''
            get_kit = f"{message.split(f'{prefix}')[-1]}"
            print(f" >>>>> Поиск кита {get_kit}")
            get_kits()
            #	 idx	name		command	cd		once
            cases_kits = [
                (None,	'help',		None,	'0',	None),
                (None,	'sethome',	None,	'0',	None),
                (None,	'home',		None,	'0',	None),
                (None,	'home bed',	None,	'0',	None)
            ]
            kits.extend(cases_kits)

            #print(f"ALL KITS>>\n{kits}")
            for kit in kits:
                if f"{prefix}{kit[1]}" == f"{prefix}{get_kit}": # or f"{get_kit}" in cases_kits:
                    platformid = player_match.group(1)
                    in_cooldown, result = check_cooldown(platformid, get_kit)

                    ### Check  useonce
                    if kit[4] is not None and kit[4].strip() != "0":
                        print(f"Kit name {get_kit} for single used and already executed..")
                        send_notify('1', loc("for_single_used"), get_player_index(platformid))
                        break
                    ### WORK SKIPPING
                    if in_cooldown and result:
                        global timer
                        print(f"User {nick} has already executed the kit today, skipping.\n")

                        target_time = datetime.strptime(result[4], '%Y-%m-%d %H:%M:%S')
                        time_difference = target_time - datetime.now()
                        days, hours, remainder = time_difference.days, *divmod(time_difference.seconds, 3600)
                        minutes, seconds = divmod(remainder, 60)
                        timer = f"{days}д:{hours:02}ч:{minutes:02}м:{seconds:02}с" if days > 0 or hours > 0 else f"{minutes:02}м:{seconds:02}с"
                        send_notify('1', loc("cooldown"), get_player_index(platformid))
                        return
                    ### WORK
                    if platformid:
                        process_kits(nick, platformid, kit, get_kit)
                    else:
                        print(f"Account ID {platformid} not found for process_kits.")
                    break
            print(f" >>>>> Завершена обработка {get_kit}")
    except Exception as e:
        print(f"process_line error: {e}")

# sql SELECT ap.x, ap.y, ap.z FROM actor_position ap JOIN characters c ON ap.id = c.id WHERE c.char_name = 'Illidan'
# sql SELECT HEX(value) AS hex_value FROM properties WHERE object_id = 812 AND name = 'BP_BAC_SpawnPoints_C.OwnerNetId';
def process_kits(nick, platformid, kit, get_kit):
    conn = None
    today = datetime.now()
    #kit_name = kit[1]
    global home_name, kit_name
    kit_name = get_kit
    #print(f'PROCCESS_KITS >> {kit}')
	# метод (устарело) разбиение команд кита для поштучного ввода
    #command_list = kit[2].strip().replace('{steamid}', platformid).split("\r\n") if kit[2] is not None else ''
    command_string = kit[2].strip() if kit[2] is not None else ''
    command_string = command_string.replace('{steamid}', platformid).replace('{kit_name}', kit_name)
    command_list = command_string.split("\r\n")
    # метод (новый) для ввода всех команд за раз
    command_list = '|'.join(command_list)
    cooldown = int(kit[3]) if kit[3] else 1440
    cooldown_date = (today + timedelta(minutes=cooldown)).strftime('%Y-%m-%d %H:%M:%S')
    print(f" >>work for >> nick:{nick} id:{platformid}")
    print(f" >>KIT>> {kit}")
    print(f" >>Name>> {kit_name} CD>> {cooldown} Date>> {cooldown_date}")

    # Формируем полное имя команды cases_kits
    match f"{kit_name}":
        case "help":
            print(f" >> CASE {kit_name}")

            #message = f"Это первая строка Help \n Это строка с переносом \\n \rЭта строка с переносом \\r"
            print("send_notify_button")
            if any(char.isspace() for char in nick):
                message = loc("help")
                message = '|'.join(f'testfifo 2 {line.strip()}' for line in message.strip().split('\n'))
                player_idx = get_player_index(platformid)
                command = f"con {player_idx} {message}"
                result = send_rcon_command(rcon_ip, rcon_port, rcon_pass, command, num_retries=4, timeout=3)
                #send_notify('2', message, get_player_index(platformid))
            else:
                message = loc("help_button")
                send_notify_button(message, get_player_index(platformid), nick)


        case "sethome":
            print(f" >> CASE {kit_name}")
            # Get Spawn Pos
            x, y ,z = sethome(platformid)
            if x and y and z:
                # Write Spawn Pos to db
                conn = sqlite3.connect(db_name)
                cursor = conn.cursor()
                home_name = f"1"
                db_write = "INSERT OR REPLACE INTO SetHome (platform_id, player_name, home_name, x, y, z) VALUES (?, ?, ?, ?, ?, ?);"
                cursor.execute(db_write, (platformid, nick, home_name, x, y ,z))
                conn.commit()
                #message = f"'Точка возврата {home_name} установлена."
                message = loc("set_home")
                send_notify('2', message, get_player_index(platformid))
            else:
                message = loc("bed_notfound")
                send_notify('2', message, get_player_index(platformid))

        case "home":
            print(f" >> CASE {kit_name}")
            # Get Spawn Pos from DB
            conn = sqlite3.connect(db_name)
            cursor = conn.cursor()
            home_name = '1'
            cursor.execute("SELECT x, y, z FROM SetHome WHERE platform_id = ? AND home_name = ?", (platformid, home_name))
            result = cursor.fetchone()
            if result:
                x, y, z = result
                print(f"x: {x}, y: {y}, z: {z}")
                message = loc("welcome_back")
                player_idx = get_player_index(platformid)
                teleport_home = f"con {player_idx} TeleportPlayer {x} {y} {z}|testfifo 2 {message}"
                result = send_rcon_command(rcon_ip, rcon_port, rcon_pass, teleport_home, num_retries=4, timeout=3)
                #send_notify('2', message, player_idx)
            else:
                print("No data found.")
                message = loc("return_notfound")
                player_idx = get_player_index(platformid)
                send_notify('2', message, player_idx)

        case "home bed":
            print(f" >> CASE home bed {kit_name}")
            # Get Spawn Pos from DB
            x, y ,z = sethome(platformid)
            if x and y and z:
                print(f" TELEPORT TO x: {x}, y: {y}, z: {z}")
                message = loc("welcome_back")
                player_idx = get_player_index(platformid)
                teleport_home = f"con {player_idx} TeleportPlayer {x} {y} {z}|testfifo 2 {message}"
                result = send_rcon_command(rcon_ip, rcon_port, rcon_pass, teleport_home, num_retries=4, timeout=3)
            else:
                message = loc("bed_notfound")
                send_notify('2', message, get_player_index(platformid))

        case _:
            print(f" >> CASE {kit_name}")
            player_idx = get_player_index(platformid)
            message = loc("kit_end")

            command_list = f'con {player_idx} {command_list}|testfifo 2 {message}'
            command_list = [command_list, '']
            # выполнения команд
            for command in command_list:
                if command:
                    result = send_rcon_command(rcon_ip, rcon_port, rcon_pass, command, num_retries=4, timeout=3)
            #send_notify('2', message, player_idx)

    # Запись в базу данных
    try:
        # Write Kit Cooldown in db
        conn = sqlite3.connect(db_name)
        cursor = conn.cursor()
        db_write = "INSERT OR REPLACE INTO AccountCD (platform_id, player_name, kit_name, cooldown_date) VALUES (?, ?, ?, ?);"
        cursor.execute(db_write, (platformid, nick, kit_name, cooldown_date))
        conn.commit()
        print(f"Запись {platformid} {nick} {kit_name} {cooldown_date} добавлена в базу данных.")
    except Exception as e:
        print(f"process_kits Error write to database: {e}")
    finally:
        if conn:
            conn.close()
			
def send_notify(type, message, player_idx):
    notify_cmd = f'con {player_idx} testfifo {type} {message}'
    result = send_rcon_command(rcon_ip, rcon_port, rcon_pass, notify_cmd, num_retries=4, timeout=3)
def send_notify_button(message, player_idx, nick):
    notify_cmd = f"""con {player_idx} PlayerMessage "{nick}" {message}"""
    result = send_rcon_command(rcon_ip, rcon_port, rcon_pass, notify_cmd, num_retries=4, timeout=3)

def get_player_index(platformid):
    result = send_rcon_command(rcon_ip, rcon_port, rcon_pass, 'listplayers', num_retries=4, timeout=2)
    for line in result.strip().split("\n")[1:]:
        parts = [part.strip() for part in line.split("|")]
        if len(parts) > 4 and parts[4] == platformid:
            return parts[0]
    print(f"Player {platformid} not found.")
    return None

def sethome(platformid):
    getpos = f"""
WITH filtered_values AS (
    SELECT object_id
    FROM (
        SELECT object_id,
               CASE 
                   WHEN SUBSTR(hex(value), 1, 10) = '0000000024' THEN CAST(SUBSTR(value, 23, 17) AS TEXT)
                   WHEN SUBSTR(hex(value), 1, 10) = '0000000042' THEN CAST(SUBSTR(value, 22, 32) AS TEXT)
                   WHEN SUBSTR(hex(value), 1, 10) = '0000000022' THEN CAST(SUBSTR(value, 25, 16) AS TEXT)
                   ELSE NULL 
               END AS processed_value
        FROM properties
        WHERE name = 'BP_BAC_SpawnPoints_C.OwnerNetId'
    ) AS pv
    WHERE processed_value = '{platformid}')
SELECT x || ' ' || y || ' ' || z AS ''
FROM actor_position
WHERE id = (
    SELECT object_id
    FROM filtered_values
    LIMIT 1
)
UNION ALL
SELECT 'empty'
WHERE NOT EXISTS (
    SELECT 1
    FROM filtered_values
);
    """
    try:
        command = f'sql {getpos}'
        result = send_rcon_command(rcon_ip, rcon_port, rcon_pass, command, num_retries=4, timeout=3)
        #print(f" >> result {result}")
        if "empty" in result:
            print(" >> Player dont have bed or not found")
            return None, None, None
        else:
            # Разделяем строку по пробелам и фильтруем пустые элементы
            parts = list(filter(None, result.split(' ')))
            x = f'{parts[1]}'
            y = f'{parts[2]}'
            z = f'{parts[3]}'
            #y = str(float(parts[2]) + 10)
            z = str(float(parts[3]) + 300)
            return x, y, z
    except Exception as e:
        print(f"sethome error get coords: {e}")
        return None, None, None

###########################################
def log_to_file(text):
    today = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    string = f"{today} >> {text}"
    try:
        with open(logging_file, 'a', encoding='utf-8') as file:
            file.write(string + '\n')
    except Exception as e:
        print(f"Error while logging to file: {e}")

def check_cooldown(steam_id, get_kit):
    today = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    conn = None
    try:
        conn = sqlite3.connect(db_name)
        cursor = conn.cursor()
        cursor.execute("""SELECT * FROM AccountCD WHERE platform_id = ? AND kit_name = ?""", (steam_id, get_kit))
        result = cursor.fetchone()
        if result:
            cooldown_date = result[4]
            in_cooldown = cooldown_date >= today
            return in_cooldown, result
        else:
            return False, result
    except Exception as e:
        print(f"check_cooldown Error: {e}")
        return False, result
    finally:
        if conn:
            conn.close()

async def main():
    check_db()
    get_kits()
    await watch_log_file(log_dir)

asyncio.run(main())
