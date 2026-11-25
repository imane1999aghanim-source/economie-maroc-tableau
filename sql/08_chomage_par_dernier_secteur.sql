-- Chômeurs selon leur dernier secteur d'activité
-- Projet : économie marocaine 2022-2025 (BigQuery, dataset Economie_marocaine)

SELECT indicateur, valeur
FROM `bright-aloe-508623-v8.Economie_marocaine.chomage_emploi`
WHERE categorie = 'Chômeurs par dernier secteur'
ORDER BY valeur DESC
