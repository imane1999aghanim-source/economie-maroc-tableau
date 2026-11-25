-- Inflation et chômage côte à côte, avec variations (courbe de Phillips)
-- Projet : économie marocaine 2022-2025 (BigQuery, dataset Economie_marocaine)

WITH inflation AS (
  SELECT annee, variation_pct AS inflation_pct
  FROM `bright-aloe-508623-v8.Economie_marocaine.inflation2022`
  WHERE indicateur = 'IPC annuel moyen'

  UNION ALL

  SELECT annee, variation_pct AS inflation_pct
  FROM `bright-aloe-508623-v8.Economie_marocaine.inflation_2023_2024_2025`
  WHERE indicateur = 'IPC annuel moyen'
),

chomage AS (
  SELECT annee, valeur AS chomage_pct
  FROM `bright-aloe-508623-v8.Economie_marocaine.chomage2022`
  WHERE indicateur = 'Taux de chômage national'

  UNION ALL

  SELECT annee, valeur AS chomage_pct
  FROM `bright-aloe-508623-v8.Economie_marocaine.chomage_emploi`
  WHERE indicateur = 'Taux de chômage national'
),

final AS (
  SELECT
    i.annee,
    i.inflation_pct,
    c.chomage_pct
  FROM inflation i
  JOIN chomage c
    ON i.annee = c.annee
)

SELECT
  annee,
  inflation_pct,
  ROUND(inflation_pct - LAG(inflation_pct) OVER (ORDER BY annee), 1) AS variation_inflation_pts,
  chomage_pct,
  ROUND(chomage_pct - LAG(chomage_pct) OVER (ORDER BY annee), 1) AS variation_chomage_pts
FROM final
ORDER BY annee;
