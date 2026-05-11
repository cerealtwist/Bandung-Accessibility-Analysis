# Bandung Accessibility Analysis
### A 15-Minute City Study using Google Cloud Platform

![Python](https://img.shields.io/badge/Python-3.10+-blue?logo=python&logoColor=white)
![BigQuery](https://img.shields.io/badge/BigQuery-GCP-orange?logo=google-cloud&logoColor=white)
![Vertex AI](https://img.shields.io/badge/Vertex_AI-GCP-blue?logo=google-cloud&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

How accessible is Bandung for its residents without a car?

This project applies the **15-minute city** framework to Kota Bandung, Indonesia,
measuring how well residents can reach essential daily facilities (education, healthcare,
markets, and public transport) within a walkable distance from any point in the city.
The analysis is powered entirely by **Google Cloud Platform**, combining BigQuery GIS,
Google Colab, and Vertex AI.

#### Google Colab Link: https://colab.research.google.com/drive/14j7qSZOdcN_gMSiv79bVbhgMXjInypM4#scrollTo=xIyWO6aHIzL3

---

## Key Findings

- Only **8.6%** of Bandung's urban grid qualifies as *High Accessibility*
- **58.8%** of the city remains *Low Accessibility*, concentrated in eastern and southern peripheries
- **Gedebage** is the most critical blank spot, with 97.4% of its area in the lowest accessibility tier
- Central districts (Bandung Wetan, Sumur Bandung) show strong accessibility, confirming a **monocentric urban structure**
- All four facility categories (education, health, market, transport) are highly correlated (r = 0.79–0.87), suggesting co-location of services

---

## Architecture

```
Overture Maps (BigQuery Public Dataset)
OpenStreetMap  (BigQuery Public Dataset)
        │
        ▼
   BigQuery GIS
   ─────────────────────────────────────────
   • Spatial filtering (bounding box Bandung)
   • POI categorization
   • Spatial deduplication (SQL)
   • Administrative boundary extraction
        │
        ▼
   Google Colab
   ─────────────────────────────────────────
   • 500m × 500m grid construction
   • Radius-based POI density (KD-Tree, 1km)
   • Weighted Accessibility Index
   • K-Means Clustering (Elbow Method)
   • Spatial join with district boundaries
   • PyDeck + Folium visualizations
        │
        ▼
   Vertex AI Model Registry
   ─────────────────────────────────────────
   • Trained K-Means model stored via GCS
   • Registered for reproducibility (MLOps)
```

---

## Data Sources

| Source | Usage | License |
|--------|-------|---------|
| [Overture Maps](https://overturemaps.org) via BigQuery | Education, health, market POIs | CDLA Permissive 2.0 |
| [OpenStreetMap](https://www.openstreetmap.org) via BigQuery | Public transport stops (`highway=bus_stop`) | ODbL |

> **Note on data quality**: Overture Maps was chosen as the primary POI source because it provides significantly better coverage for Indonesian cities compared to OSM alone, particularly for education and health facilities. OSM was retained for transport stops due to its superior coverage of individual bus stop locations.

---

## Methodology

### 1. POI Data Collection
Data was queried from two BigQuery public datasets covering Bandung's bounding box
(lat: -6.99 to -6.85, lon: 107.55 to 107.72). A spatial deduplication step using
SQL window functions removed duplicate POIs that appeared in both sources,
resulting in **6,212 unique POIs** across four categories.

### 2. Grid Construction
The city was divided into a uniform **500m × 500m grid** (1,216 cells total).
This approach was chosen over administrative boundaries to ensure uniform spatial
units and avoid dependence on additional boundary datasets at the analysis stage.

### 3. Accessibility Index
For each grid cell, POI counts within a **1km radius** were computed using
`scipy.spatial.cKDTree` for efficiency. Counts were normalized using Min-Max
scaling and combined into a weighted composite index:

| Category | Weight | Rationale |
|----------|--------|-----------|
| Transport | 0.30 | Core mobility enabler |
| Education | 0.25 | High spatial coverage |
| Health | 0.25 | Critical daily need |
| Market | 0.20 | Daily food access |

### 4. K-Means Clustering
The optimal number of clusters (k=3) was determined using the **Elbow Method**.
The resulting clusters map naturally to three accessibility tiers: High, Moderate,
and Low — replacing the arbitrary manual thresholds used in initial exploration.
The model is registered in **Vertex AI Model Registry** to demonstrate MLOps practice.

### 5. District-level Aggregation
Grid-level results were spatially joined to Bandung's 30 kecamatan (district)
boundaries extracted from OpenStreetMap, enabling policy-relevant administrative analysis.

---

## Results

### Cluster Profiles

| Cluster | Grid Cells | Percentage | Avg. Index | Avg. Education POIs | Avg. Transport POIs |
|---------|-----------|------------|------------|---------------------|---------------------|
| High Accessibility | 105 | 8.6% | 0.505 | 91.1 | 34.6 |
| Moderate Accessibility | 396 | 32.6% | 0.207 | 43.3 | 10.8 |
| Low Accessibility | 715 | 58.8% | 0.045 | 11.6 | 2.0 |

### Top and Bottom Districts

| Rank | Kecamatan | Avg. Index | % Low Accessibility |
|------|-----------|------------|---------------------|
| 1 (Best) | Bandung Wetan | 0.574 | 0.0% |
| 2 | Sumur Bandung | 0.556 | 0.0% |
| 3 | Coblong | 0.391 | 7.4% |
| ... | ... | ... | ... |
| 28 | Ujungberung | 0.086 | 69.2% |
| 29 | Mandalajati | 0.094 | 88.2% |
| 30 (Worst) | Gedebage | 0.043 | 97.4% |

---

## Repository Structure

```
Bandung-Accessibility-Analysis/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── notebooks/
│   └── Bandung_City_Analysis.ipynb     # Main analysis notebook
│
├── sql/
│   ├── 01_query_osm_poi.sql            # Extract POIs from OpenStreetMap
│   ├── 02_query_overture_poi.sql       # Extract POIs from Overture Maps
│   ├── 03_deduplication.sql            # Spatial deduplication
│   └── 04_kecamatan_boundary.sql       # Extract district boundaries
│
└── assets/
    └── maps/
        ├── choropleth_kecamatan.png
        ├── cluster_map_pydeck.png
        ├── blank_spot_analysis.png
        ├── cluster_profiles.png
        ├── correlation_heatmap.png
        └── elbow_curve.png
```

---

## Setup & Reproduction

### Prerequisites
- Google Cloud Platform account with an active project
- BigQuery API enabled
- Vertex AI API enabled
- Google Cloud Storage bucket

### Running the Notebook

1. Open `notebooks/Bandung_City_Analysis.ipynb` in Google Colab
2. Update `project_id` in cell 0 with your GCP Project ID
3. Run all cells in order

> The notebook connects to BigQuery to fetch pre-processed data from
> `bandung_15min_city.*` tables. To reproduce the full pipeline from scratch,
> run the SQL scripts in `sql/` first in your own BigQuery project.

### BigQuery Dataset Setup

Run the SQL scripts in `sql/` sequentially in BigQuery to recreate the data pipeline:

```sql
-- Step 1: Create dataset
CREATE SCHEMA IF NOT EXISTS `your-project.bandung_15min_city`;

-- Step 2–4: Run scripts in order
-- sql/01_query_osm_poi.sql
-- sql/02_query_overture_poi.sql
-- sql/03_deduplication.sql
-- sql/04_kecamatan_boundary.sql
```

---

## Limitations

- The index measures **proximity-based accessibility**, not true walkability. Infrastructure
  quality data (sidewalks, street lighting) is insufficiently mapped in OSM for Bandung.
- **Euclidean distance** (straight-line) is used rather than network distance, which does not
  account for topographic barriers or road network connectivity.
- Analysis scope is limited to **Kota Bandung** administrative boundary. The Bandung
  metropolitan area (including Kabupaten Bandung and Kabupaten Bandung Barat) is excluded.
- POI data completeness depends on community contributions to OSM and Overture Maps,
  which may not capture all facilities present on the ground.

---

## Future Work

- Integrate **Metro Jabar Trans route and stop data** for transit-weighted accessibility scoring
- Replace Euclidean distance with **network distance** via `osmnx`
- Add **population density** data from BPS to weight accessibility by actual demand
- Build an **interactive public dashboard** (Streamlit + Cloud Run) for warga Bandung
  to explore accessibility in their neighborhood

---

## Tech Stack

`Python` `Google BigQuery` `Vertex AI` `Google Cloud Storage` `Google Colab`
`GeoPandas` `scikit-learn` `PyDeck` `Folium` `scipy` `pandas` `matplotlib` `seaborn`

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

Data from OpenStreetMap is © OpenStreetMap contributors, available under the
[Open Database License (ODbL)](https://opendatacommons.org/licenses/odbl/).
Data from Overture Maps is available under the
[CDLA Permissive 2.0 License](https://cdla.dev/permissive-2-0/).

---

## Acknowledgements

- [Transport for Bandung](https://transportforbandung.org) for reference on Metro Jabar Trans routes
- [OpenStreetMap Indonesia](https://openstreetmap.id) community for spatial data contributions
- Overture Maps Foundation for open POI data
