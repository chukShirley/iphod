defmodule Stations do

  def start_link do
    Agent.start_link fn -> build() end, name: __MODULE__
  end

  def identity(), do: Agent.get(__MODULE__, &(&1))
  def reading(n) when n |> is_integer, do: identity()[Integer.to_string(n)]
  def reading(n), do: identity()[n]

  def before(), do: [identity()["before"]["Minister"], identity()["before"]["All"]]
  def before("Minister"), do: identity()["before"]["Minister"]
  def before("All"), do: identity()["before"]["All"]
  def before(_), do: ""

  def afterStation(), do: [ identity()["after"]["All"] ]
  def afterStation("All"), do: identity()["after"]["All"]
  def afterStation(_), do: ""

  def station(n) when n |> is_integer, do: identity()[Integer.to_string(n)]
  def station(n), do: identity()[n]

  def for_elm(n) when n |> is_integer, do: for_elm(Integer.to_string(n))
  def for_elm(n) do
    st = station(n)
    [_, beforeMinister, _, beforeAll] = st["before"]
    [_, afterAll] = st["after"]
    %{  id: st["id"],
        beforeMinister: beforeMinister,
        beforeAll: beforeAll,
        afterAll: afterAll,
        title: st["title"],
        reading: LocalText.request("web", st["reading"]),
        images: st["images"],
        aboutImage: st["aboutImage"],
        reflections: st["reflections"],
        prayer: st["prayer"]
      }
  end

  def build() do
    %{
      "1" =>
        %{
          "id" => "1",
          "before" => [
            "Minister:",
            "We adore you, O Christ, and we bless you.",
            "All:", 
            "Because of your holy cross you have redeemed the world."

          ],
          "after" => [
            "All",
            "Lord Jesus, help us walk in your steps."
          ],
          "title" => "Jesus in the Garden of Gethsemane",
          "reading" => "Matthew 26:36-41",
          "images" => "FRa_Angelico_1450_fresco.jpg",
          "aboutImage" => "The Agony in the Garden, Fra Angelico, fresco, 1450",
          "reflections" => """
            Jesus was in agony. Grief and anguish came upon him. The sin of all mankind weighed on
            him heavily. But the greater his pain, the more fervently did he pray. Pain always remains
            a challenge to us. We feel left alone. We forget to pray, and break down. Some even take
            their lives. But if we turn to God, we grow spiritually strong and go out to help our fellow-
            beings in trouble. Jesus continues to suffer in his persecuted disciples. Pope Benedict XVI
            says that even in our times \the Church does not lack martyrs". Christ is in agony among
            us, and in our times.We pray for those who suffer. The mystery of Christian suffering is
            that it has a redemptive value. May the harassments that believers undergo complete in
            them the sufferings of Christ that bring
          """,
          "prayer" => """
            Lord Jesus, enable us to delve deeper into the great\mystery of evil" and our own contribution 
            to it. As sufferings came into human life through sin, it was your plan that humanity
            be saved from sin through suffering. May none of the little annoyances, humiliations, and
            frustrations that we undergo in our daily lives and the great shocks that take us by surprise,
            go to waste. Linked with your own agony, may the agonies we endure be acceptable to you
            and bring us hope.[4] Lord, teach us to be compassionate, not only to the hungry, thirsty,
            sick, or those in some special need, but also to those inclined to be rude, argumentative
            and hurtful. In this way, as you have helped us in all our troubles, we may in turn \comfort
            those who are in any affliction, with the comfort that we ourselves have received".
          """
        },
      "2" =>
        %{
          "id" => "2",
          "before" => [
            "Minister:",
            "We adore you, O Christ, and we bless you.",
            "All:", 
            "Because of your holy cross you have redeemed the world."

          ],
          "after" => [
            "All",
            "Lord Jesus, help us walk in your steps."
          ],
          "title" => "Jesus is betrayed by Judas and arrested",
          "reading" => "Mark 14:43-46",
          "images" => "Giotto-KissofJudas.jpg",
          "aboutImage" => "The Arrest of Christ / Kiss of Judas, Giotto, 1304",
          "reflections" => """
            It is one of his trusted friends that betrays Jesus, and with a kiss. The way Jesus confronted
            violence has a message for our times. Violence is suicidal, he tells Peter: it is not defeated
            by more violence, but by a superior spiritual energy that reaches out in the form of healing
            love. Jesus touches the High Priest's slave and heals him. The violent man today too may
            need a healing touch that comes from a love that transcends the immediate issues. In times
            of conflict between persons, ethnic and religious groups, nations, economic and political
            interests, Jesus says, confrontation and violence are not the answer, but love, persuasion
            and reconciliation. Even when we seem to fail in such efforts, we plant the seeds of peace
            which will bear fruit in due time. The rightness of our cause is our strength.
          """,
          "prayer" => """
            Lord Jesus, you consider us your friends, yet we notice traces of infidelity in ourselves. We
            acknowledge our transgressions. We are presumptuous at times and over-confident. And
            we fall. Let not avarice, lust or pride take us by surprise. How thoughtlessly do we fly
            after ephemeral satisfactions and untested ideas! Grant that we may not be tossed to and
            fro and carried about by every wind of doctrine. . . but speaking the truth in love, grow
            up in every way into Christ the head. May truth and sincerity of purpose be our strength.
            Restrain, Lord, our impetuosity in situations of violence, as you restrained Peter's impulsive
            character. Keep us unruffled in spirit before opposition and unfair treatment. Convince us
            that "A gentle answer quiets anger" in our families, and that "gentleness" combined with
            "wisdom" restores tranquillity in society. "Lord, make me an instrument of Your peace."
          """
        },
      "3" =>
        %{
          "id" => "3",
          "before" => [
            "Minister:",
            "We adore you, O Christ, and we bless you.",
            "All:", 
            "Because of your holy cross you have redeemed the world."

          ],
          "after" => [
            "All",
            "Lord Jesus, help us walk in your steps."
          ],
          "title" => "Jesus is condemned by the Sanhedrin",
          "reading" => "Luke 22:66-71",
          "images" => "ChristBeforeTheHighPriestGerardVanHonthorst_1590-1656.jpg",
          "aboutImage" => "Jesus before the High Priest. Gerard von Honthorst",
          "reflections" => """
            In every land, there have been innocent persons who suffered, people who died fighting for
            freedom, equality or justice. Those who struggle on behalf of God's little ones are promoting
            God's own work. For he presses for the rights of the weak and the oppressed. Whoever
            collaborates in this work, in the spirit of Jesus, brings hope to the oppressed and offers a
            corrective message to the evildoer himself. Jesus' manner of struggling for justice is not to
            rouse the collective anger of people against the opponent, so that they are led into forms
            of greater injustice. On the contrary, it is to challenge the foe with the rightness of one's
            cause and evoke the good will of the opponent in such a way that injustice is renounced
            through persuasion and a change of heart. Mahatma Gandhi brought this teaching of Jesus
            on non-violence into public life with amazing success.

          """,
          "prayer" => """
            Lord, often we judge others in haste, indifferent to actual realities and insensitive to people's
            feelings! We develop stratagems of self-justification and explain away the irresponsible
            manner in which we have dealt with "the other". Forgive us! When we are misjudged and
            ill-treated, Lord, give us the inner serenity and self-confidence that your Son manifested in
            the face of unjust treatment. Keep us from an aggressive response which goes against your
            Spirit. On the contrary, help us to bring your powerful word of forgiveness into situations
            of tension and anxiety, so that it may reveal its dynamic power in history. "In His will is
            our peace."
          """
        },
      "4" =>
        %{
          "id" => "4",
          "before" => [
            "Minister:",
            "We adore you, O Christ, and we bless you.",
            "All:", 
            "Because of your holy cross you have redeemed the world."

          ],
          "after" => [
            "All",
            "Lord Jesus, help us walk in your steps."
          ],
          "title" => "Jesus is denied by St. Peter",
          "reading" => "Matthew 26:69-75",
          "images" => "5-Caravaggio-Denial.jpg",
          "aboutImage" => "The Denial of Peter, Caravaggio",
          "reflections" => """
            Peter claimed to be strong, but he broke down before a servant girl. Human weakness takes
            us by surprise, and we collapse. That is why Jesus asks us to watch and pray. He urges
            self-renunciation and closeness to God. There is a rebellious "self" within us. We are often
            of "two minds", but we fail to recognize this inner inconsistency. Peter recognized it when
            his eyes met the eyes of Jesus, and he wept. Later, Thomas, encountering the Risen Lord,
            acknowledged his own faithlessness and believed. In the light of Christ, Paul became aware
            of the inconsistency within himself, and he overcame it with the Lord's help. Going deeper
            still, he discovered: "It is no longer I who live, but it is Christ who lives in me."
          """,
          "prayer" => """
            Lord, how easily do we allow a distance to grow between what we profess to be and what
            we really are! How often do we fail to carry out our own decisions, or even fulfil our most
            solemn promises! And as a result we often hesitate to make any permanent commitment,
            even to you! We confess that we have failed to bring into our life that inner discipline that
            is expected of any adult person and required for the success of any human endeavour. Give
            sturdiness to our inner determination; help us to bring every good work we have begun to
            a successful conclusion. Enable us to stand firm, as mature and fully convinced Christians,
            "in complete obedience to God's will".
          """
        },
      "5" =>
        %{
          "id" => "5",
          "before" => [
            "Minister:",
            "We adore you, O Christ, and we bless you.",
            "All:", 
            "Because of your holy cross you have redeemed the world."

          ],
          "after" => [
            "All",
            "Lord Jesus, help us walk in your steps."
          ],
          "title" => "Jesus is judged by Pontius Pilate Mark",
          "reading" => "Mark 15:1-5, 15",
          "images" => "1_trapped15.jpg",
          "aboutImage" => "",
          "reflections" => """
            It was not the rightness of an issue that mattered to Pilate, but his professional interests.
            Such an attitude did not help him, either in this case or in his later career. He was so
            unlike Jesus, whose inner rectitude made him fearless. Nor was Pilate interested in the
            truth. He walks away from Jesus exclaiming, "What is truth?" Such indifference to truth
            is not uncommon these days. People are often concerned about what gives immediate
            satisfaction. They are content with superficial answers. Decisions are made based not
            on principles of integrity, but on opportunistic considerations. Failing to make morally
            responsible options damages the vital interests of the human person, and of the human
            family. We pray that the "spiritual and ethical concepts" contained in the word of God will
            inspire the living norms of society in our times.
          """,
          "prayer" => """
            Lord, give us the courage to make responsible decisions when rendering a public service.
            Bring probity into public life and assist us to be true to our conscience. Lord, you are
            the source of all Truth. Guide us in our search for ultimate answers. Going beyond mere
            partial and incomplete explanations, may we search for what is permanently true, beautiful
            and good. Lord, keep us fearless before the "slings and arrows of outrageous fortune".
            When shadows grow deep on life's wearisome paths, and the dark night comes, enable us
            to hearken to the teaching of your Apostle Paul: "Be watchful, stand firm in your faith, be
            courageous, be strong."
          """
        },
      "6" =>
        %{
          "id" => "6",
          "before" => [
            "Minister:",
            "We adore you, O Christ, and we bless you.",
            "All:", 
            "Because of your holy cross you have redeemed the world."

          ],
          "after" => [
            "All",
            "Lord Jesus, help us walk in your steps."
          ],
          "title" => "Jesus is scourged at the pillar and crowned with thorns",
          "reading" => "John 19:1-3",
          "images" => "cranach_crownofthorns.jpg",
          "aboutImage" => "Lucas Cranach the Elder - c. 1510",
          "reflections" => """
            Inhumanity reaches new heights. Jesus is scourged and crowned with thorns. History is
            full of hatred and wars. Even today we witness acts of violence beyond belief: murder,
            violence to women and children, kidnapping, extortion, ethnic conflict, urban violence,
            physical and mental torture, violations of human rights. Jesus continues to suffer when
            believers are persecuted, when justice is distorted in court, corruption gets rooted, unjust
            structures grind the poor, minorities are suppressed, refugees and migrants are ill-treated.
            Jesus' garments are pulled away when the human person is put to shame on the screen,
            when women are compelled to humiliate themselves, when slum children go round the
            streets picking up crumbs. Who are the guilty? Let us not point a finger at others, for we
            ourselves may have contributed a share to these forms of inhumanity.
          """,
          "prayer" => """
            Lord Jesus, we know that it is you who suffer when we cause pain to each other and we
            remain indifferent. Your heart went out in compassion when you saw the crowds "harrassed
            and helpless, like sheep without a shepherd". Give me eyes that notice the needs of the
            poor and a heart that reaches out in love. "Give me the strength to make my love fruitful
            in service."Most of all, may we share with the indigent your "word" of hope, your assurance
            of care. May "zeal for your house" burn in us like a fire. Help us to bring the sunshine of
            your joy into the lives of those who are trudging the path of despair.
          """
        },
      "7" =>
        %{
          "id" => "7",
          "before" => [
            "Minister:",
            "We adore you, O Christ, and we bless you.",
            "All:", 
            "Because of your holy cross you have redeemed the world."

          ],
          "after" => [
            "All",
            "Lord Jesus, help us walk in your steps."
          ],
          "title" => "Jesus Bears the Cross",
          "reading" => "John 19:6, 15-17",
          "images" => "bosch_kruisdraging_gent_grt.jpg",
          "aboutImage" => "Jheronimus Bosch - c. 1510",
          "reflections" => """
            Jesus, at whose name every knee in heaven and earth bends, is made an object of fun. We
            are shocked to see to what levels of brutality human beings can sink. Jesus is humiliated
            in new ways even today: when things that are most Holy and Profound in the Faith are
            being trivialized; the sense of the sacred is allowed to erode; the religious sentiment is
            classified among unwelcome leftovers of antiquity. Everything in public life risks being
            desacralized: persons, places, pledges, prayers, practices, words, sacred writings, religious
            formulae, symbols, ceremonies. Our life together is being increasingly secularized. Religious
            life grows diffident. Thus we see the most momentous matters placed among trifles, and
            trivialities glorified. Values and norms that held societies together and drew people to
            higher ideals are laughed at and thrown overboard. Jesus continues to be ridiculed!
          """,
          "prayer" => """
            We have faith, Lord, but not enough. Help us to have more. May we never question or
            mock serious things in life like a cynic. Allow us not to drift into the desert of godlessness.
            Enable us to perceive you in the gentle breeze, see you in street corners, love you in the
            unborn child. God, enable us to understand that on Tabor or Calvary, your Son is the Lord.
            Robed or stripped of his garments, he is the Saviour of the world. Make us attentive to his
            quiet presences: in his "word", in tabernacles, shrines, humble places, simple persons, the
            life of the poor, laughter of children, whispering pines, rolling hills, the tiniest living cell,
            the smallest atom, and the distant galaxies. May we watch with wonder as he walks on the
            waters of the Rhine and the Nile and the Tanganyika.
          """
        },
      "8" =>
        %{
          "id" => "8",
          "before" => [
            "Minister:",
            "We adore you, O Christ, and we bless you.",
            "All:", 
            "Because of your holy cross you have redeemed the world."

          ],
          "after" => [
            "All",
            "Lord Jesus, help us walk in your steps."
          ],
          "title" => "Jesus is helped by Simon the Cyrenian to carry the cross",
          "reading" => "Mark 15:21",
          "images" => "simon_of_cyrene_sieger_koder.jpg",
          "aboutImage" => "Sieger Koder",
          "reflections" => """
            In Simon of Cyrene, we have the proto-type of a faithful disciple who takes up the Cross
            and follows Christ. He is not unlike millions of Christians from a humble background,
            with deep attachment to Christ. No glamour, no sophistication, but profound faith. Such
            believers keep rising on the soil of Africa, Asia and the distant islands. Vocations arise from
            their midst. Simon reminds us of small communities and tribes with their characteristic
            commitment to the common good, deep rootedness in ethical values and openness to the
            Gospel. They deserve attention and care. The Lord does not desire that "one of these little
            ones should perish". In Simon we discover the sacredness of the ordinary and the greatness
            of what looks small. For the smallest has some mystic relationship with the greatest, and
            the ordinary with the most extraordinary!
          """,
          "prayer" => """
            Lord, it is your wonderful plan to lift up the lowly and sustain the poor. Strengthen your
            Church in her service to deprived communities: the least privileged, the marginalized, slum
            dwellers, the rural poor, the undernourished, untouchables, the handicapped, people given
            to addictions. May the example of your servant, Mother Teresa of Kolkata, inspire us to
            dedicate more of our energies and resources to the cause of the "poorest of the poor". May
            we one day hear these words from Jesus: "I was hungry and you gave me food, I was thirsty
            and you gave me drink; I was a stranger and you welcomed me; I was naked and you clothed
            me; I was sick and you visited me, I was in prison and you came to me."
          """
        },
      "9" =>
        %{
          "id" => "9",
          "before" => [
            "Minister:",
            "We adore you, O Christ, and we bless you.",
            "All:", 
            "Because of your holy cross you have redeemed the world."

          ],
          "after" => [
            "All",
            "Lord Jesus, help us walk in your steps."
          ],
          "title" => "Jesus meets the women of Jerusalem",
          "reading" => "Luke 23:27-31",
          "images" => "chr_maria_m_grt.jpg",
          "aboutImage" => "Peter Paul Rubens - 1618",
          "reflections" => """
            Before the weeping women, Jesus is self-forgetful. His anxiety is not about his pains, but
            about the tragic future that awaits them and their children. The destinies of societies
            are intimately linked to the wellbeing of their women. Wherever women are held in low
            esteem or their role remains diminished, societies fail to rise to their true potentiality. In
            the same way, wherever their responsibility to the rising generation is neglected, ignored,
            or marginalized, the future of that society becomes uncertain. There are many societies in
            the world where women fail to receive a fair deal. Christ must be weeping for them. There
            are societies too that are thoughtless about their future. Christ must be weeping for their
            children. Wherever there is unconcern for the future, through the overuse of resources, the
            degradation of the environment, the oppression of women, the neglect of family values, the
            ignoring of ethical norms, the abandonment of religious traditions, Jesus must be telling
            people: "Do not weep for me, but weep for yourselves and for your children."
          """,
          "prayer" => """
            Lord, you are the Master of history. And yet you wanted our collaboration in realizing
            your plans. Help us to play a responsible role in society: leaders in their communities,
            parents in their families, educators and health-workers among those who need to be served,
            communicators in the world of information. Arouse in us a sense of mission in what we do,
            a deep sense of responsibility to each other, to society, to our common future and to you.
            For you have placed the destinies of our communities and of humanity itself into our hands.
            Lord, do not turn away from us when you see women humiliated or your image disfigured
            in the human person; when we interfere with life-systems, weaken the nurturing power of
            nature, pollute running streams or the deep blue seas or the Northern snows. Save us from
            cruel indifference to our common future, and do not let us drag our civilization down the
            path of decline.
          """
        },
      "10" =>
        %{
          "id" => "10",
          "before" => [
            "Minister:",
            "We adore you, O Christ, and we bless you.",
            "All:", 
            "Because of your holy cross you have redeemed the world."

          ],
          "after" => [
            "All",
            "Lord Jesus, help us walk in your steps."
          ],
          "title" => "Jesus is crucified",
          "reading" => "Luke 23:33-34",
          "images" => "durer_zevensmarten_kruisnageling_grt.jpg",
          "aboutImage" => "Albrecht Durer - 1495 - 1496",
          "reflections" => """
            The sufferings of Jesus reach a climax. He had stood fearlessly before Pilate. He had
            endured the mistreatment of the Roman soldiers. He had preserved his calm under the
            scourge and the crowning with thorns. On the Cross itself, he seemed untouched by a
            shower of insults. He had no word of complaint, no desire to retort. But then, finally, a
            moment comes when he breaks down. His strength can stand no more. He feels abandoned
            even by his Father! Experience tells us that even the sturdiest man can descend to the
            depths of despair. Frustrations accumulate, anger and resentment pile up. Bad health, bad
            news, bad luck, bad treatment - all can come together. It may have happened to us. It is
            at such moments we need to remember that Jesus never fails us. He cried to the Father.
            May we too cry out to the Father, who unfailingly comes to our rescue in all our distress,
            whenever we call upon him!
          """,
          "prayer" => """
            Lord, when clouds gather on the horizon and everything seems lost, when we find no friend
            to stand by us and hope slips from our hands, teach us to trust in you, who will surely come
            to our rescue. May the experience of inner pain and darkness teach us the great truth that
            in you nothing is lost, that even our sins - once we have repented of them - come to serve
            a purpose, like dry wood in the cold of winter. Lord, you have a master design beneath
            the working of the universe and the progress of history. Open our eyes to the rhythms
            and patterns in the movements of the stars; balance and proportion in the inner structure
            of elements; interrelatedness and complementarity in nature; progress and purpose in the
            march of history; correction and compensation in our personal stories. It is this harmony
            that you constantly keep restoring, despite the painful imbalances that we bring about. In
            you even the greatest loss is a gain. Christ's death, in fact, points to resurrection.
          """
        },
      "11" =>
        %{
          "id" => "11",
          "before" => [
            "Minister:",
            "We adore you, O Christ, and we bless you.",
            "All:", 
            "Because of your holy cross you have redeemed the world."

          ],
          "after" => [
            "All",
            "Lord Jesus, help us walk in your steps."
          ],
          "title" => "Jesus promises his kingdom to the good thief",
          "reading" => "Luke 23:39-43",
          "images" => "08thief_titian.jpg",
          "aboutImage" => "Tiziano Vecellio - c. 1566",
          "reflections" => """
            It is not eloquence that convinces and converts. In the case of Peter, it is a look of love; in
            the case of the Good Thief, it is unresentful serenity in suffering. Conversion takes place
            like a miracle. God opens your eyes. You recognize his presence and action. You surrender!
            Opting for Christ is always a mystery. Why does one make a definitive choice for Christ,
            even in the face of trouble, or death? Why do Christians flourish in persecuted places? We
            shall never know. But it happens over and over again. If a person who has abandoned his
            faith comes across the real face of Christ, he will be stunned by what he actually sees, and
            may surrender like Thomas: "My Lord and my God!" It is a privilege to unveil the face of
            Christ to people. It is even a greater joy to discover - or rediscover - him. "Your face, O
            Lord, do I seek. Do not hide your face from me."
          """,
          "prayer" => """
              My cry to you today, O Lord, in tears is this: "Jesus, remember me when you come into
              your Kingdom." It is for this Kingdom that I fondly long. It is the eternal home you have
              prepared for all those who seek you with sincere hearts. "No eye has seen, no ear has heard,
              no mind has conceived what God has prepared for those who love him". Help me, Lord,
              as I struggle ahead on my way to my eternal destiny. Lift the darkness from my path, and
              keep my eyes raised to the heights! 

              "Lead, kindly Light,
              amid the encircling gloom. 
              Lead thou me on. 
              The night is dark, and I am far from home. 
              Lead thou me on. 
              Keep thou my feet; I do not ask to see 
              The distant scene; one step enough for me." 
          """
        },
      "12" =>
        %{
          "id" => "12",
          "before" => [
            "Minister:",
            "We adore you, O Christ, and we bless you.",
            "All:", 
            "Because of your holy cross you have redeemed the world."

          ],
          "after" => [
            "All",
            "Lord Jesus, help us walk in your steps."
          ],
          "title" => "Jesus speaks to his mother and the beloved disciple",
          "reading" => "John 19:25-27",
          "images" => "baegert_calvarie_grt.jpg",
          "aboutImage" => "Derick Baegert - c. 1475",
          "reflections" => """
            In suffering we long for solidarity. Mother Mary reminds us of supportive love and solidarity
            within a family, John of loyalty within a community. Family cohesion, community bonds,
            ties of friendship { these are essential for the flourishing of human beings. In an anonymous
            society they grow weak. When they are missing, we become diminished persons. Again,
            in Mary we do not notice even the least sign of resentment; not a word of bitterness. The
            Virgin becomes an archetype of forgiveness in faith and hope. She shows us the way to the
            future. Even those who would like to respond to violent injustice with "violent justice" know
            that that is not the ultimate answer. Forgiveness prompts hope. There are also historic
            injuries that often rankle in the memories of societies for centuries. Unless we transmute our
            collective anger into new energies of love through forgiveness, we perish together . When
            healing comes through forgiveness, we light a lamp, announcing future possibilities for the
            "life and well-being" of humanity.
          """,
          "prayer" => """
            Lord Jesus, your Mother stood silently at your side in your final agony. She who was
            unseen on occasions when you were acclaimed a great prophet, stands beside you in your
            humiliation. May I have the courage to remain loyal even where you are least recognized.
            Let me never be embarrassed to belong to the "little flock". Lord, let me remember that
            even those whom I consider my "enemies" belong to the human family. If they treat me
            unfairly, let my prayer be only: "Father, forgive them; for they know not what they do." It
            may be in such a context that someone will suddenly recognize the true face of Christ and
            cry out like the centurion: "Truly this man was the Son of God!"
          """
        },
      "13" =>
        %{
          "id" => "13",
          "before" => [
            "Minister:",
            "We adore you, O Christ, and we bless you.",
            "All:", 
            "Because of your holy cross you have redeemed the world."

          ],
          "after" => [
            "All",
            "Lord Jesus, help us walk in your steps."
          ],
          "title" => "Jesus dies on the cross",
          "reading" => "Luke 23:44-46",
          "images" => "article-0-1A1F1D21000005DC-463_470x620.jpg",
          "aboutImage" => "", 
          "reflections" => """
            Jesus hands over his spirit to the Father in serene abandonment. What his persecutors
            thought to be a moment of defeat proves, in fact, to be a moment of triumph. When a
            prophet dies for the cause he stood for, he gives the final proof of all that he has said. Christ's
            death is something more than that. It brings redemption. "In him we have redemption
            through his blood, the forgiveness of our trespasses." With that begins for me a mystic
            journey: Christ draws me closer to him, until I shall fully belong to him. 

            "As a deer longs for flowing streams, 
            So my soul longs for you, O God. . . 
            When shall I come and behold the face of God?" 
          """,
          "prayer" => """
            Lord Jesus, it is for my own sins that you were nailed to the Cross. Help me to gain a
            deeper understanding of the grievousness of my sins and the immensity of your love. For
            "while we were still weak, Christ died for the ungodly." I admit my faults as the prophets
            did long ago: "We have sinned and done wrong and acted wickedly
            and rebelled, turning aside from your commandments and ordinances;
            we have not listened to your servants the prophets. . . ." There was nothing in me to deserve
            your kindness. Thank you for your immeasurable goodness to me. Help me to live for you,
            to shape my life after you, to be joined to you and become a new creation. 

            "Christ be with me, Christ within me, 
            Christ behind me, Christ before me, 
            Christ beside me, Christ to win me, 
            Christ to comfort and restore me." 
          """
        },
      "14" =>
        %{
          "id" => "14",
          "before" => [
            "Minister:",
            "We adore you, O Christ, and we bless you.",
            "All:", 
            "Because of your holy cross you have redeemed the world."

          ],
          "after" => [
            "All",
            "Lord Jesus, help us walk in your steps."
          ],
          "title" => "Jesus is placed in the tomb",
          "reading" => "Matthew 27:57-60",
          "images" => "grafleg_rafael_grt.jpg",
          "aboutImage" => "Raphael - 1507",
          "reflections" => """
            Tragedies make us ponder. A tsunami tells us that life is serious. Hiroshima and Nagasaki
            remain pilgrim places. When death strikes near, another world draws close. We then shed
            our illusions and have a grasp of the deeper reality. People in ancient India prayed: "Lead
            me from the unreal to the real, from darkness to light, from death to immortality." After
            Jesus left this world, Christians began to look back and interpret his life and mission. They
            carried his message to the ends of the earth. And this message itself is Jesus Christ, who
            is "the power of God and the wisdom of God". It says that the reality is Christ and that
            our ultimate destiny is to be with him.
          """,
          "prayer" => """
            Lord Jesus, enable us, as we press forward on life's weary way, to have a glimpse of our
            ultimate destiny. And when at last we cross over, we will know that "death will be no more;
            mourning and crying and pain will be no more." God will wipe away all tears from our
            eyes. It is this Good News that we are eager to announce "in every way", even in places
            where Christ has not been heard of. For this we work hard. We work "night and day" and
            wear ourselves out. Lord make us effective carriers of your Good News. "I know that my
            Redeemer lives, and at last he will stand upon the earth; and in my flesh I shall see God."
          """
        }
    }
  end
end
