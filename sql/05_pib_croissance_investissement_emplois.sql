-- PIB, croissance, investissement et emplois créés par grand secteur
-- Projet : économie marocaine 2022-2025 (BigQuery, dataset Economie_marocaine)

WITH pib AS (
  SELECT
    p.annee,
    CASE
      WHEN p.groupe = 'Primaire' THEN 'Agriculture'
      WHEN p.groupe = 'Secondaire' THEN 'Industrie et bâtiment'
      ELSE 'Services'
    END AS secteur_groupe,
    SUM(p.pib_mdh) AS pib_mdh,
    ROUND(SUM(p.part_pib_pct), 1) AS part_pib_pct,
    ROUND(SAFE_DIVIDE(SUM(p.pib_mdh * c.croissance_volume_pct), SUM(p.pib_mdh)), 1) AS croissance_pct
  FROM `bright-aloe-508623-v8.Economie_marocaine.pib_secteurs` p
  JOIN `bright-aloe-508623-v8.Economie_marocaine.croissance_secteur` c
    ON p.annee = c.annee AND p.code = c.code
  WHERE p.groupe IN ('Primaire', 'Secondaire', 'Tertiaire')
  GROUP BY p.annee, secteur_groupe
),

invest AS (
  SELECT
    annee,
    CASE
      WHEN groupe_secteurs LIKE 'Agriculture%' THEN 'Agriculture'
      WHEN groupe_secteurs IN ('Industrie', 'Bâtiment et travaux publics') THEN 'Industrie et bâtiment'
      ELSE 'Services'
    END AS secteur_groupe,
    SUM(fbcf_mdh) AS investissement_mdh
  FROM `bright-aloe-508623-v8.Economie_marocaine.investissement`
  GROUP BY annee, secteur_groupe
),

emploi AS (
  SELECT
    annee,
    CASE
      WHEN secteur LIKE 'Agriculture%' THEN 'Agriculture'
      WHEN secteur IN ('Industrie', 'Bâtiment et travaux publics') THEN 'Industrie et bâtiment'
      ELSE 'Services'
    END AS secteur_groupe,
    SUM(emplois_crees) AS emplois_crees
  FROM `bright-aloe-508623-v8.Economie_marocaine.emplois_par_secteur`
  WHERE secteur <> 'Total économie'
  GROUP BY annee, secteur_groupe
)

SELECT
  p.annee,
  p.secteur_groupe AS secteur,
  p.pib_mdh,
  p.part_pib_pct,
  p.croissance_pct,
  i.investissement_mdh,
  ROUND(SAFE_DIVIDE(i.investissement_mdh, p.pib_mdh) * 100, 1) AS investissement_pct_du_pib_secteur,
  e.emplois_crees
FROM pib p
JOIN invest i ON p.annee = i.annee AND p.secteur_groupe = i.secteur_groupe
JOIN emploi e ON p.annee = e.annee AND p.secteur_groupe = e.secteur_groupe
ORDER BY p.annee, p.secteur_groupe;
