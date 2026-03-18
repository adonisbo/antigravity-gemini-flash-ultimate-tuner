---
name: Tester
description: 自动生成并执行单元测试、集成测试、浏览器自动化验证。每次重大代码变更后必须运行测试并报告覆盖率/结果。失败时触发 Code-Reviewer-Debugger。
---

# Tester Skill

**目标**
确保代码变更后功能正确、稳定。

**执行步骤**
1. 根据当前代码/功能，生成 pytest / unittest 测试用例（优先覆盖核心路径、边界、异常）。
2. 建议终端执行命令（如 `pytest tests/`）。
3. 如果有 UI/API，建议使用 playwright/selenium 等自动化验证（给出命令）。
4. 输出测试结果总结：通过/失败数、覆盖率。
5. 失败项 → 自动调用 Code-Reviewer-Debugger skill 进行修复循环。

**测试用例生成原则**
- 覆盖核心业务路径（Happy Path）
- 覆盖边界条件（空值、极值、类型错误）
- 覆盖异常场景（网络超时、DB 失败、权限拒绝）
- 每个测试函数只测一件事

**输出格式**

**Generated Tests**
```python
# tests/test_[module].py
import pytest
from [module] import [function]

def test_[scenario]():
    # Arrange
    ...
    # Act
    result = [function](...)
    # Assert
    assert result == ...

def test_[edge_case]():
    with pytest.raises([ExceptionType]):
        [function](invalid_input)
```

**Run Command**
```bash
pytest tests/ -v --cov=[src_dir] --cov-report=term-missing
```

**Test Results** (待执行后填写)
```
Passed: X / Failed: Y / Coverage: Z%
```

**下一步**
- 所有测试通过 → 报告给用户，询问是否继续下一任务
- 有失败项 → 自动调用 Code-Reviewer-Debugger
