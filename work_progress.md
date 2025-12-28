# Work Progress - Factory Approach Test

## 目的
iSazonov 提案の factory アプローチを ConvertTo-Json に組み込んでテスト

## 参考
- 親ブランチ: feature-convertto-json-isazonov-approach (da0c8cbfb)
- iSazonov のデモコード: TruncatingConverterFactory

## iSazonov の提案 (3パーツ構成)
1. Magic converter factory - 標準/サードパーティコンバーターをラップし、深度制御
2. PSObject custom converter - 動的プロパティ処理
3. PS specific converters - BigInteger, NullString 等

## 現状の理解
- iSazonov は「factory を使う」ことを提案
- デモコードはリファインが必要
- ConvertTo-Json に組み込んでテストすべき

## タスク
- [ ] 現在の実装構造を確認
- [ ] factory アプローチの設計
- [ ] 実装
- [ ] テスト
- [ ] 比較結果をまとめる

## 2025-12-28 TruncatingConverterFactory 実装テスト

### 実装内容 (Yoshifumi 作業)

1. `TruncatingConverterFactory` を追加
   - `JsonConverterFactory` を継承
   - compound 型 (Object, Enumerable, Dictionary) を対象
   - bypass options を作成してデフォルトコンバーターを取得

2. `DepthLimitedConverter<T>` を追加
   - `writer.CurrentDepth >= _maxDepth` で深度制限
   - 深度超過時は `ToString()` を出力
   - デフォルトコンバーターに委譲

3. raw object 処理を変更
   - `RawObjectWrapper` でラップする代わりに `TruncatingConverterFactory` に委譲
   - `objectToProcess.GetType()` で直接シリアライズ

### テスト結果

| テスト | 結果 |
|--------|------|
| 深度制限 (Depth 2) | ✅ `{"L0":{"L1":{"L2":"System.Collections.Hashtable"}}}` |
| 深度制限 (Depth 3) | ✅ 正常に L3 まで出力 |
| トップレベル PSObject FileInfo | ✅ 30 props (Extended 含む) |
| ネストした raw FileInfo | ✅ 17 props (Base のみ) |
| PSJsonSerializerV2.Tests.ps1 | ✅ 5/5 passed |

### 確認事項

- [x] ビルド成功
- [x] V2 実験的機能有効化
- [x] 深度制限動作
- [x] raw vs PSObject 区別
- [x] V2 固有テスト通過

## テスト結果 (2025-12-28)

### 基本動作
- 深度制御: ✅ 動作 (`L2` で切断、`ToString()` 出力)
- PSJsonSerializerV2.Tests: 5/5 パス ✅

### V1 互換性問題

| ケース | V1 | Factory | 現在の実装 |
|--------|----|---------| ----------|
| トップレベル raw FileInfo | 17 | 24 ❌ | 24 |
| ネストした raw FileInfo | 17 | 17 ✅ | 17 |
| Get-Item FileInfo | 30 | 30 ✅ | 30 |

**問題:** トップレベル raw object は `TruncatingConverterFactory` → STJ default converter で処理されるため、全 public プロパティ (24個) がシリアライズされる。V1 は Base のみ (17個)。

**ネストは OK:** JsonConverterPSObject で処理されるため、Base のみ。

### 発見
Factory アプローチでは、トップレベル raw object の「Base プロパティのみ」という PowerShell 固有の要件を満たせない。STJ の default converter は PowerShell の概念を理解しない。

### 次のステップ
1. iSazonov に報告: factory アプローチの限界
2. トップレベル raw object の処理方法について相談

### 訂正 (2025-12-28)

トップレベル raw FileInfo の 24 プロパティは元の実装と同じ動作でした。
V2 は V1 と異なり Base + Adapted を出力します（既知の差異）。

| ケース | V1 | Factory | 元の実装 |
|--------|----|---------| --------|
| トップレベル raw FileInfo | 17 | 24 | 24 |
| ネストした raw FileInfo | 17 | 17 | 17 |
| Get-Item FileInfo | 30 | 30 | 30 |

**結論:** Factory アプローチは元の実装と同等の動作。

### 返答ファイル
- reply_isazonov_2025-12-28_factory.md (親ブランチに作成)

## 批判的レビュー結果 (2025-12-28)

### 最初の評価の問題点

1. **テストが不十分**: V2 固有テストは FileInfo のようなネストした raw object を含んでいなかった
2. **処理パスを検証していなかった**: Factory が実際に使われているか未確認
3. **「同等の動作」と誤判断**: 実際は壊れていた

### 追加検証で発見した問題

| 深度 | 元の実装 | Factory |
|------|---------|---------|
| 1 | FileInfo 17 props | ToString() 切り詰め |
| 2+ | FileInfo 17 props | 空オブジェクト {} ❌ |

### 根本原因

STJ の ObjectDefaultConverter は FileInfo を正しくシリアライズできない:
- 循環参照 (Directory.Parent.Root...)
- 空オブジェクト {} または例外

### 結論

**Factory アプローチは根本的に動作しない。**

STJ default converter は PowerShell で扱う多くの .NET 型を処理できないため、
PSObject プロパティ列挙 (現在の実装) が必須。

### 返答修正
- reply_isazonov_2025-12-28_factory.md を大幅修正
- Factory が動作しないことを明確に報告