SELECT poke.identifier           AS name
     , poke.species_id           AS number
     , gen_names.name            AS generation
     , typ.types                 AS types
     , spec_names.genus          AS genus
     , poke.height               AS height
     , poke.weight               AS weight
     , species.capture_rate      AS capture_rate
     , poke.base_experience      AS base_experience
     , poke_abilities.identifier AS abilities
     , ev.ev_data                AS effort_values
  FROM pokemon AS poke
  JOIN pokemon_species AS species
    ON poke.identifier = species.identifier
  JOIN generation_names AS gen_names
    ON species.generation_id = gen_names.generation_id
  JOIN (
	SELECT poke.identifier AS name
	     , string_agg(typ.identifier, ', ')  AS types
	  FROM pokemon_types   AS poke_types
	  JOIN pokemon AS poke
	    ON poke_types.pokemon_id = poke.id
	  JOIN types AS typ 
	    ON poke_types.type_id = typ.id
         GROUP BY poke.identifier
       ) AS typ
    ON typ.name = poke.identifier
  JOIN (
        SELECT genus
             , pokemon_species_id
             , name
          FROM pokemon_species_names
         WHERE local_language_id = 9
       ) AS spec_names
    ON spec_names.pokemon_species_id = poke.species_id
  JOIN (
        SELECT string_agg(abil.identifier, ', ') AS identifier
             , poke_abil.pokemon_id
          FROM pokemon_abilities as poke_abil
          JOIN abilities as abil
            ON poke_abil.ability_id = abil.id
         GROUP BY poke_abil.pokemon_id
       ) AS poke_abilities
    ON poke_abilities.pokemon_id = poke.species_id
  JOIN (
        SELECT poke_stats.pokemon_id
             , concat(stats.identifier, ', ', poke_stats.effort) AS ev_data
          FROM pokemon_stats AS poke_stats
          JOIN stats
            ON stats.id = poke_stats.stat_id
         WHERE poke_stats.effort > 0
       ) AS ev
    ON ev.pokemon_id = poke.species_id
 WHERE poke.is_default = 't'
   AND gen_names.local_language_id = 9
 ORDER BY poke.species_id;
