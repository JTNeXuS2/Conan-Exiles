/* Disable Decay for ADMIN buildings (remove %% for only "ADMIN" word)
(X'00000000F0F0F0F0') set decay to -
(X'00000000403f9e49') ~ (red timer??)*/
-- for clan
UPDATE properties SET 'value' = (X'00000000F0F0F0F0') WHERE name like '%DecayTimestamp%' and object_id in (select distinct object_id from buildings where owner_id in (select distinct guildid from guilds where name like '%Admin%'));
-- for player
UPDATE properties SET 'value' = (X'00000000F0F0F0F0') WHERE name like '%DecayTimestamp%' and object_id in (select distinct object_id from buildings where owner_id in (select distinct id from characters where char_name like 'Illidan'));

-- fix old menthod script
-- Downgrade DB (remove new writes SocketlessConnectionFlagFix)
--UPDATE dw_settings SET 'value' = ('AccountIds;AccountTableIndexes;AddKillerIdToCharacter;BuildingStabilityLossMultiplier;CharacterIdReservation;DupeWipeOrbs1;FollowerMarkers;GameEventTable_Stack;GameEventsTable;GameEventsTable_ArgsMap;GuildChangeCausers;GuildEmblem;GuildNewRanks;GuildRescueCooldownExtension;PlaceableStabilityPropagationVersion;PurgeScores;Remove_DecayTime;SP_StringToText;ServerPopulation;SetHungerForExistingThralls;SmartObjectUsage;Static_Buildables_Table;lastServerTimeOnline') WHERE name like 'dbtags';

UPDATE dw_settings SET value = REPLACE(value, 'SocketlessConnectionFlagFix', '') WHERE name = 'dbtags' AND value LIKE '%SocketlessConnectionFlagFix%';

.quit
