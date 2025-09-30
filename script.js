import fs from "fs";
import fetch from "node-fetch";
import dotenv from "dotenv";

dotenv.config();

const API_KEY = process.env.TMDB_API_KEY;
const BASE_URL = "https://api.themoviedb.org/3";

// helper to fetch json
async function tmdbFetch(endpoint, params = {}) {
  const url = new URL(`${BASE_URL}${endpoint}`);
  url.searchParams.set("api_key", API_KEY);
  url.searchParams.set("language", "en-US");
  for (const [k, v] of Object.entries(params)) {
    url.searchParams.set(k, v);
  }

  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`TMDB API error: ${res.status} ${res.statusText}`);
  }
  return res.json();
}

// fetch movies (list + details + credits)
async function fetchMovies(pages = 3) {
  const results = [];

  for (let page = 1; page <= pages; page++) {
    console.log(`Fetching popular movies page ${page}...`);
    const data = await tmdbFetch("/movie/popular", { page });

    for (const movie of data.results) {
      try {
        const details = await tmdbFetch(`/movie/${movie.id}`);
        const credits = await tmdbFetch(`/movie/${movie.id}/credits`);

        results.push({
          id: details.id,
          title: details.title,
          release_date: details.release_date,
          runtime: details.runtime,
          genres: details.genres,
          production_companies: details.production_companies,
          cast: credits.cast.slice(0, 10),
          crew: credits.crew.filter((c) =>
            ["Director", "Writer", "Screenplay"].includes(c.job)
          ),
        });

        console.log(`  Added movie: ${details.title} (total ${results.length})`);
      } catch (err) {
        console.error(`  Error fetching movie ${movie.id}:`, err.message);
      }
    }

    // shorter sleep
    await new Promise((r) => setTimeout(r, 1000));
  }

  return results;
}


// main
(async () => {
  try {
    const genres = await tmdbFetch("/genre/movie/list");
    const movies = await fetchMovies(3); // fetch first 3 pages (~60 movies)

    const output = {
      fetched_at: new Date().toISOString(),
      genres: genres.genres,
      movies,
    };

    fs.writeFileSync("tmdb_seed.json", JSON.stringify(output, null, 2));
    console.log("✅ Saved data to tmdb_seed.json");
  } catch (err) {
    console.error("Fatal error:", err);
  }
})();
