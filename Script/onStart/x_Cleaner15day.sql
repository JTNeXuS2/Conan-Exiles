update characters set lastTimeOnline = strftime('%s', 'now') where lastTimeOnline is NULL;
delete from buildable_health where object_id in (select distinct object_id from buildings where owner_id in (select id from characters where lastTimeOnline < strftime('%s', 'now', '-15 days')) and owner_id not in (select id from characters where guild in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null)));
delete from buildable_health where object_id in (select distinct object_id from buildings where owner_id in (select guildid from guilds where guildid not in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null)));
delete from building_instances where object_id in (select distinct object_id from buildings where owner_id in (select id from characters where lastTimeOnline < strftime('%s', 'now', '-15 days')) and owner_id not in (select id from characters where guild in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null)));
delete from building_instances where object_id in (select distinct object_id from buildings where owner_id in (select guildid from guilds where guildid not in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null)));
delete from properties where object_id in (select distinct object_id from buildings where owner_id in (select id from characters where lastTimeOnline < strftime('%s', 'now', '-15 days')) and owner_id not in (select id from characters where guild in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null)));
delete from properties where object_id in (select distinct object_id from buildings where owner_id in (select guildid from guilds where guildid not in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null)));
delete from properties where object_id in (select id from characters where lastTimeOnline < strftime('%s', 'now', '-15 days')) and object_id not in (select id from characters where guild in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null));
delete from actor_position where id in (select distinct object_id from buildings where owner_id in (select id from characters where lastTimeOnline < strftime('%s', 'now', '-15 days')) and owner_id not in (select id from characters where guild in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null)));
delete from actor_position where id in (select distinct object_id from buildings where owner_id in (select guildid from guilds where guildid not in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null)));
delete from buildings where owner_id in (select id from characters where lastTimeOnline < strftime('%s', 'now', '-15 days') and guild is null);
delete from buildings where owner_id in (select guildid from guilds where guildid not in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null));
delete from item_properties where owner_id in (select id from characters where lastTimeOnline < strftime('%s', 'now', '-15 days')) and owner_id not in (select id from characters where guild in (select guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null));
delete from item_properties where owner_id in (select guildid from guilds where guildid not in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null));
delete from item_inventory where owner_id in (select id from characters where lastTimeOnline < strftime('%s', 'now', '-15 days')) and owner_id not in (select id from characters where guild in (select guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null));
delete from item_inventory where owner_id in (select guildid from guilds where guildid not in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null));
delete from actor_position where id in (select id from characters where lastTimeOnline < strftime('%s', 'now', '-15 days') and id not in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null));
delete from actor_position where id in (select guildid from guilds where guildid not in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null));
delete from character_stats where char_id in (select id from characters where lastTimeOnline < strftime('%s', 'now', '-15 days') and guild is null);
delete from character_stats where char_id in (select id from characters where lastTimeOnline < strftime('%s', 'now', '-15 days') and guild not in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null));
delete from characters where id in (select id from characters where lastTimeOnline < strftime('%s', 'now', '-15 days') and guild is null);
delete from characters where id in (select id from characters where lastTimeOnline < strftime('%s', 'now', '-15 days') and guild not in (select distinct guild from characters where lastTimeOnline > strftime('%s', 'now', '-15 days') and guild is not null));

.quit