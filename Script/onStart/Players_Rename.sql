--------
--WITH temp AS (SELECT id FROM characters WHERE char_name LIKE 'Player_') UPDATE characters SET char_name = 'Player_' || (SELECT id FROM temp WHERE temp.id = characters.id) WHERE char_name LIKE 'Player_';

UPDATE characters SET char_name = 'Player_' || id where char_name like 'Player_';
UPDATE characters SET char_name = 'Player_' || id where char_name like '%ADMIN%';
UPDATE characters SET char_name = 'Player_' || id where char_name like 'Ku Klux Klan';

UPDATE characters SET char_name = 'Радио Тапки' where char_name like 'Радио Тапки Бля';
UPDATE characters SET char_name = 'ОЙ' where char_name like 'Pizdec';

.quit
