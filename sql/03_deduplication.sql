-- 03_deduplication.sql
-- Merge OSM and Overture data, then deduplicate spatially.
-- Deduplication strategy: group by amenity_category + rounded coordinates (4 decimal ~11m precision).
-- Priority: Overture data is kept over OSM when duplicates are found.

CREATE OR REPLACE TABLE `your-project.bandung_15min_city.poi_bandung_deduped` AS

WITH merged AS (
  -- Overture POIs (all categories)
  SELECT * FROM `your-project.bandung_15min_city.poi_overture_raw`

  UNION ALL

  -- OSM bus stops
  SELECT * FROM `your-project.bandung_15min_city.poi_osm_transport`
),

ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY
        amenity_category,
        -- Round to 4 decimal places (~11m precision) to detect near-duplicate coordinates
        CAST(ROUND(latitude, 4)  AS STRING),
        CAST(ROUND(longitude, 4) AS STRING)
      ORDER BY
        -- Prefer Overture data when duplicates exist
        CASE WHEN sumber = 'overture' THEN 0 ELSE 1 END
    ) AS rn
  FROM merged
)

SELECT
  osm_id,
  sumber,
  amenity_category,
  nama_tempat,
  latitude,
  longitude
FROM ranked
WHERE rn = 1;
