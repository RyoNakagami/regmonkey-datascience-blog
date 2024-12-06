## Description

今回のPRにおいて，[#33](https://github.com/spitz-jp/rocknroll/issues/33)に従いxxxを実施．変更内容は以下：

- aaaaに対応するため，新しいモジュール `bbbb.py` を作成
- ccccを目的に `BalancedPanelError` クラスに対して，ddddという変更を実施．
- `CheckRawData` クラスに型ヒントとエラーハンドリングを追加．

## Changes

- **New Module**:
  - `exceptions.py`: dddd.
  - `logger.py`: eeeeを目的
- **Moved Exception**:
  - `BalancedPanelError` moved to `exceptions.py` from `general.py`
- **Enhanced Class**
  - `CheckRawData` of `hogehoge.py`: ffffを実装
- **Deleted Functions**
  - `create_pokemon` of `foofoo.py`: hofehofe

## Example

<strong > &#9654;&nbsp; `exceptions.py` の変更</strong>

**Before:**

```python
# In check_dataset_format.py
class BalancedPanelError(Exception):
    def __init__(self, msg):
        self.msg = msg
        print("The above time_index list could cause the problem")
```

**After:**

```python
# In exceptions.py
class BalancedPanelError(Exception):
    def __init__(self, duplicated_entries):
        self.duplicated_entries = duplicated_entries
        super().__init__(f"Duplicated or missing (entity, time) units: {duplicated_entries}")

# In check_dataset_format.py
from exceptions import BalancedPanelError
```

## Additional Notes

- 修正内容に関する追加の情報や注意点があれば記載してください

## Related Issue

- [#Issue番号](リンク)
