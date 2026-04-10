import Foundation

// Existing Object Model

struct RitualInfo: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let meaning: String
    let history: String
    let howToUse: String
}

struct RitualDatabase {
    static let allRituals: [String: RitualInfo] = [
        "diya": RitualInfo(
            name: "Diya (Sacred Lamp)",
            image: "diya",

            meaning:
                """
                According to the Rig Veda and Yajur Veda, light represents knowledge and the 
                removal of darkness. Lighting a diya during worship symbolizes victory of 
                wisdom over ignorance and truth over illusion.
                
                Agama scriptures explain that offering light invites divine presence into the 
                home. The steady flame of the lamp teaches focus and inner calm during prayer.

                Puranic texts describe the diya as a symbol of the inner soul. Its light 
                reminds devotees to awaken spiritual awareness and live with clarity.
                """,

            history:
                """
                The practice of lighting lamps comes from early Vedic fire rituals where Agni, 
                the fire god, was worshiped as a messenger between humans and the divine.

                Later, Agama scriptures made lamp lighting an essential part of temple and 
                home worship. Every formal puja includes offering light to the deity.

                The Skanda Purana and other Puranas praise the diya as a sacred offering that 
                removes negativity and brings spiritual brightness into life.
                """,

            howToUse:
                """
                Fill the diya with ghee or oil and place a cotton wick inside. Light it at the 
                beginning of the puja and keep it in front of the deity.

                According to Agama guidelines, the lamp is offered after incense and before 
                food offerings. The flame should burn steadily during prayer.

                Allow the diya to burn peacefully while chanting or meditating. This maintains 
                a sacred and focused worship atmosphere.
                """
        ),
        "kalash": RitualInfo(
            name: "Kalash (Sacred Pot)",
            image: "kalash",

            meaning:
                """
                The kalash represents life, creation, and abundance. The Atharva Veda teaches 
                that water is the source of all existence, and the filled pot symbolizes life 
                energy.

                Agama traditions describe the kalash as a seat of divine presence during puja. 
                It is believed to attract positive spiritual energy.

                Puranic stories connect the kalash with prosperity and blessings. It represents 
                the universe and fullness of life.
                """,

            history:
                """
                Sacred water vessels appear in Vedic rituals described in the Atharva Veda and 
                Yajur Veda. Water offerings were considered essential for purification.

                Agama scriptures later formalized the kalash as an important object in temple 
                ceremonies and domestic worship.

                The Vishnu Purana mentions the kalash in creation stories and sacred rituals, 
                linking it to purity and divine grace.
                """,

            howToUse:
                """
                Fill the kalash with clean water and decorate it with mango leaves and a 
                coconut placed on top.

                Position it near the deity before beginning the ritual. It represents inviting 
                divine energy into the space.

                Keep the kalash undisturbed during worship and treat it with respect as a 
                symbol of sacred presence.
                """
        ),
        "agarbatti": RitualInfo(
            name: "Agarbatti (Sacred Incense)",
            image: "agarbatti",

            meaning:
                """
                According to the Atharva Veda, incense smoke is believed to purify the air 
                and calm the mind. In Hindu worship, agarbatti represents the idea of offering 
                our prayers to God. As the incense burns and the smoke rises upward, it 
                symbolizes our prayers reaching the divine.

                Agama scriptures explain that incense helps create a peaceful and sacred 
                atmosphere for worship. The Puranas say that pleasant fragrance represents 
                pure devotion and a clean heart. The burning incense also teaches selflessness, 
                because it burns itself to spread fragrance for others.

                Incense connects the natural elements of fire and air and helps prepare the 
                mind for prayer and meditation.
                """,

            history:
                """
                The use of incense in Hindu rituals comes from early Vedic traditions described 
                in the Atharva Veda and Yajur Veda, where fragrant herbs and woods were offered 
                into sacred fire. People believed that the rising smoke carried their offerings 
                to the gods.

                Later, the Agama scriptures made incense an important step in daily temple and 
                home worship. Texts like the Vishnu Purana and Shiva Purana explain that good 
                fragrance pleases the deities and represents inner purity.

                Traditionally, incense was made from natural materials such as sandalwood, 
                herbs, and plant resins. Besides its spiritual role, incense was also used to 
                clean the air and create a healthy environment.
                """,

            howToUse:
                """
                Light the agarbatti and place it in a holder in front of the deity. Let the 
                fragrance spread around the worship space while you chant prayers or sit 
                quietly in devotion.

                According to Agama ritual guidelines, incense is offered after flowers and 
                before lighting the lamp. Natural incense is preferred because it keeps the 
                environment pure and peaceful.

                Allow the incense to burn completely as a symbol of continuous devotion and 
                respect.
                """
        ),

        "camphor": RitualInfo(
            name: "Camphor (Kapoor)",
            image: "camphor",

            meaning:
                """
                Camphor symbolizes the burning away of ego and ignorance. When it burns, it 
                leaves no residue, teaching selfless surrender.

                Agama traditions describe camphor flame as a symbol of pure spiritual light.

                Puranic teachings connect camphor with purification and devotion.
                """,

            history:
                """
                Camphor was used in ancient rituals as a cleansing substance and sacred flame.

                Agama scriptures included camphor burning in aarti ceremonies.

                Puranic traditions praise camphor as a purifier of both space and mind.
                """,

            howToUse:
                """
                Place camphor on a holder or aarti plate and light it carefully.

                Wave it before the deity during aarti as an offering of light.

                Allow it to burn completely as a sign of devotion.
                """
        ),
        "coconut": RitualInfo(
            name: "Coconut",
            image: "coconut",

            meaning:
                """
                The coconut represents purity and self-offering in Hindu worship. According 
                to Vedic tradition, offering natural fruits symbolizes gratitude to nature and 
                the divine.

                Agama scriptures explain that the hard shell of the coconut represents the 
                human ego, while the pure water inside symbolizes inner truth and purity.

                Puranic teachings describe the coconut as an sacred offering that brings good 
                fortune and spiritual blessings.
                """,

            history:
                """
                The use of coconut in rituals comes from ancient Vedic offering traditions 
                where fruits were presented to the gods.

                Agama texts later made coconut an important item in temple and household puja, 
                especially during major ceremonies.

                Puranic literature praises coconut offerings as symbols of prosperity and 
                auspicious beginnings.
                """,

            howToUse:
                """
                Wash the coconut and place it on the puja altar as an offering.

                It may be broken after prayers as a symbol of surrender and sharing blessings.

                Offer it with devotion and distribute it as prasad after worship.
                """
        ),
        "flowers": RitualInfo(
            name: "Flowers",
            image: "flowers",

            meaning:
                """
                Flowers symbolize purity, beauty, and devotion. The Vedas describe offering 
                natural gifts as an act of gratitude.

                Agama scriptures explain that flowers express love and respect for the deity.

                Puranic teachings say that fresh flowers represent a pure heart.
                """,

            history:
                """
                Flower offerings appear in early Vedic worship as symbols of nature’s gifts.

                Agama traditions formalized flower offerings in daily puja.

                Puranic texts praise the offering of fresh flowers as spiritually uplifting.
                """,

            howToUse:
                """
                Offer clean, fresh flowers at the feet of the deity.

                Avoid damaged or dry flowers during worship.

                Replace flowers regularly to maintain purity.
                """
        ),
        "bell": RitualInfo(
            name: "Bell (Ghanti)",
            image: "bell",

            meaning:
                """
                Vedic tradition teaches that sacred sound purifies the environment and mind. 
                Ringing the bell removes distractions and prepares the devotee for prayer.

                Agama texts explain that the bell’s vibration represents cosmic sound and 
                awakens spiritual awareness.

                Puranic teachings say that pleasing sound invites divine attention and creates 
                a peaceful atmosphere.
                """,

            history:
                """
                The use of ritual sound comes from Vedic chanting traditions where vibration 
                was seen as spiritually powerful.

                Agama scriptures later required bell ringing as part of temple worship to mark 
                the start of rituals.

                Puranic literature describes sacred sound as essential for maintaining a holy 
                environment.
                """,

            howToUse:
                """
                Ring the bell gently at the beginning of puja to signal the start of worship.

                Continue ringing during aarti or important offerings to maintain focus.

                The sound should be steady and calm, helping the mind remain attentive.
                """
        ),

        "shankh": RitualInfo(
            name: "Shankh (Conch Shell)",
            image: "shankh",

            meaning:
                """
                The shankh represents sacred cosmic sound. According to Vedic belief, sound is 
                a powerful spiritual force that purifies the environment.

                Agama scriptures explain that blowing the conch removes negative energy and 
                creates a divine atmosphere.

                Puranic stories connect the shankh with divine power and protection.
                """,

            history:
                """
                The conch shell was used in ancient Vedic rituals as a sacred sound instrument.

                Agama traditions included the shankh in temple ceremonies to mark important 
                moments in worship.

                Puranic texts describe the conch as a symbol of divine authority and victory.
                """,

            howToUse:
                """
                Blow the shankh at the beginning of worship to purify the space.

                Use it during aarti or special rituals to create sacred sound.

                Keep the conch clean and treat it with respect.
                """
        ),
        "chandan": RitualInfo(
            name: "Chandan (Sandalwood Paste)",
            image: "chandan",

            meaning:
                """
                Chandan represents calmness and purity. The Vedas describe sandalwood as a 
                cooling and sacred substance.

                Agama scriptures explain that applying chandan symbolizes mental peace and 
                devotion.

                Puranic teachings connect sandalwood with spiritual purity and blessing.
                """,

            history:
                """
                Sandalwood has been used in Vedic rituals for its fragrance and cooling 
                qualities.

                Agama traditions formalized its use in decorating deities and devotees.

                Puranic texts praise sandalwood as a sacred and healing substance.
                """,

            howToUse:
                """
                Prepare sandalwood paste and apply it to the deity or forehead.

                Use it gently as a mark of respect and devotion.

                Store it cleanly and use fresh paste when possible.
                """
        ),
        "garland": RitualInfo(
            name: "Garland",
            image: "garland",

            meaning:
                """
                A garland symbolizes honor and unity. Offering flowers in a circle represents 
                continuous devotion.

                Vedic tradition views flower offerings as expressions of gratitude.

                Puranic teachings describe garlands as signs of respect and celebration.
                """,

            history:
                """
                Garlands have been used since Vedic times in ceremonies and celebrations.

                Agama scriptures included garlands in temple worship decoration.

                Puranic stories mention garlands as symbols of victory and honor.
                """,

            howToUse:
                """
                Place the garland gently around the deity or sacred image.

                Use fresh flowers to maintain purity.

                Remove and replace regularly with respect.
                """
        ),
        "idol": RitualInfo(
            name: "Idol (Murti)",
            image: "idol",

            meaning:
                """
                An idol represents a visible focus for divine worship. The Vedas teach that 
                the divine can be approached through symbols.

                Agama scriptures explain that the murti acts as a sacred center for devotion.

                Puranic traditions describe idols as forms through which devotees connect with 
                God.
                """,

            history:
                """
                Sacred symbols appeared in early Vedic worship as meditation aids.

                Agama traditions developed detailed methods for idol worship in temples.

                Puranic literature describes many divine forms represented by murtis.
                """,

            howToUse:
                """
                Place the idol in a clean and respectful location.

                Worship it daily with flowers, incense, and light.

                Keep it clean and treat it as a sacred presence.
                """
        ),
        "kumkum_container": RitualInfo(
            name: "Kumkum Box",
            image: "kumkum_container",

            meaning:
                """
                Kumkum represents auspiciousness and divine energy. According to Vedic 
                tradition, sacred markings on the forehead symbolize spiritual awareness.

                Agama scriptures explain that applying kumkum expresses devotion and respect 
                toward the divine.

                Puranic teachings connect kumkum with blessings, protection, and prosperity.
                """,

            history:
                """
                The use of sacred powders dates back to Vedic rituals where markings showed 
                religious identity and devotion.

                Agama traditions formalized the use of kumkum in temple worship and festivals.

                Puranic literature praises kumkum as a sacred symbol of divine grace.
                """,

            howToUse:
                """
                Keep kumkum in a clean container on the puja altar.

                Apply a small mark on the forehead after prayers.

                Use it respectfully as a symbol of blessing.
                """
        ),
        "matchbox": RitualInfo(
            name: "Matchbox",
            image: "matchbox",

            meaning:
                """
                Fire represents divine energy in Vedic philosophy. Lighting a flame begins 
                the sacred act of worship.

                Agama traditions teach that initiating fire marks the start of ritual purity.

                The flame symbolizes awakening spiritual awareness.
                """,

            history:
                """
                Ancient Vedic rituals used sacred fire created by traditional methods.

                Modern tools like matchboxes serve the same sacred purpose.

                They continue the tradition of honoring fire in worship.
                """,

            howToUse:
                """
                Use the matchbox carefully to light lamps and incense.

                Handle it safely and respectfully during rituals.

                Store it away from the altar after use.
                """
        ),
        "puja_thali": RitualInfo(
            name: "Puja Thali",
            image: "puja_thali",

            meaning:
                """
                The puja thali represents organization and readiness for worship.

                Vedic tradition values orderly preparation of ritual items.

                It symbolizes harmony and balance during prayer.
                """,

            history:
                """
                Containers for ritual items have existed since early Vedic ceremonies.

                Agama practices formalized arranging offerings on a dedicated plate.

                This tradition continues in household worship today.
                """,

            howToUse:
                """
                Arrange lamps, flowers, and offerings neatly on the thali.

                Use it to present items during aarti.

                Keep it clean and reserved for sacred use.
                """
        ),

        "rudraksha": RitualInfo(
            name: "Rudraksha",
            image: "rudraksha",

            meaning:
                """
                Rudraksha beads symbolize protection and spiritual discipline.

                According to Vedic and Shaiva traditions, they are associated with Lord Shiva.

                They represent focus, meditation, and inner strength.
                """,

            history:
                """
                Rudraksha use originates in ancient Shaiva worship traditions.

                Agama texts describe their importance in meditation practices.

                Puranic stories connect them with divine blessing and protection.
                """,

            howToUse:
                """
                Wear rudraksha beads during prayer or meditation.

                Keep them clean and handle with respect.

                Use them to maintain focus and calmness.
                """
        ),
    ]
}

/////////////////////////////////////////////////////

// Annual Ritual Model

//
//  AnnualRitualModels.swift
//  IndianRitual2
//
//  Full Updated Models + Database (Month Wise)
//

// MARK: - Hindu Months

enum HinduMonth: String, CaseIterable, Identifiable {

    case chaitra = "Chaitra"
    case vaishakha = "Vaishakha"
    case jyeshtha = "Jyeshtha"
    case ashadha = "Ashadha"
    case shravana = "Shravana"
    case bhadrapada = "Bhadrapada"
    case ashwin = "Ashwin"
    case kartika = "Kartika"
    case margashirsha = "Margashirsha"
    case pausha = "Pausha"
    case magha = "Magha"
    case phalguna = "Phalguna"

    var id: String { rawValue }

    // English month range
    var englishRange: String {
        switch self {
        case .chaitra: return "Mar–Apr"
        case .vaishakha: return "Apr–May"
        case .jyeshtha: return "May–Jun"
        case .ashadha: return "Jun–Jul"
        case .shravana: return "Jul–Aug"
        case .bhadrapada: return "Aug–Sep"
        case .ashwin: return "Sep–Oct"
        case .kartika: return "Oct–Nov"
        case .margashirsha: return "Nov–Dec"
        case .pausha: return "Dec–Jan"
        case .magha: return "Jan–Feb"
        case .phalguna: return "Feb–Mar"
        }
    }

    // Combined display name
    var displayName: String {
        "\(rawValue) (\(englishRange))"
    }

}

// MARK: - Ritual Item Model

struct RitualItem: Identifiable {
    let id = UUID()
    let name: String
    let reason: String
}

// MARK: - Annual Ritual Model

struct AnnualRitual: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let month: HinduMonth
    // Approximate Gregorian date for "upcoming" sorting
    let approximateMonth: Int  // 1–12
    let approximateDay: Int    // 1–31
    let items: [RitualItem]

    // New Detailed Fields
    let significance: String  // 3 Paragraphs with Ved/Purana ref
    let instructions: String  // Timeline + How to celebrate
    let history: String  // 3 Paragraphs with Ved/Purana ref

    /// Days from the given date until this ritual's next occurrence (0 = today).
    func daysUntilNext(from today: Date = .now) -> Int {
        let cal = Calendar.current
        let todayComponents = cal.dateComponents([.month, .day], from: today)
        let todayOrdinal = (todayComponents.month! - 1) * 31 + todayComponents.day!
        let ritualOrdinal = (approximateMonth - 1) * 31 + approximateDay
        let diff = ritualOrdinal - todayOrdinal
        return diff >= 0 ? diff : diff + 372   // wrap around the year
    }

    /// Whether this ritual falls on the same Gregorian day as `today`.
    func isToday(_ today: Date = .now) -> Bool {
        let c = Calendar.current
        return c.component(.month, from: today) == approximateMonth
            && c.component(.day, from: today) == approximateDay
    }
    
    /// A formatted string of the approximate date (e.g., "February 19")
    var dateString: String {
        let calendar = Calendar.current
        var comps = DateComponents()
        comps.month = approximateMonth
        comps.day = approximateDay
        comps.year = calendar.component(.year, from: Date())
        
        if let date = calendar.date(from: comps) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d"
            return formatter.string(from: date)
        }
        return ""
    }
}
// MARK: - Annual Ritual Database

struct AnnualRitualDatabase {

    static let rituals: [AnnualRitual] = [

        // MARK: - Chaitra

        // MARK: - CHAITRA

        AnnualRitual(
            name: "Chaitra Navratri",
            image: "navratri",
            month: .chaitra,
            approximateMonth: 3, approximateDay: 19,
            items: [
                RitualItem(
                    name: "Kalash", reason: "Represents the cosmic womb and divine presence."),
                RitualItem(name: "Coconut", reason: "Symbolizes self-sacrifice and purity."),
                RitualItem(
                    name: "Mango Leaves", reason: "Used for purification and auspiciousness."),
            ],
            significance: """
                According to the Devi Mahatmya of the Markandeya Purana, Chaitra Navratri represents the cyclical renewal of cosmic energy, where Shakti awakens dormant spiritual forces within the practitioner. The nine nights symbolize progressive purification of the mind and body, guiding the devotee toward inner equilibrium.


                As stated in the Skanda Purana, this period marks the commencement of the Hindu New Year and aligns human consciousness with seasonal transformation. The ritual fasting and meditation purify biological rhythms and restore harmony between the physical and metaphysical realms.

                According to Rigvedic hymns dedicated to the Divine Feminine, the worship during this time invokes the universal life force that sustains creation. Devotees cultivate resilience, clarity, and devotion to uphold Dharma in daily life.
                """,
            instructions: """
                [TIMELINE]
                Day 1: Perform Ghatasthapana at Brahma Muhurta and invoke Goddess Durga.
                Days 1–9: Recite Durga Saptashati daily and perform morning and evening Aarti.
                Day 8/9: Conduct Kanya Pujan honoring nine young girls as embodiments of Durga.

                [CELEBRATION]
                Maintain an Akhand Jyoti, decorate the altar with flowers, and offer fruits and sweets daily. Fasting and mantra chanting strengthen spiritual discipline.
                """,
            history: """
                The Brahmanda Purana records that creation began during Chaitra, making this festival a celebration of cosmic genesis.

                The Ramayana recounts that Lord Rama performed spring Navratri worship to seek divine strength before confronting Ravana, establishing the tradition of invoking Shakti for victory.

                Shakta Agamas describe the manifestation of the Goddess in nine forms during this period to restore universal balance and guide seekers toward liberation.
                """),

        AnnualRitual(
            name: "Ram Navami",
            image: "ram",
            month: .chaitra,
            approximateMonth: 3, approximateDay: 27,
            items: [
                RitualItem(
                    name: "Idol of Rama", reason: "Represents divine kingship and righteousness."),
                RitualItem(name: "Tulsi Leaves", reason: "Sacred offering symbolizing devotion."),
                RitualItem(name: "Fruits", reason: "Signifies purity and gratitude."),
            ],
            significance: """
                According to the Valmiki Ramayana, Ram Navami commemorates the birth of Lord Rama, the embodiment of Dharma and ideal kingship. His life serves as a philosophical model for ethical governance and moral conduct.


                The Vishnu Purana interprets Rama as an avatar of cosmic preservation, restoring balance during periods of moral decline. Worship during this day reinforces commitment to truth and duty.

                Vedic commentaries emphasize that remembering Rama's virtues cultivates discipline and compassion, guiding individuals toward righteous living.
                """,
            instructions: """
                [TIMELINE]
                Morning: Perform ritual bathing of Rama’s idol (Abhishekam).
                Noon: Recite Ramayana passages and chant the Rama mantra.
                Evening: Conduct Aarti and distribute prasad.

                [CELEBRATION]
                Temples are decorated with flowers, devotional songs are sung, and fasting is observed until midday.
                """,
            history: """
                Ancient temple inscriptions indicate that Ram Navami celebrations date back to early Vaishnava communities.

                Medieval Bhakti movements popularized public recitations of the Ramayana, making the festival a communal spiritual event.

                The tradition symbolizes the eternal triumph of virtue over injustice.
                """),

        AnnualRitual(
            name: "Hanuman Jayanti",
            image: "hanuman",
            month: .chaitra,
            approximateMonth: 4, approximateDay: 2,
            items: [
                RitualItem(name: "Sindoor", reason: "Symbolizes devotion and strength."),
                RitualItem(name: "Oil Lamp", reason: "Represents spiritual illumination."),
                RitualItem(name: "Banana Offerings", reason: "Traditional sacred offering."),
            ],
            significance: """
                The Ramayana portrays Hanuman as the supreme devotee, representing unwavering faith and selfless service. His birth anniversary honors the ideal of surrender to divine will.


                According to the Brahma Purana, Hanuman embodies the synthesis of strength and humility, guiding seekers toward disciplined devotion.

                Yogic traditions regard Hanuman as the patron of breath control and vitality, symbolizing mastery over life energy.
                """,
            instructions: """
                [TIMELINE]
                Dawn: Recite Hanuman Chalisa and perform Abhishekam.
                Afternoon: Offer sindoor and light oil lamps.
                Evening: Conduct collective chanting and Aarti.

                [CELEBRATION]
                Devotees fast, visit temples, and engage in devotional singing.
                """,
            history: """
                Hanuman worship gained prominence during the Bhakti era, especially through Tulsidas’ compositions.

                Regional traditions integrated martial symbolism, portraying Hanuman as a guardian deity.

                The festival reinforces ideals of courage and devotion.
                """),

        // MARK: - Vaishakha

        // MARK: - VAISHAKHA

        AnnualRitual(
            name: "Akshaya Tritiya",
            image: "akshaya",
            month: .vaishakha,
            approximateMonth: 4, approximateDay: 19,
            items: [
                RitualItem(name: "Rice Grains", reason: "Symbolize inexhaustible prosperity."),
                RitualItem(name: "Gold", reason: "Represents eternal wealth and auspiciousness."),
                RitualItem(name: "Water Offering", reason: "Signifies purification and charity."),
            ],
            significance: """
                According to the Mahabharata, Akshaya Tritiya marks the day when the Pandavas received the Akshaya Patra from Lord Krishna, symbolizing the principle of inexhaustible divine abundance. The term “Akshaya” itself denotes that spiritual merit earned on this day multiplies infinitely.


                The Vishnu Purana records that this tithi is governed by Lord Vishnu and Goddess Lakshmi, making it uniquely auspicious for acts of charity and new beginnings. Ritual actions performed on this day align human effort with cosmic prosperity.

                Vedic ritual manuals emphasize that generosity expressed during Akshaya Tritiya dissolves karmic limitations and strengthens social harmony through sacred giving.
                """,
            instructions: """
                [TIMELINE]
                Morning: Perform Lakshmi-Narayana Puja after ritual bathing.
                Midday: Donate food, clothing, or gold to the needy.
                Evening: Light lamps and chant Vishnu Sahasranama.

                [CELEBRATION]
                Homes and temples are decorated, and families begin new ventures or purchases as symbols of auspicious renewal.
                """,
            history: """
                Puranic narratives associate this day with the descent of the Ganges to Earth and the birth of Lord Parashurama.

                Ancient agrarian communities regarded the festival as a sacred marker for agricultural cycles.

                Over centuries, Akshaya Tritiya evolved into a pan-Indian celebration of prosperity and generosity.
                """),

        AnnualRitual(
            name: "Buddha Purnima",
            image: "buddha",
            month: .vaishakha,
            approximateMonth: 5, approximateDay: 1,
            items: [
                RitualItem(name: "Lotus Flowers", reason: "Symbolize enlightenment and purity."),
                RitualItem(name: "Incense", reason: "Represents mindful awareness."),
                RitualItem(name: "Candles", reason: "Signify illumination of wisdom."),
            ],
            significance: """
                Buddhist scriptures record that Buddha Purnima commemorates the birth, enlightenment, and Mahaparinirvana of Gautama Buddha. It represents the culmination of the quest for liberation from suffering.


                According to the Tripitaka, the Buddha’s enlightenment revealed the Middle Path, a philosophical framework balancing asceticism and indulgence. Observing this day invites practitioners to cultivate compassion and clarity.

                Comparative religious scholarship notes that Buddha Purnima bridges spiritual traditions by emphasizing universal ethical principles such as nonviolence and mindfulness.
                """,
            instructions: """
                [TIMELINE]
                Dawn: Meditate and recite Buddhist sutras.
                Morning: Offer flowers and incense at Buddha shrines.
                Afternoon: Engage in acts of charity and vegetarian meals.
                Evening: Participate in communal chanting.

                [CELEBRATION]
                Temples host processions, and devotees observe silence or meditation retreats.
                """,
            history: """
                Historical chronicles trace the celebration to early Buddhist sanghas that honored the Buddha’s life events on the Vaishakha full moon.

                Emperor Ashoka institutionalized public observances, spreading the festival across Asia.

                Today, Buddha Purnima remains a global symbol of peace and enlightenment.
                """),
        // MARK: - JYESHTHA

        AnnualRitual(
            name: "Vat Savitri Vrat",
            image: "savitri",
            month: .jyeshtha,
            approximateMonth: 5, approximateDay: 16,
            items: [
                RitualItem(
                    name: "Sacred Thread", reason: "Symbolizes marital fidelity and protection."),
                RitualItem(
                    name: "Banyan Tree Leaves", reason: "Represent longevity and stability."),
                RitualItem(name: "Fruits and Sweets", reason: "Offerings expressing gratitude."),
            ],
            significance: """
                The Mahabharata narrates the legend of Savitri and Satyavan, where Savitri’s unwavering devotion and wisdom persuaded Yama, the god of death, to restore her husband’s life. Vat Savitri Vrat symbolizes the triumph of virtue and determination over mortality.


                According to the Skanda Purana, the banyan tree represents eternal life and cosmic continuity. Worshipping it connects the devotee to the principle of immortality embedded in nature.

                Dharmashastra texts interpret the ritual as a reaffirmation of marital commitment and social harmony, emphasizing the ethical responsibilities of family life.
                """,
            instructions: """
                [TIMELINE]
                Morning: Married women fast and bathe before sunrise.
                Midday: Circumambulate a banyan tree while tying sacred threads.
                Evening: Recite the Savitri-Satyavan story and perform Aarti.

                [CELEBRATION]
                Women dress in traditional attire, exchange blessings, and distribute prasad.
                """,
            history: """
                The ritual originated in ancient agrarian societies that revered trees as embodiments of divine energy.

                Classical Sanskrit literature popularized Savitri as an icon of ideal devotion.

                The festival remains a cornerstone of marital rites in many regions of India.
                """),

        AnnualRitual(
            name: "Ganga Dussehra",
            image: "ganga",
            month: .jyeshtha,
            approximateMonth: 5, approximateDay: 25,
            items: [
                RitualItem(name: "Sacred Water", reason: "Represents purification and renewal."),
                RitualItem(name: "Flowers", reason: "Offerings to the river goddess."),
                RitualItem(name: "Incense", reason: "Symbolizes reverence and devotion."),
            ],
            significance: """
                The Ramayana and Puranas recount that Ganga descended to Earth through the penance of King Bhagiratha to liberate his ancestors. Ganga Dussehra commemorates this cosmic event and the cleansing power of sacred waters.


                According to the Brahma Purana, bathing in the Ganges during this period absolves ten forms of sin, aligning the devotee with spiritual purity.

                Environmental interpretations highlight the festival’s role in fostering reverence for natural resources and ecological balance.
                """,
            instructions: """
                [TIMELINE]
                Dawn: Take ritual baths in sacred rivers.
                Morning: Offer flowers and prayers to Goddess Ganga.
                Evening: Light lamps and float them on water.

                [CELEBRATION]
                Pilgrims gather at riverbanks for communal worship and charity.
                """,
            history: """
                Ancient inscriptions indicate that river worship predates classical Hinduism.

                Medieval pilgrimage traditions established Ganga Dussehra as a major festival.

                The ritual continues to symbolize purification and collective devotion.
                """),

        // MARK: - Ashadha

        AnnualRitual(
            name: "Guru Purnima",
            image: "guru",
            month: .ashadha,
            approximateMonth: 7, approximateDay: 29,
            items: [
                RitualItem(name: "Flowers", reason: "Express reverence and gratitude to the Guru."),
                RitualItem(name: "Incense", reason: "Symbolizes purification of the mind."),
                RitualItem(
                    name: "Sacred Scriptures", reason: "Represent the transmission of knowledge."),
            ],
            significance: """
                According to the Mahabharata and various Puranic traditions, Guru Purnima honors Sage Vyasa, the compiler of the Vedas and author of the Mahabharata. It celebrates the Guru as the living embodiment of divine wisdom and the bridge between ignorance and enlightenment.


                The Upanishads describe the Guru as the dispeller of darkness (Gu) and revealer of light (Ru). Observing this day reinforces the sacred bond between teacher and disciple, emphasizing humility and receptivity as prerequisites for spiritual growth.

                Yogic philosophy interprets Guru Purnima as a moment when cosmic energies favor learning and introspection. It is considered an auspicious time for renewing vows of discipline and devotion.
                """,
            instructions: """
                [TIMELINE]
                Dawn: Perform meditation and offer prayers to one's Guru.
                Morning: Recite Guru Stotras and read sacred texts.
                Afternoon: Offer flowers and symbolic gifts to teachers.
                Evening: Participate in satsang and communal chanting.

                [CELEBRATION]
                Ashrams and temples host discourses and spiritual gatherings. Disciples express gratitude through service and charity.
                """,
            history: """
                Historical accounts trace Guru Purnima to ancient Vedic gurukul traditions where students honored their teachers annually.

                Buddhist and Jain communities also adopted the festival, broadening its philosophical significance.

                Over centuries, Guru Purnima evolved into a universal celebration of knowledge and mentorship across Indian spiritual systems.
                """),

        // MARK: - Shravana

        // MARK: - SHRAVANA

        AnnualRitual(
            name: "Shravana Somvar Vrat",
            image: "somvar",
            month: .shravana,
            approximateMonth: 8, approximateDay: 10,
            items: [
                RitualItem(name: "Bilva Leaves", reason: "Sacred offering beloved to Lord Shiva."),
                RitualItem(name: "Milk", reason: "Used in Abhishekam for purification."),
                RitualItem(
                    name: "Water", reason: "Represents the sacred Ganga flowing from Shiva’s locks."
                ),
            ],
            significance: """
                The Shiva Purana identifies the month of Shravana as uniquely sacred to Lord Shiva, when cosmic energies are believed to be especially receptive to devotion. Observing fasts on Mondays aligns the devotee with Shiva’s ascetic discipline and inner stillness.


                Vedic symbolism associates Shiva with transformation and dissolution of ego. Worship during this month emphasizes purification of the mind and transcendence of worldly attachments.

                Tantric traditions interpret Shravana rituals as activating inner consciousness through mantra and meditation, guiding seekers toward liberation.
                """,
            instructions: """
                [TIMELINE]
                Morning: Observe fasting and perform Shiva Abhishekam with milk and water.
                Afternoon: Chant “Om Namah Shivaya” and meditate.
                Evening: Conduct Aarti and offer Bilva leaves.

                [CELEBRATION]
                Devotees visit Shiva temples and engage in collective chanting.
                """,
            history: """
                Ancient Shaiva communities institutionalized Shravana fasts as seasonal spiritual discipline.

                Medieval Bhakti saints popularized public Shiva worship during this month.

                The tradition symbolizes cyclical renewal and ascetic devotion.
                """),

        AnnualRitual(
            name: "Nag Panchami",
            image: "nag",
            month: .shravana,
            approximateMonth: 8, approximateDay: 17,
            items: [
                RitualItem(name: "Milk", reason: "Offered symbolically to serpent deities."),
                RitualItem(name: "Turmeric", reason: "Represents auspicious protection."),
                RitualItem(name: "Flowers", reason: "Express reverence."),
            ],
            significance: """
                The Mahabharata recounts the cosmic role of serpents (Nagas) as guardians of subterranean realms and cosmic balance. Nag Panchami honors these beings and acknowledges humanity’s relationship with nature.


                According to the Brahma Vaivarta Purana, serpent worship protects communities from misfortune and symbolizes respect for ecological harmony.

                Anthropological interpretations link the ritual to ancient fertility cults and agrarian symbolism.
                """,
            instructions: """
                [TIMELINE]
                Morning: Draw serpent symbols and offer milk and flowers.
                Afternoon: Recite Nag mantras.
                Evening: Perform household Aarti.

                [CELEBRATION]
                Rural communities emphasize protection of snakes and environmental awareness.
                """,
            history: """
                Archaeological evidence shows serpent worship predates Vedic civilization.

                Classical Hinduism integrated Nag rituals into mainstream practice.

                The festival preserves ecological reverence and mythological continuity.
                """),

        AnnualRitual(
            name: "Raksha Bandhan",
            image: "rakhi",
            month: .shravana,
            approximateMonth: 8, approximateDay: 28,
            items: [
                RitualItem(name: "Rakhi Thread", reason: "Symbolizes protection and bond."),
                RitualItem(name: "Sweets", reason: "Express joy and goodwill."),
                RitualItem(name: "Lamp", reason: "Represents auspicious blessing."),
            ],
            significance: """
                Puranic legends associate Raksha Bandhan with divine protection, including Indra’s wife tying a protective thread before battle. The ritual symbolizes sacred bonds of duty and care.


                Dharmic philosophy interprets the thread as a reminder of social responsibility and mutual support.

                Cultural studies emphasize the festival’s role in strengthening familial and communal ties.
                """,
            instructions: """
                [TIMELINE]
                Morning: Sisters tie Rakhi on brothers’ wrists.
                Afternoon: Exchange gifts and blessings.
                Evening: Perform family Aarti.

                [CELEBRATION]
                Families gather for feasts and rituals.
                """,
            history: """
                Medieval chronicles document Raksha Bandhan as both familial and political ritual.

                The practice evolved into a universal celebration of protective relationships.

                It continues to reinforce social cohesion.
                """),

        // MARK: - Bhadrapada

        // MARK: - BHADRAPADA

        AnnualRitual(
            name: "Ganesh Chaturthi",
            image: "ganesh",
            month: .bhadrapada,
            approximateMonth: 9, approximateDay: 14,
            items: [
                RitualItem(
                    name: "Ganesh Idol", reason: "Represents the manifest presence of Lord Ganesha."
                ),
                RitualItem(
                    name: "Modak", reason: "Symbolizes the sweetness of spiritual knowledge."),
                RitualItem(name: "Durva Grass", reason: "Sacred offering beloved to Ganesha."),
            ],
            significance: """
                According to the Ganapati Atharvashirsha and the Mudgala Purana, Lord Ganesha embodies the primordial sound “Om,” representing the unity of existence. Ganesh Chaturthi celebrates the manifestation of wisdom and the removal of obstacles.


                Philosophical commentaries interpret Ganesha’s form symbolically: the elephant head represents expansive intelligence, while the broken tusk signifies sacrifice in pursuit of knowledge.

                The festival emphasizes the integration of intellect and devotion, guiding practitioners toward clarity and humility.
                """,
            instructions: """
                [TIMELINE]
                Day 1: Install the Ganesh idol and perform Prana Pratishtha.
                Daily: Offer Modaks, chant Ganesh mantras, and perform Aarti.
                Final Day: Conduct immersion (Visarjan) in water.

                [CELEBRATION]
                Homes and communities host devotional singing and cultural programs.
                """,
            history: """
                Historical records credit the Maratha ruler Shivaji and later Bal Gangadhar Tilak with popularizing public celebrations.

                The festival evolved into a symbol of cultural unity and resistance during colonial times.

                Today it remains a vibrant expression of communal devotion.
                """),

        // MARK: - Ashwin

        // MARK: - ASHWIN

        AnnualRitual(
            name: "Sharad Navratri",
            image: "durga",
            month: .ashwin,
            approximateMonth: 10, approximateDay: 11,
            items: [
                RitualItem(name: "Kalash", reason: "Symbolizes divine cosmic energy."),
                RitualItem(name: "Coconut", reason: "Represents purity and surrender."),
                RitualItem(name: "Garlands", reason: "Express devotion to the Goddess."),
            ],
            significance: """
                The Devi Bhagavata Purana describes Sharad Navratri as the cosmic reenactment of the Goddess Durga’s victory over Mahishasura, symbolizing the triumph of higher consciousness over ignorance. Each of the nine nights represents progressive spiritual purification.


                Tantric scriptures interpret the festival as awakening dormant Kundalini energy. Devotees meditate on the nine forms of the Goddess to harmonize internal energies.

                Philosophical traditions regard Navratri as a cyclical reminder of the eternal battle between Dharma and Adharma within human consciousness.
                """,
            instructions: """
                [TIMELINE]
                Day 1: Perform Ghatasthapana and invoke Goddess Durga.
                Days 1–9: Daily fasting, chanting, and Aarti.
                Day 8/9: Conduct Kanya Pujan and special offerings.

                [CELEBRATION]
                Communities organize devotional music, dance, and cultural rituals.
                """,
            history: """
                Ancient Shakta traditions institutionalized autumn Navratri as a harvest and spiritual festival.

                Regional variations such as Durga Puja in Bengal developed elaborate artistic expressions.

                The festival remains a central pillar of Goddess worship.
                """),

        AnnualRitual(
            name: "Dussehra (Vijayadashami)",
            image: "dussehra",
            month: .ashwin,
            approximateMonth: 10, approximateDay: 20,
            items: [
                RitualItem(name: "Effigy of Ravana", reason: "Symbolizes destruction of evil."),
                RitualItem(name: "Sacred Weapons", reason: "Represent righteous power."),
                RitualItem(name: "Flowers", reason: "Offerings of victory and gratitude."),
            ],
            significance: """
                The Ramayana narrates Vijayadashami as the day Lord Rama defeated Ravana, symbolizing the victory of righteousness. The festival teaches the inevitability of moral justice.


                The Devi Mahatmya associates the day with Durga’s final victory over demonic forces, reinforcing the theme of cosmic balance.

                Ethical philosophy interprets Dussehra as a reminder to conquer inner vices through discipline and wisdom.
                """,
            instructions: """
                [TIMELINE]
                Morning: Perform victory prayers and weapon worship.
                Afternoon: Community processions and rituals.
                Evening: Burn effigies of Ravana and celebrate.

                [CELEBRATION]
                Public performances of the Ramayana (Ramlila) are staged.
                """,
            history: """
                Classical Sanskrit drama incorporated Dussehra themes into royal ceremonies.

                Medieval kingdoms used the festival to display martial readiness.

                It continues to symbolize collective triumph and renewal.
                """),

        // MARK: - Kartika

        // MARK: - KARTIKA

        AnnualRitual(
            name: "Diwali (Deepavali)",
            image: "diwali",
            month: .kartika,
            approximateMonth: 11, approximateDay: 8,
            items: [
                RitualItem(
                    name: "Oil Lamps (Diyas)",
                    reason: "Symbolize the victory of light over darkness."),
                RitualItem(name: "Lakshmi Idol", reason: "Represents prosperity and abundance."),
                RitualItem(name: "Incense", reason: "Purifies the environment and mind."),
            ],
            significance: """
                The Skanda Purana and Padma Purana describe Diwali as the cosmic celebration of light dispelling spiritual ignorance. It commemorates the return of Lord Rama to Ayodhya and the restoration of righteous order.


                Vaishnava traditions associate the festival with Goddess Lakshmi emerging from the cosmic ocean during Samudra Manthan, symbolizing prosperity born from disciplined effort.

                Philosophical interpretations view Diwali as the illumination of inner consciousness, encouraging the devotee to transcend material darkness through wisdom.
                """,
            instructions: """
                [TIMELINE]
                Morning: Clean and decorate the home as a symbol of inner purification.
                Evening: Perform Lakshmi Puja and light rows of diyas.
                Night: Offer prayers and share sweets.

                [CELEBRATION]
                Families gather, exchange gifts, and illuminate their surroundings.
                """,
            history: """
                Ancient agrarian societies celebrated autumn harvests with light rituals.

                Classical Hindu kingdoms institutionalized Diwali as a royal festival.

                Over centuries, it evolved into a universal symbol of renewal.
                """),

        AnnualRitual(
            name: "Karwa Chauth",
            image: "karwa",
            month: .kartika,
            approximateMonth: 10, approximateDay: 29,
            items: [
                RitualItem(name: "Sieve", reason: "Used symbolically during moon sighting."),
                RitualItem(name: "Lamp", reason: "Represents marital devotion."),
                RitualItem(name: "Water Vessel", reason: "Symbolizes life and continuity."),
            ],
            significance: """
                Dharmic literature interprets Karwa Chauth as a vow of marital solidarity, emphasizing sacrifice and mutual responsibility.


                Folkloric narratives portray the ritual as strengthening emotional bonds and spiritual partnership.

                Social philosophy recognizes the festival’s role in preserving familial harmony.
                """,
            instructions: """
                [TIMELINE]
                Sunrise: Begin day-long fast.
                Evening: Perform moon worship and break fast.

                [CELEBRATION]
                Married women gather for communal rituals and storytelling.
                """,
            history: """
                Historical accounts trace the festival to ancient warrior communities.

                It evolved into a widespread marital observance.

                The ritual continues to symbolize devotion and unity.
                """),

        // MARK: - MARGASHIRSHA

        AnnualRitual(
            name: "Gita Jayanti",
            image: "gita",
            month: .margashirsha,
            approximateMonth: 12, approximateDay: 20,
            items: [
                RitualItem(
                    name: "Bhagavad Gita", reason: "Represents the scripture of divine wisdom."),
                RitualItem(name: "Lamp", reason: "Symbolizes enlightenment and knowledge."),
                RitualItem(name: "Flowers", reason: "Offerings of reverence to Krishna."),
            ],
            significance: """
                The Mahabharata records Gita Jayanti as the day Lord Krishna imparted the Bhagavad Gita to Arjuna on the battlefield of Kurukshetra. This dialogue encapsulates the synthesis of Karma, Bhakti, and Jnana yoga.


                Vedantic philosophy interprets the Gita as a universal manual for righteous action without attachment to outcomes. Observing this day renews commitment to ethical living and spiritual discipline.

                Comparative theology regards the Gita as one of humanity’s greatest philosophical texts, bridging metaphysics and practical ethics.
                """,
            instructions: """
                [TIMELINE]
                Morning: Recite selected chapters of the Bhagavad Gita.
                Afternoon: Attend discourses and study sessions.
                Evening: Perform Aarti and meditation.

                [CELEBRATION]
                Temples and institutions organize readings and philosophical discussions.
                """,
            history: """
                Traditional accounts place the origin of Gita Jayanti in early Vaishnava communities.

                Medieval scholars institutionalized public recitations.

                The observance continues to inspire global philosophical engagement.
                """),

        AnnualRitual(
            name: "Vivah Panchami",
            image: "ram",
            month: .margashirsha,
            approximateMonth: 12, approximateDay: 13,
            items: [
                RitualItem(
                    name: "Turmeric", reason: "Auspicious purification marking joyous union."),
                RitualItem(
                    name: "Flowers", reason: "Represent beauty and devotion on the sacred occasion."
                ),
                RitualItem(name: "Lamp", reason: "Illuminates the divine marriage ceremony."),
            ],
            significance: """
                The Valmiki Ramayana records Vivah Panchami as the day Lord Rama wed Sita Devi in Mithila, witnessed by sages and celestial beings. The divine union symbolizes the perfect bond between Dharma and devotion.

                According to Vaishnava philosophy, the marriage of Rama and Sita represents cosmic harmony between the masculine principle of righteousness and the feminine principle of pure devotion and grace.

                Spiritual commentaries describe this day as exceptionally auspicious for weddings and for renewing marital commitments, as the divine couple's union embodies ideal love guided by ethical values.
                """,
            instructions: """
                [TIMELINE]
                Morning: Perform Rama-Sita Puja in homes and temples.
                Midday: Recite the Sita Swayamvar passages from the Ramayana.
                Evening: Conduct special Aarti and distribute prasad.

                [CELEBRATION]
                Temples enact dramatic recreations of the divine wedding. Devotees offer garlands and seek blessings for harmony in their own marriages.
                """,
            history: """
                Ancient Vaishnava communities in Mithila institutionalized commemoration of the divine wedding.

                Medieval Bhakti poets like Tulsidas celebrated the occasion in devotional verse.

                The festival preserves reverence for sacred marriage as a spiritual and social foundation.
                """),

        AnnualRitual(
            name: "Mokshada Ekadashi",
            image: "ekadashi",
            month: .margashirsha,
            approximateMonth: 12, approximateDay: 19,
            items: [
                RitualItem(
                    name: "Tulsi Leaves",
                    reason: "Sacred to Vishnu — essential for this Ekadashi worship."),
                RitualItem(name: "Lamp", reason: "Symbolizes divine presence and liberation."),
                RitualItem(
                    name: "Sacred Water", reason: "Used for purification before Vishnu Puja."),
            ],
            significance: """
                The Brahmanda Purana identifies Mokshada Ekadashi as the day Lord Krishna delivered the Bhagavad Gita to Arjuna. Observing this Ekadashi is believed to grant liberation (Moksha) to both the devotee and deceased ancestors.

                Vaishnava theology holds that fasting and prayer on this day dissolve accumulated karmic debts across many lifetimes.

                Philosophical commentaries interpret this observance as an affirmation that liberation is accessible through sincere devotion and ethical discipline.
                """,
            instructions: """
                [TIMELINE]
                Sunrise: Begin fasting and perform Vishnu Puja with Tulsi leaves.
                Daytime: Chant Vishnu Sahasranama and recite Gita passages.
                Evening: Perform Aarti and offer ancestral prayers.
                Next Morning: Break fast with prayer and charity.

                [CELEBRATION]
                Temples conduct special Vishnu worship and Gita recitations throughout the day.
                """,
            history: """
                Ancient Vaishnava sruti traditions codified Mokshada Ekadashi as the most potent fasting day of the year.

                Its identity with Gita Jayanti deepened its spiritual significance across traditions.

                The observance unites devotion to Lord Vishnu with the philosophical teachings of the Bhagavad Gita.
                """),

        // MARK: - PAUSHA

        AnnualRitual(
            name: "Pausha Putrada Ekadashi",
            image: "ekadashi",
            month: .pausha,
            approximateMonth: 12, approximateDay: 30,
            items: [
                RitualItem(name: "Tulsi Leaves", reason: "Sacred offering to Lord Vishnu."),
                RitualItem(name: "Lamp", reason: "Represents divine presence."),
                RitualItem(name: "Fruits", reason: "Consumed during fasting."),
            ],
            significance: """
                The Padma Purana describes Putrada Ekadashi as a sacred observance dedicated to Lord Vishnu for the blessing of progeny and family well-being. The ritual symbolizes continuity of lineage and preservation of Dharma.


                Vaishnava theology interprets fasting on Ekadashi as purification of the body and mind, strengthening devotion and discipline.

                Philosophical commentary views the ritual as affirming responsibility toward future generations.
                """,
            instructions: """
                [TIMELINE]
                Sunrise: Begin fasting and perform Vishnu Puja.
                Daytime: Chant Vishnu Sahasranama and meditate.
                Next Morning: Break fast with prayers.

                [CELEBRATION]
                Devotees engage in charity and scripture recitation.
                """,
            history: """
                Ancient Vaishnava communities institutionalized Ekadashi fasting cycles.

                Puranic literature codified its observance.

                The tradition remains central to household spirituality.
                """),

        AnnualRitual(
            name: "Saphala Ekadashi",
            image: "ekadashi1",
            month: .pausha,
            approximateMonth: 11, approximateDay: 12,
            items: [
                RitualItem(name: "Incense", reason: "Purifies ritual space."),
                RitualItem(name: "Flowers", reason: "Offerings of devotion."),
                RitualItem(name: "Lamp", reason: "Symbolizes enlightenment."),
            ],
            significance: """
                The Bhavishya Purana interprets Saphala Ekadashi as a ritual ensuring success and fulfillment. Observance aligns human effort with divine grace.


                Devotional traditions emphasize introspection and repentance.

                Ethical philosophy regards it as renewal of intention.
                """,
            instructions: """
                [TIMELINE]
                Observe fasting and perform Vishnu worship.
                Engage in meditation and chanting.

                [CELEBRATION]
                Quiet household observance with prayer.
                """,
            history: """
                Medieval devotional movements reinforced Ekadashi cycles.

                The ritual persists as personal spiritual discipline.
                """),

        AnnualRitual(
            name: "Pausha Purnima",
            image: "purnima",
            month: .pausha,
            approximateMonth: 1, approximateDay: 3,
            items: [
                RitualItem(name: "Lamp", reason: "Symbolizes the full moon's divine illumination."),
                RitualItem(
                    name: "Sacred Water", reason: "Ritual bathing in rivers on the full moon."),
                RitualItem(name: "Sesame Seeds", reason: "Donated as charity for ancestral merit."),
            ],
            significance: """
                The Skanda Purana describes Pausha Purnima as the concluding full moon of winter, sacred to both Vishnu and the sun. Ritual bathing on this day purifies accumulated sins of the waning year and initiates the period of Uttarayana.

                Pilgrimage traditions regard Pausha Purnima as the formal beginning of the Kumbh Mela cycle at Prayagraj, attracting millions of devotees to bathe at the Triveni Sangam.

                Philosophical commentaries interpret the full winter moon as symbolizing unwavering awareness in the darkness of ignorance — a call to maintain spiritual clarity through austere conditions.
                """,
            instructions: """
                [TIMELINE]
                Dawn: Take ritual bath in sacred rivers or water bodies.
                Morning: Offer prayers to the sun and Vishnu.
                Afternoon: Donate sesame, food, and clothing to the needy.
                Evening: Light lamps and perform full-moon meditation.

                [CELEBRATION]
                Pilgrims gather at Prayagraj, Varanasi, and other sacred river confluences for communal worship.
                """,
            history: """
                Ancient pilgrimage traditions placed special emphasis on winter full-moon bathing for purification.

                The Kumbh Mela association with Pausha Purnima dates to classical Puranic records.

                The festival continues to draw one of the world's largest peaceful gatherings of devotees.
                """),

        // MARK: - Magha

        // MARK: - MAGHA

        AnnualRitual(
            name: "Makar Sankranti",
            image: "sankranti",
            month: .magha,
            approximateMonth: 1, approximateDay: 14,
            items: [
                RitualItem(name: "Sesame Seeds", reason: "Symbolize warmth and vitality."),
                RitualItem(name: "Jaggery", reason: "Represents sweetness and harmony."),
                RitualItem(name: "Sacred Water", reason: "Used for ritual purification."),
            ],
            significance: """
                Vedic astronomy identifies Makar Sankranti as the sun’s transition into Capricorn, marking the beginning of Uttarayana, an auspicious half of the solar year. The festival symbolizes cosmic renewal and the triumph of light.


                According to the Mahabharata, Bhishma awaited Uttarayana to relinquish his mortal body, associating the period with spiritual ascent.

                Philosophical traditions interpret the festival as alignment of human life with celestial rhythms, promoting discipline and gratitude.
                """,
            instructions: """
                [TIMELINE]
                Dawn: Take ritual baths in rivers.
                Morning: Offer prayers to Surya (Sun God).
                Daytime: Donate sesame and food.

                [CELEBRATION]
                Communities celebrate with feasts and kite flying.
                """,
            history: """
                Ancient solar cults institutionalized Sankranti rituals.

                Agrarian societies linked it to harvest cycles.

                It remains a pan-Indian festival of renewal.
                """),

        AnnualRitual(
            name: "Magha Purnima",
            image: "purnima",
            month: .magha,
            approximateMonth: 2, approximateDay: 1,
            items: [
                RitualItem(name: "Lamp", reason: "Symbolizes spiritual illumination."),
                RitualItem(name: "Flowers", reason: "Offerings of devotion."),
                RitualItem(name: "Sacred Water", reason: "Used for purification rituals."),
            ],
            significance: """
                Puranic literature regards Magha Purnima as a culmination of winter austerities, emphasizing purification and charity.


                Pilgrimage traditions associate the full moon with sacred gatherings at river confluences.

                Philosophical commentary highlights collective devotion and humility.
                """,
            instructions: """
                Perform ritual bathing and offer prayers.
                Engage in charity and meditation.

                [CELEBRATION]
                Pilgrims gather at sacred sites.
                """,
            history: """
                Historical pilgrimage fairs institutionalized Magha Purnima.

                It continues to symbolize communal purification.
                """),

        AnnualRitual(
            name: "Vasant Panchami",
            image: "navratri",
            month: .magha,
            approximateMonth: 1, approximateDay: 23,
            items: [
                RitualItem(
                    name: "Yellow Flowers",
                    reason: "Represent spring, wisdom, and Goddess Saraswati."),
                RitualItem(
                    name: "Pen and Books", reason: "Offered to Saraswati as tools of knowledge."),
                RitualItem(name: "Yellow Sweets", reason: "Symbolize the sweetness of learning."),
            ],
            significance: """
                The Skanda Purana and Devi Bhagavata describe Vasant Panchami as the day of Goddess Saraswati's manifestation — the divine embodiment of knowledge, arts, music, and wisdom. The yellow color signifies the blooming of mustard fields and the arrival of spring.

                Vedic educational traditions hold this day as supremely auspicious for beginning the study of scriptures, arts, and sciences. Children perform their first letters (Vidyarambha) on this occasion.

                Philosophical traditions interpret Saraswati worship as cultivating clarity of mind and purity of speech — prerequisites for accessing higher knowledge and spiritual truth.
                """,
            instructions: """
                [TIMELINE]
                Morning: Perform Saraswati Puja dressed in yellow attire.
                Daytime: Children write first letters and students offer books and instruments at altars.
                Evening: Participate in cultural performances celebrating arts.

                [CELEBRATION]
                Schools, colleges, and temples host Saraswati worship with music and scholarly competitions.
                """,
            history: """
                Vedic gurukul traditions institutionalized Vasant Panchami as the ideal day for educational initiation.

                Medieval kingdoms dedicated this day to royal patronage of arts and learning.

                The festival remains central to both educational and spiritual communities across India.
                """),

        AnnualRitual(
            name: "Kumbh Mela Snan",
            image: "ganga",
            month: .magha,
            approximateMonth: 1, approximateDay: 18,
            items: [
                RitualItem(
                    name: "Sacred Water",
                    reason: "The act of bathing itself is the primary offering."),
                RitualItem(
                    name: "Saffron Cloth", reason: "Worn by renunciants during sacred dips."),
                RitualItem(
                    name: "Sesame and Flowers", reason: "Offered to the river as thanksgiving."),
            ],
            significance: """
                The Atharva Veda and Skanda Purana describe the Kumbh Mela as arising from the cosmic churning (Samudra Manthan), when drops of the nectar of immortality fell at four sacred sites in India. Bathing during this alignment is believed to grant liberation from the cycle of rebirth.

                Astrological texts specify precise planetary configurations — especially Jupiter entering Aquarius — that amplify the spiritual merit of sacred bathing during the Magha month at Prayagraj.

                Philosophical traditions interpret the mass gathering as a living embodiment of Sanatan Dharma's unbroken continuity — the largest peaceful assembly of humanity centered on a shared spiritual aspiration.
                """,
            instructions: """
                [TIMELINE]
                Pre-dawn: Proceed to the sacred river before sunrise.
                Dawn (Amrit Snan): Take the sacred ritual dip precisely at sunrise.
                Morning: Offer prayers, sesame, and flowers to the river.
                Afternoon: Attend discourses of saints and sages gathered at the site.

                [CELEBRATION]
                Millions of pilgrims gather at Prayagraj, Haridwar, Nashik, or Ujjain depending on the year. Monastic orders perform grand processions (Shahi Snan).
                """,
            history: """
                Ancient Puranic records describe the origins of Kumbh Mela in the cosmic myth of the nectar of immortality.

                Chinese traveler Xuanzang recorded massive Hindu bathing fairs at Prayagraj in the 7th century CE.

                Recognized by UNESCO as an intangible cultural heritage, Kumbh Mela is the largest peaceful gathering in human history.
                """),

        // MARK: - Phalguna

        // MARK: - PHALGUNA

        AnnualRitual(
            name: "Maha Shivaratri",
            image: "shivratri",
            month: .phalguna,
            approximateMonth: 2, approximateDay: 15,
            items: [
                RitualItem(
                    name: "Bilva Leaves",
                    reason: "Sacred offering symbolizing purity and surrender."),
                RitualItem(name: "Milk", reason: "Used in Abhishekam to cool and purify."),
                RitualItem(name: "Water", reason: "Represents the Ganga flowing from Shiva."),
            ],
            significance: """
                The Shiva Purana describes Maha Shivaratri as the cosmic night when Shiva performs the Tandava, symbolizing creation, preservation, and dissolution. Observing this night represents transcendence of ignorance and union with ultimate consciousness.


                Yogic philosophy interprets Shivaratri as a moment when planetary alignments enhance spiritual receptivity. Wakeful meditation symbolizes awareness overcoming inertia.

                Tantric traditions regard the night as awakening dormant spiritual energy and dissolving ego boundaries.
                """,
            instructions: """
                [TIMELINE]
                Sunset: Begin fasting and purification.
                Night: Perform four rounds of Shiva Abhishekam and chant mantras.
                Dawn: Break fast after final prayers.

                [CELEBRATION]
                Temples remain open all night for worship and meditation.
                """,
            history: """
                Ancient Shaiva ascetics institutionalized night-long vigils.

                Medieval Bhakti movements expanded communal celebrations.

                The festival remains central to Shaiva spirituality.
                """),

        AnnualRitual(
            name: "Holi",
            image: "holi",
            month: .phalguna,
            approximateMonth: 3, approximateDay: 4,
            items: [
                RitualItem(name: "Colors", reason: "Symbolize joy and unity."),
                RitualItem(name: "Bonfire Wood", reason: "Used for Holika Dahan purification."),
                RitualItem(name: "Sweets", reason: "Express celebration and goodwill."),
            ],
            significance: """
                The Bhagavata Purana recounts the legend of Prahlada and Holika, symbolizing devotion triumphing over tyranny. Holi represents destruction of negativity and renewal of life.


                Vaishnava traditions associate the festival with Krishna’s playful divine love, expressing spiritual joy.

                Philosophical interpretations view Holi as dissolving social boundaries and celebrating universal unity.
                """,
            instructions: """
                [TIMELINE]
                Eve: Perform Holika Dahan bonfire ritual.
                Next Day: Celebrate with colors and communal gatherings.

                [CELEBRATION]
                Music, dance, and feasting mark the festival.
                """,
            history: """
                Ancient spring festivals merged with Puranic narratives.

                Medieval Bhakti poetry popularized Holi symbolism.

                It remains a global celebration of renewal.
                """),

        // MARK: - MONTHLY RECURRING RITUALS

        AnnualRitual(
            name: "Ekadashi Vrat",
            image: "ekadashi",
            month: .phalguna,
            approximateMonth: 2, approximateDay: 27,
            items: [
                RitualItem(name: "Tulsi Leaves", reason: "Sacred to Lord Vishnu."),
                RitualItem(name: "Lamp", reason: "Represents devotion."),
                RitualItem(name: "Fruits", reason: "Consumed during fasting."),
            ],
            significance: """
                Vaishnava scriptures describe Ekadashi as purification of mind and senses. Regular observance strengthens discipline and devotion.


                Philosophical traditions interpret cyclical fasting as mastery over desire.
                """,
            instructions: """
                Observe fasting and perform Vishnu worship.
                Engage in meditation and charity.
                """,
            history: """
                Ekadashi cycles were codified in Puranic ritual calendars.

                They remain central to Vaishnava practice.
                """),

        AnnualRitual(
            name: "Purnima Pooja",
            image: "purnima",
            month: .phalguna,
            approximateMonth: 3, approximateDay: 3,
            items: [
                RitualItem(name: "Lamp", reason: "Symbolizes fullness and illumination."),
                RitualItem(name: "Flowers", reason: "Offerings of gratitude."),
            ],
            significance: """
                Full moon worship represents completeness and cosmic balance.


                Philosophical traditions link lunar cycles to emotional and spiritual rhythms.
                """,
            instructions: """
                Perform evening prayers and meditation.
                Offer lamps and flowers.
                """,
            history: """
                Lunar observances date back to early Vedic rituals.
                """),

        AnnualRitual(
            name: "Amavasya Pooja",
            image: "amavasya",
            month: .phalguna,
            approximateMonth: 2, approximateDay: 17,
            items: [
                RitualItem(name: "Oil Lamp", reason: "Guides ancestral spirits."),
                RitualItem(name: "Water", reason: "Used for ancestral offerings."),
            ],
            significance: """
                New moon rituals honor ancestors and acknowledge cyclical renewal.


                Philosophical traditions interpret darkness as potential for rebirth.
                """,
            instructions: """
                Perform ancestral offerings and quiet reflection.
                """,
            history: """
                Ancestral rites predate classical Hinduism and continue as household tradition.
                """),

    ]

}
