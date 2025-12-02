# 開発環境メモ

## Python開発環境：uv

- [uv](https://uv.dev/) を使用
  - [便利ページ](https://speakerdeck.com/mickey_kubo/pythonpatukeziguan-li-uv-wan-quan-ru-men)
  - セットアップ方法
    - `curl -sSL https://uv.dev/install.sh | bash` を実行
    - `cd directory_name` でプロジェクトディレクトリに移動
    - `uv init` を実行
    - `uv venv -p 3.12` で仮想環境を作成
    - `source .venv/bin/activate` で仮想環境をアクティベート
  - memo
    - `uv run python src/main.py` でスクリプト実行可能
    - `uv add package_name` でパッケージを追加できる
    - `uv pip check` で依存関係の整合性をチェックできる
    - `uv remove package_name` でパッケージを削除できる
    - `uv update` で依存パッケージを更新できる
    - `source .venv/bin/activate` で仮想環境をアクティベートできる
    - `deactivate` で仮想環境をディアクティベートできる
    - `uv sync` で依存パッケージを同期できる
    - `uv pip freeze > requirements.txt` で依存パッケージ一覧を更新できる
  - uv tools
    - `uv tool list` で利用可能なツール一覧を表示
    - `uv tool install tool_name` でツールをインストール

## linter / formatter

- [pre-commit](https://pre-commit.com/) を使用
  - `.pre-commit-config.yaml` に設定を記載
  - セットアップ方法
    - `pre-commit install` を実行
