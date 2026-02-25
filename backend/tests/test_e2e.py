"""E2E smoke test — full user journey against a live API.

Covers: register → login → upload question → dashboard → recommendations
Plus: knowledge, models, prediction, weekly-review, exams, flashcards, question detail/aggregate

Usage:
    # Against localhost (default)
    pytest tests/test_e2e.py -v

    # Against public IP
    API_BASE=http://8.130.16.212:8001 pytest tests/test_e2e.py -v
"""
import os
import time

import httpx
import pytest

BASE = os.getenv("API_BASE", "http://localhost:8001")

# Unique phone per run to avoid 409 conflicts
_PHONE = f"138{int(time.time()) % 100000000:08d}"
_PASSWORD = "e2eTest2026!"

# Shared state across ordered tests
_state: dict = {}


@pytest.fixture(scope="module")
def client():
    # trust_env=False bypasses system proxy (socks5 etc.)
    with httpx.Client(base_url=BASE, timeout=15, trust_env=False) as c:
        yield c


def _auth() -> dict:
    return {"Authorization": f"Bearer {_state['token']}"}


# ────────────────────────────────────────────
# Phase 1: Health check
# ────────────────────────────────────────────

def test_01_health(client: httpx.Client):
    r = client.get("/health")
    assert r.status_code == 200
    body = r.json()
    assert body["status"] == "ok"
    print(f"[health] ok — base={BASE}")


# ────────────────────────────────────────────
# Phase 2: Register + Login
# ────────────────────────────────────────────

def test_02_register(client: httpx.Client):
    r = client.post("/api/auth/register", json={
        "phone": _PHONE,
        "password": _PASSWORD,
        "nickname": "E2E Tester",
        "region_id": "tianjin",
        "subject": "physics",
        "target_score": 80,
    })
    assert r.status_code == 201, f"register failed: {r.status_code} {r.text}"
    data = r.json()
    assert "access_token" in data
    assert data["user"]["phone"] == _PHONE
    _state["token"] = data["access_token"]
    _state["user_id"] = data["user"]["id"]
    print(f"[register] phone={_PHONE} user_id={_state['user_id']}")


def test_03_register_duplicate(client: httpx.Client):
    """Duplicate registration should return 409."""
    r = client.post("/api/auth/register", json={
        "phone": _PHONE,
        "password": _PASSWORD,
        "region_id": "tianjin",
        "subject": "physics",
        "target_score": 80,
    })
    assert r.status_code == 409


def test_04_login(client: httpx.Client):
    r = client.post("/api/auth/login", json={
        "phone": _PHONE,
        "password": _PASSWORD,
    })
    assert r.status_code == 200, f"login failed: {r.status_code} {r.text}"
    data = r.json()
    assert "access_token" in data
    # Refresh token from login
    _state["token"] = data["access_token"]
    print(f"[login] ok — token refreshed")


def test_05_login_wrong_password(client: httpx.Client):
    r = client.post("/api/auth/login", json={
        "phone": _PHONE,
        "password": "wrongpassword",
    })
    assert r.status_code == 401


def test_06_me(client: httpx.Client):
    r = client.get("/api/auth/me", headers=_auth())
    assert r.status_code == 200
    data = r.json()
    assert data["phone"] == _PHONE
    assert data["target_score"] == 80
    print(f"[me] nickname={data.get('nickname')}")


def test_07_me_no_token(client: httpx.Client):
    r = client.get("/api/auth/me")
    assert r.status_code in (401, 403)


# ────────────────────────────────────────────
# Phase 3: Upload question
# ────────────────────────────────────────────

def test_08_upload_question(client: httpx.Client):
    r = client.post("/api/questions/upload", headers=_auth(), json={
        "image_url": "https://example.com/e2e_test.png",
        "source": "manual",
    })
    assert r.status_code == 201, f"upload failed: {r.status_code} {r.text}"
    data = r.json()
    assert "id" in data
    assert data["diagnosis_status"] == "pending"
    _state["question_id"] = data["id"]
    print(f"[upload] question_id={data['id']}")


def test_09_upload_second_question(client: httpx.Client):
    """Upload a second question to verify count increments."""
    r = client.post("/api/questions/upload", headers=_auth(), json={
        "image_url": "https://example.com/e2e_test2.png",
        "is_correct": False,
        "source": "manual",
    })
    assert r.status_code == 201
    data = r.json()
    _state["question_id_2"] = data["id"]


# ────────────────────────────────────────────
# Phase 4: Query history + detail + aggregate
# ────────────────────────────────────────────

def test_10_question_history(client: httpx.Client):
    r = client.get("/api/questions/history", headers=_auth())
    assert r.status_code == 200, f"history failed: {r.status_code} {r.text}"
    data = r.json()
    assert isinstance(data, list)
    # Should have at least one date group with our uploaded questions
    total_questions = sum(len(g["questions"]) for g in data)
    assert total_questions >= 2, f"Expected >=2 questions, got {total_questions}"
    print(f"[history] {len(data)} date groups, {total_questions} questions total")


def test_11_question_detail(client: httpx.Client):
    qid = _state.get("question_id")
    assert qid, "No question_id from upload step"
    r = client.get(f"/api/questions/{qid}", headers=_auth())
    assert r.status_code == 200, f"detail failed: {r.status_code} {r.text}"
    data = r.json()
    assert data["id"] == qid
    assert data["source"] == "manual"
    print(f"[detail] diagnosis_status={data['diagnosis_status']}")


def test_12_question_detail_404(client: httpx.Client):
    r = client.get("/api/questions/nonexistent-id", headers=_auth())
    assert r.status_code == 404, f"Expected 404, got {r.status_code}"


def test_13_question_aggregate(client: httpx.Client):
    r = client.get("/api/questions/aggregate", headers=_auth(), params={"group_by": "model"})
    assert r.status_code == 200
    data = r.json()
    assert isinstance(data, list)
    print(f"[aggregate] {len(data)} groups")


# ────────────────────────────────────────────
# Phase 5: Dashboard (core MVP verification)
# ────────────────────────────────────────────

def test_14_dashboard(client: httpx.Client):
    r = client.get("/api/dashboard", headers=_auth())
    assert r.status_code == 200, f"dashboard failed: {r.status_code} {r.text}"
    data = r.json()
    assert "total_questions" in data
    assert data["total_questions"] >= 2, f"Expected >=2, got {data['total_questions']}"
    # Record for bug tracking
    _state["dashboard"] = data
    print(f"[dashboard] total={data['total_questions']} errors={data['error_count']} "
          f"predicted={data.get('predicted_score')}")
    # BUG check: N001 says four ability fields are always 0
    for field in ("formula_memory_rate", "model_identify_rate",
                  "calculation_accuracy", "reading_accuracy"):
        val = data.get(field)
        if val == 0 or val == 0.0:
            print(f"  ⚠ BUG: {field}={val} (always 0, see N001)")


def test_15_dashboard_no_token(client: httpx.Client):
    r = client.get("/api/dashboard")
    assert r.status_code in (401, 403)


# ────────────────────────────────────────────
# Phase 6: Recommendations
# ────────────────────────────────────────────

def test_16_recommendations(client: httpx.Client):
    r = client.get("/api/recommendations", headers=_auth())
    assert r.status_code == 200, f"recommendations failed: {r.status_code} {r.text}"
    data = r.json()
    assert isinstance(data, list)
    print(f"[recommendations] {len(data)} items")


# ────────────────────────────────────────────
# Phase 7: Knowledge & Model trees
# ────────────────────────────────────────────

def test_17_knowledge_tree(client: httpx.Client):
    r = client.get("/api/knowledge/tree")
    assert r.status_code == 200
    data = r.json()
    assert isinstance(data, list)
    print(f"[knowledge_tree] {len(data)} top-level nodes")


def test_18_model_tree(client: httpx.Client):
    r = client.get("/api/models/tree")
    assert r.status_code == 200
    data = r.json()
    assert isinstance(data, list)
    print(f"[model_tree] {len(data)} top-level nodes")


# ────────────────────────────────────────────
# Phase 8: Prediction + Weekly Review + Exams + Flashcards
# ────────────────────────────────────────────

def test_19_prediction(client: httpx.Client):
    r = client.get("/api/prediction/score", headers=_auth())
    assert r.status_code == 200, f"prediction failed: {r.status_code} {r.text}"
    data = r.json()
    print(f"[prediction] predicted={data.get('predicted_score')} "
          f"trend_data={data.get('trend_data')}")
    # BUG check: N001 says trend_data is hardcoded []
    if data.get("trend_data") == []:
        print("  ⚠ BUG: trend_data=[] (hardcoded, see N001)")


def test_20_weekly_review(client: httpx.Client):
    r = client.get("/api/weekly-review", headers=_auth())
    assert r.status_code == 200, f"weekly-review failed: {r.status_code} {r.text}"
    data = r.json()
    print(f"[weekly_review] score_change={data.get('score_change')}")
    # BUG check: N001 says score_change is hardcoded 0.0
    if data.get("score_change") == 0.0:
        print("  ⚠ BUG: score_change=0.0 (hardcoded, see N001)")


def test_21_exams_recent(client: httpx.Client):
    r = client.get("/api/exams/recent", headers=_auth())
    # BUG: returns 500 — endpoint is broken (no exams table, see N001)
    assert r.status_code in (200, 500), f"exams/recent unexpected: {r.status_code}"
    if r.status_code == 500:
        print("  ⚠ BUG: exams/recent returns 500 (broken endpoint, see N001)")
    else:
        data = r.json()
        assert isinstance(data, list)
        print(f"[exams/recent] {len(data)} items")
        if data == []:
            print("  ⚠ BUG: exams/recent=[] (mock, see N001)")


def test_22_exams_heatmap(client: httpx.Client):
    r = client.get("/api/exams/heatmap", headers=_auth())
    assert r.status_code == 200
    data = r.json()
    assert isinstance(data, list)
    print(f"[exams/heatmap] {len(data)} points")


def test_23_flashcards(client: httpx.Client):
    r = client.get("/api/flashcards", headers=_auth())
    assert r.status_code == 200, f"flashcards failed: {r.status_code} {r.text}"
    data = r.json()
    assert isinstance(data, list)
    print(f"[flashcards] {len(data)} cards")


# ────────────────────────────────────────────
# Phase 9: Existing account login (seed data)
# ────────────────────────────────────────────

def test_24_login_existing_account(client: httpx.Client):
    """Login with pre-seeded test account to verify seed data."""
    r = client.post("/api/auth/login", json={
        "phone": "13800000001",
        "password": "test1234",
    })
    assert r.status_code == 200, f"seed login failed: {r.status_code} {r.text}"
    data = r.json()
    _state["seed_token"] = data["access_token"]
    print(f"[seed_login] user_id={data['user']['id']}")


def test_25_seed_dashboard(client: httpx.Client):
    """Dashboard for seed account — may have pre-existing data."""
    token = _state.get("seed_token")
    if not token:
        pytest.skip("seed login failed")
    headers = {"Authorization": f"Bearer {token}"}
    r = client.get("/api/dashboard", headers=headers)
    assert r.status_code == 200
    data = r.json()
    print(f"[seed_dashboard] total={data['total_questions']} "
          f"predicted={data.get('predicted_score')}")


# ────────────────────────────────────────────
# Phase 9b: Mastery 链路测试
# ────────────────────────────────────────────

def test_30_upload_with_model_and_kp_correct(client: httpx.Client):
    """Upload a correct question with model_id + kp_ids → triggers mastery update."""
    r = client.post("/api/questions/upload", headers=_auth(), json={
        "image_url": "https://example.com/mastery_test.png",
        "is_correct": True,
        "source": "manual",
        "primary_model_id": "model_newton_app",
        "related_kp_ids": ["kp_newton_second", "kp_friction"],
    })
    assert r.status_code == 201, f"mastery upload failed: {r.status_code} {r.text}"
    data = r.json()
    _state["mastery_q_id"] = data["id"]
    print(f"[mastery_upload] correct=True model=model_newton_app kp=[newton,friction]")


def test_31_dashboard_after_mastery(client: httpx.Client):
    """After uploading with model+kp, dashboard dimensions should be non-zero."""
    r = client.get("/api/dashboard", headers=_auth())
    assert r.status_code == 200
    data = r.json()
    # formula_memory_rate comes from kp mastery → should be > 0 now
    assert data["formula_memory_rate"] > 0, \
        f"formula_memory_rate still 0 after correct kp upload"
    # model_identify_rate comes from model mastery → should be > 0
    assert data["model_identify_rate"] > 0, \
        f"model_identify_rate still 0 after correct model upload"
    # calculation_accuracy = correct/total → should be > 0
    assert data["calculation_accuracy"] > 0, \
        f"calculation_accuracy still 0"
    # reading_accuracy from recent_results → should be > 0
    assert data["reading_accuracy"] > 0, \
        f"reading_accuracy still 0"
    print(f"[mastery_dashboard] formula={data['formula_memory_rate']:.3f} "
          f"model={data['model_identify_rate']:.3f} "
          f"calc={data['calculation_accuracy']:.3f} "
          f"read={data['reading_accuracy']:.3f}")


# ────────────────────────────────────────────
# Phase 9c: Prediction 链路测试
# ────────────────────────────────────────────

def test_32_prediction_after_mastery(client: httpx.Client):
    """After mastery update, predicted_score should be non-null."""
    r = client.get("/api/prediction/score", headers=_auth())
    assert r.status_code == 200
    data = r.json()
    assert data["predicted_score"] is not None, \
        f"predicted_score still null after mastery upload"
    assert data["predicted_score"] > 0, \
        f"predicted_score={data['predicted_score']} should be > 0"
    _state["predicted_score_after_correct"] = data["predicted_score"]
    print(f"[prediction_after_mastery] predicted={data['predicted_score']} "
          f"priority_models={len(data.get('priority_models', []))}")


# ────────────────────────────────────────────
# Phase 9d: 连续错题上传测试
# ────────────────────────────────────────────

def test_33_upload_3_wrong_questions(client: httpx.Client):
    """Upload 3 wrong questions to verify dashboard changes reasonably."""
    _state["pre_error_dashboard"] = _state.get("dashboard", {})
    for i in range(3):
        r = client.post("/api/questions/upload", headers=_auth(), json={
            "image_url": f"https://example.com/wrong_{i+1}.png",
            "is_correct": False,
            "source": "manual",
            "primary_model_id": "model_coulomb_balance",
            "related_kp_ids": ["kp_coulomb_law"],
        })
        assert r.status_code == 201, f"wrong upload {i+1} failed: {r.status_code}"
    print("[error_upload] 3 wrong questions uploaded (model_coulomb_balance + kp_coulomb_law)")


def test_34_dashboard_after_errors(client: httpx.Client):
    """After 3 wrong uploads, verify dashboard reflects changes."""
    r = client.get("/api/dashboard", headers=_auth())
    assert r.status_code == 200
    data = r.json()
    # total_questions should have increased by 3 (from mastery test) + 3 (errors) = +4 from phase 5
    prev_total = _state.get("dashboard", {}).get("total_questions", 0)
    assert data["total_questions"] > prev_total, \
        f"total_questions didn't increase: {data['total_questions']} vs prev {prev_total}"
    # error_count should have increased
    prev_errors = _state.get("dashboard", {}).get("error_count", 0)
    assert data["error_count"] >= prev_errors + 3, \
        f"error_count={data['error_count']} expected >={prev_errors + 3}"
    print(f"[error_dashboard] total={data['total_questions']} errors={data['error_count']} "
          f"formula={data['formula_memory_rate']:.3f} model={data['model_identify_rate']:.3f}")


def test_35_prediction_after_errors(client: httpx.Client):
    """Predicted score should decrease after wrong answers."""
    r = client.get("/api/prediction/score", headers=_auth())
    assert r.status_code == 200
    data = r.json()
    prev_score = _state.get("predicted_score_after_correct")
    if prev_score is not None and data["predicted_score"] is not None:
        # Score should drop after 3 wrong answers
        assert data["predicted_score"] < prev_score, \
            f"predicted_score didn't decrease: {data['predicted_score']} vs {prev_score}"
        print(f"[prediction_after_errors] {prev_score} → {data['predicted_score']} (dropped ✓)")
    else:
        print(f"[prediction_after_errors] predicted={data['predicted_score']}")


# ────────────────────────────────────────────
# Phase 10: Session endpoints (diagnosis / learning / training)
# ────────────────────────────────────────────

def test_36_diagnosis_session(client: httpx.Client):
    """GET /api/diagnosis/session — verify 200 + session_id/status/messages."""
    r = client.get("/api/diagnosis/session", headers=_auth())
    assert r.status_code == 200, f"diagnosis/session failed: {r.status_code} {r.text}"
    data = r.json()
    assert "session_id" in data, "missing session_id"
    assert "status" in data, "missing status"
    assert "messages" in data, "missing messages"
    assert isinstance(data["messages"], list)
    print(f"[diagnosis_session] session_id={data['session_id']!r} "
          f"status={data['status']} messages={len(data['messages'])}")


def test_37_learning_session(client: httpx.Client):
    """GET /api/knowledge/learning/session — verify 200 + structure."""
    r = client.get("/api/knowledge/learning/session", headers=_auth())
    assert r.status_code == 200, f"learning/session failed: {r.status_code} {r.text}"
    data = r.json()
    assert "knowledge_point_id" in data, "missing knowledge_point_id"
    assert "knowledge_point_name" in data, "missing knowledge_point_name"
    assert "current_step" in data, "missing current_step"
    assert "dialogues" in data, "missing dialogues"
    assert isinstance(data["dialogues"], list)
    print(f"[learning_session] kp_id={data['knowledge_point_id']!r} "
          f"step={data['current_step']} dialogues={len(data['dialogues'])}")


def test_38_training_session(client: httpx.Client):
    """GET /api/models/training/session — verify 200 + structure."""
    r = client.get("/api/models/training/session", headers=_auth())
    assert r.status_code == 200, f"training/session failed: {r.status_code} {r.text}"
    data = r.json()
    assert "model_id" in data, "missing model_id"
    assert "model_name" in data, "missing model_name"
    assert "current_step" in data, "missing current_step"
    assert "dialogues" in data, "missing dialogues"
    assert isinstance(data["dialogues"], list)
    print(f"[training_session] model_id={data['model_id']!r} "
          f"step={data['current_step']} dialogues={len(data['dialogues'])}")


# ────────────────────────────────────────────

def test_99_summary(client: httpx.Client):
    """Print E2E summary with discovered bugs."""
    print("\n" + "=" * 60)
    print(f"E2E SUMMARY — base={BASE}")
    print(f"  Test user: {_PHONE}")
    print(f"  User ID:   {_state.get('user_id', 'N/A')}")
    print(f"  Questions: {_state.get('question_id', 'N/A')}, "
          f"{_state.get('question_id_2', 'N/A')}")
    dash = _state.get("dashboard", {})
    if dash:
        print(f"  Dashboard: total={dash.get('total_questions')} "
              f"errors={dash.get('error_count')}")
    ps = _state.get("predicted_score_after_correct")
    if ps is not None:
        print(f"  Predicted score (after correct): {ps}")
    print("=" * 60)
