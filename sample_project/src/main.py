"""
sample_project/src/main.py

最小化 FastAPI 应用示例
演示 Antigravity Gemini 3 Flash Ultimate Tuner 的 Skills 生效效果

使用方式：
    uv run uvicorn src.main:app --reload --port 8000
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from pydantic_settings import BaseSettings


# ── 配置（使用 Pydantic Settings v2，2026 最佳实践）────────────
class Settings(BaseSettings):
    """应用配置，从环境变量自动读取。"""
    app_name: str = "SampleProject"
    app_version: str = "0.1.0"
    debug: bool = False

    model_config = {"env_prefix": "APP_"}


settings = Settings()


# ── 应用初始化 ────────────────────────────────────────────────
app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="Antigravity Gemini 3 Flash Ultimate Tuner 示例项目",
    docs_url="/docs",
    redoc_url="/redoc",
)


# ── 全局异常处理（用于演示 Code-Reviewer-Debugger Skill）────────
from fastapi import Request
from fastapi.responses import JSONResponse
from pydantic import ValidationError


@app.exception_handler(ValidationError)
async def validation_exception_handler(request: Request, exc: ValidationError):
    """统一处理 Pydantic v2 ValidationError，返回标准化错误格式。"""
    return JSONResponse(
        status_code=422,
        content={
            "error": "ValidationError",
            "detail": exc.errors(),
            "message": "请求参数验证失败，请检查输入格式",
        },
    )


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """全局兜底异常处理器。"""
    return JSONResponse(
        status_code=500,
        content={
            "error": type(exc).__name__,
            "message": "服务器内部错误",
        },
    )


# ── 数据模型 ──────────────────────────────────────────────────
class Item(BaseModel):
    """示例数据模型。"""
    name: str
    description: str | None = None
    price: float
    in_stock: bool = True


class ItemResponse(BaseModel):
    """响应模型。"""
    id: int
    item: Item
    message: str


# ── 内存数据库（演示用）────────────────────────────────────────
_items_db: dict[int, Item] = {
    1: Item(name="苹果", price=3.5, description="新鲜红富士"),
    2: Item(name="香蕉", price=2.0, description="进口香蕉"),
}
_next_id = 3


# ── 路由 ─────────────────────────────────────────────────────
@app.get("/", tags=["健康检查"])
async def root():
    """根路由：健康检查。"""
    return {
        "status": "ok",
        "app": settings.app_name,
        "version": settings.app_version,
        "message": "Antigravity Gemini 3 Flash Ultimate Tuner 示例项目运行中",
    }


@app.get("/items", response_model=list[ItemResponse], tags=["商品管理"])
async def list_items():
    """获取所有商品列表。"""
    return [
        ItemResponse(id=item_id, item=item, message="查询成功")
        for item_id, item in _items_db.items()
    ]


@app.get("/items/{item_id}", response_model=ItemResponse, tags=["商品管理"])
async def get_item(item_id: int):
    """根据 ID 获取单个商品。"""
    if item_id not in _items_db:
        raise HTTPException(status_code=404, detail=f"商品 ID={item_id} 不存在")
    return ItemResponse(id=item_id, item=_items_db[item_id], message="查询成功")


@app.post("/items", response_model=ItemResponse, status_code=201, tags=["商品管理"])
async def create_item(item: Item):
    """创建新商品。"""
    global _next_id
    _items_db[_next_id] = item
    response = ItemResponse(id=_next_id, item=item, message="创建成功")
    _next_id += 1
    return response


@app.delete("/items/{item_id}", tags=["商品管理"])
async def delete_item(item_id: int):
    """删除商品。"""
    if item_id not in _items_db:
        raise HTTPException(status_code=404, detail=f"商品 ID={item_id} 不存在")
    del _items_db[item_id]
    return {"message": f"商品 ID={item_id} 已删除"}
