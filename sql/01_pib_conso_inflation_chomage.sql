-- PIB, consommation des ménages, inflation et chômage, avec variations d'une année à l'autre
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

conso AS (
  SELECT
    annee,
    valeur_mdh AS conso_menages_mdh,
    part_pib_pct,
    ROUND(valeur_mdh / (part_pib_pct / 100), 0) AS pib_total_mdh,
    ROUND(
      SAFE_DIVIDE(
        valeur_mdh - LAG(valeur_mdh) OVER (ORDER BY annee),
        LAG(valeur_mdh) OVER (ORDER BY annee)
      ) * 100, 1
    ) AS variation_conso_pct
  FROM `bright-aloe-508623-v8.Economie_marocaine.pib_par_demande1`
  WHERE composante LIKE 'Consommation finale des m%'
)

SELECT
  i.annee,
  co.pib_total_mdh,
  co.conso_menages_mdh,
  co.variation_conso_pct,
  i.inflation_pct,
  ROUND(i.inflation_pct - LAG(i.inflation_pct) OVER (ORDER BY i.annee), 1) AS variation_inflation_pts,
  c.chomage_pct,
  ROUND(c.chomage_pct - LAG(c.chomage_pct) OVER (ORDER BY i.annee), 1) AS variation_chomage_pts
FROM inflation i
JOIN chomage c ON i.annee = c.annee
LEFT JOIN conso co ON i.annee = co.annee
ORDER BY i.annee;
  
