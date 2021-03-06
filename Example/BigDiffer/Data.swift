import Foundation

enum Data {
    // https://github.com/github/gemoji/blob/master/db/emoji.json
    static let gemojiPeople: [String] = """
😀 grinning
😃 smiley
😄 smile
😁 grin
😆 laughing
😅 sweat_smile
😂 joy
🤣 rofl
☺️ relaxed
😊 blush
😇 innocent
🙂 slightly_smiling_face
🙃 upside_down_face
😉 wink
😌 relieved
😍 heart_eyes
😘 kissing_heart
😗 kissing
😙 kissing_smiling_eyes
😚 kissing_closed_eyes
😋 yum
😜 stuck_out_tongue_winking_eye
😝 stuck_out_tongue_closed_eyes
😛 stuck_out_tongue
🤑 money_mouth_face
🤗 hugs
🤓 nerd_face
😎 sunglasses
🤡 clown_face
🤠 cowboy_hat_face
😏 smirk
😒 unamused
😞 disappointed
😔 pensive
😟 worried
😕 confused
🙁 slightly_frowning_face
☹️ frowning_face
😣 persevere
😖 confounded
😫 tired_face
😩 weary
😤 triumph
😠 angry
😡 rage
😶 no_mouth
😐 neutral_face
😑 expressionless
😯 hushed
😦 frowning
😧 anguished
😮 open_mouth
😲 astonished
😵 dizzy_face
😳 flushed
😱 scream
😨 fearful
😰 cold_sweat
😢 cry
😥 disappointed_relieved
🤤 drooling_face
😭 sob
😓 sweat
😪 sleepy
😴 sleeping
🙄 roll_eyes
🤔 thinking
🤥 lying_face
😬 grimacing
🤐 zipper_mouth_face
🤢 nauseated_face
🤧 sneezing_face
😷 mask
🤒 face_with_thermometer
🤕 face_with_head_bandage
😈 smiling_imp
👿 imp
👹 japanese_ogre
👺 japanese_goblin
💩 hankey
👻 ghost
💀 skull
☠️ skull_and_crossbones
👽 alien
👾 space_invader
🤖 robot
🎃 jack_o_lantern
😺 smiley_cat
😸 smile_cat
😹 joy_cat
😻 heart_eyes_cat
😼 smirk_cat
😽 kissing_cat
🙀 scream_cat
😿 crying_cat_face
😾 pouting_cat
👐 open_hands
🙌 raised_hands
👏 clap
🙏 pray
🤝 handshake
👍 +1
👎 -1
👊 fist_oncoming
✊ fist_raised
🤛 fist_left
🤜 fist_right
🤞 crossed_fingers
✌️ v
🤘 metal
👌 ok_hand
👈 point_left
👉 point_right
👆 point_up_2
👇 point_down
☝️ point_up
✋ hand
🤚 raised_back_of_hand
🖐 raised_hand_with_fingers_splayed
🖖 vulcan_salute
👋 wave
🤙 call_me_hand
💪 muscle
🖕 middle_finger
✍️ writing_hand
🤳 selfie
💅 nail_care
💍 ring
💄 lipstick
💋 kiss
👄 lips
👅 tongue
👂 ear
👃 nose
👣 footprints
👁 eye
👀 eyes
🗣 speaking_head
👤 bust_in_silhouette
👥 busts_in_silhouette
👶 baby
👦 boy
👧 girl
👨 man
👩 woman
👱‍♀ blonde_woman
👱 blonde_man
👴 older_man
👵 older_woman
👲 man_with_gua_pi_mao
👳‍♀ woman_with_turban
👳 man_with_turban
👮‍♀ policewoman
👮 policeman
👷‍♀ construction_worker_woman
👷 construction_worker_man
💂‍♀ guardswoman
💂 guardsman
🕵️‍♀️ female_detective
🕵 male_detective
👩‍⚕ woman_health_worker
👨‍⚕ man_health_worker
👩‍🌾 woman_farmer
👨‍🌾 man_farmer
👩‍🍳 woman_cook
👨‍🍳 man_cook
👩‍🎓 woman_student
👨‍🎓 man_student
👩‍🎤 woman_singer
👨‍🎤 man_singer
👩‍🏫 woman_teacher
👨‍🏫 man_teacher
👩‍🏭 woman_factory_worker
👨‍🏭 man_factory_worker
👩‍💻 woman_technologist
👨‍💻 man_technologist
👩‍💼 woman_office_worker
👨‍💼 man_office_worker
👩‍🔧 woman_mechanic
👨‍🔧 man_mechanic
👩‍🔬 woman_scientist
👨‍🔬 man_scientist
👩‍🎨 woman_artist
👨‍🎨 man_artist
👩‍🚒 woman_firefighter
👨‍🚒 man_firefighter
👩‍✈ woman_pilot
👨‍✈ man_pilot
👩‍🚀 woman_astronaut
👨‍🚀 man_astronaut
👩‍⚖ woman_judge
👨‍⚖ man_judge
🤶 mrs_claus
🎅 santa
👸 princess
🤴 prince
👰 bride_with_veil
🤵 man_in_tuxedo
👼 angel
🤰 pregnant_woman
🙇‍♀ bowing_woman
🙇 bowing_man
💁 tipping_hand_woman
💁‍♂ tipping_hand_man
🙅 no_good_woman
🙅‍♂ no_good_man
🙆 ok_woman
🙆‍♂ ok_man
🙋 raising_hand_woman
🙋‍♂ raising_hand_man
🤦‍♀ woman_facepalming
🤦‍♂ man_facepalming
🤷‍♀ woman_shrugging
🤷‍♂ man_shrugging
🙎 pouting_woman
🙎‍♂ pouting_man
🙍 frowning_woman
🙍‍♂ frowning_man
💇 haircut_woman
💇‍♂ haircut_man
💆 massage_woman
💆‍♂ massage_man
🕴 business_suit_levitating
💃 dancer
🕺 man_dancing
👯 dancing_women
👯‍♂ dancing_men
🚶‍♀ walking_woman
🚶 walking_man
🏃‍♀ running_woman
🏃 running_man
👫 couple
👭 two_women_holding_hands
👬 two_men_holding_hands
💑 couple_with_heart_woman_man
👩‍❤️‍👩 couple_with_heart_woman_woman
👨‍❤️‍👨 couple_with_heart_man_man
💏 couplekiss_man_woman
👩‍❤️‍💋‍👩 couplekiss_woman_woman
👨‍❤️‍💋‍👨 couplekiss_man_man
👪 family_man_woman_boy
👨‍👩‍👧 family_man_woman_girl
👨‍👩‍👧‍👦 family_man_woman_girl_boy
👨‍👩‍👦‍👦 family_man_woman_boy_boy
👨‍👩‍👧‍👧 family_man_woman_girl_girl
👩‍👩‍👦 family_woman_woman_boy
👩‍👩‍👧 family_woman_woman_girl
👩‍👩‍👧‍👦 family_woman_woman_girl_boy
👩‍👩‍👦‍👦 family_woman_woman_boy_boy
👩‍👩‍👧‍👧 family_woman_woman_girl_girl
👨‍👨‍👦 family_man_man_boy
👨‍👨‍👧 family_man_man_girl
👨‍👨‍👧‍👦 family_man_man_girl_boy
👨‍👨‍👦‍👦 family_man_man_boy_boy
👨‍👨‍👧‍👧 family_man_man_girl_girl
👩‍👦 family_woman_boy
👩‍👧 family_woman_girl
👩‍👧‍👦 family_woman_girl_boy
👩‍👦‍👦 family_woman_boy_boy
👩‍👧‍👧 family_woman_girl_girl
👨‍👦 family_man_boy
👨‍👧 family_man_girl
👨‍👧‍👦 family_man_girl_boy
👨‍👦‍👦 family_man_boy_boy
👨‍👧‍👧 family_man_girl_girl
👚 womans_clothes
👕 shirt
👖 jeans
👔 necktie
👗 dress
👙 bikini
👘 kimono
👠 high_heel
👡 sandal
👢 boot
👞 mans_shoe
👟 athletic_shoe
👒 womans_hat
🎩 tophat
🎓 mortar_board
👑 crown
⛑ rescue_worker_helmet
🎒 school_satchel
👝 pouch
👛 purse
👜 handbag
💼 briefcase
👓 eyeglasses
🕶 dark_sunglasses
""".components(separatedBy: .newlines)

    static let gemojiFoods: [String] = """
🍏 green_apple
🍎 apple
🍐 pear
🍊 tangerine
🍋 lemon
🍌 banana
🍉 watermelon
🍇 grapes
🍓 strawberry
🍈 melon
🍒 cherries
🍑 peach
🍍 pineapple
🥝 kiwi_fruit
🥑 avocado
🍅 tomato
🍆 eggplant
🥒 cucumber
🥕 carrot
🌽 corn
🌶 hot_pepper
🥔 potato
🍠 sweet_potato
🌰 chestnut
🥜 peanuts
🍯 honey_pot
🥐 croissant
🍞 bread
🥖 baguette_bread
🧀 cheese
🥚 egg
🍳 fried_egg
🥓 bacon
🥞 pancakes
🍤 fried_shrimp
🍗 poultry_leg
🍖 meat_on_bone
🍕 pizza
🌭 hotdog
🍔 hamburger
🍟 fries
🥙 stuffed_flatbread
🌮 taco
🌯 burrito
🥗 green_salad
🥘 shallow_pan_of_food
🍝 spaghetti
🍜 ramen
🍲 stew
🍥 fish_cake
🍣 sushi
🍱 bento
🍛 curry
🍚 rice
🍙 rice_ball
🍘 rice_cracker
🍢 oden
🍡 dango
🍧 shaved_ice
🍨 ice_cream
🍦 icecream
🍰 cake
🎂 birthday
🍮 custard
🍭 lollipop
🍬 candy
🍫 chocolate_bar
🍿 popcorn
🍩 doughnut
🍪 cookie
🥛 milk_glass
🍼 baby_bottle
☕️ coffee
🍵 tea
🍶 sake
🍺 beer
🍻 beers
🥂 clinking_glasses
🍷 wine_glass
🥃 tumbler_glass
🍸 cocktail
🍹 tropical_drink
🍾 champagne
🥄 spoon
🍴 fork_and_knife
🍽 plate_with_cutlery
""".components(separatedBy: .newlines)

    static let gemojiFoodsByPeople: [String] = gemojiFoods.flatMap { f in
        gemojiPeople.map {[f, $0].joined(separator: " ")}
    }
}
