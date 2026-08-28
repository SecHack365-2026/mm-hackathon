PRAGMA foreign_keys = ON;
BEGIN;

DELETE FROM channel_conversation_steps
WHERE conversation_id LIKE 'social_%';

INSERT INTO channel_conversation_steps(
    conversation_id, step_order, channel_name, username, day_offset, minute_of_day, message
) VALUES
-- town-square: 日々の声かけや、全員が参加しやすい軽い相談。
('social_town_lunch_map', 1, 'town-square', 'user03', 2, 700, '@user18 この前話していたお弁当屋、今日も出ていますか？ 最近は昼休みの店が混みやすく、買いに出てから席へ戻るまで二十分以上かかる日が続いています。もし今日も出ているなら、十二時十五分ごろに入口へ集まり、希望者でまとめて向かえればと思っています。初めて利用する人向けに、売り場の場所、辛くないメニューの有無、支払い方法も分かる範囲で教えてもらえると助かります。'),
('social_town_lunch_map', 2, 'town-square', 'user18', 2, 704, '出ています。今日は鶏の照り焼きと豆のカレーでした。'),
('social_town_lunch_map', 3, 'town-square', 'user27', 2, 708, '豆のカレー気になります。列は長そうですか？'),
('social_town_lunch_map', 4, 'town-square', 'user18', 2, 711, '今なら五人くらいなので、すぐ買えそうです。'),
('social_town_lunch_map', 5, 'town-square', 'user03', 2, 714, 'では十五分に入口へ行きます。紙袋が目印です。'),
('social_town_lunch_map', 6, 'town-square', 'user27', 2, 718, '了解です。飲み物を買ってから合流します。'),

('social_town_lost_umbrella', 1, 'town-square', 'user12', 5, 1020, '共有スペースに紺色の折り畳み傘を忘れたかもしれません。'),
('social_town_lost_umbrella', 2, 'town-square', 'user31', 5, 1024, '@user12 木の持ち手で、小さな白い印が付いた傘ですか？'),
('social_town_lost_umbrella', 3, 'town-square', 'user12', 5, 1027, 'それです。見つけてくれてありがとうございます。'),
('social_town_lost_umbrella', 4, 'town-square', 'user31', 5, 1031, '雨に間に合ってよかったです。受付横の傘立てへ移しておきました。'),
('social_town_lost_umbrella', 5, 'town-square', 'user08', 5, 1035, '似た傘が多いので、目印があると助かりますね。'),
('social_town_lost_umbrella', 6, 'town-square', 'user12', 5, 1039, '見つかってほっとしました。今度から明るい色のバンドも付けておきます。'),

('social_town_music_poll', 1, 'town-square', 'user22', 8, 765, '@user06 午後の作業用BGM、静かな曲と少し明るい曲ならどちらがよさそうですか？'),
('social_town_music_poll', 2, 'town-square', 'user06', 8, 769, '昼食後なので、少し明るい方に一票です。'),
('social_town_music_poll', 3, 'town-square', 'user35', 8, 773, '歌詞がない曲だと集中しやすくてうれしいです。'),
('social_town_music_poll', 4, 'town-square', 'user22', 8, 777, 'では軽めの器楽曲を小さい音で流します。'),
('social_town_music_poll', 5, 'town-square', 'user06', 8, 782, '音量が気になったらすぐ言ってください。'),
('social_town_music_poll', 6, 'town-square', 'user35', 8, 787, '今くらいなら考えを邪魔せず、気分だけ明るくなってちょうどよいです。'),

('social_town_snack_share', 1, 'town-square', 'user09', 11, 915, '個包装のお菓子を休憩机に置きました。甘いものと塩味があります。'),
('social_town_snack_share', 2, 'town-square', 'user24', 11, 919, '@user09 塩味の方は辛くないですか？'),
('social_town_snack_share', 3, 'town-square', 'user09', 11, 922, '辛くないせんべいです。原材料の表示も箱に残しています。'),
('social_town_snack_share', 4, 'town-square', 'user16', 11, 926, 'ありがとうございます。午後の休憩で一ついただきます。'),
('social_town_snack_share', 5, 'town-square', 'user24', 11, 931, 'せんべい、思ったより軽い味でお茶にも合いました。午後のよい息抜きになりました。'),
('social_town_snack_share', 6, 'town-square', 'user09', 11, 936, 'まだ多めにあるので、遠慮なくどうぞ。'),

('social_town_window_weather', 1, 'town-square', 'user14', 15, 1005, '@user32 外が急に暗くなりましたが、雨は降っていますか？'),
('social_town_window_weather', 2, 'town-square', 'user32', 15, 1009, '細かい雨が降り始めました。風も少し強いです。'),
('social_town_window_weather', 3, 'town-square', 'user05', 15, 1013, '窓際の資料だけ内側へ移動しておきます。'),
('social_town_window_weather', 4, 'town-square', 'user14', 15, 1017, '助かります。入口のマットも出しておきます。'),
('social_town_window_weather', 5, 'town-square', 'user32', 15, 1022, '十分ほどで弱まりそうですが、帰る方は傘が必要です。'),
('social_town_window_weather', 6, 'town-square', 'user05', 15, 1027, '帰り道が少し心配ですね。共有の傘が二本あるので、必要な方は遠慮なく声をかけてください。'),

-- break-room: 休憩中の短いやり取りと生活上の小さな助け合い。
('social_break_coffee_grind', 1, 'break-room', 'user04', 3, 870, '@user19 コーヒー豆を挽く音、今出しても大丈夫ですか？'),
('social_break_coffee_grind', 2, 'break-room', 'user19', 3, 873, '大丈夫です。こちらの通話はちょうど終わりました。'),
('social_break_coffee_grind', 3, 'break-room', 'user28', 3, 877, 'いい香りですね。今日は深煎りですか？'),
('social_break_coffee_grind', 4, 'break-room', 'user04', 3, 881, '少し深めです。酸味が控えめな豆を選びました。'),
('social_break_coffee_grind', 5, 'break-room', 'user28', 3, 885, 'お湯が余ったら、私の分もお願いできますか？'),
('social_break_coffee_grind', 6, 'break-room', 'user04', 3, 889, 'もちろんです。濃さが合うか気になるので、まず小さいカップで味見してください。'),

('social_break_fridge_label', 1, 'break-room', 'user20', 6, 740, '冷蔵庫の奥に日付のない保存容器があります。'),
('social_break_fridge_label', 2, 'break-room', 'user11', 6, 744, '@user20 緑のふたなら私のものです。昨日入れました。'),
('social_break_fridge_label', 3, 'break-room', 'user20', 6, 748, 'それでした。名前を書いた付箋を横に置いておきます。'),
('social_break_fridge_label', 4, 'break-room', 'user11', 6, 752, 'ありがとうございます。今日中に持ち帰ります。'),
('social_break_fridge_label', 5, 'break-room', 'user33', 6, 756, '油性ペンも冷蔵庫の横へ補充しました。'),
('social_break_fridge_label', 6, 'break-room', 'user20', 6, 760, '置き場所まで整って助かります。これなら急いでいるときも忘れず記名できそうです。'),

('social_break_stretch', 1, 'break-room', 'user25', 9, 900, '@user07 肩まわりの短いストレッチ、前に教えていたものをもう一度やりませんか？ 午前中に画面を見続けていたせいか、肩が上がったままになっている感じがします。休憩室で三分ほど、椅子に座ったままできて、特別な道具を使わない内容だと参加しやすそうです。痛みがある人は見学だけでもよいことと、無理に首を回さないことも最初に伝えたいです。動きが難しければ、途中で止めて声をかけてください。'),
('social_break_stretch', 2, 'break-room', 'user07', 9, 904, 'いいですね。椅子に座ったままできる動きにしましょう。'),
('social_break_stretch', 3, 'break-room', 'user13', 9, 908, '三分くらいなら参加したいです。少し肩が軽くなるとうれしいです。'),
('social_break_stretch', 4, 'break-room', 'user07', 9, 912, 'では肩を上げ下げしてから、首をゆっくり傾けます。'),
('social_break_stretch', 5, 'break-room', 'user25', 9, 916, '痛みが出ない範囲で十分ですよ。'),
('social_break_stretch', 6, 'break-room', 'user13', 9, 920, '少し軽くなりました。午後も姿勢に気を付けます。'),

('social_break_tea_choice', 1, 'break-room', 'user30', 13, 625, '新しい茶葉を二種類もらいました。ほうじ茶と柑橘の紅茶です。'),
('social_break_tea_choice', 2, 'break-room', 'user17', 13, 629, '@user30 朝なので、ほうじ茶を少し試したいです。'),
('social_break_tea_choice', 3, 'break-room', 'user30', 13, 633, '一杯分だけ淹れますね。香りはかなり穏やかです。'),
('social_break_tea_choice', 4, 'break-room', 'user38', 13, 637, '午後になったら柑橘の方も試してみたいです。'),
('social_break_tea_choice', 5, 'break-room', 'user17', 13, 641, 'ほうじ茶、香りが穏やかで朝にも飲みやすいです。少し迷いましたがこちらを選んでよかったです。'),
('social_break_tea_choice', 6, 'break-room', 'user30', 13, 645, '茶葉は棚の透明な缶に入れておきます。'),

('social_break_fan_setting', 1, 'break-room', 'user36', 17, 780, '@user10 休憩室の扇風機、弱にしても寒くないですか？'),
('social_break_fan_setting', 2, 'break-room', 'user10', 17, 784, '弱なら大丈夫です。壁側へ向けるとちょうどよさそうです。'),
('social_break_fan_setting', 3, 'break-room', 'user21', 17, 788, '窓も少し開けると空気が動きそうですね。'),
('social_break_fan_setting', 4, 'break-room', 'user36', 17, 792, 'では扇風機は壁向き、窓は少しだけ開けます。'),
('social_break_fan_setting', 5, 'break-room', 'user10', 17, 796, '音も気にならないので、このままでよさそうです。'),
('social_break_fan_setting', 6, 'break-room', 'user21', 17, 800, '風が直接当たらず楽になりました。冷えすぎないよう、最後に出る人が窓を閉めましょう。'),

-- late-night-talk: 夜更けの作業を無理なく切り上げる会話。
('social_late_release_pause', 1, 'late-night-talk', 'user02', 4, 1320, '@user15 変更点の確認は終わりましたか？ 今夜の作業は表示の微調整が中心ですが、遅い時間に確認項目を増やすと見落としが出そうで心配しています。主要な動作が通っているなら、残った箇所には再現手順と画面の状態だけをメモし、続きは明日の午前へ回したいです。いま止めても困る人がいないか、保存前に一度だけ確認させてください。急ぎの事情があれば、無理に閉じず先に相談しましょう。'),
('social_late_release_pause', 2, 'late-night-talk', 'user15', 4, 1324, '主要な動作は見ましたが、細かい表示が一件残っています。'),
('social_late_release_pause', 3, 'late-night-talk', 'user26', 4, 1328, '急ぎでなければ、明るい時間に画面を見直した方がよさそうです。'),
('social_late_release_pause', 4, 'late-night-talk', 'user02', 4, 1332, '同意です。今夜は差分を保存して止めましょう。'),
('social_late_release_pause', 5, 'late-night-talk', 'user15', 4, 1336, '明日の確認項目をメモへ追記しました。'),
('social_late_release_pause', 6, 'late-night-talk', 'user26', 4, 1340, '確認しました。続きは午前中に引き取ります。'),

('social_late_rain_sound', 1, 'late-night-talk', 'user34', 7, 1370, '雨音が大きくなってきました。まだ作業中の方はいますか？'),
('social_late_rain_sound', 2, 'late-night-talk', 'user08', 7, 1374, '@user34 あと十分だけ整理して終わる予定です。'),
('social_late_rain_sound', 3, 'late-night-talk', 'user34', 7, 1378, '帰り道が心配なので、強くなる前に区切りましょう。'),
('social_late_rain_sound', 4, 'late-night-talk', 'user08', 7, 1382, 'いま保存しました。少し名残惜しいですが、明日のTODOも二つ残せたので安心して終われます。'),
('social_late_rain_sound', 5, 'late-night-talk', 'user40', 7, 1386, '帰りが心配な方へ、共有の大きい傘が入口に一本あります。'),
('social_late_rain_sound', 6, 'late-night-talk', 'user34', 7, 1390, '情報ありがとうございます。必要なら借ります。'),

('social_late_bookmark', 1, 'late-night-talk', 'user16', 12, 1295, '@user29 調べ物の途中ですが、参考ページが増えすぎました。'),
('social_late_bookmark', 2, 'late-night-talk', 'user29', 12, 1299, '今夜読むものと明日読むものに分けると整理しやすいですよ。'),
('social_late_bookmark', 3, 'late-night-talk', 'user16', 12, 1303, 'まず結論に関係する三件だけ残してみます。'),
('social_late_bookmark', 4, 'late-night-talk', 'user05', 12, 1307, '残りは題名と一行メモだけ付けておけば十分そうです。'),
('social_late_bookmark', 5, 'late-night-talk', 'user16', 12, 1311, 'その形で整理できました。今日はここまでにします。'),
('social_late_bookmark', 6, 'late-night-talk', 'user29', 12, 1315, 'きれいに分けられましたね。続きが分かる状態なら、今夜は気にせず休めそうです。'),

('social_late_keyboard', 1, 'late-night-talk', 'user23', 18, 1345, '静かな時間だと、キーボードの音がいつもより大きく感じます。'),
('social_late_keyboard', 2, 'late-night-talk', 'user37', 18, 1349, '@user23 私は環境音を小さく流すと少し気にならなくなります。'),
('social_late_keyboard', 3, 'late-night-talk', 'user23', 18, 1353, '試してみます。雨音くらいがよさそうです。'),
('social_late_keyboard', 4, 'late-night-talk', 'user37', 18, 1357, '音量を上げすぎないよう、タイマーも付けると安心です。'),
('social_late_keyboard', 5, 'late-night-talk', 'user01', 18, 1361, '集中していると区切りを忘れやすいのが少し心配です。眠気が来る前に、保存して休憩も入れてくださいね。'),
('social_late_keyboard', 6, 'late-night-talk', 'user23', 18, 1365, 'ちょうど一区切りなので、ここで終わります。'),

-- remote-lounge: 在宅勤務の環境や連携を整える会話。
('social_remote_mic_test', 1, 'remote-lounge', 'user06', 1, 535, '@user24 朝の通話前に、マイクの音を確認してもらえますか？'),
('social_remote_mic_test', 2, 'remote-lounge', 'user24', 1, 539, '声は聞こえますが、机の振動音が少し入っています。'),
('social_remote_mic_test', 3, 'remote-lounge', 'user06', 1, 543, 'マイクを台から外して、布の上へ置いてみました。'),
('social_remote_mic_test', 4, 'remote-lounge', 'user24', 1, 547, 'かなり静かになりました。声の大きさも十分です。'),
('social_remote_mic_test', 5, 'remote-lounge', 'user39', 1, 551, '念のため、自動音量調整も切っておくと安定します。'),
('social_remote_mic_test', 6, 'remote-lounge', 'user06', 1, 555, '設定できました。一人では机の音に気付けなかったので、二人に聞いてもらえて心強かったです。'),

('social_remote_delivery', 1, 'remote-lounge', 'user18', 6, 825, '午後に荷物が届くため、少しだけ応答が遅れるかもしれません。'),
('social_remote_delivery', 2, 'remote-lounge', 'user03', 6, 829, '@user18 急ぎの確認はこちらで先に見ておきます。'),
('social_remote_delivery', 3, 'remote-lounge', 'user18', 6, 833, '助かります。戻ったら未確認のものから追います。'),
('social_remote_delivery', 4, 'remote-lounge', 'user30', 6, 837, '共有メモに優先順を付けておきました。'),
('social_remote_delivery', 5, 'remote-lounge', 'user18', 6, 841, '確認しました。一番上の項目から対応します。'),
('social_remote_delivery', 6, 'remote-lounge', 'user03', 6, 845, 'こちらは落ち着いているので、戻る時間を気にして慌てなくて大丈夫です。荷物を受け取ってからゆっくり確認してください。'),

('social_remote_sunlight', 1, 'remote-lounge', 'user13', 10, 600, '@user28 朝日で画面が見づらいのですが、机の向きを変えていますか？'),
('social_remote_sunlight', 2, 'remote-lounge', 'user28', 10, 604, '窓に対して横向きにすると、映り込みがかなり減りました。'),
('social_remote_sunlight', 3, 'remote-lounge', 'user13', 10, 608, '通路を塞がない範囲で、少し回してみます。'),
('social_remote_sunlight', 4, 'remote-lounge', 'user40', 10, 612, '薄い布を一枚掛ける方法も手軽ですよ。'),
('social_remote_sunlight', 5, 'remote-lounge', 'user13', 10, 616, '机の向きだけで十分見やすくなりました。'),
('social_remote_sunlight', 6, 'remote-lounge', 'user28', 10, 620, '目を細めずに見られるようになってよかったです。午後に暗く感じたら、無理せず元へ戻せますね。'),

('social_remote_focus_block', 1, 'remote-lounge', 'user32', 16, 845, '一時間だけ集中したいので、返事が少し遅れます。十五時から十六時まで通知を静かにし、途中の質問には戻ってから順番に回答する予定です。今日中に判断が必要な連絡だけは、先頭に「急ぎ」と書いてもらえれば確認します。同じように集中時間を取りたい人がいれば、この時間だけ一緒に試して、終わった後にやりやすさを共有しませんか。参加しない方は、普段どおり連絡してもらって大丈夫です。'),
('social_remote_focus_block', 2, 'remote-lounge', 'user09', 16, 849, '@user32 急ぎの連絡だけ、私が拾っておきます。'),
('social_remote_focus_block', 3, 'remote-lounge', 'user32', 16, 853, 'ありがとうございます。終わったら状況を確認します。'),
('social_remote_focus_block', 4, 'remote-lounge', 'user17', 16, 857, 'こちらも同じ時間を作業枠にします。'),
('social_remote_focus_block', 5, 'remote-lounge', 'user32', 16, 917, '戻りました。急ぎの連絡はありませんでしたか？'),
('social_remote_focus_block', 6, 'remote-lounge', 'user09', 16, 921, 'ありませんでした。集中枠お疲れさまです。'),

-- office-events: 小規模な社内企画を相談し、担当を決める会話。
('social_event_boardgame', 1, 'office-events', 'user07', 2, 950, '@user21 金曜の夕方、短いボードゲーム会を開きませんか？ 十七時から三十分だけ会議机を使い、途中参加や見学も自由な小さな集まりを想定しています。初めて遊ぶ人が多そうなので、説明が五分以内で終わり、勝敗より会話を楽しめるものがよさそうです。持参できるゲーム、参加できそうな時間、避けたいルールがあれば事前に教えてください。片付けまで含めて、予定の時間内に終えるつもりです。'),
('social_event_boardgame', 2, 'office-events', 'user21', 2, 954, 'いいですね。三十分で終わるものなら参加しやすそうです。'),
('social_event_boardgame', 3, 'office-events', 'user34', 2, 958, '四人用と六人用を一つずつ持っていけます。'),
('social_event_boardgame', 4, 'office-events', 'user07', 2, 962, '人数を見て選べるので助かります。十七時開始にしましょう。'),
('social_event_boardgame', 5, 'office-events', 'user21', 2, 966, '説明が短い方を最初に遊びたいです。'),
('social_event_boardgame', 6, 'office-events', 'user34', 2, 970, '了解です。ルールを一枚にまとめて持っていきます。'),

('social_event_photo_walk', 1, 'office-events', 'user11', 5, 735, '昼休みに建物の周りを撮る小さな写真散歩を考えています。高価なカメラを使う会ではなく、スマートフォンで光や形を一つ見つけ、十五分ほどで入口へ戻る気軽な企画です。人の顔や車の番号が写った写真は共有せず、撮影してよい場所だけを歩きます。暑さや雨が気になる場合は室内へ切り替えるので、参加条件について希望があれば教えてください。撮った写真を見せるかどうかも、それぞれの自由にします。'),
('social_event_photo_walk', 2, 'office-events', 'user26', 5, 739, '@user11 スマートフォンだけでも参加できますか？'),
('social_event_photo_walk', 3, 'office-events', 'user11', 5, 743, 'もちろんです。道具より、気になった景色を見つける会です。'),
('social_event_photo_walk', 4, 'office-events', 'user36', 5, 747, '暑さが少し心配なので、日陰の多い短い経路なら参加したいです。'),
('social_event_photo_walk', 5, 'office-events', 'user11', 5, 751, '十五分で戻れる経路を地図にしておきます。'),
('social_event_photo_walk', 6, 'office-events', 'user26', 5, 755, 'それなら気軽ですね。昼食後に入口へ行きます。'),

('social_event_lightning_talk', 1, 'office-events', 'user15', 9, 990, '@user04 来週の短い発表会、まだ一枠空いています。話してみませんか？'),
('social_event_lightning_talk', 2, 'office-events', 'user04', 9, 994, '最近試したメモの整理方法なら、五分で話せそうです。'),
('social_event_lightning_talk', 3, 'office-events', 'user25', 9, 998, '実際の画面を一枚見せてもらえると分かりやすそうです。'),
('social_event_lightning_talk', 4, 'office-events', 'user04', 9, 1002, '個人情報を消した例を作ってみます。'),
('social_event_lightning_talk', 5, 'office-events', 'user15', 9, 1006, '@user25 当日の進行と時間計測をお願いできますか？'),
('social_event_lightning_talk', 6, 'office-events', 'user25', 9, 1010, 'できます。発表中に焦らせないよう、残り一分で見える合図をそっと出しますね。'),

('social_event_cleanup', 1, 'office-events', 'user29', 13, 980, '交流会の片付けを手伝える方を二人ほど探しています。'),
('social_event_cleanup', 2, 'office-events', 'user10', 13, 984, '@user29 机と椅子を戻す作業なら担当できます。'),
('social_event_cleanup', 3, 'office-events', 'user38', 13, 988, '飲み物とごみの確認を引き受けます。'),
('social_event_cleanup', 4, 'office-events', 'user29', 13, 992, '二人とも引き受けてくれて心強いです。終了後に十分だけ、無理のない範囲でお願いします。'),
('social_event_cleanup', 5, 'office-events', 'user10', 13, 996, '@user38 分別用の袋は会場にありますか？'),
('social_event_cleanup', 6, 'office-events', 'user38', 13, 1000, '入口の箱に三種類用意してあります。'),

('social_event_breakfast', 1, 'office-events', 'user19', 18, 510, '@user33 来週の朝、軽い朝食会を試してみたいです。'),
('social_event_breakfast', 2, 'office-events', 'user33', 18, 514, '八時半からなら参加できます。温かい飲み物があるとうれしいです。'),
('social_event_breakfast', 3, 'office-events', 'user06', 18, 518, 'パンと果物なら少量ずつ用意できそうです。'),
('social_event_breakfast', 4, 'office-events', 'user19', 18, 522, '無理に早く来なくてよい、自由参加の形にしましょう。'),
('social_event_breakfast', 5, 'office-events', 'user33', 18, 526, '@user06 食べ物の種類を前日に書いておくと安心ですね。'),
('social_event_breakfast', 6, 'office-events', 'user06', 18, 530, '食べられるか迷わず選べるよう、原材料も一緒に一覧へ書いておきます。ほかに気になる点はありますか？'),

-- onboarding: 新しく参加した人の小さな疑問を周囲が解決する会話。
('social_onboard_channel_map', 1, 'onboarding', 'user39', 1, 585, '@user02 チャンネルが多いのですが、最初はどこを見ればよいですか？ 一覧を上から開いてみたものの、過去ログをどこまで読めばよいのか分からず、通知も全部有効なままです。初日に確認する場所、担当が決まってから参加すればよい場所、雑談として自由に見る場所の三つに分けて教えてもらえると助かります。あとから参加先や通知設定を変えられるなら、その方法も知りたいです。'),
('social_onboard_channel_map', 2, 'onboarding', 'user02', 1, 589, 'まず全体案内と、担当に近いチャンネルの二つで十分です。'),
('social_onboard_channel_map', 3, 'onboarding', 'user14', 1, 593, '雑談は後から参加しても、過去ログを全部読む必要はありません。'),
('social_onboard_channel_map', 4, 'onboarding', 'user39', 1, 597, '安心しました。通知も必要なものから設定します。'),
('social_onboard_channel_map', 5, 'onboarding', 'user02', 1, 601, '@user39 分からない略語があれば、この場所で聞いてください。'),
('social_onboard_channel_map', 6, 'onboarding', 'user39', 1, 605, 'ありがとうございます。まず案内を読んでみます。'),

('social_onboard_profile', 1, 'onboarding', 'user40', 4, 650, 'プロフィールの自己紹介は、どのくらい書くとよいでしょうか？'),
('social_onboard_profile', 2, 'onboarding', 'user12', 4, 654, '@user40 担当と、声をかけてもよい話題が一つあると十分です。'),
('social_onboard_profile', 3, 'onboarding', 'user40', 4, 658, 'では担当分野と、好きな飲み物を書いてみます。'),
('social_onboard_profile', 4, 'onboarding', 'user27', 4, 662, '読み方が難しい名前なら、呼び方もあると助かります。'),
('social_onboard_profile', 5, 'onboarding', 'user40', 4, 666, '@user27 呼んでほしい短い名前も追記しました。'),
('social_onboard_profile', 6, 'onboarding', 'user12', 4, 670, '話しかけるきっかけが見えて、ぐっと親しみやすくなりました。初日の紹介としてこれで十分だと思います。'),

('social_onboard_first_meeting', 1, 'onboarding', 'user31', 8, 555, '@user17 初めての朝会は、何か準備しておくものがありますか？'),
('social_onboard_first_meeting', 2, 'onboarding', 'user17', 8, 559, '昨日したことと、今日したいことを一行ずつで大丈夫です。'),
('social_onboard_first_meeting', 3, 'onboarding', 'user31', 8, 563, '困っていることがなくても、そのまま伝えてよいですか？'),
('social_onboard_first_meeting', 4, 'onboarding', 'user17', 8, 567, 'はい。特になし、と共有すれば次へ進めます。'),
('social_onboard_first_meeting', 5, 'onboarding', 'user05', 8, 571, '@user31 聞いているだけの参加から始めても大丈夫ですよ。'),
('social_onboard_first_meeting', 6, 'onboarding', 'user31', 8, 575, '少し緊張していましたが、聞くだけでもよいと分かって安心しました。短いメモを用意して参加します。'),

('social_onboard_terms', 1, 'onboarding', 'user22', 12, 805, '会話に出てくる略語を、まだいくつか理解できていません。'),
('social_onboard_terms', 2, 'onboarding', 'user09', 12, 809, '@user22 よく使う言葉の一覧が固定投稿にあります。'),
('social_onboard_terms', 3, 'onboarding', 'user22', 12, 813, '見つけました。短い説明が付いていて助かります。'),
('social_onboard_terms', 4, 'onboarding', 'user35', 12, 817, '一覧にない言葉は、遠慮なくその場で聞いてください。'),
('social_onboard_terms', 5, 'onboarding', 'user22', 12, 821, '@user35 一つだけ一覧にない言葉があるので、後で質問します。'),
('social_onboard_terms', 6, 'onboarding', 'user09', 12, 825, '質問してもらえると一覧の不足にも気付けます。回答後に一緒に追加して、次の人にも役立てましょう。'),

('social_onboard_lunch_invite', 1, 'onboarding', 'user37', 17, 675, '@user16 今日が初日なのですが、昼食は皆さん別々ですか？'),
('social_onboard_lunch_invite', 2, 'onboarding', 'user16', 17, 679, '自由ですが、今日は数人で近くへ行く予定です。'),
('social_onboard_lunch_invite', 3, 'onboarding', 'user37', 17, 683, 'よければ一緒に行きたいです。食べられないものはありません。'),
('social_onboard_lunch_invite', 4, 'onboarding', 'user24', 17, 687, '十二時十五分に入口へ集まります。ゆっくり歩いて行ける店です。'),
('social_onboard_lunch_invite', 5, 'onboarding', 'user37', 17, 691, '@user24 時間と場所、分かりました。ありがとうございます。'),
('social_onboard_lunch_invite', 6, 'onboarding', 'user16', 17, 695, '初日は予定が読みづらいと思うので、途中で変わっても気にしないでください。ここへ一言あれば待たずに出発できます。'),

-- weekend-club: 休日の任意参加活動を穏やかに相談する会話。
('social_weekend_walk', 1, 'weekend-club', 'user08', 3, 620, '@user30 土曜の朝、川沿いを短く歩きませんか？ 九時に広場へ集まり、往復三十分ほどの平らな道を、会話できるくらいのゆっくりした速さで歩く予定です。途中の橋から合流したり、疲れたところで先に戻ったりしても構いません。雨や強い暑さの場合は延期し、当日の朝八時までにここで知らせるので、無理のない範囲で参加してください。歩く速さに希望があれば、出発前に遠慮なく伝えてください。'),
('social_weekend_walk', 2, 'weekend-club', 'user30', 3, 624, '九時開始なら参加できます。速すぎないペースが希望です。'),
('social_weekend_walk', 3, 'weekend-club', 'user13', 3, 628, '途中参加でも大丈夫なら、橋の近くから合流したいです。'),
('social_weekend_walk', 4, 'weekend-club', 'user08', 3, 632, '大丈夫です。三十分ほど歩いて、同じ場所へ戻ります。'),
('social_weekend_walk', 5, 'weekend-club', 'user30', 3, 636, '@user13 合流する五分前にここへ書きますね。'),
('social_weekend_walk', 6, 'weekend-club', 'user13', 3, 640, '助かります。水だけ持って向かいます。'),

('social_weekend_cooking', 1, 'weekend-club', 'user21', 7, 690, '休日に作れる簡単なスープのレシピを試しています。'),
('social_weekend_cooking', 2, 'weekend-club', 'user33', 7, 694, '@user21 切るものが少ないレシピだとうれしいです。'),
('social_weekend_cooking', 3, 'weekend-club', 'user21', 7, 698, '豆と冷凍野菜を煮るだけなので、包丁はほぼ使いません。'),
('social_weekend_cooking', 4, 'weekend-club', 'user04', 7, 702, '味付けは塩だけでもまとまりますか？'),
('social_weekend_cooking', 5, 'weekend-club', 'user21', 7, 706, '@user04 最後に少しだけ香辛料を足すと香りが出ます。'),
('social_weekend_cooking', 6, 'weekend-club', 'user33', 7, 710, '材料がほとんど家にありました。包丁をあまり使わずに済むなら、料理が得意でなくても試せそうで楽しみです。'),

('social_weekend_puzzle', 1, 'weekend-club', 'user28', 11, 840, '@user36 日曜に持ち寄るパズル、難しさはどのくらいにしますか？'),
('social_weekend_puzzle', 2, 'weekend-club', 'user36', 11, 844, '初めての人もいるので、十分ほどで解けるものがよさそうです。'),
('social_weekend_puzzle', 3, 'weekend-club', 'user18', 11, 848, '言葉遊びなら一問用意できます。'),
('social_weekend_puzzle', 4, 'weekend-club', 'user28', 11, 852, '私は図形の問題を、ヒント付きで持っていきます。'),
('social_weekend_puzzle', 5, 'weekend-club', 'user36', 11, 856, '@user18 答えは別の紙にしておいてもらえますか？'),
('social_weekend_puzzle', 6, 'weekend-club', 'user18', 11, 860, 'うっかり答えが見えると惜しいので、封筒に入れて持っていきます。ヒントの順番も迷わないよう番号を付けますね。'),

('social_weekend_plants', 1, 'weekend-club', 'user05', 16, 610, '小さな鉢植えの植え替えをしようと思っています。'),
('social_weekend_plants', 2, 'weekend-club', 'user25', 16, 614, '@user05 余っている土があるので、少し持っていけます。'),
('social_weekend_plants', 3, 'weekend-club', 'user05', 16, 618, '助かります。直径十センチの鉢一つ分で十分です。'),
('social_weekend_plants', 4, 'weekend-club', 'user14', 16, 622, '底に敷く小石も少し余っています。よければ一緒に持っていきましょうか？'),
('social_weekend_plants', 5, 'weekend-club', 'user05', 16, 626, '@user14 ぜひお願いします。受け皿はこちらで用意します。'),
('social_weekend_plants', 6, 'weekend-club', 'user25', 16, 630, '必要な量が分かって安心しました。重くならないよう、土と小石は小さな袋へ分けておきます。'),

-- one-liner: 一言から始まり、短く気持ちよく終わる雑談。
('social_one_pen', 1, 'one-liner', 'user10', 2, 630, '書きやすいペンを一本見つけるだけで、メモが少し楽しくなります。'),
('social_one_pen', 2, 'one-liner', 'user32', 2, 634, '@user10 太さはどのくらいですか？'),
('social_one_pen', 3, 'one-liner', 'user10', 2, 638, '細めですが、紙に引っかからないものです。'),
('social_one_pen', 4, 'one-liner', 'user22', 2, 642, '色違いがあるなら試してみたいです。'),
('social_one_pen', 5, 'one-liner', 'user10', 2, 646, '@user22 予備を机に置いたので、一本使ってみてください。'),
('social_one_pen', 6, 'one-liner', 'user22', 2, 650, '思った以上に滑らかで、急いで書いても字が乱れにくいですね。次に買う一本で迷ったら、これを選びます。'),

('social_one_cloud', 1, 'one-liner', 'user27', 6, 930, '窓の外に、魚みたいな形の雲が浮かんでいます。'),
('social_one_cloud', 2, 'one-liner', 'user01', 6, 934, '@user27 見ました。私は大きな葉っぱにも見えます。'),
('social_one_cloud', 3, 'one-liner', 'user27', 6, 938, '言われてみると、葉の先のようにも見えますね。'),
('social_one_cloud', 4, 'one-liner', 'user39', 6, 942, '少し形が崩れて、今度は鳥っぽくなりました。'),
('social_one_cloud', 5, 'one-liner', 'user01', 6, 946, '@user39 羽のところだけまだ残っています。'),
('social_one_cloud', 6, 'one-liner', 'user27', 6, 950, '同じ雲なのに、見る人と時間で別のものになるのが面白いですね。少し窓を見るだけでよい気分転換になりました。'),

('social_one_timer', 1, 'one-liner', 'user17', 10, 905, '二十五分のタイマーを使うと、着手だけはしやすくなりました。以前は作業時間を長く確保してから始めようとして、準備だけで午前が終わることもありました。最近は一つの作業を小さく決め、終了音が鳴ったら保存して五分だけ席を立つようにしています。集中できない日に試した人がいれば、時間の長さや休憩の取り方も聞いてみたいです。合わない日は途中で止めるくらいの気軽さで続けています。'),
('social_one_timer', 2, 'one-liner', 'user35', 10, 909, '@user17 休憩時間もタイマーで区切っていますか？'),
('social_one_timer', 3, 'one-liner', 'user17', 10, 913, '五分だけ測って、必ず席を立つようにしています。'),
('social_one_timer', 4, 'one-liner', 'user09', 10, 917, '私も午後の作業で試してみます。'),
('social_one_timer', 5, 'one-liner', 'user17', 10, 921, '@user09 最初は一回だけでも、区切りが分かりやすいですよ。'),
('social_one_timer', 6, 'one-liner', 'user09', 10, 925, 'ちょうど一つ終わりました。短い休憩に入ります。'),

('social_one_socks', 1, 'one-liner', 'user24', 15, 590, '左右で少し違う靴下を履いてきたことに、今気付きました。'),
('social_one_socks', 2, 'one-liner', 'user06', 15, 594, '@user24 色が近ければ、新しい組み合わせということにしましょう。'),
('social_one_socks', 3, 'one-liner', 'user24', 15, 598, '片方が細いしま模様で、片方が無地です。'),
('social_one_socks', 4, 'one-liner', 'user31', 15, 602, '同じ色なら、よく見ないと分からなさそうです。'),
('social_one_socks', 5, 'one-liner', 'user24', 15, 606, '@user31 今日はこのまま堂々と過ごすことにします。'),
('social_one_socks', 6, 'one-liner', 'user06', 15, 610, '失敗ではなく新しい組み合わせと思う、その判断がよいですね。朝からこちらまで少し元気が出ました。'),

-- mystery-lab: 身近な違和感を安全に観察して解く軽い謎。
('social_mystery_clock', 1, 'mystery-lab', 'user03', 4, 745, '休憩室の時計だけ、ほかより三分進んで見えます。端末の時刻と壁の別の時計は一致しているので、表示の見間違いではなさそうです。電池が弱いなら遅れる印象がありますが、毎日ほぼ同じ差のため、誰かが意図的に早めた可能性も考えています。設定を直す前に、理由を知っている人や、裏側の表示を確認できる人はいませんか？ 勝手に合わせると困る人がいるかもしれないので、まず経緯を確かめたいです。'),
('social_mystery_clock', 2, 'mystery-lab', 'user20', 4, 749, '@user03 私の端末と比べても、ちょうど三分進んでいます。'),
('social_mystery_clock', 3, 'mystery-lab', 'user03', 4, 753, '誰かが意図的に早めたのでしょうか。'),
('social_mystery_clock', 4, 'mystery-lab', 'user12', 4, 757, '遅刻防止で以前から少し進めている、と聞いたことがあります。'),
('social_mystery_clock', 5, 'mystery-lab', 'user20', 4, 761, '@user12 時計の裏に小さく三分進みと書いてありました。'),
('social_mystery_clock', 6, 'mystery-lab', 'user03', 4, 765, '謎は解けました。知らない人向けに表示を見やすくしましょう。'),

('social_mystery_footprints', 1, 'mystery-lab', 'user26', 8, 680, '窓際に小さな足跡のような跡があります。'),
('social_mystery_footprints', 2, 'mystery-lab', 'user38', 8, 684, '@user26 丸が二つ並んでいて、確かに足跡っぽいですね。'),
('social_mystery_footprints', 3, 'mystery-lab', 'user26', 8, 688, '窓は閉まっていたので、外からではなさそうです。'),
('social_mystery_footprints', 4, 'mystery-lab', 'user07', 8, 692, '植木鉢の底に同じ形の突起があります。'),
('social_mystery_footprints', 5, 'mystery-lab', 'user38', 8, 696, '@user07 水やりで鉢を動かした跡のようですね。'),
('social_mystery_footprints', 6, 'mystery-lab', 'user26', 8, 700, '小さな動物ではなかったのは少し残念ですが、原因が分かってすっきりしました。跡を拭いて受け皿も置きました。'),

('social_mystery_note', 1, 'mystery-lab', 'user14', 13, 710, '机に数字が三つだけ書かれた紙が置かれています。'),
('social_mystery_note', 2, 'mystery-lab', 'user23', 13, 714, '@user14 数字は今日の日付と一致していませんか？'),
('social_mystery_note', 3, 'mystery-lab', 'user14', 13, 718, '順番を入れ替えると今日の日付になります。'),
('social_mystery_note', 4, 'mystery-lab', 'user34', 13, 722, '裏面に昼の予定、と薄く書いてあります。'),
('social_mystery_note', 5, 'mystery-lab', 'user23', 13, 726, '@user34 昼食の受け取り番号かもしれません。'),
('social_mystery_note', 6, 'mystery-lab', 'user14', 13, 730, '持ち主が見つかって安心しました。やはり昼食の注文番号で、探していた本人もほっとした様子でした。'),

('social_mystery_hum', 1, 'mystery-lab', 'user30', 19, 830, '廊下の端で、低い音が一定間隔で聞こえます。'),
('social_mystery_hum', 2, 'mystery-lab', 'user11', 19, 834, '@user30 危険な感じではなく、機械の待機音に近いですね。'),
('social_mystery_hum', 3, 'mystery-lab', 'user30', 19, 838, '音が鳴ると、壁際の小さなランプも光ります。'),
('social_mystery_hum', 4, 'mystery-lab', 'user19', 19, 842, '空気清浄機のフィルター確認ランプではないでしょうか。'),
('social_mystery_hum', 5, 'mystery-lab', 'user11', 19, 846, '@user19 説明表示を見たら、交換時期のお知らせでした。'),
('social_mystery_hum', 6, 'mystery-lab', 'user30', 19, 850, '故障の音ではないと分かって安心しました。急ぎではなさそうですが、忘れないうちに担当へ交換をお願いしておきます。');

COMMIT;
