-- 04_kecamatan_boundary.sql
-- Extract administrative district (kecamatan) boundaries for Kota Bandung
-- from OpenStreetMap via BigQuery.
-- admin_level = 6 corresponds to kecamatan in Kota Bandung's OSM data.

SELECT
  (SELECT value FROM UNNEST(all_tags) WHERE key = 'name')        AS nama_kecamatan,
  (SELECT value FROM UNNEST(all_tags) WHERE key = 'admin_level') AS admin_level,
  geometry
FROM
  `bigquery-public-data.geo_openstreetmap.planet_features`
WHERE
  ST_INTERSECTSBOX(geometry, 107.55, -6.99, 107.72, -6.85)
  AND EXISTS (
    SELECT 1 FROM UNNEST(all_tags)
    WHERE key = 'admin_level'
    AND value = '6'
  )
  AND EXISTS (
    SELECT 1 FROM UNNEST(all_tags)
    WHERE key = 'boundary'
    AND value = 'administrative'
  );
