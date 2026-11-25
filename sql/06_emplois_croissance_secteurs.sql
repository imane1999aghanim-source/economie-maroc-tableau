-- Emplois créés et croissance par grand secteur
-- Projet : économie marocaine 2022-2025 (BigQuery, dataset Economie_marocaine)

WITH emplois AS (
  SELECT
    annee,
    CASE secteur
      WHEN 'Agriculture, forêt et pêche' THEN 'Agriculture'
      WHEN 'Industrie' THEN 'Industrie et bâtiment'
      WHEN 'Bâtiment et travaux publics' THEN 'Industrie et bâtiment'
      WHEN 'Services' THEN 'Services'
    END AS secteur_groupe,
    SUM(emplois_crees) AS emplois_crees
  FROM `bright-aloe-508623-v8.Economie_marocaine.emplois_par_secteur`
  WHERE secteur != 'Total économie'
  GROUP BY annee, secteur_groupe
),
croissance AS (
  SELECT
    p.annee,
    CASE p.groupe
      WHEN 'Primaire' THEN 'Agriculture'
      WHEN 'Secondaire' THEN 'Industrie et bâtiment'
      WHEN 'Tertiaire' THEN 'Services'
    END AS secteur_groupe,
    SUM(c.croissance_volume_pct * p.pib_mdh) / SUM(p.pib_mdh) AS croissance_pct
  FROM `bright-aloe-508623-v8.Economie_marocaine.pib_secteurs` p
  JOIN bright-aloe-508623-v8.Economie_marocaine.croissance_secteur c
    ON p.annee = c.annee AND p.code = c.code
  WHERE p.groupe IN ('Primaire', 'Secondaire', 'Tertiaire')
  GROUP BY p.annee, secteur_groupe
)
SELECT
  e.annee, e.secteur_groupe, e.emplois_crees,
  ROUND(c.croissance_pct, 1) AS croissance_pct
FROM emplois e
JOIN croissance c ON e.annee = c.annee AND e.secteur_groupe = c.secteur_groupe
ORDER BY e.annee, e.secteur_groupe;
