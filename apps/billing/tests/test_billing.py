import pytest
from sqlalchemy import create_engine, select
from sqlalchemy.orm import Session
from app.orders import Base, Order, create_order

@pytest.fixture
def engine():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    return engine

def test_create_order(engine):
    """Test creating and persisting an order in the database."""
    new_order = {
        "user_id": 1,
        "number_of_items": 3,
        "total_amount": 99.99
    }
    create_order(engine, new_order)
    with Session(engine) as session:
        order = session.scalars(select(Order)).first()
        assert order is not None
        assert order.user_id == 1
        assert order.number_of_items == 3
        assert order.total_amount == 99.99
