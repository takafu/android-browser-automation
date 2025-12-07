# 実践的なTips & ハック集

Android Browser Automationを使う上での実用的な知見とハック。

## 表示関連

### デスクトップレイアウトを強制する

Slackなどの複雑なサイトで、モバイルレイアウトになってしまう場合：

```bash
source ~/android-browser-automation/client/browser.sh

# ズームアウトしてデスクトップレイアウトを見やすく
browser_execute "document.body.style.zoom = '0.7'"  # 70%
browser_execute "document.body.style.zoom = '0.5'"  # 50%（より小さく）
```

**タイミング:** ページ読み込み完了後に実行。

### フローティングウィンドウのサイズ

現在の設定: 画面の95%幅 × 85%高さ

変更する場合は `FloatingBubbleService.kt:171-172` を編集。

---

## ページ読み込み

### 重要: バックグラウンド vs フォアグラウンド

**WebViewがバックグラウンドにいると表示が更新されない。**

**解決策:**

1. **バブルをタップして展開** - WebViewがフォアグラウンドに
2. **スクリーンショットは常に取得可能** - バックグラウンドでもOK

```bash
# バブルを閉じた状態でも動作する
browser_goto "https://example.com"
browser_eval "document.title"
browser_screenshot check.png  # これで確認
```

### Slackなどの複雑なページ

**初回読み込みは必ずリロード:**

```bash
browser_goto "https://spiball.slack.com"
sleep 3
browser_refresh  # リロードでリソース読み込み成功率向上
sleep 5
```

**理由:** 初回はリソース読み込みエラー（net::ERR_FAILED）が発生しやすい。

---

## 自動化のベストプラクティス

### ページ遷移の待機

```bash
browser_goto "https://example.com"
sleep 3  # 軽いページ
# または
sleep 5-8  # Slack等の重いページ
```

**確認方法:**
```bash
# URLが変わったか確認
browser_url

# タイトルが取得できるか確認
browser_title
```

### フォーム入力

```bash
# 入力フィールドに値を設定
browser_execute "document.querySelector('input[name=\"email\"]').value = 'test@example.com'"

# inputイベントを発火（React等のフレームワーク対応）
browser_execute "
const input = document.querySelector('input[name=\"email\"]');
input.value = 'test@example.com';
input.dispatchEvent(new Event('input', { bubbles: true }));
"
```

### ボタンクリック

```bash
# 直接クリック
browser_execute "document.querySelector('button').click()"

# セレクタで特定
browser_execute "document.querySelector('button[type=\"submit\"]').click()"

# テキストで検索
browser_execute "
Array.from(document.querySelectorAll('button'))
  .find(b => b.textContent.includes('送信'))
  ?.click()
"
```

---

## トラブルシューティング

### ページが真っ白

**原因1: まだ読み込み中**
```bash
sleep 5
browser_refresh
```

**原因2: JavaScriptエラー**
```bash
# コンソールログを確認
adb logcat -s AutomationService:D | grep "Console:"
```

**原因3: リソース読み込み失敗**
```bash
browser_refresh  # リロードで解決することが多い
```

### チャンネルドロップダウンが空（Slack）

WebSocket接続が確立されていない。**ページをリロード:**

```bash
browser_refresh
sleep 5
# 再度操作
```

### Google OAuth がブロックされる

WebViewでのGoogle OAuthは制限される。**代替案:**
- メールでマジックリンク
- パスワード認証
- 他のブラウザでログイン→Cookieコピー

---

## 便利なスニペット

### ページ情報の一括取得

```bash
source ~/android-browser-automation/client/browser.sh

echo "URL: $(browser_url)"
echo "Title: $(browser_title)"
echo "Links: $(browser_eval 'document.querySelectorAll(\"a\").length')"
```

### スクリーンショット付きログ

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
browser_screenshot ~/storage/downloads/slack-$TIMESTAMP.png
echo "Screenshot saved: slack-$TIMESTAMP.png"
```

### 要素の存在確認

```bash
# 要素が見つかるまで待機
while true; do
    exists=$(browser_eval "!!document.querySelector('#target')")
    if [ "$exists" = "true" ]; then
        echo "Element found!"
        break
    fi
    sleep 1
done
```

### セッション保持

アプリを再インストールするとCookie/セッションが消える。

**対策:** 開発中は`adb install -r`で上書きインストール（`./auto-dev.sh`が自動実行）。

---

## パフォーマンス

### スクリーンショットは重い

頻繁に撮ると遅くなる。確認が必要なときだけ使用。

### evalよりexecuteが速い

結果が不要なら`browser_execute`を使う：

```bash
# 遅い
browser_eval "console.log('test')"

# 速い
browser_execute "console.log('test')"
```

---

## Slack自動化の例

### ログインからトークン取得まで

```bash
source ~/android-browser-automation/client/browser.sh

# 1. ワークスペースにアクセス
browser_goto "https://spiball.slack.com"
sleep 5
browser_refresh  # 初回はリロード推奨
sleep 5

# 2. 手動でログイン（メールでマジックコード）

# 3. 管理画面へ
browser_goto "https://api.slack.com/apps/"
sleep 5

# 4. アプリ選択→OAuth→トークン取得
# （手動操作またはJavaScript自動化）
```

### デスクトップ表示のコツ

```bash
# 1. ページ読み込み
browser_goto "https://spiball.slack.com"
sleep 5
browser_refresh

# 2. バブルをタップしてウィンドウ展開

# 3. ズームアウト
browser_execute "document.body.style.zoom = '0.7'"

# これでデスクトップレイアウトが見やすくなる
```

---

## 開発時のコツ

### ビルド→テストのサイクル

```bash
cd ~/android-browser-automation
./auto-dev.sh  # ビルド→インストール→起動（自動）
sleep 3
source client/browser.sh
browser_goto "https://example.com"
```

### ログ監視

```bash
# リアルタイムログ
adb logcat -s AutomationService:D | grep "page_"

# エラーのみ
adb logcat -s chromium:E AutomationService:E
```

### スクリーンショットでデバッグ

```bash
# 各ステップでスクリーンショット
browser_goto "https://slack.com"
browser_screenshot step1.png

browser_execute "document.querySelector('button').click()"
sleep 2
browser_screenshot step2.png
```

---

## 既知の制限事項

### できないこと

- ❌ ファイルアップロード（未実装）
- ❌ ポップアップウィンドウ（ブロックされる）
- ❌ Google OAuth（WebView制限）
- ❌ ダウンロード（未実装）

### 回避策

- Cookieコピー
- 代替認証方法（メール、パスワード）
- JavaScript経由での操作

---

## よくある質問

**Q: バブルが2回目のクリックで消える**

A: 古いバージョンのバグ。最新版に更新してください。

**Q: Slackのチャンネルドロップダウンが空**

A: WebSocket未接続。ページをリロード（`browser_refresh`）。

**Q: スクリーンショットが真っ白**

A: バブルを開いた状態で撮影。または、バブルを閉じていてもWebViewは動作しているので、それが正常な場合もある（`about:blank`を表示中など）。
