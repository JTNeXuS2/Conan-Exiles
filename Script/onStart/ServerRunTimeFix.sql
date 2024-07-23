-- проверим таймер создания сервера (влияет на все ветшание) если его нет поставим сейчас + 1 день (86400)
WITH count_query AS (SELECT COUNT(*) AS count FROM dw_settings WHERE name = 'serverruntime') INSERT OR IGNORE INTO dw_settings (name, value) SELECT 'serverruntime', 86400 FROM count_query WHERE count = 0;
.quit
