/* Disable Decay for ADMIN buildings (remove %% for only "ADMIN" word)
(X'00000000F0F0F0F0') set decay to -
(X'00000000403f9e49') ~ (red timer??)*/
-- for clan
UPDATE properties SET 'value' = (X'00000000F0F0F0F0') WHERE name like '%DecayTimestamp%' and object_id in (select distinct object_id from buildings where owner_id in (select distinct guildid from guilds where name like '%111111111%'));
-- for player
UPDATE properties SET 'value' = (X'00000000F0F0F0F0') WHERE name like '%DecayTimestamp%' and object_id in (select distinct object_id from buildings where owner_id in (select distinct id from characters where char_name like '111111111'));

-- обновить онлайн игрока

UPDATE characters SET lastTimeOnline = strftime('%s', 'now', '0 days') where char_name like '111111111';
UPDATE properties SET 'value' = (X'00000000F0F0F0F0') WHERE name like '%DecayTimestamp%' and object_id in (select distinct object_id from buildings where owner_id in (select distinct guildid from guilds where name like '111111111'));

.quit
