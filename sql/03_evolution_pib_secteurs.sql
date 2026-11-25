-- Évolution du PIB de chaque secteur d'une année à l'autre (en valeur, inflation comprise)
-- Projet : économie marocaine 2022-2025 (BigQuery, dataset Economie_marocaine)

SELECT
  secteur,
  annee,
  pib_mdh,
  LAG(pib_mdh) OVER (PARTITION BY secteur ORDER BY annee) AS pib_annee_precedente,
  pib_mdh - LAG(pib_mdh) OVER (PARTITION BY secteur ORDER BY annee) AS evolution_mdh,
  ROUND(
    (pib_mdh - LAG(pib_mdh) OVER (PARTITION BY secteur ORDER BY annee))
    / LAG(pib_mdh) OVER (PARTITION BY secteur ORDER BY annee) * 100, 2
  ) AS croissance_pct
FROM `bright-aloe-508623-v8.Economie_marocaine.pib_secteurs`
ORDER BY annee, evolution_mdh DESC
