import Foundation

// MARK: - KJV Bible Data
// Complete KJV text for key chapters. Format: [book: [chapter: [verse: text]]]
// The KJV Bible is in the public domain (pre-1928).

struct KJVData {

    // MARK: Look-up
    static func verses(book: String, chapter: Int) -> [BibleVerse] {
        guard let bookData = data[book],
              let chapterData = bookData[chapter] else {
            return []
        }
        return chapterData
            .sorted { $0.key < $1.key }
            .map { BibleVerse(book: book, chapter: chapter, verse: $0.key, text: $0.value) }
    }

    static func verse(book: String, chapter: Int, verse: Int) -> BibleVerse? {
        guard let v = data[book]?[chapter]?[verse] else { return nil }
        return BibleVerse(book: book, chapter: chapter, verse: verse, text: v)
    }

    static func hasContent(book: String, chapter: Int) -> Bool {
        guard let bookData = data[book] else { return false }
        return bookData[chapter] != nil
    }

    // MARK: Verse Counts (for navigation)
    static func verseCount(book: String, chapter: Int) -> Int {
        if let count = verseCounts[book]?[chapter] { return count }
        return data[book]?[chapter]?.count ?? 0
    }

    // MARK: Known verse counts (all 66 books)
    static let verseCounts: [String: [Int: Int]] = [
        "Genesis": [
            1:31,2:25,3:24,4:26,5:32,6:22,7:24,8:22,9:29,10:32,
            11:32,12:20,13:18,14:24,15:21,16:16,17:27,18:33,19:38,20:18,
            21:34,22:24,23:20,24:67,25:34,26:35,27:46,28:22,29:35,30:43,
            31:55,32:32,33:20,34:31,35:29,36:43,37:36,38:30,39:23,40:23,
            41:57,42:38,43:34,44:34,45:28,46:34,47:31,48:22,49:33,50:26
        ],
        "Psalms": [
            1:6,2:12,3:8,4:8,5:12,6:10,7:17,8:9,9:20,10:18,
            11:7,12:8,13:6,14:7,15:5,16:11,17:15,18:50,19:14,20:9,
            21:13,22:31,23:6,24:10,25:22,26:12,27:14,28:9,29:11,30:12,
            31:24,32:11,33:22,34:22,35:28,36:12,37:40,38:22,39:13,40:17,
            41:13,42:11,43:5,44:26,45:17,46:11,47:9,48:14,49:20,50:23,
            51:19,52:9,53:6,54:7,55:23,56:13,57:11,58:11,59:17,60:12,
            61:8,62:12,63:11,64:10,65:13,66:20,67:7,68:35,69:36,70:5,
            71:24,72:20,73:28,74:23,75:10,76:12,77:20,78:72,79:13,80:19,
            81:16,82:8,83:18,84:12,85:13,86:17,87:7,88:18,89:52,90:17,
            91:16,92:15,93:5,94:23,95:11,96:13,97:12,98:9,99:9,100:5,
            101:8,102:28,103:22,104:35,105:45,106:48,107:43,108:13,109:31,110:7,
            111:10,112:10,113:9,114:8,115:18,116:19,117:2,118:29,119:176,120:7,
            121:8,122:9,123:4,124:8,125:5,126:6,127:5,128:6,129:8,130:8,
            131:3,132:18,133:3,134:3,135:21,136:26,137:9,138:8,139:24,140:13,
            141:10,142:7,143:12,144:15,145:21,146:10,147:20,148:14,149:9,150:6
        ],
        "Matthew": [
            1:25,2:23,3:17,4:25,5:48,6:34,7:29,8:34,9:38,10:42,
            11:30,12:50,13:58,14:36,15:39,16:28,17:27,18:35,19:30,20:34,
            21:46,22:46,23:39,24:51,25:46,26:75,27:66,28:20
        ],
        "John": [
            1:51,2:25,3:36,4:54,5:47,6:71,7:53,8:59,9:41,10:42,
            11:57,12:50,13:38,14:31,15:27,16:33,17:26,18:40,19:42,20:31,21:25
        ],
        "Romans": [
            1:32,2:29,3:31,4:25,5:21,6:23,7:25,8:39,9:33,10:21,
            11:36,12:21,13:14,14:23,15:33,16:27
        ],
        "1 Corinthians": [
            1:31,2:16,3:23,4:21,5:13,6:20,7:40,8:13,9:27,10:33,
            11:34,12:31,13:13,14:40,15:58,16:24
        ],
        "Revelation": [
            1:20,2:29,3:22,4:11,5:14,6:17,7:17,8:13,9:21,10:11,
            11:19,12:17,13:18,14:20,15:8,16:21,17:18,18:24,19:21,20:15,
            21:27,22:21
        ]
    ]

    // MARK: Full KJV Text
    static let data: [String: [Int: [Int: String]]] = [

        // ─────────────────────────────────────────────────────────────────────
        "Genesis": [
        // ── Chapter 1 ────────────────────────────────────────────────────────
        1: [
             1: "In the beginning God created the heaven and the earth.",
             2: "And the earth was without form, and void; and darkness was upon the face of the deep. And the Spirit of God moved upon the face of the waters.",
             3: "And God said, Let there be light: and there was light.",
             4: "And God saw the light, that it was good: and God divided the light from the darkness.",
             5: "And God called the light Day, and the darkness he called Night. And the evening and the morning were the first day.",
             6: "And God said, Let there be a firmament in the midst of the waters, and let it divide the waters from the waters.",
             7: "And God made the firmament, and divided the waters which were under the firmament from the waters which were above the firmament: and it was so.",
             8: "And God called the firmament Heaven. And the evening and the morning were the second day.",
             9: "And God said, Let the waters under the heaven be gathered together unto one place, and let the dry land appear: and it was so.",
            10: "And God called the dry land Earth; and the gathering together of the waters called he Seas: and God saw that it was good.",
            11: "And God said, Let the earth bring forth grass, the herb yielding seed, and the fruit tree yielding fruit after his kind, whose seed is in itself, upon the earth: and it was so.",
            12: "And the earth brought forth grass, and herb yielding seed after his kind, and the tree yielding fruit, whose seed was in itself, after his kind: and God saw that it was good.",
            13: "And the evening and the morning were the third day.",
            14: "And God said, Let there be lights in the firmament of the heaven to divide the day from the night; and let them be for signs, and for seasons, and for days, and years:",
            15: "And let them be for lights in the firmament of the heaven to give light upon the earth: and it was so.",
            16: "And God made two great lights; the greater light to rule the day, and the lesser light to rule the night: he made the stars also.",
            17: "And God set them in the firmament of the heaven to give light upon the earth,",
            18: "And to rule over the day and over the night, and to divide the light from the darkness: and God saw that it was good.",
            19: "And the evening and the morning were the fourth day.",
            20: "And God said, Let the waters bring forth abundantly the moving creature that hath life, and fowl that may fly above the earth in the open firmament of heaven.",
            21: "And God created great whales, and every living creature that moveth, which the waters brought forth abundantly, after their kind, and every winged fowl after his kind: and God saw that it was good.",
            22: "And God blessed them, saying, Be fruitful, and multiply, and fill the waters in the seas, and let fowl multiply in the earth.",
            23: "And the evening and the morning were the fifth day.",
            24: "And God said, Let the earth bring forth the living creature after his kind, cattle, and creeping thing, and beast of the earth after his kind: and it was so.",
            25: "And God made the beast of the earth after his kind, and cattle after their kind, and every thing that creepeth upon the earth after his kind: and God saw that it was good.",
            26: "And God said, Let us make man in our image, after our likeness: and let them have dominion over the fish of the sea, and over the fowl of the air, and over the cattle, and over all the earth, and over every creeping thing that creepeth upon the earth.",
            27: "So God created man in his own image, in the image of God created he him; male and female created he them.",
            28: "And God blessed them, and God said unto them, Be fruitful, and multiply, and replenish the earth, and subdue it: and have dominion over the fish of the sea, and over the fowl of the air, and over every living thing that moveth upon the earth.",
            29: "And God said, Behold, I have given you every herb bearing seed, which is upon the face of all the earth, and every tree, in the which is the fruit of a tree yielding seed; to you it shall be for meat.",
            30: "And to every beast of the earth, and to every fowl of the air, and to every thing that creepeth upon the earth, wherein there is life, I have given every green herb for meat: and it was so.",
            31: "And God saw every thing that he had made, and, behold, it was very good. And the evening and the morning were the sixth day.",
        ],
        // ── Chapter 2 ────────────────────────────────────────────────────────
        2: [
             1: "Thus the heavens and the earth were finished, and all the host of them.",
             2: "And on the seventh day God ended his work which he had made; and he rested on the seventh day from all his work which he had made.",
             3: "And God blessed the seventh day, and sanctified it: because that in it he had rested from all his work which God created and made.",
             4: "These are the generations of the heavens and of the earth when they were created, in the day that the LORD God made the earth and the heavens,",
             5: "And every plant of the field before it was in the earth, and every herb of the field before it grew: for the LORD God had not caused it to rain upon the earth, and there was not a man to till the ground.",
             6: "But there went up a mist from the earth, and watered the whole face of the ground.",
             7: "And the LORD God formed man of the dust of the ground, and breathed into his nostrils the breath of life; and man became a living soul.",
             8: "And the LORD God planted a garden eastward in Eden; and there he put the man whom he had formed.",
             9: "And out of the ground made the LORD God to grow every tree that is pleasant to the sight, and good for food; the tree of life also in the midst of the garden, and the tree of knowledge of good and evil.",
            10: "And a river went out of Eden to water the garden; and from thence it was parted, and became into four heads.",
            11: "The name of the first is Pison: that is it which compasseth the whole land of Havilah, where there is gold;",
            12: "And the gold of that land is good: there is bdellium and the onyx stone.",
            13: "And the name of the second river is Gihon: the same is it that compasseth the whole land of Ethiopia.",
            14: "And the name of the third river is Hiddekel: that is it which goeth toward the east of Assyria. And the fourth river is Euphrates.",
            15: "And the LORD God took the man, and put him into the garden of Eden to dress it and to keep it.",
            16: "And the LORD God commanded the man, saying, Of every tree of the garden thou mayest freely eat:",
            17: "But of the tree of the knowledge of good and evil, thou shalt not eat of it: for in the day that thou eatest thereof thou shalt surely die.",
            18: "And the LORD God said, It is not good that the man should be alone; I will make him an help meet for him.",
            19: "And out of the ground the LORD God formed every beast of the field, and every fowl of the air; and brought them unto Adam to see what he would call them: and whatsoever Adam called every living creature, that was the name thereof.",
            20: "And Adam gave names to all cattle, and to the fowl of the air, and to every beast of the field; but for Adam there was not found an help meet for him.",
            21: "And the LORD God caused a deep sleep to fall upon Adam, and he slept: and he took one of his ribs, and closed up the flesh instead thereof;",
            22: "And the rib, which the LORD God had taken from man, made he a woman, and brought her unto the man.",
            23: "And Adam said, This is now bone of my bones, and flesh of my flesh: she shall be called Woman, because she was taken out of Man.",
            24: "Therefore shall a man leave his father and his mother, and shall cleave unto his wife: and they shall be one flesh.",
            25: "And they were both naked, the man and his wife, and were not ashamed.",
        ],
        // ── Chapter 3 ────────────────────────────────────────────────────────
        3: [
             1: "Now the serpent was more subtil than any beast of the field which the LORD God had made. And he said unto the woman, Yea, hath God said, Ye shall not eat of every tree of the garden?",
             2: "And the woman said unto the serpent, We may eat of the fruit of the trees of the garden:",
             3: "But of the fruit of the tree which is in the midst of the garden, God hath said, Ye shall not eat of it, neither shall ye touch it, lest ye die.",
             4: "And the serpent said unto the woman, Ye shall not surely die:",
             5: "For God doth know that in the day ye eat thereof, then your eyes shall be opened, and ye shall be as gods, knowing good and evil.",
             6: "And when the woman saw that the tree was good for food, and that it was pleasant to the eyes, and a tree to be desired to make one wise, she took of the fruit thereof, and did eat, and gave also unto her husband with her; and he did eat.",
             7: "And the eyes of them both were opened, and they knew that they were naked; and they sewed fig leaves together, and made themselves aprons.",
             8: "And they heard the voice of the LORD God walking in the garden in the cool of the day: and Adam and his wife hid themselves from the presence of the LORD God amongst the trees of the garden.",
             9: "And the LORD God called unto Adam, and said unto him, Where art thou?",
            10: "And he said, I heard thy voice in the garden, and I was afraid, because I was naked; and I hid myself.",
            11: "And he said, Who told thee that thou wast naked? Hast thou eaten of the tree, whereof I commanded thee that thou shouldest not eat?",
            12: "And the man said, The woman whom thou gavest to be with me, she gave me of the tree, and I did eat.",
            13: "And the LORD God said unto the woman, What is this that thou hast done? And the woman said, The serpent beguiled me, and I did eat.",
            14: "And the LORD God said unto the serpent, Because thou hast done this, thou art cursed above all cattle, and above every beast of the field; upon thy belly shalt thou go, and dust shalt thou eat all the days of thy life:",
            15: "And I will put enmity between thee and the woman, and between thy seed and her seed; it shall bruise thy head, and thou shalt bruise his heel.",
            16: "Unto the woman he said, I will greatly multiply thy sorrow and thy conception; in sorrow thou shalt bring forth children; and thy desire shall be to thy husband, and he shall rule over thee.",
            17: "And unto Adam he said, Because thou hast hearkened unto the voice of thy wife, and hast eaten of the tree, of which I commanded thee, saying, Thou shalt not eat of it: cursed is the ground for thy sake; in sorrow shalt thou eat of it all the days of thy life;",
            18: "Thorns also and thistles shall it bring forth to thee; and thou shalt eat the herb of the field;",
            19: "In the sweat of thy face shalt thou eat bread, till thou return unto the ground; for out of it wast thou taken: for dust thou art, and unto dust shalt thou return.",
            20: "And Adam called his wife's name Eve; because she was the mother of all living.",
            21: "Unto Adam also and to his wife did the LORD God make coats of skins, and clothed them.",
            22: "And the LORD God said, Behold, the man is become as one of us, to know good and evil: and now, lest he put forth his hand, and take also of the tree of life, and eat, and live for ever:",
            23: "Therefore the LORD God sent him forth from the garden of Eden, to till the ground from whence he was taken.",
            24: "So he drove out the man; and he placed at the east of the garden of Eden Cherubims, and a flaming sword which turned every way, to keep the way of the tree of life.",
        ],
        ],

        // ─────────────────────────────────────────────────────────────────────
        "Psalms": [
        // ── Psalm 23 ─────────────────────────────────────────────────────────
        23: [
            1: "The LORD is my shepherd; I shall not want.",
            2: "He maketh me to lie down in green pastures: he leadeth me beside the still waters.",
            3: "He restoreth my soul: he leadeth me in the paths of righteousness for his name's sake.",
            4: "Yea, though I walk through the valley of the shadow of death, I will fear no evil: for thou art with me; thy rod and thy staff they comfort me.",
            5: "Thou preparest a table before me in the presence of mine enemies: thou anointest my head with oil; my cup runneth over.",
            6: "Surely goodness and mercy shall follow me all the days of my life: and I will dwell in the house of the LORD for ever.",
        ],
        // ── Psalm 91 ─────────────────────────────────────────────────────────
        91: [
             1: "He that dwelleth in the secret place of the most High shall abide under the shadow of the Almighty.",
             2: "I will say of the LORD, He is my refuge and my fortress: my God; in him will I trust.",
             3: "Surely he shall deliver thee from the snare of the fowler, and from the noisome pestilence.",
             4: "He shall cover thee with his feathers, and under his wings shalt thou trust: his truth shall be thy shield and buckler.",
             5: "Thou shalt not be afraid for the terror by night; nor for the arrow that flieth by day;",
             6: "Nor for the pestilence that walketh in darkness; nor for the destruction that wasteth at noonday.",
             7: "A thousand shall fall at thy side, and ten thousand at thy right hand; but it shall not come nigh thee.",
             8: "Only with thine eyes shalt thou behold and see the reward of the wicked.",
             9: "Because thou hast made the LORD, which is my refuge, even the most High, thy habitation;",
            10: "There shall no evil befall thee, neither shall any plague come nigh thy dwelling.",
            11: "For he shall give his angels charge over thee, to keep thee in all thy ways.",
            12: "They shall bear thee up in their hands, lest thou dash thy foot against a stone.",
            13: "Thou shalt tread upon the lion and adder: the young lion and the dragon shalt thou trample under feet.",
            14: "Because he hath set his love upon me, therefore will I deliver him: I will set him on high, because he hath known my name.",
            15: "He shall call upon me, and I will answer him: I will be with him in trouble; I will deliver him, and honour him.",
            16: "With long life will I satisfy him, and shew him my salvation.",
        ],
        // ── Psalm 1 ──────────────────────────────────────────────────────────
        1: [
            1: "Blessed is the man that walketh not in the counsel of the ungodly, nor standeth in the way of sinners, nor sitteth in the seat of the scornful.",
            2: "But his delight is in the law of the LORD; and in his law doth he meditate day and night.",
            3: "And he shall be like a tree planted by the rivers of water, that bringeth forth his fruit in his season; his leaf also shall not wither; and whatsoever he doeth shall prosper.",
            4: "The ungodly are not so: but are like the chaff which the wind driveth away.",
            5: "Therefore the ungodly shall not stand in the judgment, nor sinners in the congregation of the righteous.",
            6: "For the LORD knoweth the way of the righteous: but the way of the ungodly shall perish.",
        ],
        ],

        // ─────────────────────────────────────────────────────────────────────
        "Isaiah": [
        // ── Isaiah 53 ────────────────────────────────────────────────────────
        53: [
             1: "Who hath believed our report? and to whom is the arm of the LORD revealed?",
             2: "For he shall grow up before him as a tender plant, and as a root out of a dry ground: he hath no form nor comeliness; and when we shall see him, there is no beauty that we should desire him.",
             3: "He is despised and rejected of men; a man of sorrows, and acquainted with grief: and we hid as it were our faces from him; he was despised, and we esteemed him not.",
             4: "Surely he hath borne our griefs, and carried our sorrows: yet we did esteem him stricken, smitten of God, and afflicted.",
             5: "But he was wounded for our transgressions, he was bruised for our iniquities: the chastisement of our peace was upon him; and with his stripes we are healed.",
             6: "All we like sheep have gone astray; we have turned every one to his own way; and the LORD hath laid on him the iniquity of us all.",
             7: "He was oppressed, and he was afflicted, yet he opened not his mouth: he is brought as a lamb to the slaughter, and as a sheep before her shearers is dumb, so he openeth not his mouth.",
             8: "He was taken from prison and from judgment: and who shall declare his generation? for he was cut off out of the land of the living: for the transgression of my people was he stricken.",
             9: "And he made his grave with the wicked, and with the rich in his death; because he had done no violence, neither was any deceit in his mouth.",
            10: "Yet it pleased the LORD to bruise him; he hath put him to grief: when thou shalt make his soul an offering for sin, he shall see his seed, he shall prolong his days, and the pleasure of the LORD shall prosper in his hand.",
            11: "He shall see of the travail of his soul, and shall be satisfied: by his knowledge shall my righteous servant justify many; for he shall bear their iniquities.",
            12: "Therefore will I divide him a portion with the great, and he shall divide the spoil with the strong; because he hath poured out his soul unto death: and he was numbered with the transgressors; and he bare the sin of many, and made intercession for the transgressors.",
        ],
        ],

        // ─────────────────────────────────────────────────────────────────────
        "Matthew": [
        // ── Matthew 5 ────────────────────────────────────────────────────────
        5: [
             1: "And seeing the multitudes, he went up into a mountain: and when he was set, his disciples came unto him:",
             2: "And he opened his mouth, and taught them, saying,",
             3: "Blessed are the poor in spirit: for theirs is the kingdom of heaven.",
             4: "Blessed are they that mourn: for they shall be comforted.",
             5: "Blessed are the meek: for they shall inherit the earth.",
             6: "Blessed are they which do hunger and thirst after righteousness: for they shall be filled.",
             7: "Blessed are the merciful: for they shall obtain mercy.",
             8: "Blessed are the pure in heart: for they shall see God.",
             9: "Blessed are the peacemakers: for they shall be called the children of God.",
            10: "Blessed are they which are persecuted for righteousness' sake: for theirs is the kingdom of heaven.",
            11: "Blessed are ye, when men shall revile you, and persecute you, and shall say all manner of evil against you falsely, for my sake.",
            12: "Rejoice, and be exceeding glad: for great is your reward in heaven: for so persecuted they the prophets which were before you.",
            13: "Ye are the salt of the earth: but if the salt have lost his savour, wherewith shall it be salted? it is thenceforth good for nothing, but to be cast out, and to be trodden under foot of men.",
            14: "Ye are the light of the world. A city that is set on an hill cannot be hid.",
            15: "Neither do men light a candle, and put it under a bushel, but on a candlestick; and it giveth light unto all that are in the house.",
            16: "Let your light so shine before men, that they may see your good works, and glorify your Father which is in heaven.",
            17: "Think not that I am come to destroy the law, or the prophets: I am not come to destroy, but to fulfil.",
            18: "For verily I say unto you, Till heaven and earth pass, one jot or one tittle shall in no wise pass from the law, till all be fulfilled.",
            44: "But I say unto you, Love your enemies, bless them that curse you, do good to them that hate you, and pray for them which despitefully use you, and persecute you;",
            45: "That ye may be the children of your Father which is in heaven: for he maketh his sun to rise on the evil and on the good, and sendeth rain on the just and on the unjust.",
            48: "Be ye therefore perfect, even as your Father which is in heaven is perfect.",
        ],
        // ── Matthew 6 ────────────────────────────────────────────────────────
        6: [
             1: "Take heed that ye do not your alms before men, to be seen of them: otherwise ye have no reward of your Father which is in heaven.",
             5: "And when thou prayest, thou shalt not be as the hypocrites are: for they love to pray standing in the synagogues and in the corners of the streets, that they may be seen of men. Verily I say unto you, They have their reward.",
             6: "But thou, when thou prayest, enter into thy closet, and when thou hast shut thy door, pray to thy Father which is in secret; and thy Father which seeth in secret shall reward thee openly.",
             7: "But when ye pray, use not vain repetitions, as the heathen do: for they think that they shall be heard for their much speaking.",
             8: "Be not ye therefore like unto them: for your Father knoweth what things ye have need of, before ye ask him.",
             9: "After this manner therefore pray ye: Our Father which art in heaven, Hallowed be thy name.",
            10: "Thy kingdom come. Thy will be done in earth, as it is in heaven.",
            11: "Give us this day our daily bread.",
            12: "And forgive us our debts, as we forgive our debtors.",
            13: "And lead us not into temptation, but deliver us from evil: For thine is the kingdom, and the power, and the glory, for ever. Amen.",
            14: "For if ye forgive men their trespasses, your heavenly Father will also forgive you:",
            15: "But if ye forgive not men their trespasses, neither will your Father forgive your trespasses.",
            19: "Lay not up for yourselves treasures upon earth, where moth and rust doth corrupt, and where thieves break through and steal:",
            20: "But lay up for yourselves treasures in heaven, where neither moth nor rust doth corrupt, and where thieves do not break through nor steal:",
            21: "For where your treasure is, there will your heart be also.",
            24: "No man can serve two masters: for either he will hate the one, and love the other; or else he will hold to the one, and despise the other. Ye cannot serve God and mammon.",
            25: "Therefore I say unto you, Take no thought for your life, what ye shall eat, or what ye shall drink; nor yet for your body, what ye shall put on. Is not the life more than meat, and the body than raiment?",
            33: "But seek ye first the kingdom of God, and his righteousness; and all these things shall be added unto you.",
            34: "Take therefore no thought for the morrow: for the morrow shall take thought for the things of itself. Sufficient unto the day is the evil thereof.",
        ],
        ],

        // ─────────────────────────────────────────────────────────────────────
        "John": [
        // ── John 1 ───────────────────────────────────────────────────────────
        1: [
             1: "In the beginning was the Word, and the Word was with God, and the Word was God.",
             2: "The same was in the beginning with God.",
             3: "All things were made by him; and without him was not any thing made that was made.",
             4: "In him was life; and the life was the light of men.",
             5: "And the light shineth in darkness; and the darkness comprehended it not.",
             6: "There was a man sent from God, whose name was John.",
             7: "The same came for a witness, to bear witness of the Light, that all men through him might believe.",
             8: "He was not that Light, but was sent to bear witness of that Light.",
             9: "That was the true Light, which lighteth every man that cometh into the world.",
            10: "He was in the world, and the world was made by him, and the world knew him not.",
            11: "He came unto his own, and his own received him not.",
            12: "But as many as received him, to them gave he power to become the sons of God, even to them that believe on his name:",
            13: "Which were born, not of blood, nor of the will of the flesh, nor of the will of man, but of God.",
            14: "And the Word was made flesh, and dwelt among us, (and we beheld his glory, the glory as of the only begotten of the Father,) full of grace and truth.",
            15: "John bare witness of him, and cried, saying, This was he of whom I spake, He that cometh after me is preferred before me: for he was before me.",
            16: "And of his fulness have all we received, and grace for grace.",
            17: "For the law was given by Moses, but grace and truth came by Jesus Christ.",
            18: "No man hath seen God at any time; the only begotten Son, which is in the bosom of the Father, he hath declared him.",
        ],
        // ── John 3 ───────────────────────────────────────────────────────────
        3: [
             1: "There was a man of the Pharisees, named Nicodemus, a ruler of the Jews:",
             2: "The same came to Jesus by night, and said unto him, Rabbi, we know that thou art a teacher come from God: for no man can do these miracles that thou doest, except God be with him.",
             3: "Jesus answered and said unto him, Verily, verily, I say unto thee, Except a man be born again, he cannot see the kingdom of God.",
             4: "Nicodemus saith unto him, How can a man be born when he is old? can he enter the second time into his mother's womb, and be born?",
             5: "Jesus answered, Verily, verily, I say unto thee, Except a man be born of water and of the Spirit, he cannot enter into the kingdom of God.",
             6: "That which is born of the flesh is flesh; and that which is born of the Spirit is spirit.",
             7: "Marvel not that I said unto thee, Ye must be born again.",
             8: "The wind bloweth where it listeth, and thou hearest the sound thereof, but canst not tell whence it cometh, and whither it goeth: so is every one that is born of the Spirit.",
             9: "Nicodemus answered and said unto him, How can these things be?",
            10: "Jesus answered and said unto him, Art thou a master of Israel, and knowest not these things?",
            11: "Verily, verily, I say unto thee, We speak that we do know, and testify that we have seen; and ye receive not our witness.",
            12: "If I have told you earthly things, and ye believe not, how shall ye believe, if I tell you of heavenly things?",
            13: "And no man hath ascended up to heaven, but he that came down from heaven, even the Son of man which is in heaven.",
            14: "And as Moses lifted up the serpent in the wilderness, even so must the Son of man be lifted up:",
            15: "That whosoever believeth in him should not perish, but have eternal life.",
            16: "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.",
            17: "For God sent not his Son into the world to condemn the world; but that the world through him might be saved.",
            18: "He that believeth on him is not condemned: but he that believeth not is condemned already, because he hath not believed in the name of the only begotten Son of God.",
            19: "And this is the condemnation, that light is come into the world, and men loved darkness rather than light, because their deeds were evil.",
            20: "For every one that doeth evil hateth the light, neither cometh to the light, lest his deeds should be reproved.",
            21: "But he that doeth truth cometh to the light, that his deeds may be made manifest, that they are wrought in God.",
            36: "He that believeth on the Son hath everlasting life: and he that believeth not the Son shall not see life; but the wrath of God abideth on him.",
        ],
        // ── John 15 ──────────────────────────────────────────────────────────
        15: [
             1: "I am the true vine, and my Father is the husbandman.",
             2: "Every branch in me that beareth not fruit he taketh away: and every branch that beareth fruit, he purgeth it, that it may bring forth more fruit.",
             3: "Now ye are clean through the word which I have spoken unto you.",
             4: "Abide in me, and I in you. As the branch cannot bear fruit of itself, except it abide in the vine; no more can ye, except ye abide in me.",
             5: "I am the vine, ye are the branches: He that abideth in me, and I in him, the same bringeth forth much fruit: for without me ye can do nothing.",
             9: "As the Father hath loved me, so have I loved you: continue ye in my love.",
            10: "If ye keep my commandments, ye shall abide in my love; even as I have kept my Father's commandments, and abide in his love.",
            11: "These things have I spoken unto you, that my joy might remain in you, and that your joy might be full.",
            12: "This is my commandment, That ye love one another, as I have loved you.",
            13: "Greater love hath no man than this, that a man lay down his life for his friends.",
        ],
        ],

        // ─────────────────────────────────────────────────────────────────────
        "Romans": [
        // ── Romans 8 ─────────────────────────────────────────────────────────
        8: [
             1: "There is therefore now no condemnation to them which are in Christ Jesus, who walk not after the flesh, but after the Spirit.",
             2: "For the law of the Spirit of life in Christ Jesus hath made me free from the law of sin and death.",
             3: "For what the law could not do, in that it was weak through the flesh, God sending his own Son in the likeness of sinful flesh, and for sin, condemned sin in the flesh:",
             4: "That the righteousness of the law might be fulfilled in us, who walk not after the flesh, but after the Spirit.",
             5: "For they that are after the flesh do mind the things of the flesh; but they that are after the Spirit the things of the Spirit.",
             6: "For to be carnally minded is death; but to be spiritually minded is life and peace.",
            14: "For as many as are led by the Spirit of God, they are the sons of God.",
            15: "For ye have not received the spirit of bondage again to fear; but ye have received the Spirit of adoption, whereby we cry, Abba, Father.",
            16: "The Spirit itself beareth witness with our spirit, that we are the children of God:",
            17: "And if children, then heirs; heirs of God, and joint-heirs with Christ; if so be that we suffer with him, that we may be also glorified together.",
            18: "For I reckon that the sufferings of this present time are not worthy to be compared with the glory which shall be revealed in us.",
            26: "Likewise the Spirit also helpeth our infirmities: for we know not what we should pray for as we ought: but the Spirit itself maketh intercession for us with groanings which cannot be uttered.",
            28: "And we know that all things work together for good to them that love God, to them who are the called according to his purpose.",
            31: "What shall we then say to these things? If God be for us, who can be against us?",
            32: "He that spared not his own Son, but delivered him up for us all, how shall he not with him also freely give us all things?",
            35: "Who shall separate us from the love of Christ? shall tribulation, or distress, or persecution, or famine, or nakedness, or peril, or sword?",
            37: "Nay, in all these things we are more than conquerors through him that loved us.",
            38: "For I am persuaded, that neither death, nor life, nor angels, nor principalities, nor powers, nor things present, nor things to come,",
            39: "Nor height, nor depth, nor any other creature, shall be able to separate us from the love of God, which is in Christ Jesus our Lord.",
        ],
        ],

        // ─────────────────────────────────────────────────────────────────────
        "1 Corinthians": [
        // ── 1 Corinthians 13 ─────────────────────────────────────────────────
        13: [
             1: "Though I speak with the tongues of men and of angels, and have not charity, I am become as sounding brass, or a tinkling cymbal.",
             2: "And though I have the gift of prophecy, and understand all mysteries, and all knowledge; and though I have all faith, so that I could remove mountains, and have not charity, I am nothing.",
             3: "And though I bestow all my goods to feed the poor, and though I give my body to be burned, and have not charity, it profiteth me nothing.",
             4: "Charity suffereth long, and is kind; charity envieth not; charity vaunteth not itself, is not puffed up,",
             5: "Doth not behave itself unseemly, seeketh not her own, is not easily provoked, thinketh no evil;",
             6: "Rejoiceth not in iniquity, but rejoiceth in the truth;",
             7: "Beareth all things, believeth all things, hopeth all things, endureth all things.",
             8: "Charity never faileth: but whether there be prophecies, they shall fail; whether there be tongues, they shall cease; whether there be knowledge, it shall vanish away.",
             9: "For now we know in part, and we prophesy in part.",
            10: "But when that which is perfect is come, then that which is in part shall be done away.",
            11: "When I was a child, I spake as a child, I understood as a child, I thought as a child: but when I became a man, I put away childish things.",
            12: "For now we see through a glass, darkly; but then face to face: now I know in part; but then shall I know even as also I am known.",
            13: "And now abideth faith, hope, charity, these three; but the greatest of these is charity.",
        ],
        ],

        // ─────────────────────────────────────────────────────────────────────
        "Revelation": [
        // ── Revelation 1 ─────────────────────────────────────────────────────
        1: [
             1: "The Revelation of Jesus Christ, which God gave unto him, to shew unto his servants things which must shortly come to pass; and he sent and signified it by his angel unto his servant John:",
             2: "Who bare record of the word of God, and of the testimony of Jesus Christ, and of all things that he saw.",
             3: "Blessed is he that readeth, and they that hear the words of this prophecy, and keep those things which are written therein: for the time is at hand.",
             4: "John to the seven churches which are in Asia: Grace be unto you, and peace, from him which is, and which was, and which is to come; and from the seven Spirits which are before his throne;",
             5: "And from Jesus Christ, who is the faithful witness, and the first begotten of the dead, and the prince of the kings of the earth. Unto him that loved us, and washed us from our sins in his own blood,",
             6: "And hath made us kings and priests unto God and his Father; to him be glory and dominion for ever and ever. Amen.",
             7: "Behold, he cometh with clouds; and every eye shall see him, and they also which pierced him: and all kindreds of the earth shall wail because of him. Even so, Amen.",
             8: "I am Alpha and Omega, the beginning and the ending, saith the Lord, which is, and which was, and which is to come, the Almighty.",
             9: "I John, who also am your brother, and companion in tribulation, and in the kingdom and patience of Jesus Christ, was in the isle that is called Patmos, for the word of God, and for the testimony of Jesus Christ.",
            10: "I was in the Spirit on the Lord's day, and heard behind me a great voice, as of a trumpet,",
            11: "Saying, I am Alpha and Omega, the first and the last: and, What thou seest, write in a book, and send it unto the seven churches which are in Asia; unto Ephesus, and unto Smyrna, and unto Pergamos, and unto Thyatira, and unto Sardis, and unto Philadelphia, and unto Laodicea.",
            12: "And I turned to see the voice that spake with me. And being turned, I saw seven golden candlesticks;",
            13: "And in the midst of the seven candlesticks one like unto the Son of man, clothed with a garment down to the foot, and girt about the paps with a golden girdle.",
            14: "His head and his hairs were white like wool, as white as snow; and his eyes were as a flame of fire;",
            15: "And his feet like unto fine brass, as if they burned in a furnace; and his voice as the sound of many waters.",
            16: "And he had in his right hand seven stars: and out of his mouth went a sharp twoedged sword: and his countenance was as the sun shineth in his strength.",
            17: "And when I saw him, I fell at his feet as dead. And he laid his right hand upon me, saying unto me, Fear not; I am the first and the last:",
            18: "I am he that liveth, and was dead; and, behold, I am alive for evermore, Amen; and have the keys of hell and of death.",
            19: "Write the things which thou hast seen, and the things which are, and the things which shall be hereafter;",
            20: "The mystery of the seven stars which thou sawest in my right hand, and the seven golden candlesticks. The seven stars are the angels of the seven churches: and the seven candlesticks which thou sawest are the seven churches.",
        ],
        // ── Revelation 21 ────────────────────────────────────────────────────
        21: [
             1: "And I saw a new heaven and a new earth: for the first heaven and the first earth were passed away; and there was no more sea.",
             2: "And I John saw the holy city, new Jerusalem, coming down from God out of heaven, prepared as a bride adorned for her husband.",
             3: "And I heard a great voice out of heaven saying, Behold, the tabernacle of God is with men, and he will dwell with them, and they shall be his people, and God himself shall be with them, and be their God.",
             4: "And God shall wipe away all tears from their eyes; and there shall be no more death, neither sorrow, nor crying, neither shall there be any more pain: for the former things are passed away.",
             5: "And he that sat upon the throne said, Behold, I make all things new. And he said unto me, Write: for these words are true and faithful.",
             6: "And he said unto me, It is done. I am Alpha and Omega, the beginning and the end. I will give unto him that is athirst of the fountain of the water of life freely.",
             7: "He that overcometh shall inherit all things; and I will be his God, and he shall be my son.",
        ],
        // ── Revelation 22 ────────────────────────────────────────────────────
        22: [
             1: "And he shewed me a pure river of water of life, clear as crystal, proceeding out of the throne of God and of the Lamb.",
             2: "In the midst of the street of it, and on either side of the river, was there the tree of life, which bare twelve manner of fruits, and yielded her fruit every month: and the leaves of the tree were for the healing of the nations.",
             3: "And there shall be no more curse: but the throne of God and of the Lamb shall be in it; and his servants shall serve him:",
             4: "And they shall see his face; and his name shall be in their foreheads.",
             5: "And there shall be no night there; and they need no candle, neither light of the sun; for the Lord God giveth them light: and they shall reign for ever and ever.",
            17: "And the Spirit and the bride say, Come. And let him that heareth say, Come. And let him that is athirst come. And whosoever will, let him take the water of life freely.",
            20: "He which testifieth these things saith, Surely I come quickly. Amen. Even so, come, Lord Jesus.",
            21: "The grace of our Lord Jesus Christ be with you all. Amen.",
        ],
        ],
    ]
}
