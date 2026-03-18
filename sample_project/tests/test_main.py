"""
tests/test_main.py

示例项目的 pytest 测试用例
演示 Tester Skill 自动生成的标准测试结构

运行方式：
    uv run pytest tests/ -v --cov=src --cov-report=term-missing
"""

import pytest
from fastapi.testclient import TestClient

from src.main import app, _items_db, Item

# ── 测试客户端 ────────────────────────────────────────────────
client = TestClient(app)


# ── Fixtures ──────────────────────────────────────────────────
@pytest.fixture(autouse=True)
def reset_db():
    """每个测试前重置内存数据库，保证测试隔离。"""
    import src.main as main_module
    main_module._items_db = {
        1: Item(name="苹果", price=3.5, description="新鲜红富士"),
        2: Item(name="香蕉", price=2.0, description="进口香蕉"),
    }
    main_module._next_id = 3
    yield


# ── 健康检查 ──────────────────────────────────────────────────
class TestHealthCheck:
    def test_root_returns_ok(self):
        """根路由应返回 status=ok。"""
        response = client.get("/")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"
        assert "version" in data

    def test_root_contains_app_name(self):
        """根路由应包含应用名称。"""
        response = client.get("/")
        assert "app" in response.json()


# ── 商品列表 ──────────────────────────────────────────────────
class TestListItems:
    def test_list_items_returns_200(self):
        """列表接口应返回 200。"""
        response = client.get("/items")
        assert response.status_code == 200

    def test_list_items_returns_list(self):
        """列表接口应返回数组。"""
        response = client.get("/items")
        assert isinstance(response.json(), list)

    def test_list_items_initial_count(self):
        """初始数据库应有 2 个商品。"""
        response = client.get("/items")
        assert len(response.json()) == 2


# ── 获取单个商品 ──────────────────────────────────────────────
class TestGetItem:
    def test_get_existing_item(self):
        """获取存在的商品应返回 200。"""
        response = client.get("/items/1")
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == 1
        assert data["item"]["name"] == "苹果"

    def test_get_nonexistent_item_returns_404(self):
        """获取不存在的商品应返回 404。"""
        response = client.get("/items/999")
        assert response.status_code == 404

    def test_get_item_response_structure(self):
        """获取商品响应应包含 id、item、message 字段。"""
        response = client.get("/items/1")
        data = response.json()
        assert "id" in data
        assert "item" in data
        assert "message" in data

    # 边界条件
    def test_get_item_id_zero(self):
        """ID=0 不存在，应返回 404。"""
        response = client.get("/items/0")
        assert response.status_code == 404

    def test_get_item_negative_id(self):
        """负数 ID 不存在，应返回 404。"""
        response = client.get("/items/-1")
        assert response.status_code == 404


# ── 创建商品 ──────────────────────────────────────────────────
class TestCreateItem:
    def test_create_item_returns_201(self):
        """创建商品应返回 201。"""
        payload = {"name": "橙子", "price": 5.0}
        response = client.post("/items", json=payload)
        assert response.status_code == 201

    def test_create_item_increments_id(self):
        """创建商品后 ID 应递增。"""
        payload = {"name": "橙子", "price": 5.0}
        r1 = client.post("/items", json=payload)
        r2 = client.post("/items", json=payload)
        assert r2.json()["id"] == r1.json()["id"] + 1

    def test_create_item_with_all_fields(self):
        """创建包含所有字段的商品。"""
        payload = {
            "name": "西瓜",
            "description": "大西瓜",
            "price": 15.0,
            "in_stock": True,
        }
        response = client.post("/items", json=payload)
        assert response.status_code == 201
        data = response.json()
        assert data["item"]["name"] == "西瓜"
        assert data["item"]["description"] == "大西瓜"

    # 异常场景
    def test_create_item_missing_required_field(self):
        """缺少必填字段（price）应返回 422。"""
        payload = {"name": "橙子"}  # 缺少 price
        response = client.post("/items", json=payload)
        assert response.status_code == 422

    def test_create_item_invalid_price_type(self):
        """price 类型错误应返回 422。"""
        payload = {"name": "橙子", "price": "not_a_number"}
        response = client.post("/items", json=payload)
        assert response.status_code == 422


# ── 删除商品 ──────────────────────────────────────────────────
class TestDeleteItem:
    def test_delete_existing_item(self):
        """删除存在的商品应返回 200。"""
        response = client.delete("/items/1")
        assert response.status_code == 200

    def test_delete_removes_item(self):
        """删除后再次获取应返回 404。"""
        client.delete("/items/1")
        response = client.get("/items/1")
        assert response.status_code == 404

    def test_delete_nonexistent_item_returns_404(self):
        """删除不存在的商品应返回 404。"""
        response = client.delete("/items/999")
        assert response.status_code == 404
