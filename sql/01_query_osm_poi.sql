-- 01_query_osm_poi.sql
-- Extract bus stop locations from OpenStreetMap for Bandung
-- Source: bigquery-public-data.geo_openstreetmap.planet_features
-- Coverage: Bounding box Kota Bandung (lat: -6.99 to -6.85, lon: 107.55 to 107.72)

CREATE OR REPLACE TABLE `your-project.bandung_15min_city.poi_osm_transport` AS

SELECT
  CAST(osm_id AS STRING) AS osm_id,
  'osm'                  AS sumber,
  'transport'            AS amenity_category,
  (SELECT value FROM UNNEST(all_tags) WHERE key = 'name') AS nama_tempat,
  ST_Y(ST_Centroid(geometry)) AS latitude,
  ST_X(ST_Centroid(geometry)) AS longitude
FROM
  `bigquery-public-data.geo_openstreetmap.planet_features`
WHERE
  ST_INTERSECTSBOX(geometry, 107.55, -6.99, 107.72, -6.85)
  AND EXISTS (
    SELECT 1 FROM UNNEST(all_tags)
    WHERE key = 'highway'
    AND value = 'bus_stop'
  );
