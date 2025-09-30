import fs from "fs";

// Load TMDB JSON
const raw = fs.readFileSync("tmdb_seed.json", "utf-8");
const data = JSON.parse(raw);

const lines = [];

// -------------------- GENRES --------------------
for (const g of data.genres) {
  lines.push(
    `INSERT INTO genres (id, name) VALUES (${g.id}, ${JSON.stringify(g.name)}) ON DUPLICATE KEY UPDATE name=VALUES(name);`
  );
}

// -------------------- USERS (dummy) --------------------
for (let i = 1; i <= 10; i++) {
  const uname = `user${i}`;
  const email = `user${i}@example.com`;
  const pw = "$2a$10$FakeHashedPassword"; // fake bcrypt hash
  lines.push(
    `INSERT INTO users (id, username, email, password_hash, is_verified, role) VALUES (${i}, '${uname}', '${email}', '${pw}', TRUE, 'USER');`
  );
}

// -------------------- PEOPLE & COMPANIES --------------------
const people = new Map();
const companies = new Map();

for (const m of data.movies) {
  for (const p of m.cast || []) people.set(p.id, p);
  for (const p of m.crew || []) people.set(p.id, p);
  for (const c of m.production_companies || []) companies.set(c.id, c);
}

// Companies
for (const [cid, c] of companies) {
  lines.push(
    `INSERT INTO companies (id, name, origin_country) VALUES (${cid}, ${JSON.stringify(c.name)}, ${
      c.origin_country ? JSON.stringify(c.origin_country) : "NULL"
    }) ON DUPLICATE KEY UPDATE name=VALUES(name);`
  );
}

// People
for (const [pid, p] of people) {
  lines.push(
    `INSERT INTO people (id, name) VALUES (${pid}, ${JSON.stringify(p.name)}) ON DUPLICATE KEY UPDATE name=VALUES(name);`
  );
}

// -------------------- MOVIES --------------------
for (const m of data.movies) {
  const mid = m.id;
  const title = JSON.stringify(m.title);
  const overview = m.overview ? JSON.stringify(m.overview) : "NULL";
  const releaseDate = m.release_date ? `'${m.release_date}'` : "NULL";
  const runtime = m.runtime || "NULL";

  lines.push(
    `INSERT INTO movies (id, tmdb_id, title, overview, release_date, runtime) VALUES (${mid}, ${mid}, ${title}, ${overview}, ${releaseDate}, ${runtime});`
  );
}

// -------------------- MOVIE_GENRES --------------------
for (const m of data.movies) {
  const mid = m.id;
  for (const g of m.genres || []) {
    lines.push(
      `INSERT INTO movie_genres (movie_id, genre_id) VALUES (${mid}, ${g.id});`
    );
  }
}

// -------------------- MOVIE_CAST --------------------
for (const m of data.movies) {
  const mid = m.id;
  for (const c of m.cast || []) {
    const char = c.character ? JSON.stringify(c.character) : "NULL";
    const order = c.order ?? 0;
    lines.push(
      `INSERT INTO movie_cast (movie_id, person_id, movie_character, billing_order) VALUES (${mid}, ${c.id}, ${char}, ${order});`
    );
  }
}

// -------------------- MOVIE_CREW --------------------
for (const m of data.movies) {
  const mid = m.id;
  for (const c of m.crew || []) {
    const job = c.job ? JSON.stringify(c.job) : "NULL";
    lines.push(
      `INSERT INTO movie_crew (movie_id, person_id, job) VALUES (${mid}, ${c.id}, ${job});`
    );
  }
}

// -------------------- REVIEWS --------------------
let reviewId = 1;
for (let uid = 1; uid <= 10; uid++) {
  for (let j = 0; j < 3; j++) {
    const movie = data.movies[Math.floor(Math.random() * data.movies.length)];
    const rating = Math.floor(Math.random() * 10) + 1;
    const text = `Review ${reviewId} by user${uid}`;
    lines.push(
      `INSERT INTO reviews (id, user_id, movie_id, rating, review_text, created_at) VALUES (${reviewId}, ${uid}, ${movie.id}, ${rating}, ${JSON.stringify(
        text
      )}, NOW());`
    );
    reviewId++;
  }
}

// -------------------- WATCHLISTS --------------------
let wlId = 1;
for (let uid = 1; uid <= 10; uid++) {
  for (let j = 0; j < 2; j++) {
    const movie = data.movies[Math.floor(Math.random() * data.movies.length)];
    lines.push(
      `INSERT INTO watchlists (id, user_id, movie_id, added_at) VALUES (${wlId}, ${uid}, ${movie.id}, NOW());`
    );
    wlId++;
  }
}

// -------------------- SAVE TO FILE --------------------
fs.writeFileSync("seed_data.sql", lines.join("\n"));
console.log("✅ SQL seed file created: seed_data.sql");
