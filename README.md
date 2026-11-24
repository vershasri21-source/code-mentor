# Code Mentor

AI code mentor for student developers.

## Planned structure

```
code-mentor/
├── prototype/              # Day 1-2: run this first
│   ├── review_prototype.py
│   └── sample_bad.py
├── backend/                # FastAPI app (Phase 1)
│   ├── schema.sql
│   ├── app/
│   │   ├── main.py             # FastAPI entry
│   │   ├── config.py           # env vars
│   │   ├── db.py               # SQLAlchemy session
│   │   ├── models.py
│   │   ├── routers/
│   │   │   ├── auth.py         # GitHub OAuth
│   │   │   ├── webhooks.py     # PR events + signature check
│   │   │   └── reviews.py      # history, feedback
│   │   ├── services/
│   │   │   ├── github.py       # fetch diff, post comments
│   │   │   ├── static_tools.py # bandit / semgrep / gitleaks
│   │   │   ├── llm.py          # prompts + JSON parsing
│   │   │   └── mistakes.py     # mistake memory, practice mode
│   │   └── workers/tasks.py    # Celery review job
│   └── tests/
├── frontend/               # Next.js dashboard (Phase 3)
├── benchmark/              # buggy PRs + precision/recall script
├── docker-compose.yml      # postgres, redis, api, worker
└── requirements.txt
```

## Run the prototype

```
pip install -r requirements.txt
export ANTHROPIC_API_KEY=your_key
cd prototype
python review_prototype.py sample_bad.py
python review_prototype.py sample_bad.py --lang hinglish
```
