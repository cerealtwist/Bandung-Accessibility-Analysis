-- 02_query_overture_poi.sql
-- Extract POIs from Overture Maps for Bandung
-- Source: bigquery-public-data.overture_maps.place
-- Coverage: Bounding box Kota Bandung (lat: -6.99 to -6.85, lon: 107.55 to 107.72)

CREATE OR REPLACE TABLE `your-project.bandung_15min_city.poi_overture_raw` AS

-- Education
SELECT
  id                    AS osm_id,
  'overture'            AS sumber,
  'education'           AS amenity_category,
  names.primary         AS nama_tempat,
  ST_Y(geometry)        AS latitude,
  ST_X(geometry)        AS longitude
FROM `bigquery-public-data.overture_maps.place`
WHERE ST_INTERSECTSBOX(geometry, 107.55, -6.99, 107.72, -6.85)
  AND categories.primary IN ('school', 'elementary_school', 'college_university', 'education')

UNION ALL

-- Health
SELECT
  id, 'overture', 'health',
  names.primary, ST_Y(geometry), ST_X(geometry)
FROM `bigquery-public-data.overture_maps.place`
WHERE ST_INTERSECTSBOX(geometry, 107.55, -6.99, 107.72, -6.85)
  AND categories.primary IN ('hospital', 'clinic', 'doctor', 'pharmacy')

UNION ALL

-- Market
SELECT
  id, 'overture', 'market',
  names.primary, ST_Y(geometry), ST_X(geometry)
FROM `bigquery-public-data.overture_maps.place`
WHERE ST_INTERSECTSBOX(geometry, 107.55, -6.99, 107.72, -6.85)
  AND categories.primary IN ('grocery_store', 'convenience_store', 'supermarket', 'marketplace')

UNION ALL

-- Transport (named stops and stations)
SELECT
  id, 'overture', 'transport',
  names.primary, ST_Y(geometry), ST_X(geometry)
FROM `bigquery-public-data.overture_maps.place`
WHERE ST_INTERSECTSBOX(geometry, 107.55, -6.99, 107.72, -6.85)
  AND categories.primary IN ('transportation', 'bus_station', 'train_station');
