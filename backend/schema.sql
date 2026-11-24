-- PostgreSQL schema for the AI code mentor

CREATE TABLE users (
    id            SERIAL PRIMARY KEY,
    github_id     BIGINT UNIQUE NOT NULL,
    username      TEXT NOT NULL,
    role          TEXT NOT NULL DEFAULT 'student',   -- student | mentor
    language_pref TEXT NOT NULL DEFAULT 'english',   -- english | hinglish
    created_at    TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE organizations (            -- coding clubs / classes
    id         SERIAL PRIMARY KEY,
    name       TEXT NOT NULL,
    owner_id   INT REFERENCES users(id)
);

CREATE TABLE memberships (
    org_id  INT REFERENCES organizations(id) ON DELETE CASCADE,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (org_id, user_id)
);

CREATE TABLE repos (
    id              SERIAL PRIMARY KEY,
    user_id         INT REFERENCES users(id) ON DELETE CASCADE,
    github_repo_id  BIGINT UNIQUE NOT NULL,
    full_name       TEXT NOT NULL,
    webhook_secret  TEXT NOT NULL,
    active          BOOLEAN DEFAULT TRUE
);

CREATE TABLE pull_requests (
    id          SERIAL PRIMARY KEY,
    repo_id     INT REFERENCES repos(id) ON DELETE CASCADE,
    pr_number   INT NOT NULL,
    title       TEXT,
    head_sha    TEXT,
    UNIQUE (repo_id, pr_number)
);

CREATE TABLE reviews (
    id          SERIAL PRIMARY KEY,
    pr_id       INT REFERENCES pull_requests(id) ON DELETE CASCADE,
    status      TEXT NOT NULL DEFAULT 'queued',   -- queued | running | done | failed
    model       TEXT,
    tokens_used INT,
    created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE findings (
    id           SERIAL PRIMARY KEY,
    review_id    INT REFERENCES reviews(id) ON DELETE CASCADE,
    file_path    TEXT NOT NULL,
    line         INT,
    source       TEXT NOT NULL,        -- bandit | semgrep | eslint | llm
    concept_tag  TEXT NOT NULL,        -- sql_injection, null_check, ...
    severity     TEXT NOT NULL,        -- critical | warning | suggestion
    hint         TEXT,
    explanation  TEXT,
    fix          TEXT,
    helpful      BOOLEAN,              -- student feedback (NULL = no vote)
    created_at   TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_findings_concept ON findings(concept_tag);

CREATE TABLE practice_exercises (
    id          SERIAL PRIMARY KEY,
    user_id     INT REFERENCES users(id) ON DELETE CASCADE,
    concept_tag TEXT NOT NULL,
    prompt      TEXT NOT NULL,
    solution    TEXT,
    completed   BOOLEAN DEFAULT FALSE
);

-- Mistake memory: which concepts does a student repeat?
-- SELECT f.concept_tag, COUNT(*) AS times
-- FROM findings f
-- JOIN reviews r ON r.id = f.review_id
-- JOIN pull_requests p ON p.id = r.pr_id
-- JOIN repos rp ON rp.id = p.repo_id
-- WHERE rp.user_id = :uid
-- GROUP BY f.concept_tag ORDER BY times DESC;
