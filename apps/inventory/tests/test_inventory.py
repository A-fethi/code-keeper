import pytest
from app import create_app
@pytest.fixture
def client():
    app = create_app({
        "TESTING": True,
        "SQLALCHEMY_DATABASE_URI": "sqlite:///:memory:"
    })
    with app.test_client() as client:
        yield client
def test_get_movies_empty(client):
    """Test retrieving movies when database is empty."""
    response = client.get("/api/movies")
    assert response.status_code == 200
    assert response.get_json() == {"movies": []}
def test_create_movie(client):
    """Test creating a new movie."""
    response = client.post(
        "/api/movies",
        json={"title": "Inception", "description": "Sci-Fi thriller"}
    )
    assert response.status_code == 200
    assert "Inception" in response.get_json().get("message", "")
def test_get_movie_by_id(client):
    """Test retrieving a created movie by ID."""
    client.post(
        "/api/movies",
        json={"title": "Interstellar", "description": "Space movie"}
    )
    response = client.get("/api/movies/1")
    assert response.status_code == 200
    data = response.get_json()
    assert data["title"] == "Interstellar"
