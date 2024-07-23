/* Remove old event logs */
delete from game_events where worldTime < strftime('%s', 'now', '-5 days');
.quit
