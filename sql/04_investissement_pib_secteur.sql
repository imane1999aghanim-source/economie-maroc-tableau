-- Investissement (FBCF) en % du PIB de chaque grand secteur
-- Projet : économie marocaine 2022-2025 (BigQuery, dataset Economie_marocaine)

WITH pib_groupe AS (
  SELECT
    annee,
    'Agriculture, forêt et services annexes' AS groupe_secteurs,
    SUM(pib_mdh) AS pib_mdh
  FROM `bright-aloe-508623-v8.Economie_marocaine.pib_secteurs`
  WHERE groupe = 'Primaire'
  GROUP BY annee

  UNION ALL

  SELECT
    annee,
    'Industrie et bâtiment' AS groupe_secteurs,
    SUM(pib_mdh) AS pib_mdh
  FROM `bright-aloe-508623-v8.Economie_marocaine.pib_secteurs`
  WHERE groupe = 'Secondaire'
  GROUP BY annee

  UNION ALL

  SELECT
    annee,
    'Services' AS groupe_secteurs,
    SUM(pib_mdh) AS pib_mdh
  FROM `bright-aloe-508623-v8.Economie_marocaine.pib_secteurs`
  WHERE groupe = 'Tertiaire'
  GROUP BY annee
),

investissement_groupe AS (
  SELECT
    annee,
    CASE
      WHEN groupe_secteurs IN ('Industrie', 'Bâtiment et travaux publics') THEN 'Industrie et bâtiment'
      ELSE groupe_secteurs
    END AS groupe_secteurs,
    SUM(fbcf_mdh) AS fbcf_mdh
  FROM `bright-aloe-508623-v8.Economie_marocaine.investissement`
  GROUP BY annee, groupe_secteurs
)

SELECT
  i.annee,
  i.groupe_secteurs,
  p.pib_mdh,
  i.fbcf_mdh AS investissement_mdh,
  ROUND(SAFE_DIVIDE(i.fbcf_mdh, p.pib_mdh) * 100, 1) AS investissement_pct_du_pib_secteur
FROM investissement_groupe i
JOIN pib_groupe p
  ON i.annee = p.annee AND i.groupe_secteurs = p.groupe_secteurs
ORDER BY i.annee, i.groupe_secteurs;

