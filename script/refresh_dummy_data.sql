PRAGMA foreign_keys = ON;
BEGIN IMMEDIATE;

-- Keep the original hand-written bank and replace only this refresh's additions.
DELETE FROM messages WHERE id > 80;
UPDATE sqlite_sequence SET seq = 80 WHERE name = 'messages';

-- Story arcsと競合する旧文面は、別の出来事へ差し替える。
UPDATE messages SET text = '休憩スペースの棚に見覚えのない鍵が置かれています。' WHERE id = 60;
UPDATE messages SET text = 'B社との初回商談が終わり、次回は現場担当者も参加予定です。' WHERE id = 63;
UPDATE messages SET text = '提案の軸を導入後の定着支援まで広げます。' WHERE id = 64;
UPDATE messages SET text = 'Auroraの検索画面をステージングへ反映しました。' WHERE id = 69;
UPDATE messages SET text = '朝会の議事メモを共同編集できるようにしました。' WHERE id = 72;

INSERT INTO messages(category, kind, text) VALUES
('casual', 'single', '駅前の新しいパン屋、朝はまだ並ばずに入れました。'),
('casual', 'single', '午後の集中タイム、通知を30分だけ切ってみます。'),
('casual', 'single', '共有スペースの傘、持ち主が分かるように札を付けました。'),
('casual', 'single', '金曜のデモが終わったら軽く打ち上げしませんか。'),
('casual', 'reply', 'いいですね、時間が決まったら参加します。'),
('casual', 'reply', '助かります。こちらでも声をかけておきます。'),

('latenight', 'single', 'ここまでで区切って、残りは明日の自分に渡します。'),
('latenight', 'single', '夜中の修正は差分を小さくしておくのが安心ですね。'),
('latenight', 'single', '静かな時間なので設計メモだけ整理しています。'),
('latenight', 'single', '明日の朝に迷わないよう、TODOを3行残しました。'),
('latenight', 'reply', '無理せず、続きは朝に回しましょう。'),
('latenight', 'reply', 'メモ確認しました。先に休んでください。'),

('breakroom', 'single', '冷蔵庫の奥に期限が近い牛乳が一本あります。'),
('breakroom', 'single', '午後用に麦茶を作っておきました。'),
('breakroom', 'single', 'いただいたお菓子は共有棚の上段に置きました。'),
('breakroom', 'single', '新しいコーヒー豆、酸味が控えめで飲みやすいです。'),
('breakroom', 'reply', 'ありがとうございます。休憩のときにいただきます。'),
('breakroom', 'reply', '気づいてくれて助かりました。'),

('oneliner', 'single', '今日の一言: 小さいPRはレビューが速い。'),
('oneliner', 'single', '今日の一言: 迷ったらログを見る。'),
('oneliner', 'single', '今日の一言: 早めの共有がいちばん効く。'),
('oneliner', 'single', '今日の一言: 動くデモは説明を助ける。'),
('oneliner', 'reply', '今日いちばん刺さりました。'),
('oneliner', 'reply', '明日の自分にも伝えたいです。'),

('dev', 'single', '`/api/v4/health` の応答まで確認できました。次は認証周りを見ます。'),
('dev', 'single', '設定値を環境変数へ移したので、ローカル手順も更新します。'),
('dev', 'single', '差分を小さく分けたら原因のコミットを特定できました。'),
('dev', 'single', 'レビュー指摘の境界値テストを追加して再実行中です。'),
('dev', 'reply', '再現手順と期待値もPRに追記してもらえると助かります。'),
('dev', 'reply', 'こちらの環境でも同じ結果になりました。'),

('devtips', 'single', 'SQLiteの外部キー検査は `PRAGMA foreign_key_check` で確認できます。'),
('devtips', 'single', 'ログの時刻がUTCかローカルか、最初に揃えると調査が速いです。'),
('devtips', 'single', '再現しない不具合は入力と環境の差分を表にすると見つけやすいです。'),
('devtips', 'single', '一時ファイルを成果物に含めないよう `.gitignore` も確認しましょう。'),
('devtips', 'reply', '手元でも試せる最小例があると助かります。'),
('devtips', 'reply', 'その観点が抜けていました。確認します。'),

('project', 'single', 'Phoenixの検索画面は主要3操作まで通りました。'),
('project', 'single', '今週は性能改善より、失敗時の表示を優先します。'),
('project', 'single', 'デモシナリオを3分版と10分版に分けました。'),
('project', 'single', '未決定事項を議事録の先頭にまとめています。'),
('project', 'reply', '担当と期限を決めてチケットにします。'),
('project', 'reply', 'デモ前に一度通しで確認しましょう。'),

('weekly', 'single', '今週は認証フローの整理と結合テストを進めました。'),
('weekly', 'single', '来週はデモ準備を優先し、新規機能は増やしません。'),
('weekly', 'single', '詰まった点はデータ移行でした。手順を文書化しています。'),
('weekly', 'single', 'レビュー待ち2件、調査中1件です。'),
('weekly', 'reply', '来週の優先順位、認識合っています。'),
('weekly', 'reply', 'ブロッカーの共有ありがとうございます。'),

('release', 'single', 'v2.3.1をステージングへ反映し、スモークテストを完了しました。'),
('release', 'single', '変更点は通知設定と検索速度の改善です。'),
('release', 'single', '本番反映は14時開始、判断期限は14時30分です。'),
('release', 'single', '既知の制約をリリースノート末尾に追記しました。'),
('release', 'reply', '監視項目を確認しました。対応できます。'),
('release', 'reply', '利用者向けのお知らせも更新済みです。'),

('incident', 'single', '10:14からAPIのp95が上昇。影響範囲を確認しています。'),
('incident', 'single', '読み取り処理は正常、書き込み処理のみ遅延しています。'),
('incident', 'single', '暫定対応を適用し、エラー率は通常値に戻りました。'),
('incident', 'single', 'タイムラインと恒久対応案をインシデント記録へまとめました。'),
('incident', 'reply', 'こちらは顧客影響の有無を確認します。'),
('incident', 'reply', 'メトリクスでも復旧を確認できました。'),

('security', 'single', '依存パッケージの更新差分を確認し、影響なしと判断しました。'),
('security', 'single', '共有トークンの棚卸しを実施し、未使用分を失効しました。'),
('security', 'single', '検証環境に本番データを持ち込まない手順へ更新しました。'),
('security', 'single', '権限変更の監査ログを月次で確認する担当を決めます。'),
('security', 'reply', '対象範囲と確認結果を記録しておきます。'),
('security', 'reply', '自分の設定も見直しました。問題ありません。'),

('design', 'single', 'エラー表示に次の操作を添える案をFigmaへ追加しました。'),
('design', 'single', '主要ボタンのラベルを動詞から始める形に揃えます。'),
('design', 'single', '空状態で何をすればよいか分かる説明を追加しました。'),
('design', 'single', 'キーボード操作時のフォーカス表示を確認中です。'),
('design', 'reply', '比較案だとこちらの方が迷いにくいです。'),
('design', 'reply', '実データを入れた状態でも確認したいです。'),

('botplay', 'single', '`/standup` の返答形式を3パターン試しています。'),
('botplay', 'single', 'Botへのメンションがない投稿には反応しない設定です。'),
('botplay', 'single', 'テスト用Webhookを再発行しました。古いURLは無効です。'),
('botplay', 'single', '長文を送ったときの要約結果をこのスレッドで比較します。'),
('botplay', 'reply', '期待した形式で返ってきました。'),
('botplay', 'reply', '停止条件も一緒にテストしておきましょう。'),

('botdev', 'single', 'イベント受信後の再試行を指数バックオフへ変更しました。'),
('botdev', 'single', 'Botの権限を投稿とリアクション追加だけに絞りました。'),
('botdev', 'single', '署名検証に失敗したリクエストは処理前に破棄します。'),
('botdev', 'single', 'レート制限時のログに待機秒数を出すようにしました。'),
('botdev', 'reply', '権限一覧をREADMEにも載せてください。'),
('botdev', 'reply', '異常系のテストケースも追加します。'),

('bug', 'single', '【バグ報告】未読から開くと先頭ではなく末尾へ移動します。'),
('bug', 'single', '【バグ報告】絵文字を連続入力すると候補が閉じません。'),
('bug', 'single', 'macOS 15.6、Chrome 140で再現しました。'),
('bug', 'single', 'キャッシュ削除後も再現。新規アカウントでは未再現です。'),
('bug', 'reply', '発生時刻と対象チャンネルも分かりますか。'),
('bug', 'reply', 'こちらで再現できたので調査を引き継ぎます。'),

('announce', 'single', '【お知らせ】金曜15時から成果共有会を行います。'),
('announce', 'single', '【お知らせ】共用検証環境は本日18時に再起動します。'),
('announce', 'single', '【お知らせ】来週の全体定例は30分早く開始します。'),
('announce', 'single', '【お知らせ】デモ用アカウントの一覧を更新しました。'),
('announce', 'reply', '予定を確認しました。ありがとうございます。'),
('announce', 'reply', '関係するメンバーにも共有します。'),

('faq', 'single', 'Q. Botのアクセストークンはどこで発行しますか。'),
('faq', 'single', 'Q. ローカル環境を初期化する手順はありますか。'),
('faq', 'single', 'Q. 通知が多いチャンネルだけミュートできますか。'),
('faq', 'single', 'Q. 投稿の検索条件を保存できますか。'),
('faq', 'reply', 'A. 手順書の「初期設定」から確認できます。'),
('faq', 'reply', 'A. 管理者権限が必要なので担当へ連絡してください。'),

('onboarding', 'single', '開発環境のセットアップが終わりました。よろしくお願いします。'),
('onboarding', 'single', '担当サービスの構成図を読みながら動作確認しています。'),
('onboarding', 'single', '最初のレビュー依頼を出しました。確認お願いします。'),
('onboarding', 'single', '分からない用語をチームWikiへメモしています。'),
('onboarding', 'reply', 'セットアップ完了お疲れさまです。'),
('onboarding', 'reply', '困ったらこのチャンネルで聞いてください。'),

('event', 'single', '成果共有会の登壇順を仮決めしました。'),
('event', 'single', '会場レイアウト案を共有ドライブへ置きました。'),
('event', 'single', '受付を13時30分から始める想定です。'),
('event', 'single', '懇親会の食事制限をフォームで確認します。'),
('event', 'reply', '当日の誘導を担当できます。'),
('event', 'reply', '参加人数が確定したら備品を調整します。'),

('mystery', 'single', '会議室の時計が毎日2分ずつ進んでいる気がします。'),
('mystery', 'single', '誰も頼んでいない付箋が箱で届きました。'),
('mystery', 'single', '深夜だけテストBotのアイコンが変わるという噂があります。'),
('mystery', 'single', '共有棚のアヒルが今朝は窓際に移動していました。'),
('mystery', 'reply', '原因が分かったらここに追記してください。'),
('mystery', 'reply', '写真があると手がかりになりそうです。'),

('business', 'single', 'B社向け提案は導入後3か月の運用まで含めて整理します。'),
('business', 'single', '次回商談では現場担当者にも同席いただく予定です。'),
('business', 'single', '見積条件のうちサポート時間だけ再確認が必要です。'),
('business', 'single', 'デモでは検索時間の短縮を実データで見せます。'),
('business', 'reply', '先方の判断基準も確認しておきましょう。'),
('business', 'reply', 'この内容で提案資料を更新します。'),

('customer', 'single', '初回設定で迷いやすい3項目を導入チェックリストへ追加しました。'),
('customer', 'single', '問い合わせの再現動画を受領し、原因を確認しています。'),
('customer', 'single', '回答テンプレートを使わず、今回の状況に合わせて案内します。'),
('customer', 'single', '導入1週間後のフォロー会で検索機能の使い方を扱います。'),
('customer', 'reply', '案内前に検証環境で手順を確認します。'),
('customer', 'reply', '解決後の確認連絡まで担当します。'),

('aurora', 'single', 'Auroraの通知設定画面をステージングへ反映しました。'),
('aurora', 'single', '検索結果0件時の導線をチームで確認します。'),
('aurora', 'single', '利用ログの保存期間について法務確認を依頼しました。'),
('aurora', 'single', '金曜のデモは登録、検索、共有の順で進めます。'),
('aurora', 'reply', 'デモデータを今日中に準備します。'),
('aurora', 'reply', 'その順番なら価値が伝わりやすいと思います。'),

('remote', 'single', '午後は宅配対応で10分ほど離席する可能性があります。'),
('remote', 'single', '自宅回線の切り替えテストが無事終わりました。'),
('remote', 'single', '今日は集中作業のため朝会後は通知を絞ります。'),
('remote', 'single', '共同編集のリンクを会議メモの先頭に置きました。'),
('remote', 'reply', '了解です。急ぎはメンションします。'),
('remote', 'reply', '会議メモから追えるので大丈夫です。'),

('admin', 'single', '予備モニター2台の貸出状況を更新しました。'),
('admin', 'single', '来月分のソフトウェア更新申請をまとめています。'),
('admin', 'single', '会議室Aのプロジェクターは金曜午前に点検予定です。'),
('admin', 'single', '備品申請は品名と用途を一緒に書いてください。'),
('admin', 'reply', '申請内容を確認しました。手配します。'),
('admin', 'reply', '在庫を確認して今日中に返答します。'),

('hobby', 'single', '今週の散歩会は川沿いを40分ほど歩く予定です。'),
('hobby', 'single', 'ボードゲーム会に初心者向けの協力ゲームを持っていきます。'),
('hobby', 'single', '写真部の今月テーマは「帰り道」になりました。'),
('hobby', 'single', '読書会の候補を3冊に絞ったので投票をお願いします。'),
('hobby', 'reply', '初参加ですが混ざってもいいですか。'),
('hobby', 'reply', '予定が合うので参加します。');

UPDATE channel_weights
SET weight = CASE category
    WHEN 'casual' THEN 18
    WHEN 'dev' THEN 18
    WHEN 'botplay' THEN 16
    WHEN 'devtips' THEN 14
    WHEN 'botdev' THEN 14
    WHEN 'bug' THEN 12
    WHEN 'breakroom' THEN 12
    WHEN 'project' THEN 11
    WHEN 'business' THEN 11
    WHEN 'aurora' THEN 11
    WHEN 'customer' THEN 10
    WHEN 'oneliner' THEN 10
    WHEN 'latenight' THEN 10
    WHEN 'weekly' THEN 9
    WHEN 'remote' THEN 9
    WHEN 'release' THEN 8
    WHEN 'incident' THEN 8
    WHEN 'design' THEN 8
    WHEN 'faq' THEN 8
    WHEN 'event' THEN 8
    WHEN 'admin' THEN 8
    WHEN 'announce' THEN 7
    WHEN 'security' THEN 7
    WHEN 'onboarding' THEN 7
    WHEN 'mystery' THEN 7
    WHEN 'hobby' THEN 7
    ELSE 8
END;

DELETE FROM settings WHERE key IN ('base_ts', 'split_import_percent');
INSERT OR REPLACE INTO settings(key, value_int) VALUES
('history_days', 21),
('active_hour_start', 8),
('active_hour_end', 22),
('min_channel_members', 5),
('seed', 42);

DELETE FROM always_on_channels;
INSERT INTO always_on_channels(channel_name) VALUES
('town-square'),
('announcements');

INSERT OR IGNORE INTO persona_categories(persona_key, category) VALUES
('manager', 'business'),
('manager', 'aurora'),
('qa_tester', 'customer'),
('designer', 'aurora'),
('night_owl', 'remote'),
('joker', 'breakroom'),
('quiet_type', 'mystery');

INSERT OR IGNORE INTO persona_categories(persona_key, category) VALUES
('manager', 'release'),
('manager', 'event'),
('manager', 'admin'),
('foodie', 'hobby');

UPDATE team
SET description = 'Bot開発と運用フローを試せる、会話履歴入りのデモチーム'
WHERE name = 'sh365-fes';

UPDATE users
SET nickname = last_name || ' ' || first_name;

COMMIT;
