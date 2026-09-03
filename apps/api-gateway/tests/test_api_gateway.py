import pytest
from app import create_app

@pytest.fixture
def client():
    app = create_app()
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_app_created(client):
    """Test that the Flask app initializes correctly."""
    assert client is not None

def test_404_error_handler(client):
    """Test that a non-existent route returns 404 JSON."""
    response = client.get("/non-existent-route")
    assert response.status_code == 404
    assert "Service not found" in response.get_json().get("error", "")

def test_billing_endpoint_requires_json(client):
    """Test that /api/billing/ returns 400 when body is not JSON."""
    response = client.post("/api/billing/", data="not json", content_type="text/plain")
    assert response.status_code == 400
