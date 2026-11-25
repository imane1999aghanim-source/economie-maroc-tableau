-- Variation d'une année à l'autre de chaque composante du PIB par la demande (consommation, investissement, etc.)
-- Projet : économie marocaine 2022-2025 (BigQuery, dataset Economie_marocaine)

with etape1 as 
(select valeur_mdh,annee,part_pib_pct,composante,
Lag (valeur_mdh) over (partition by composante order by annee) as pib_precedent
 FROM `bright-aloe-508623-v8.Economie_marocaine.PIB_demande` order by part_pib_pct desc)
 select composante,valeur_mdh,annee,part_pib_pct,pib_precedent,round((valeur_mdh-pib_precedent) /pib_precedent*100, 2) as variation_part_pib_pct,
from etape1 order by annee,composante

