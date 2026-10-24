-- все обьекты с отключенным ветшанием
-- SELECT object_id FROM properties WHERE name LIKE '%DecayTimestamp%' AND value = X'00000000f0f0f0f0';

/* Disable Decay for ADMIN buildings (remove %% for only "ADMIN" word)
(X'00000000F0F0F0F0') set decay to -
(X'00000000403f9e49') ~ (red timer??)*/

------------------------------------------------
-- ADMIN----
-- запустить таймер на 360 часов для ранее отключенныех построек
UPDATE properties SET value = X'0c020000f903000000000000403f9e49' WHERE name LIKE '%DecayTimestamp%' AND value = X'0c020000f903000000000000F0F0F0F0' AND object_id IN (SELECT object_id FROM buildings WHERE owner_id <> 0);

-- LISTs
-- 23.06 REDZONE BRAT2
--update player online
UPDATE characters SET lastTimeOnline = strftime('%s', 'now', '0 days') where char_name like 'BRAT2';
-- for clan
UPDATE properties SET 'value' = (X'0c020000f903000000000000F0F0F0F0') WHERE name like '%DecayTimestamp%' and object_id in (select distinct object_id from buildings where owner_id in (select distinct guildid from guilds where name like '%REDZONE%'));
UPDATE properties SET 'value' = (X'0c020000f90300000000000000000000') WHERE name like '%DecayState%' and object_id in (select distinct object_id from buildings where owner_id in (select distinct guildid from guilds where name like '%REDZONE%'));
-- for player
UPDATE properties SET 'value' = (X'0c020000f903000000000000F0F0F0F0') WHERE name like '%DecayTimestamp%' and object_id in (select distinct object_id from buildings where owner_id in (select distinct id from characters where char_name like 'BRAT2'));
UPDATE properties SET 'value' = (X'0c020000f90300000000000000000000') WHERE name like '%DecayState%' and object_id in (select distinct object_id from buildings where owner_id in (select distinct id from characters where char_name like 'BRAT2'));


-- Downgrade DB (remove new writes SocketlessConnectionFlagFix) вся магия таймера тут
UPDATE dw_settings SET value = REPLACE(value, 'SocketlessConnectionFlagFix', '') WHERE name = 'dbtags' AND value LIKE '%SocketlessConnectionFlagFix%';

.quit
