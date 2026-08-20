# 月音こな Cursor Installer (GitHub Pages)

`tsukine_kona_mouse_cursors.zip` または展開済みフォルダをブラウザへドラッグ＆ドロップし、Windows用の適用ファイル (`.cmd`) を生成する静的Webページです。

## 使い方

1. このリポジトリをGitHubへpushします。
2. **Settings → Pages** で、デプロイ元を `main` ブランチの `/ (root)` に設定します。
3. 公開されたページを開き、対象ZIPまたはフォルダをD&Dします。
4. 15種類すべて認識されたら「適用ファイルを作成」を押します。
5. ダウンロードされた `*-install.cmd` をWindowsで実行します。

カーソルは `%LOCALAPPDATA%\CursorAutoSetter\Cursors\<スキーム名>` に保存され、`HKCU\Control Panel\Cursors` と `HKCU\Control Panel\Cursors\Schemes` にユーザー単位で登録されます。管理者権限は不要です。

## プライバシー

カーソルファイルの処理はブラウザ内で行います。サーバーへのアップロード処理はありません。ZIP展開には JSZip 3.10.1 を jsDelivr から読み込みます。

## 対象ファイル

このページは以下の15ファイルを持つ配布物専用です。

- 月音こな_通常選択.ani
- 月音こな_ヘルプ選択.ani
- 月音こな_バックグラウンドで作業中.ani
- 月音こな_待ち状態.ani
- 月音こな_領域選択.ani
- 月音こな_テキスト選択.ani
- 月音こな_手書き.ani
- 月音こな_利用不可.ani
- 月音こな_上下に拡大／縮小.ani
- 月音こな_左右に拡大／縮小.ani
- 月音こな_斜めに拡大／縮小１.ani
- 月音こな_斜めに拡大／縮小２.ani
- 月音こな_移動.ani
- 月音こな_代替選択.ani
- 月音こな_リンク選択.ani

ZIP内の `__MACOSX` は無視し、Unicodeファイル名はNFC正規化して比較します。
