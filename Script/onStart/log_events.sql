--REPORTS
--EXPORT 3day log
.headers on
.mode csv
.once log_events.csv
select datetime(ge.worldTime, 'unixepoch', 'localtime') as WorldTime, ROUND(ge.X, 3) ||' '|| ROUND(ge.Y, 3) ||' '|| ROUND(ge.Z, 3) as 'X Y Z',
case ge.eventType WHEN '0' then 'Старт сервер' WHEN '1' then 'Стоп Сервер' WHEN '85' then 'CHARACTER BEGIN' WHEN '86' then 'убит' WHEN '87' then 'Разрушен объект' 
WHEN '88' then 'Разрушен блок(и)' WHEN '89' then 'Раб вернулся' WHEN '90' then 'Раб голодает' WHEN '91' then 'Несанкционированный доступ' WHEN '92' then 'Дружественный доступ' 
WHEN '93' then 'Обокраден' WHEN '94' then 'Дружественный доступ' WHEN '95' then 'Аватар призван' WHEN '96' then 'Купол призван' WHEN '97' then 'Создание алтаря Т3' 
WHEN '98' then 'Алтарь Т3 построен' WHEN '99' then 'блок(и) демонтирован' WHEN '100' then 'Постройка разобрана' WHEN '101' then 'Постройка снесена' WHEN '102' then 'Раб украден' 
WHEN '103' then 'погиб' WHEN '104' then 'умер от голода' WHEN '105' then 'Умер от температуры' WHEN '106' then 'Раб удален' WHEN '107' then 'Убит под картой' 
WHEN '170' then 'СИСТЕМЫ НАЧАЛО' WHEN '171' then 'Начало ветшать' WHEN '172' then 'Потеря стабильности' WHEN '173' then 'Обветшало' WHEN '174' then 'Компонент Потеря стабильности' 
WHEN '175' then 'Чистка началась' WHEN '176' then 'Чистка завершена' WHEN '177' then 'Сумка сгнила' WHEN '178' then 'Сумка уничтожена' 
WHEN '179' then 'Тралл обветшал' ELSE ge.eventType END 'Событие', 

case ge.ownerName WHEN '' then '>>' ELSE ge.ownerName END 'Владелец',
'	' || ge.ownerGuildName as 'Клан Владелец',
case ge.objectName WHEN '' then '	' ELSE ge.objectName END 'Объект (ID)',
case ge.causerName WHEN '' then '=>' ELSE ge.causerName END 'Причинятель',
'	' || ge.causerGuildName as 'Клан Причинятель',

REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ge.argsMap, '{', '' ), '}', '' ), ',', '
' ), ':', '' ), '"', ' ' ), 'thrallTemplateId ', 'Раб:' ), 'itemTemplateId ', 'ID:
' ), 'persistentCauser ', 'Causer:
' ), 'nonPersistentCauser', 'nonCauser:
' ), '
', ' ' ), char(10), '') as 'itemTemplateId',
ge.stack as 'stack' from game_events as ge where ge.worldTime > strftime('%s', 'now', '-3 days') order by WorldTime desc;

-- full log
.headers on
.mode csv
.once log_events_full.csv
select datetime(ge.worldTime, 'unixepoch', 'localtime') as WorldTime, 
quote(ge.ownerName) as 'Владелец',
quote(ge.ownerGuildName) as 'Клан Владелец',
case ge.eventType WHEN '0' then 'Старт сервер' WHEN '1' then 'Стоп Сервер' WHEN '85' then 'CHARACTER BEGIN' WHEN '86' then 'убит' WHEN '87' then 'Разрушен объект' 
WHEN '88' then 'Разрушен блок(и)' WHEN '89' then 'Раб вернулся' WHEN '90' then 'Раб голодает' WHEN '91' then 'Несанкционированный доступ' WHEN '92' then 'Дружественный доступ' 
WHEN '93' then 'Обокраден' WHEN '94' then 'Дружественный доступ' WHEN '95' then 'Аватар призван' WHEN '96' then 'Купол призван' WHEN '97' then 'Создание алтаря Т3' 
WHEN '98' then 'Алтарь Т3 построен' WHEN '99' then 'блок(и) демонтирован' WHEN '100' then 'Постройка разобрана' WHEN '101' then 'Постройка снесена' WHEN '102' then 'Раб украден' 
WHEN '103' then 'погиб' WHEN '104' then 'умер от голода' WHEN '105' then 'Умер от температуры' WHEN '106' then 'Раб удален' WHEN '107' then 'Убит под картой' 
WHEN '170' then 'СИСТЕМЫ НАЧАЛО' WHEN '171' then 'Начало ветшать' WHEN '172' then 'Потеря стабильности' WHEN '173' then 'Обветшало' WHEN '174' then 'Компонент Потеря стабильности' 
WHEN '175' then 'Чистка началась' WHEN '176' then 'Чистка завершена' WHEN '177' then 'Сумка сгнила' WHEN '178' then 'Сумка уничтожена' 
WHEN '179' then 'Тралл обветшал' ELSE ge.eventType END 'Событие', 
quote(ge.objectName) as 'Объект (ID)',
quote(ge.causerName) as 'Причинятель',
quote(ge.causerGuildName) as 'Клан Причинятель',
quote(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ge.argsMap, '{', '' ), '}', '' ), ',', '
' ), ':', '' ), '"', '' ), 'thrallTemplateId ', 'Раб:' ), 'itemTemplateId ', 'ID:
' ), 'persistentCauser ', 'Causer:
' ), 'nonPersistentCauser', 'nonCauser:
' ), '
', '' ), ' ', '' ) )as 'itemTemplateId',
quote(ge.stack) as 'stack' from game_events as ge order by WorldTime desc;

.quit