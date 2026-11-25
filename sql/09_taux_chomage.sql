-- Taux de chômage par catégorie et par année
-- Projet : économie marocaine 2022-2025 (BigQuery, dataset Economie_marocaine)

SELECT indicateur, annee, valeur
FROM `bright-aloe-508623-v8.Economie_marocaine.chomage_emploi`
WHERE indicateur LIKE 'Taux de chômage%'
ORDER BY indicateur, annee
