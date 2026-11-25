-- Commerce extérieur (exportations, importations, solde, couverture) et croissance par grand secteur. Le code U99 (tourisme) est inclus dans les services.
-- Projet : économie marocaine 2022-2025 (BigQuery, dataset Economie_marocaine)

WITH croissance AS (
  SELECT
    p.annee,
    CASE p.groupe
      WHEN 'Primaire' THEN 'Agriculture'
      WHEN 'Secondaire' THEN 'Industrie et bâtiment'
      WHEN 'Tertiaire' THEN 'Services'
    END AS secteur,
    SUM(c.croissance_volume_pct * p.pib_mdh) / SUM(p.pib_mdh) AS croissance_pct
  FROM `bright-aloe-508623-v8.Economie_marocaine.pib_secteurs` p
  JOIN `bright-aloe-508623-v8.Economie_marocaine.croissance_secteur` c
    ON p.annee = c.annee AND p.code = c.code
  WHERE p.groupe IN ('Primaire', 'Secondaire', 'Tertiaire')
  GROUP BY p.annee, secteur
),

commerce AS (
  SELECT
    annee,
    CASE
      WHEN code IN ('A00', 'A05') THEN 'Agriculture'
      WHEN code IN ('B00', 'DE0', 'F00') OR code LIKE 'C%' THEN 'Industrie et bâtiment'
      ELSE 'Services'
    END AS secteur,
    SUM(CASE WHEN flux = 'Exportations' THEN valeur_mdh ELSE 0 END) AS exportations_mdh,
    SUM(CASE WHEN flux = 'Importations' THEN valeur_mdh ELSE 0 END) AS importations_mdh
  FROM `bright-aloe-508623-v8.Economie_marocaine.commerce_exterieur`
  WHERE niveau = 'detail'
  GROUP BY annee, secteur
)

SELECT
  g.annee,
  g.secteur,
  ROUND(g.croissance_pct, 1) AS croissance_pct,
  co.exportations_mdh,
  co.importations_mdh,
  (co.exportations_mdh - co.importations_mdh) AS solde_commercial_mdh,
  ROUND(SAFE_DIVIDE(co.exportations_mdh, co.importations_mdh) * 100, 0) AS taux_couverture_pct
FROM croissance g
LEFT JOIN commerce co
  ON g.annee = co.annee AND g.secteur = co.secteur
ORDER BY g.annee, g.secteur;
