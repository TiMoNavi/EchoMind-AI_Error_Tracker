"""Smoke tests — verify all 11 API endpoints are reachable and return expected status codes.

Usage:
    pip install httpx pytest pytest-asyncio
    pytest tests/test_smoke.py -v
"""
import pytest
import httpx

BASE = "http://localhost:8000"

# ── shared state across tests ──
_state: dict = {}


@pytest.fixture(scope="module")
def client():
    with httpx.Client(base_url=BASE, timeout=10) as c:
        yield c


def _auth_headers() -> dict:
    return {"Authorization": f"Bearer {_state['token']}"}


# ── 1. Health ──

def test_health(client: httpx.Client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


# ── 2. Auth: register ──

def test_register(client: httpx.Client):
    r = client.post("/api/auth/register", json={
        "phone": "13800000001",
        "password": "test1234",
        "region_id": "tianjin",
        "subject": "physics",
        "target_score": 70,
    })
    assert r.status_code == 201
    data = r.json()
    assert "access_token" in data
    assert "user" in data
    _state["token"] = data["access_token"]
    _state["user_id"] = data["user"]["id"]


# ── 3. Auth: duplicate register ──

def test_register_duplicate(client: httpx.Client):
    r = client.post("/api/auth/register", json={
        "phone": "13800000001",
        "password": "test1234",
        "region_id": "tianjin",
        "subject": "physics",
        "target_score": 70,
    })
    assert r.status_code == 409


# ── 4. Auth: login ──

def test_login(client: httpx.Client):
    r = client.post("/api/auth/login", json={
        "phone": "13800000001",
        "password": "test1234",
    })
    assert r.status_code == 200
    data = r.json()
    assert "access_token" in data
    assert data["user"]["phone"] == "13800000001"
    _state["token"] = data["access_token"]


# ── 5. Auth: login wrong password ──

def test_login_wrong_password(client: httpx.Client):
    r = client.post("/api/auth/login", json={
        "phone": "13800000001",
        "password": "wrong",
    })
    assert r.status_code == 401


# ── 6. Auth: me ──

def test_me(client: httpx.Client):
    r = client.get("/api/auth/me", headers=_auth_headers())
    assert r.status_code == 200
    assert r.json()["phone"] == "13800000001"


# ── 7. Auth: me without token ──

def test_me_no_token(client: httpx.Client):
    r = client.get("/api/auth/me")
    assert r.status_code in (401, 403)


# ── 8. Knowledge tree ──

def test_knowledge_tree(client: httpx.Client):
    r = client.get("/api/knowledge/tree")
    assert r.status_code == 200
    assert isinstance(r.json(), list)


# ── 9. Knowledge detail (404 for missing) ──

def test_knowledge_detail_404(client: httpx.Client):
    r = client.get("/api/knowledge/nonexistent", headers=_auth_headers())
    assert r.status_code == 404


# ── 10. Model tree ──

def test_model_tree(client: httpx.Client):
    r = client.get("/api/models/tree")
    assert r.status_code == 200
    assert isinstance(r.json(), list)


# ── 11. Model detail (404 for missing) ──

def test_model_detail_404(client: httpx.Client):
    r = client.get("/api/models/nonexistent", headers=_auth_headers())
    assert r.status_code == 404


# ── 12. Upload question ──

def test_upload_question(client: httpx.Client):
    r = client.post("/api/questions/upload", headers=_auth_headers(), json={
        "image_url": "https://example.com/q1.png",
        "source": "manual",
    })
    assert r.status_code == 201
    data = r.json()
    assert data["diagnosis_status"] == "pending"
    _state["question_id"] = data["id"]


# ── 13. Question history ──

def test_question_history(client: httpx.Client):
    r = client.get("/api/questions/history", headers=_auth_headers())
    assert r.status_code == 200
    data = r.json()
    assert isinstance(data, list)
    assert len(data) >= 1


# ── 14. Dashboard ──

def test_dashboard(client: httpx.Client):
    r = client.get("/api/dashboard", headers=_auth_headers())
    assert r.status_code == 200
    data = r.json()
    assert "total_questions" in data
    assert data["total_questions"] >= 1


# ── 15. Recommendations ──

def test_recommendations(client: httpx.Client):
    r = client.get("/api/recommendations", headers=_auth_headers())
    assert r.status_code == 200
    assert isinstance(r.json(), list)
